/**
 * @description this is the logic class for manipulating that houses the business logic for the Case Metric object.
 * @author BAH
 * @see VCR_CaseMetricRepo
 * @see VCC_GenericBatch
 */
public without sharing class VCC_CaseMetricLogic extends ABS_BatchExecutioner {
    private static final String VCC_REPORTING = 'VCC_Reporting';
    private static final List<String> DEVELOPER_NAMES = new List<String>{
        'VCC_Administrative',
        'VCC_Clinical_Triage',
        'VCC_Vitrual_Clinic_Visit'
    };
    private static final String EXECUTIONER_NAME = 'VCC_CaseMetricLogic';

    private final String queryLocator;
    @TestVisible
    private Map<String, VCC_Queue_Mapping__mdt> devNameToQueueMapping;
    private final Map<String, Object> bindParams;
    private final String recordTypeId;
    private List<VCC_Case_Metrics__c> upsertMetricCases;
    private List<Case> inputCaseList;

    /**
     * @description property for the caseMetricRepo object
     * provides access to the methods in the VCR_CaseMetricRepo class
     * static so that it can be accessed from the test class
     * @see VCR_CaseMetricRepo
     */
    @TestVisible
    private static VCR_CaseMetricRepo caseMetricRepo {
        get {
            return caseMetricRepo = caseMetricRepo ?? new VCR_CaseMetricRepo();
        }
        set;
    }

    /**
     * @description property for the caseRepo object
     * provides access to the methods in the VCR_CaseRepo class
     * static so that it can be accessed from the test class
     * @see VCR_CaseRepo
     */
    @TestVisible
    private static VCR_CaseRepo caseRepo {
        get {
            return caseRepo ?? new VCR_CaseRepo();
        }
        set;
    }

    /**
     * @description This is the constructor for the VCC_CaseMetricLogic class.
     * It initializes the object by querying and locating the necessary data.
     */
    public VCC_CaseMetricLogic() {
        queryLocator = getQueryLocatorString();
        devNameToQueueMapping = VCC_Queue_Mapping__mdt.getAll();
        bindParams = getBindVariables();
        recordTypeId = getRecordTypeId();
        super.executionerName = EXECUTIONER_NAME;
    }

    /**
     * @description This method fetches and returns the query string from the caseRepo.
     * @return String Returns the query string.
     */
    public override String getQueryLocatorString() {
        return caseRepo.getQueryLocatorString();
    }
    /**
     * @description This method fetches and returns the query locator from the caseRepo.
     * @param query The query string to process
     * @return Database.QueryLocator Returns the query locator.
     */
    public override Database.QueryLocator getQueryLocator(String query) {
        if (String.isBlank(query)) {
            return null;
        }
        return caseRepo.getQueryLocator(query, this.bindParams);
    }

    /**
     * @description This method fetches and returns the bind variables from the caseRepo.
     * @return Map<String, Object> Returns the bind variables.
     */
    public override Map<String, Object> getBindVariables() {
        return new Map<String, Object>{ 'developerNames' => DEVELOPER_NAMES };
    }

    /**
     * @description This method processes a list of Case records. It collects important information from the given Case records
     * including their Id, ParentId if any, and associated metrics. Then, it retrieves related childCase records.
     * If an associated metric record doesn't exist for a Case and it is not a child Case, a new metric record is created with detailed properties.
     * @param inputList List of Case records to process
     */
    public override void execute(List<SObject> inputList) {
        this.inputCaseList = (List<Case>) inputList;
        upsertMetricCases = new List<VCC_Case_Metrics__c>();
        for (Case currentCase : inputCaseList) {
            upsertMetricCases.add(generateCaseMetrics(currentCase));
        }

        caseMetricRepo.upsertCaseMetrics(upsertMetricCases);
    }
    /**
     * @description This method generates a VCC_Case_Metrics__c record for the given Case record.
     * It sets the VCC_Case__c, VCC_Child_Case__c, VCC_VISN__c, and RecordTypeId fields of the VCC_Case_Metrics__c record.
     * @param currentCase The Case record to process
     * @return VCC_Case_Metrics__c Returns the generated VCC_Case_Metrics__c record.
     */
    @TestVisible
    private VCC_Case_Metrics__c generateCaseMetrics(Case currentCase) {
        VCC_Case_Metrics__c caseMetrics = currentCase?.Case_Metrics__r != null && !currentCase.Case_Metrics__r.isEmpty()
            ? currentCase.Case_Metrics__r[0]
            : new VCC_Case_Metrics__c();
        if (currentCase?.Cases != null && !currentCase.Cases.isEmpty()) {
            caseMetrics.VCC_Child_Case__c = currentCase.Cases[0].Id;
        }
        if (caseMetrics?.Id == null) {
            caseMetrics.VCC_Case__c = currentCase?.Id; //If the caseMetrics is new, set the VCC_Case__c field
        }
        caseMetrics.VCC_VISN__c = getRecordVISNName(currentCase);
        caseMetrics.RecordTypeId = recordTypeId;

        return caseMetrics;
    }
    /**
     * @description This method fetches and returns the VISN Name of the record.
     * @param inputCase The Case record to process
     * @return String Returns the VISN Name of the record.
     */
    @TestVisible
    private String getRecordVISNName(Case inputCase) {
        String recordVISNName;
        if (inputCase.Owner instanceof User) {
            User tempUser = inputCase.Owner;
            recordVISNName = tempUser.Division;
        } else if (inputCase.Owner instanceof Group && inputCase.OwnerId != null) {
            Group tempGroup = inputCase.Owner;
            String developerName = tempGroup.DeveloperName;
            if (devNameToQueueMapping.containsKey(developerName)) {
                recordVISNName = devNameToQueueMapping.get(developerName).VCC_VISN_Name__c;
            }
        } else {
            recordVISNName = '';
        }
        return recordVISNName;
    }
    /**
     * @description This method fetches and returns the RecordTypeId of the VCC_Reporting record type.
     * @return String Returns the RecordTypeId of the VCC_Reporting record type.
     */
    @TestVisible
    private static String getRecordTypeId() {
        return VCC_Case_Metrics__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get(VCC_REPORTING)
            .getRecordTypeId();
    }
}
