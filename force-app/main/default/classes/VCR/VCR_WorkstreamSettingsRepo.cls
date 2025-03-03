/**
 * @description MDT repository class to provide query access to the VCC_Workstream_Settings__mdt object and related child MDT objects
 * - In 1.19.0, child MDT objects include:
 *   - VCC_Workstream_Sort_Config__mdt
 * @author Booz Allen Hamilton
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public inherited sharing class VCR_WorkstreamSettingsRepo extends VTC_BaseCustomMetadataRepo {
    /**
     * @description The following static final Strings are the known HDR data types, as currently spelled out across the VAHC code base, (particularly in LWCs)
     */
    public static final String DATATYPE_ALLERGIES = 'allergies';
    public static final String DATATYPE_APPOINTMENTS = 'appointments';
    public static final String DATATYPE_CONSULTS = 'consults';
    public static final String DATATYPE_DIRECTIVES = 'directives';
    public static final String DATATYPE_DISCHARGESUMMARY = 'dischargeSummary';
    public static final String DATATYPE_EHR_PROGRESS_NOTES = 'ehr_progress_notes';
    public static final String DATATYPE_EMAIL = 'email';
    public static final String DATATYPE_IMMUNIZATIONS = 'immunizations';
    public static final String DATATYPE_LABS = 'labs';
    public static final String DATATYPE_MEDICATIONS = 'meds';
    public static final String DATATYPE_ORDERS = 'orders';
    public static final String DATATYPE_PROBLEMS = 'problems';
    public static final String DATATYPE_IMAGING = 'radiology';
    public static final String DATATYPE_VISITS = 'visits';
    public static final String DATATYPE_VITALS = 'vitals';

    /**
     * @description This maps known 'dataType' values from elsewhere in the code base to values in the VCC_Workstream_Sort_Config__mdt.VCC_HDR_Data_Type__c picklist
     * - Any future child MDT tables (for configuring other workstream behaviors), would ideally also use a picklist whose values match the VCC_Workstream_Sort_Config__mdt.VCC_HDR_Data_Type__c field
     */
    public static final Map<String, String> dataTypePicklistValueMap {
        get {
            if (dataTypePicklistValueMap == null) {
                dataTypePicklistValueMap = new Map<String, String>{
                    DATATYPE_ALLERGIES => 'Allergies',
                    DATATYPE_APPOINTMENTS => 'Appointments',
                    DATATYPE_CONSULTS => 'Consults',
                    DATATYPE_DIRECTIVES => 'Directives',
                    DATATYPE_DISCHARGESUMMARY => 'Discharge Summary',
                    DATATYPE_EHR_PROGRESS_NOTES => 'EHR Progress Note',
                    DATATYPE_EMAIL => 'Email',
                    DATATYPE_IMAGING => 'Imaging',
                    DATATYPE_IMMUNIZATIONS => 'Immunizations',
                    DATATYPE_LABS => 'Labs',
                    DATATYPE_MEDICATIONS => 'Medications',
                    DATATYPE_ORDERS => 'Orders',
                    DATATYPE_PROBLEMS => 'Problems',
                    DATATYPE_VISITS => 'Visits',
                    DATATYPE_VITALS => 'Vitals'
                };
            }
            return dataTypePicklistValueMap;
        }
        set;
    }

    /**
     * @description Informs logic of dataTypeSettingFieldMap, as it is used in VCC_WorkstreamSettingsController.pickDurationValue() and VCC_WorkstreamSettingsController.pickMaxValue()
     */
    public enum SettingFieldType {
        DURATION,
        MAX
    }

    /**
     * @description Provides instruction set for the VCC_WorkstreamSettingsController.pickField() method
     * - Used when reading a VCC_Workstream_Settings__mdt record's fields for a given setting type (e.g. DURATION, MAX) and dataType (e.g. 'allergies', 'consults')
     */
    public static Map<SettingFieldType, Map<String, SObjectField>> dataTypeSettingFieldMap {
        get {
            if (dataTypeSettingFieldMap == null) {
                dataTypeSettingFieldMap = new Map<SettingFieldType, Map<String, SObjectField>>{
                    SettingFieldType.DURATION => new Map<String, SObjectField>{
                        DATATYPE_ALLERGIES => VCC_Workstream_Settings__mdt.VCC_Allergies_Adverse_Reactions_Duration__c,
                        DATATYPE_APPOINTMENTS => VCC_Workstream_Settings__mdt.VCC_Appointments_Duration__c,
                        DATATYPE_CONSULTS => VCC_Workstream_Settings__mdt.VCC_Consults_Duration__c,
                        DATATYPE_DIRECTIVES => VCC_Workstream_Settings__mdt.VCC_Directives_Duration__c,
                        DATATYPE_DISCHARGESUMMARY => VCC_Workstream_Settings__mdt.VCC_Discharge_Summary_Duration__c,
                        DATATYPE_EHR_PROGRESS_NOTES => VCC_Workstream_Settings__mdt.VCC_EHR_Progress_Notes_Duration__c,
                        DATATYPE_IMMUNIZATIONS => VCC_Workstream_Settings__mdt.VCC_Immunizations_Duration__c,
                        DATATYPE_LABS => VCC_Workstream_Settings__mdt.VCC_Labs_Duration__c,
                        DATATYPE_MEDICATIONS => VCC_Workstream_Settings__mdt.VCC_Meds_Duration__c,
                        DATATYPE_ORDERS => VCC_Workstream_Settings__mdt.VCC_Orders_Duration__c,
                        DATATYPE_PROBLEMS => VCC_Workstream_Settings__mdt.VCC_Problems_Duration__c,
                        DATATYPE_IMAGING => VCC_Workstream_Settings__mdt.VCC_Imaging_Duration__c,
                        DATATYPE_VISITS => VCC_Workstream_Settings__mdt.VCC_Visits_Duration__c,
                        DATATYPE_VITALS => VCC_Workstream_Settings__mdt.VCC_Vitals_Duration__c
                    },
                    SettingFieldType.MAX => new Map<String, SObjectField>{
                        DATATYPE_CONSULTS => VCC_Workstream_Settings__mdt.VCC_Consults_Max__c,
                        DATATYPE_DIRECTIVES => VCC_Workstream_Settings__mdt.VCC_Directives_Max__c,
                        DATATYPE_DISCHARGESUMMARY => VCC_Workstream_Settings__mdt.VCC_Discharge_Summary_Max__c,
                        DATATYPE_EHR_PROGRESS_NOTES => VCC_Workstream_Settings__mdt.VCC_EHR_Progress_Notes_Max__c,
                        DATATYPE_LABS => VCC_Workstream_Settings__mdt.VCC_Labs_Max__c,
                        DATATYPE_ORDERS => VCC_Workstream_Settings__mdt.VCC_Orders_Max__c,
                        DATATYPE_PROBLEMS => VCC_Workstream_Settings__mdt.VCC_Problems_Max__c,
                        DATATYPE_IMAGING => VCC_Workstream_Settings__mdt.VCC_Imaging_Max__c,
                        DATATYPE_VISITS => VCC_Workstream_Settings__mdt.VCC_Visits_Max__c,
                        DATATYPE_VITALS => VCC_Workstream_Settings__mdt.VCC_Vitals_Max__c
                    }
                };
            }
            return dataTypeSettingFieldMap;
        }
        set;
    }

    /**
     * @description Default no-arg constructor
     * - Initializes class with default object of VCC_Workstream_Settings__mdt and a large list of default SELECT fields
     */
    public VCR_WorkstreamSettingsRepo() {
        super(VCC_Workstream_Settings__mdt.SObjectType);
        this.defaultSelectFields.addAll(
            new List<String>{
                'DeveloperName',
                'Medication_Retrieval_Length_days__c',
                'VCC_Allergies_Adverse_Reactions_Duration__c',
                'VCC_Appointments_Duration__c',
                'VCC_Consults_Duration__c',
                'VCC_Consults_Max__c',
                'VCC_Directives_Duration__c',
                'VCC_Directives_Max__c',
                'VCC_Discharge_Summary_Duration__c',
                'VCC_Discharge_Summary_Max__c',
                'VCC_EHR_Progress_Notes_Duration__c',
                'VCC_EHR_Progress_Notes_Max__c',
                'VCC_Imaging_Duration__c',
                'VCC_Imaging_Max__c',
                'VCC_Immunizations_Duration__c',
                'VCC_Labs_Duration__c',
                'VCC_Labs_Max__c',
                'VCC_Meds_Duration__c',
                'VCC_Orders_Duration__c',
                'VCC_Orders_Max__c',
                'VCC_Problems_Duration__c',
                'VCC_Problems_Max__c',
                'VCC_Visits_Duration__c',
                'VCC_Visits_Max__c',
                'VCC_Vitals_Duration__c',
                'VCC_Vitals_Max__c',
                'Workstream__c'
            }
        );
    }

    /**
     * @description Uses VCC_Workstream_Settings__mdt.getInstance() method to retrieve a VCC_Workstream_Settings__mdt record by its DeveloperName
     * @param workstreamSettingsType `VCC_Enum.VCC_WorkstreamSettingsTypeEnum` a workstream enum value
     * - values of this enum correspond to VCC_Workstream_Settings__mdt records' DeveloperName values
     * - falls back to 'Default' string if null
     *
     * @return `VCC_Workstream_Settings__mdt` a record with all its fields
     */
    public VCC_Workstream_Settings__mdt fetchWorkstreamSetting(
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum workstreamSettingsType
    ) {
        return VCC_Workstream_Settings__mdt.getInstance(workstreamSettingsType?.name() ?? 'Default');
    }

    /**
     * @description Returns a VCC_Workstream_Settings__mdt record and all related child MDT records
     * - This is an an overload for `fetchWithChildren(VCC_Enum.VCC_WorkstreamSettingsTypeEnum, String)`
     * - As of 1.19.0, "child MDT records" includes VCC_Workstream_Setting_Sort_Configs__mdt
     * @param workstreamSettingsType `VCC_Enum.VCC_WorkstreamSettingsTypeEnum` a workstream enum value
     * - values of this enum correspond to VCC_Workstream_Settings__mdt records' DeveloperName values
     * - falls back to 'Default' string if null
     *
     * @return `VCC_Workstream_Settings__mdt` a record, with related lists of child MDT records
     */
    public VCC_Workstream_Settings__mdt fetchWithChildren(
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum workstreamSettingsType
    ) {
        return this.fetchWithChildren(workstreamSettingsType, null);
    }

    /**
     * @description Returns a VCC_Workstream_Settings__mdt record and all related child MDT records with the given hdrDataType value.
     * - As of 1.19.0, "child MDT records" includes VCC_Workstream_Setting_Sort_Configs__mdt
     * @param workstreamSettingsType `VCC_Enum.VCC_WorkstreamSettingsTypeEnum` a workstream enum value
     * - values of this enum correspond to VCC_Workstream_Settings__mdt records' DeveloperName values
     * - falls back to 'Default' string if null
     * @param hdrDataType `String` an HDR data type (e.g. 'allergies', 'consults')
     *
     * @return `VCC_Workstream_Settings__mdt` a record, with list(s) of child MDT records
     */
    public VCC_Workstream_Settings__mdt fetchWithChildren(
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum workstreamSettingsType,
        String hdrDataType
    ) {
        Map<Id, VCC_Workstream_Settings__mdt> allSettingsByIds = new Map<Id, VCC_Workstream_Settings__mdt>(
            new VCR_WorkstreamSettingsRepo().getAllWorkstreamSettingsWithFilteredChildren(hdrDataType)
        );
        return allSettingsByIds.get(this.fetchWorkstreamSetting(workstreamSettingsType)?.Id);
    }

    /**
     * @description Builds a query to fetch <strong>ALL</strong> VCC_Workstream_Settings__mdt records, with related MDT records.
     * - The result of this method is intended to be cached by `VCR_WorkstreamRepo.WorkstreamSettingsCache` class.
     * - (note that Platform Cache usage has been delayed until getting required DTC approval.)
     * - The main query against VCC_Workstream_Settings__mdt is NOT filtered.
     * - Related MDT records are filtered against the given hdrDataType value.
     * @param hdrDataType `String` an HDR data type (e.g. 'allergies', 'consults')
     *
     * @return `List<VCC_Workstream_Settings__mdt>` a list containing ALL existing VCC_Workstream_Settings__mdt records.
     * - Each record may have related lists of child MDT records, which have been filtered against the given hdrDataType value.
     */
    @TestVisible
    private List<VCC_Workstream_Settings__mdt> getAllWorkstreamSettingsWithFilteredChildren(String hdrDataType) {
        Set<String> childrenSubQueries = new Set<String>();
        //this list is the point at which, in the future, we add in additional sub queries.
        //for 1.19.0, only a Sort Config sub query is present.
        for (String childSubQuery : new List<String>{ buildSortConfigSubQuery(hdrDataType) }) {
            if (String.isNotBlank(childSubQuery)) {
                childrenSubQueries.add(childSubQuery);
            }
        }
        Set<String> fields = new Set<String>();
        fields.addAll(this.defaultSelectFields);
        fields.addAll(childrenSubQueries);
        String selectClause = this.calculateSelectClause(fields);
        String fromClause = this.calculateFromClause();
        String query = selectClause + ' ' + fromClause;
        return this.fetch(query);
    }

    /**
     * @description Builds a sub-query against the VCC_Workstream_Setting_Sort_Config__mdt object, for use in a query against the VCC_Workstream_Settings__mdt table.
     * @param hdrDataType `String` an HDR data type (e.g. 'allergies', 'consults')
     *
     * @return `String` the built query. If hdrDataType is not null, will include a WHERE clause against the VCC_HDR_Data_Type__c field
     */
    @TestVisible
    private static String buildSortConfigSubQuery(String hdrDataType) {
        List<String> subQueryMembers = new List<String>{
            '(SELECT DeveloperName, VCC_HDR_Data_Type__c, VCC_Sort_By__c, VCC_Sort_Direction__c FROM VCC_Workstream_Setting_Sort_Configs__r'
        };
        if (String.isNotBlank(hdrDataType)) {
            //add a VCC_HDR_Data_Type__c condition
            //hdrDataType is synonymous with 'dataType' parameter used in some classes and LWCs... e.g. 'allergies', 'consults', etc.
            //but there are some minor spelling/punctuation differences between the code base and the VCC_HDR_Data_Type__c picklist
            //use dataTypePicklistValueMap to try to translate to a known VCC_HDR_Data_Type__c picklist value; fallback to given value
            subQueryMembers.add(
                'WHERE VCC_HDR_Data_Type__c = \'' + (dataTypePicklistValueMap.get(hdrDataType) ?? hdrDataType) + '\''
            );
        }
        subQueryMembers.add(')');
        return String.join(subQueryMembers, ' ');
    }
}
