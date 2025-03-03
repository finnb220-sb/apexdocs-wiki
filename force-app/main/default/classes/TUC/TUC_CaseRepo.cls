/**
 * @description - This class is responsible for encapsulating all CRUD operations
 * on the case object for the TUC module. It extends the VCR_CaseRepo class.
 *
 * @author Booz Allen Hamilton
 * @see VCR_CaseRepo
 * @see TUC_HomeChildKanbanController
 */
public inherited sharing class TUC_CaseRepo extends VCR_CaseRepo {
    /// Constants
    private static final String CONTROLLING_METADATA_DEVELOPER_NAME = 'Available_Cases_By_VISN';
    /// Configuration variables
    public KanbanMetadataConfig kanbanConfig;
    private static final String ORDER_BY_CLAUSE_FOR_NEW_AND_PATIENT_CALLBACK = ' ORDER BY RecordType.Name ASC, TUC_Wait_Time__c DESC NULLS LAST LIMIT :calculatedLimit ';
    private static final String ORDER_BY_CLAUSE_DEFAULT = ' ORDER BY LastModifiedDate ASC, TUC_Wait_Time__c DESC NULLS LAST LIMIT :calculatedLimit ';
    private static final String ORDER_BY_CLAUSE_CLOSED = ' ORDER BY LastModifiedDate DESC NULLS LAST LIMIT :calculatedLimit ';
    private static final String HIGH_ACUITY_TYPE_STRING = 'Tele_Urgent_Care_0_2_Hours';
    private static final String INTERMEDIATE_ACUITY_TYPE_STRING = 'Tele_Urgent_Care_2_8_Hours_Case';

    private static final String MAIN_DELIMITER = ';';
    private static final String SUB_DELIMITER = ',';
    private static final String MAPPING_DELIMITER = '-';
    private static final String TYPE_DELIMITER = ':';
    private static final String REFERENCE_STRING = 'REFERENCE';

    /**
     * @description - Constructor for TUC_CaseRepo. Calls super which sets this.sObjectType to 'Case'
     */
    public TUC_CaseRepo() {
        kanbanConfig = new KanbanMetadataConfig(fetchControllingMetadataRecord());
    }

    /**
     * @description - Advanced Constructor for TUC_CaseRepo. Calls super which sets this.sObjectType to 'Case'
     * @param kanbanConfigDevName - The DeveloperName of a config provided by the Aura Cmp.
     */
    public TUC_CaseRepo(String kanbanConfigDevName) {
        kanbanConfig = new KanbanMetadataConfig(fetchControllingMetadataRecord(kanbanConfigDevName));
    }

    /**
     * @description - Sets in the provided VISN data for the current transaction, then calls the strategy fetch method for further parsing
     * @param visnIds - A list of VISN IDs to query against so that associated cases will be included in the results.
     * @param strategy - The strategy to use for fetching cases.
     *
     * @return Map<String, List<Case>> - a map of lists, representing case data for each status of the Kanban board.
     */
    public Map<String, List<Case>> fetchListOfCasesForVisns(
        List<Decimal> visnIds,
        TUC_GetKanbanStrategyInterface strategy
    ) {
        /// Fail fast, fail safe.
        if (visnIds?.size() == 0) {
            return new Map<String, List<Case>>();
        }
        kanbanConfig.visnIds = visnIds;
        strategy.setConfig(kanbanConfig);
        return strategy.fetchCasesForKanbanForVisns(visnIds, this);
    }

    /**
     * @description - Sets in the provided VISN data, mostly used for test classes
     * @param visnIds - A list of VISN IDs to that cases must be associated with to be included in the results.
     */
    public void setConfigVisnIds(List<Decimal> visnIds) {
        if (visnIds?.size() != 0) {
            kanbanConfig.visnIds = visnIds;
        }
    }

    /**
     * @description - Calls the fetch method using the New/PatientCallBack orderBy and OpenCaseLimit
     * @param statusString - The status to query
     *
     * @return List<Case> - A list of cases that should be sorted by the tuc wait time field.
     */
    public List<Case> fetchCasesSortedByWaitTime(String statusString) {
        return this.fetchCasesByStatusWithClause(
            statusString,
            ORDER_BY_CLAUSE_FOR_NEW_AND_PATIENT_CALLBACK,
            kanbanConfig.openCaseLimit
        );
    }

    /**
     * @description - Calls the fetch method using the Default orderBy and OpenCaseLimit
     * @param statusString - The status to query
     *
     * @return List<Case> - A list of cases that should be sorted by the tuc wait time field.
     */
    public List<Case> fetchCasesByStatus(String statusString) {
        return this.fetchCasesByStatusWithClause(statusString, ORDER_BY_CLAUSE_DEFAULT, kanbanConfig.openCaseLimit);
    }

    /**
     * @description - Calls the fetch method using the Closed orderBy and ClosedCaseLimit
     * @param statusString - The status to query
     *
     * @return List<Case> - A list of cases that should be sorted by the tuc wait time field.
     */
    public List<Case> fetchClosedCases(String statusString) {
        return this.fetchCasesByStatusWithClause(statusString, ORDER_BY_CLAUSE_CLOSED, kanbanConfig.closedCaseLimit);
    }

    /**
     * @description - This method fetches the default Config.
     * @return TUC_Kanban_Config__mdt - the metadata record that controls the kanban board.
     */
    public TUC_Kanban_Config__mdt fetchKanbanConfigMetadata() {
        return kanbanConfig.internalKanbanConfig;
    }

    /**
     * @description - This method takes in an Id and some field information from the cmp, creates an SObject, and attempts to update it with doUpdate
     *                Contains some legacy code from previous versions but with repo powered update.
     * @param recordId - The Id of the object we want to update
     * @param recordField - The Api name of the field we want updated
     * @param recordVal - The desired new value of the field
     *
     * @return String - Reports if the update was successful or not. Successful results return 'true'.
     *                  In error scenarios the error message is returned.
     */
    public String updateRecord(String recordId, String recordField, String recordVal) {
        try {
            Case newCase = new Case();
            newCase.Id = recordId;
            newCase.put(recordField, recordVal);
            Database.SaveResult saveResult = this.doUpdate(newCase);
            if (saveResult.isSuccess()) {
                return 'true';
            } else {
                String errorMessage = saveResult.getErrors()[0].getMessage();
                Logger.error('TUC_CaseRepo update record error message: ' + errorMessage);
                Logger.saveLog();
                return errorMessage;
            }
        } catch (Exception wildException) {
            String errorMessage = wildException.getMessage();
            Logger.error(
                'Error updating TUC Case for record ' + recordId + ' field= ' + recordField + ', value = ' + recordVal,
                wildException
            );
            Logger.saveLog();
            return errorMessage;
        }
    }

    /**
     * @description - This method takes in an SObject from the cmp and attempts to delete it using doDelete
     * @param deleteTarget - The object to delete
     *
     * @return String - Reports if the update was successful or not. Successful results return 'true'.
     *                  In error scenarios the error message is returned.
     */
    public String deleteRecord(SObject deleteTarget) {
        try {
            Database.DeleteResult deleteResult = this.doDelete(deleteTarget);
            if (deleteResult.isSuccess()) {
                return 'true';
            } else {
                String errorMessage = deleteResult.getErrors()[0].getMessage();
                Logger.error('TUC_CaseRepo delete record deleteResultError message: ' + errorMessage);
                Logger.saveLog();
                return errorMessage;
            }
        } catch (Exception wildException) {
            String errorMessage = wildException.getMessage();
            Logger.error('Error deleting record deleteTarget= ' + deleteTarget, wildException);
            Logger.saveLog();
            return errorMessage;
        }
    }

    /// private methods

    /**
     * @description - Private method that actually facilitates the query building and fetch call
     * @param statusString - The status to query
     * @param orderByClause - The desired sort order of the query, provided from in-repo Final fields
     * @param calculatedLimit - The limit to apply to the query.
     *
     * @return List<Case> - A list of cases that are sorted by the provided orderByClause
     */
    private List<Case> fetchCasesByStatusWithClause(
        String statusString,
        String orderByClause,
        Integer calculatedLimit
    ) {
        /// Query construction
        String baseQuery = this.generateBaseQueryForKanbanBoard();
        String query = baseQuery + orderByClause;
        return this.fetch(
            query,
            getBindParamsForVISNQuery(kanbanConfig.visnIds, new List<String>{ statusString }, calculatedLimit)
        );
    }

    /**
     * @description - This method is responsible for generating the base query for the kanban board. This method has
     * been extracted to it's own method for de-duplication purposes.
     *
     * @return String - The base query for the kanban board.
     */
    private String generateBaseQueryForKanbanBoard() {
        String selectClause =
            'SELECT Id, Status, TUC_Wait_Time__c, ' +
            String.join(kanbanConfig.fieldsToDisplayOnCard, ', ').removeEnd(',') +
            ', Contact.Name, Owner.Name';
        String fromClause = ' ' + this.calculateFromClause(); // note that added space up front.
        String whereClause =
            ' WHERE Status In :activeStatuses ' +
            'AND (ClosedDate >= N_DAYS_AGO:2 OR Status != \'Closed\') ' +
            'AND RecordType.DeveloperName IN :recordTypeDeveloperNames ' +
            'AND TUC_Assigned_VISN__c IN :visnIds';
        return selectClause + fromClause + whereClause;
    }

    /**
     * @description - This method is responsible for constructing the Bind variables for the query.
     * @param visnIds - List<Decimal> of VISN Ids used to limit searching
     * @param statuses - List<String> of statuses to search for.
     * @param calculatedLimit - Integer of the limit to apply to the query.
     *
     * @return Map<String, Object> - A map of bind parameters for the query.
     */
    private static Map<String, Object> getBindParamsForVISNQuery(
        List<Decimal> visnIds,
        List<String> statuses,
        Integer calculatedLimit
    ) {
        return new Map<String, Object>{
            'visnIds' => visnIds,
            'activeStatuses' => statuses,
            'recordTypeDeveloperNames' => new List<String>{ HIGH_ACUITY_TYPE_STRING, INTERMEDIATE_ACUITY_TYPE_STRING },
            'calculatedLimit' => calculatedLimit
        };
    }

    /**
     * @description - Gets the default Kanban config metadata
     *
     * @return TUC_Kanban_Config__mdt - The metadata record that controls the kanban board.
     */
    private TUC_Kanban_Config__mdt fetchControllingMetadataRecord() {
        return this.fetchControllingMetadataRecord(CONTROLLING_METADATA_DEVELOPER_NAME);
    }

    /**
     * @description - This method is responsible for fetching the controlling metadata record.
     * @param metadataDevName - The Dev Name of a desired TUC_Kanban_Config__mdt
     *
     * @return TUC_Kanban_Config__mdt - The metadata record that controls the kanban board.
     */
    private TUC_Kanban_Config__mdt fetchControllingMetadataRecord(String metadataDevName) {
        TUC_KanbanConfigMdtRepo kanbanRepo = new TUC_KanbanConfigMdtRepo();
        return kanbanRepo.fetchControllingMetadataRecord(metadataDevName);
    }

    /**
     * @description - Sub-class for config setup relating to TUC_Kanban_Config_mdt
     */
    public class KanbanMetadataConfig {
        /// Configuration variables
        private final TUC_Kanban_Config__mdt internalKanbanConfig;

        /// VISN Ids are set outside the class
        /** @description - A list of VISNs the running user has access to based on Public Group Assignments **/
        public List<Decimal> visnIds = new List<Decimal>();

        /// These are extracted from the custom metadata record, but 'unpacked' here.
        /** @description - A list that represents the fields displayed on a Case card on the Kanban **/
        public final List<String> fieldsToDisplayOnCard;
        /** @description - The list of fields that are displayed by the popup on hovering over a card **/
        public final Map<String, String> fieldsToDisplayOnPopup;
        /** @description - The statuses we wish to make columns for and retrieve data for **/
        public final List<String> includedCaseStatuses;
        /** @description - The field that controls how columns are broken up and cases divided. Required. **/
        public final String groupByField;
        /** @description - The maximum query limit for cases in a non-closed status. Required. **/
        public final Integer openCaseLimit;
        /** @description - The maximum query limit for cases in the closed status. Required. **/
        public final Integer closedCaseLimit;
        /** @description - A list containing the Case Record Types we want to retrieve data for. Required. **/
        public final List<String> includedRecordTypeDeveloperNames;
        /** @description - A list representing the statuses we wish to sort by TUC_Wait_Time__c. Required. **/
        public final List<String> tucWaitTimeStatuses;
        /** @description - This map represents the Aura translation map needed to correctly map and display the case data retrieved **/
        public final Map<String, Map<String, String>> fieldTypeMap;

        /// Just in case the future state of the CMDT exposes additional fields. Also passed back to the front end for initialization
        /** @description - The raw Config metadata, should it be needed in whole form. **/
        public final TUC_Kanban_Config__mdt rawCMDT;

        /**
         * @description - Constructor for KanbanMetadataConfig. Sets up all the variables from TUC_Kanban_Config_mdt to respective final variables.
         * @param incomingConfig - The TUC_Kanban_Config_mdt record to use for configuration
         */
        public KanbanMetadataConfig(TUC_Kanban_Config__mdt incomingConfig) {
            this.internalKanbanConfig = incomingConfig;
            this.fieldsToDisplayOnCard = incomingConfig.Fields_To_Display_on_Card__c.split(MAIN_DELIMITER);
            this.includedCaseStatuses = incomingConfig.Values_To_Include_for_Group_By__c.split(MAIN_DELIMITER);
            this.groupByField = incomingConfig.Kanban_Group_By__c;
            this.openCaseLimit = Integer.valueOf(incomingConfig.SOQL_limit_for_open_statuses__c);
            this.closedCaseLimit = Integer.valueOf(incomingConfig.SOQL_limit_for_closed_statuses__c);
            this.includedRecordTypeDeveloperNames = incomingConfig.Included_Recordtype_Developer_names__c.split(
                MAIN_DELIMITER
            );
            this.tucWaitTimeStatuses = incomingConfig.Statuses_to_sort_by_TUC_wait_time__c.split(MAIN_DELIMITER);
            this.rawCMDT = incomingConfig;
            try {
                this.fieldsToDisplayOnPopup = setPopupFields(incomingConfig.Fields_To_Display_on_Popup__c);
                this.fieldTypeMap = setFieldMappingMap(incomingConfig.Field_Type_Map__c);
            } catch (Exception wildException) {
                Logger.error(
                    'TUC_CaseRepo metadata config constructor error fieldsString= ' +
                        incomingConfig.Fields_To_Display_on_Popup__c +
                        ' fieldMappingString= ' +
                        incomingConfig.Field_Type_Map__c,
                    wildException
                );
                Logger.saveLog();
            }
        }

        /**
         * @description - This method fills out the map of data that powers the Popup card on the front end.
         *                The data is parsed into a Label => ApiName format into the map so data is correctly labeled
         *                to expectations while showing correct value.
         * @param fieldsString - The raw mapping data coming from Fields_To_Display_on_Popup__c
         * @return Map<String, String> - Returns the completed map back to the constructor.
         */
        private Map<String, String> setPopupFields(String fieldsString) {
            Map<String, String> popupMap = new Map<String, String>();
            List<String> popupList = fieldsString.split(MAIN_DELIMITER);
            for (String popupFieldMapping : popupList) {
                popupMap.put(
                    popupFieldMapping.substringBefore(SUB_DELIMITER),
                    popupFieldMapping.substringAfter(SUB_DELIMITER)
                );
            }
            return popupMap;
        }

        /**
         * @description - This method breaks up the incoming raw data for the Aura to read the data and fill out the Case Card correctly.
         *                The Aura has quite an intricate setup and thus it needed 4 delimiters to break up the main data per field.
         *                Typically the format is ApiName{Type:STRING}, but can also be ApiName{relationShipName:NAME,Type:STRING} for
         *                ID Reference Fields. The hope is that the format will be maintained on the cache side as retrieving and computing
         *                all this data into a map was intensive on older versions.
         * @param fieldMappingString - The raw mapping data coming from Field_Type_Map__c
         * @return Map<String, Map<String, String>> - Returns the completed map back to the constructor.
         */
        private Map<String, Map<String, String>> setFieldMappingMap(String fieldMappingString) {
            Map<String, Map<String, String>> fieldTypeInnerMap = new Map<String, Map<String, String>>();
            List<String> fieldMappingList = fieldMappingString.split(MAIN_DELIMITER);
            for (String fieldMappingItem : fieldMappingList) {
                String fieldApiName = fieldMappingItem.substringBefore(SUB_DELIMITER);
                String mainMapping = fieldMappingItem.substringAfter(SUB_DELIMITER);
                if (fieldMappingItem.contains(REFERENCE_STRING)) {
                    List<String> mappings = mainMapping.split(MAPPING_DELIMITER);
                    Map<String, String> newMap = new Map<String, String>();
                    for (String mapping : mappings) {
                        newMap.put(mapping.substringBefore(TYPE_DELIMITER), mapping.substringafter(TYPE_DELIMITER));
                    }
                    fieldTypeInnerMap.put(fieldApiName, newMap);
                } else {
                    Map<String, String> newMap = new Map<String, String>{
                        mainMapping.substringBefore(TYPE_DELIMITER) => mainMapping.substringAfter(TYPE_DELIMITER)
                    };
                    fieldTypeInnerMap.put(fieldApiName, newMap);
                }
            }
            return fieldTypeInnerMap;
        }
    }
}
