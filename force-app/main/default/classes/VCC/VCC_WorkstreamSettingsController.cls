/**
 * @description WorkstreamSettingsController retrieves workstream settings and based on dataType populates start date, end date, and duration in months values and stores in the VCC_Model Object.
 *
 * note this class suppresses the excessive parameter rule, we need a constructor with a max attribute, that brings the total to 5 params for now, in the future we should consider implementing a builder or some void methods that can set an instance of VCC_WorkstreamSettings controller
 */
public with sharing class VCC_WorkstreamSettingsController {
    @Testvisible
    private static final String DATE_FORMAT = 'M/d/yyyy';
    /**
     * @description Default value for duration, when no valid field or value is found by pickDurationValue() method
     */
    @TestVisible
    private static final Integer FALLBACK_DURATION = 12;

    /**
     * @description Default value for max, when no valid field or value is found by pickMaxValue() method
     * - Fallback to null value because not all data types HAVE a field for max value (e.g. allergies, appointments, immunizations, meds)
     * - In the future, we could change this fallback value.
     */
    @TestVisible
    private static final Integer FALLBACK_MAX = null;

    /**
     * @description Empty constructor
     */
    public VCC_WorkstreamSettingsController() {
        return;
    }

    /**
     * @description A memoized instance of VCR_WorkstreamSettingsRepo
     */
    @TestVisible
    private static VCR_WorkstreamSettingsRepo workstreamSettingsRepo {
        get {
            if (workstreamSettingsRepo == null) {
                workstreamSettingsRepo = new VCR_WorkstreamSettingsRepo();
            }
            return workstreamSettingsRepo;
        }
        set;
    }

    /**
     * @description A memoized result from the VCC_WorkstreamSettingsController.determineWorkstreamSettingType() method
     */
    @TestVisible
    private static VCC_Enum.VCC_WorkstreamSettingsTypeEnum workstreamSettingsType {
        get {
            if (workstreamSettingsType == null) {
                workstreamSettingsType = determineWorkstreamSettingType();
            }
            return workstreamSettingsType;
        }
        set;
    }

    /**
     * @description A memoized instance of VCC_Workstream_Settings__mdt having DeveloperName 'Default', plus any child config data in other MDT tables
     * - Used as fallback for reading config values in the absence of a known workstream/persona
     */
    @TestVisible
    private static VCC_Workstream_Settings__mdt defaultSettings {
        get {
            if (defaultSettings == null) {
                defaultSettings = workstreamSettingsRepo.fetchWithChildren(null);
            }
            return defaultSettings;
        }
        set;
    }

    /**
     * @description Determines a VCC_Enum.VCC_WorkstreamSettingsTypeEnum value from <strong>current user's</strong> PermissionSetGroup assignments
     * - as of 1.19.0, leverages platform cache
     * - Platform Cache usage has been delayed until getting required DTC approval.
     * @return `VCC_Enum.VCC_WorkstreamSettingsTypeEnum` an enum value that directly corresponds to the DeveloperName of a single VCC_Workstream_Settings__mdt record
     */
    public static VCC_Enum.VCC_WorkstreamSettingsTypeEnum determineWorkstreamSettingType() {
        return determineWorkstreamSettingTypeForUserId(UserInfo.getUserId());
    }

    /**
     * @description Determines a VCC_Enum.VCC_WorkstreamSettingsTypeEnum value from PermissionSetGroup assignments for given User Id
     * @param userId `Id` of a User record
     *
     * @return `VCC_Enum.VCC_WorkstreamSettingsTypeEnum` an enum value that directly corresponds to the DeveloperName of a single VCC_Workstream_Settings__mdt record
     */
    @TestVisible
    private static VCC_Enum.VCC_WorkstreamSettingsTypeEnum determineWorkstreamSettingTypeForUserId(Id userId) {
        if (userId == null) {
            return null;
        }
        for (PermissionSetGroup permissionSetGroup : VCC_SecurityService.getPermissionSetGroupsForUser(userId)) {
            if (permissionSetGroup.DeveloperName.contains('Pharmacy')) {
                return VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy;
            }
            if (
                permissionSetGroup.DeveloperName.contains('MSA') ||
                permissionSetGroup.DeveloperName.contains('Medical_Provider')
            ) {
                return VCC_Enum.VCC_WorkstreamSettingsTypeEnum.MSA;
            }
            if (permissionSetGroup.DeveloperName.contains('Nurse')) {
                return VCC_Enum.VCC_WorkstreamSettingsTypeEnum.RN;
            }
            if (permissionSetGroup.DeveloperName.contains('VCV')) {
                return VCC_Enum.VCC_WorkstreamSettingsTypeEnum.VCV;
            }
        }
        return null;
    }

    /**
     * @description Retrieves workstream settings for given HDR data type
     * - Uses workstream settings appropriate to current user, based on their PermissionSetGroup assignments
     * - This method may be called by other Apex classes, but it just calls the AuraEnabled `getSettings()` method
     * @see getSettings
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     * @return `VCC_Model` Object with data points for HDR queries and display behavior (e.g. startDate, endDate, sort configuration, etc)
     */
    public VCC_Model getSettingsInMemory(String dataType) {
        return getSettings(dataType);
    }

    /**
     * @description Retrieves workstream settings for given HDR data type
     * - Uses workstream settings appropriate to current user, based on their PermissionSetGroup assignments
     * - cacheable by lightning components
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     * @return `VCC_Model` Object with data points for HDR queries and display behavior (e.g. startDate, endDate, sort configuration, etc)
     */
    @AuraEnabled(Cacheable=true)
    public static VCC_Model getSettings(String dataType) {
        VCC_Workstream_Settings__mdt workstreamSettings = getWorkstreamSettings(dataType);

        Integer durationInMonths = pickDurationValue(workstreamSettings, dataType);
        Integer max = pickMaxValue(workstreamSettings, dataType);
        Datetime startDate = Datetime.now().addMonths(-durationInMonths);
        Datetime endDate = Datetime.now();
        VCC_Workstream_Setting_Sort_Config__mdt sortConfig = workstreamSettings.VCC_Workstream_Setting_Sort_Configs__r
                ?.size() > 0
            ? workstreamSettings.VCC_Workstream_Setting_Sort_Configs__r.get(0)
            : null;

        return new VCC_Model(
            dataType,
            startDate,
            endDate,
            durationInMonths,
            max,
            sortConfig?.VCC_Sort_By__c,
            sortconfig?.VCC_Sort_Direction__c
        );
    }

    /**
     * @description Reads appropriate '..._Duration__c' field from the given VCC_Workstream_Settings__mdt record, given a dataType
     * @param setting `VCC_Workstream_Settings__mdt` a VCC_Workstream_Settings__mdt record
     * - Uses memoized defaultSettings, if null
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     * - This value is used to pick the correct '..._Duration__c' field, according to the VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap
     *
     * @return `Integer` a '..._Duration__c' field value from the given VCC_Workstream_Settings__mdt record, or the FALLBACK_DURATION value
     */
    @TestVisible
    private static Integer pickDurationValue(VCC_Workstream_Settings__mdt setting, String dataType) {
        SObjectField durationField = pickField(VCR_WorkstreamSettingsRepo.SettingFieldType.DURATION, dataType);
        Decimal fieldValue = durationField != null ? (Decimal) ((setting ?? defaultSettings).get(durationField)) : null;
        return fieldValue?.intValue() ?? FALLBACK_DURATION;
    }

    /**
     * @description Reads appropriate '..._Max__c' field from the given VCC_Workstream_Settings__mdt record, given a dataType
     * @param setting `VCC_Workstream_Settings__mdt` a VCC_Workstream_Settings__mdt record
     * - Uses memoized defaultSettings, if null
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     * - This value is used to pick the correct '..._Max__c' field, according to the VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap
     *
     * @return `Integer` a '..._Max__c' field value from the given VCC_Workstream_Settings__mdt record, or the FALLBACK_MAX value
     */
    @TestVisible
    private static Integer pickMaxValue(VCC_Workstream_Settings__mdt setting, String dataType) {
        SObjectField maxField = pickField(VCR_WorkstreamSettingsRepo.SettingFieldType.MAX, dataType);
        Decimal fieldValue = maxField != null ? (Decimal) ((setting ?? defaultSettings).get(maxField)) : null;
        return fieldValue?.intValue() ?? FALLBACK_MAX;
    }

    /**
     * @description Uses VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap to pick an appropriate field from which to read a value
     * @param fieldType `VCR_WorkstreamSettingsRepo.SettingFieldType` DURATION or MAX; informs if this method will seek a '..._Duration__c' or '..._Max__c' field
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     *
     * @return `SObjectField` a field on the VCC_Workstream_Settings__mdt object, picked based on DURATION or MAX, plus hdr data type
     */
    private static SObjectField pickField(VCR_WorkstreamSettingsRepo.SettingFieldType fieldType, String dataType) {
        return VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap.get(fieldType)?.get(dataType);
    }

    /**
     * @description This no-arg method signature was left intact (but not AuraEnabled) for compatibility with existing classes that already referenced it
     * - This is an overload for getWorkstreamSettings(String dataType)
     *
     * @return `VCC_Workstream_Settings__mdt` a VCC_Workstream_Settings__mdt record appropriate for current user's workstream
     * @see getWorkstreamSettings getWorkstreamSettings(String dataType) signature
     */
    public static VCC_Workstream_Settings__mdt getWorkstreamSettings() {
        return getWorkstreamSettings(null);
    }

    /**
     * @description Uses VCR_WorkstreamSettingsRepo to fetch VCC_Workstream_Settings__mdt appropriate for current user's workstream
     * @see determineWorkstreamSettingType for logic to determine "current user's workstream"
     * @param dataType `String` an HDR data type (e.g. 'allergies', 'consults')
     * - If present, the retrieved VCC_Workstream_Settings__mdt will include related lists with child MDT records, filtered against the dataType value
     * - If not present, the retrieved record will not include any child MDT records.
     * @return `VCC_Workstream_Settings__mdt` a VCC_Workstream_Settings__mdt record appropriate for current user's workstream
     */
    @AuraEnabled(Cacheable=true)
    public static VCC_Workstream_Settings__mdt getWorkstreamSettings(String dataType) {
        return dataType != null
            ? workstreamSettingsRepo.fetchWithChildren(workstreamSettingsType, dataType)
            : workstreamSettingsRepo.fetchWorkstreamSetting(workstreamSettingsType);
    }

    /**
     * @description This inner class codifies the shape of data returned to callers by VCC_WorkstreamSettingsController.getSettings()
     */
    public class VCC_Model {
        /**
         * @description The type of the model, indicating the category of the VCC model.
         */
        @AuraEnabled
        public String type { get; set; }

        /**
         * @description The start date of the model's effective period, provided as a string in the "MM/dd/yyyy" format.
         */
        @AuraEnabled
        public String startDate { get; set; }

        /**
         * @description The end date of the model's effective period, provided as a string in the "MM/dd/yyyy" format.
         */
        @AuraEnabled
        public String endDate { get; set; }

        /**
         * @description The max records for the data type based on workstream.
         */
        @AuraEnabled
        public Integer max { get; set; }

        /**
         * @description The duration of the model's effective period in months.
         */
        @AuraEnabled
        public Integer durationInMonths { get; set; }

        /**
         * @description The field by which to initially sort the datatable that's using these settings
         */
        @AuraEnabled
        public String sortBy { get; set; }

        /**
         * @description The direction in which to initially sort the datatable that's using these settings
         */
        @AuraEnabled
        public String sortDirection { get; set; }

        /**
         * @description Initializes a new instance of the VCC_Model class with specified details.
         * - This constructor sets the model's type, start date, end date, and duration in months based on the provided arguments.
         * - The start date and end date are formatted as strings in the "MM/dd/yyyy" format for consistency and ease of use.
         *
         * @param type `String` The type of the model, indicating the category of the VCC model.
         * @param startDate `Datetime` The start date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param endDate `Datetime` The end date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param durationInMonths `Integer` The duration of the model's effective period in months, provided as an Integer.
         */
        public VCC_Model(String type, Datetime startDate, Datetime endDate, Integer durationInMonths) {
            this(type, startDate, endDate, durationInMonths, null);
        }

        /**
         * @description Initializes a new instance of the VCC_Model class with specified details.
         * - This constructor sets the model's type, start date, end date, and duration in months based on the provided arguments.
         * - The start date and end date are formatted as strings in the "MM/dd/yyyy" format for consistency and ease of use.
         *
         * @param type `String` The type of the model, indicating the category of the VCC model.
         * @param startDate `Datetime` The start date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param endDate `Datetime` The end date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param durationInMonths `Integer` The duration of the model's effective period in months, provided as an Integer.
         * @param max `Integer` The max records for the data type based on workstream.
         */
        public VCC_Model(String type, Datetime startDate, Datetime endDate, Integer durationInMonths, Integer max) {
            this(type, startDate, endDate, durationInMonths, max, null, null);
        }

        /**
         * @description Initializes a new instance of the VCC_Model class with specified details.
         * - This constructor sets the model's type, start date, end date, and duration in months based on the provided arguments.
         * - The start date and end date are formatted as strings in the "MM/dd/yyyy" format for consistency and ease of use.
         *
         * @param type `String` The type of the model, indicating the category of the VCC model.
         * @param startDate `Datetime` The start date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param endDate `Datetime` The end date of the model's effective period, provided as a Datetime object and formatted as a string.
         * @param durationInMonths `Integer` The duration of the model's effective period in months, provided as an Integer.
         * @param max `Integer` The max records for the data type based on workstream.
         * @param sortBy `String` The datatable field to sort by, on-load
         * @param sortDirection `String` The direction in which to sort the datatable, on-load
         */
        public VCC_Model(
            String type,
            Datetime startDate,
            Datetime endDate,
            Integer durationInMonths,
            Integer max,
            String sortBy,
            String sortDirection
        ) {
            this.type = type;
            this.startDate = startDate?.format(DATE_FORMAT);
            this.endDate = endDate?.format(DATE_FORMAT);
            this.durationInMonths = durationInMonths;
            this.max = max;
            this.sortBy = sortBy;
            this.sortDirection = sortDirection;
        }
    }
}
