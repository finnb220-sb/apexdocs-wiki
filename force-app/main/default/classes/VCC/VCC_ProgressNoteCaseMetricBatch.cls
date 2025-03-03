/**
 * @description this is the  class that houses the business logic for updating the Case Metric Field on historical Progress Notes
 * @see VCR_VCR_ProgressNoteRepo
 * @see VCC_GenericBatch
 */

public with sharing class VCC_ProgressNoteCaseMetricBatch extends ABS_BatchExecutioner {
    private static final String EXECUTIONER_NAME = 'VCC_ProgressNoteCaseMetrics';
    private final Map<String, Object> bindVariables;
    private final String queryLocatorString;
    private List<VCC_Progress_Note__c> progressNotes;

    /**
     * @description property for the pnRepo object
     * provides access to the methods in the VCR_ProgressNoteRepo class
     * static so that it can be accessed from the test class
     * @see VCR_ProgressNoteRepo
     */

    @TestVisible
    private static VCR_ProgressNoteRepo pnRepo {
        get {
            return pnRepo ?? new VCR_ProgressNoteRepo();
        }
        set;
    }

    /**
     * @description property for the caseMetricRepo object
     * provides access to the methods in the VCR_CaseMetricRepo class
     * static so that it can be accessed from the test class
     * @see VCR_CaseMetricRepo
     */

    @TestVisible
    private static VCR_CaseMetricRepo caseMetricRepo {
        get {
            return caseMetricRepo ?? new VCR_CaseMetricRepo();
        }
        set;
    }

    /**
     * @description This is the constructor for the VCC_ProgressNoteCaseMetricBatch class.
     * It initializes the object by querying and locating the necessary data.
     */
    public VCC_ProgressNoteCaseMetricBatch() {
        queryLocatorString = getQueryLocatorString();
        bindVariables = getBindVariables();
        super.executionerName = EXECUTIONER_NAME;
    }

    /**
     * @description This method fetches the bind parameters for our SOQL Query
     * @return Map of Bind Values.
     */
    public override Map<String, Object> getBindVariables() {
        Map<String, Object> bindParameters = new Map<String, Object>{};
        return bindParameters;
    }

    /**
     * @description This method fetches and returns the query string from the Progress Note Repo.
     * @return String Returns the query string.
     */
    public override String getQueryLocatorString() {
        return pnRepo.getQueryLocatorString();
    }

    /**
     * @description This method fetches and returns the query locator from the caseRepo.
     * @param query The query string to process
     * @return Database.QueryLocator Returns the query locator.
     */
    public override Database.QueryLocator getQueryLocator(String query) {
        return pnRepo.getQueryLocator(queryLocatorString);
    }

    /**
     * @description Method to execute the VCC_Progress_Note__c Case Metrics Field Batch
     * @param progressNotesInputs List<VCC_Progress_Note__c> to execute the batch for
     */
    public override void execute(List<SObject> progressNotesInputs) {
        this.progressNotes = (List<VCC_Progress_Note__c>) progressNotesInputs;
        Set<Id> caseIdsFromProgressNotes = new Set<Id>();
        for (VCC_Progress_Note__c progressNote : progressNotes) {
            caseIdsFromProgressNotes.add(progressNote.VCC_Case__c);
        }

        // Get all the Case Metrics that have the Same Case Id as the Progress Note Case Id

        List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();

        if (VCC_Case_Metrics__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()) {
            caseMetrics = caseMetricRepo.fetchCaseMetricByCaseId(caseIdsFromProgressNotes);
        }

        // Put all the case metrics in a map so we can find them based on case id
        Map<String, Object> caseMetricsByCaseIdMap = new Map<String, VCC_Case_Metrics__c>();
        for (VCC_Case_Metrics__c caseMetric : caseMetrics) {
            caseMetricsByCaseIdMap.put(caseMetric.VCC_Case__c, caseMetric);
        }
        // Build up a list of progress notes that have been updated with the metric that matches with that progress note
        List<VCC_Progress_Note__c> progressNotesToUpdate = new List<VCC_Progress_Note__c>();
        for (VCC_Progress_Note__c progressNote : progressNotes) {
            if (caseMetricsByCaseIdMap.containsKey(progressNote.VCC_Case__c)) {
                progressNote.VCC_Case_Metrics__c = ((VCC_Case_Metrics__c) caseMetricsByCaseIdMap.get(
                        progressNote.VCC_Case__c
                    ))
                    .Id;
                //progressNotesToUpdate.add(progressNote);
            }
            progressNotesToUpdate.add(progressNote);
        }
        pnRepo.updateProgressNotes(progressNotesToUpdate);
    }
}
