/**
 * @description This is a repository class for manipulating VCC_Case_Metrics__c records. It provides methods for fetching records, upserting records, and constructing SOQL clauses.
 * @author BAH
 * @see VCC_Case_Metrics__c
 * @see VCC_CaseMetricLogic
 */
public inherited sharing class VCR_CaseMetricRepo extends VTC_BaseRepo {
    private static final Set<String> DEFAULT_FIELDS = new Set<String>{
        'CreatedById',
        'CreatedDate',
        'Id',
        'IsDeleted',
        'LastModifiedById',
        'LastModifiedDate',
        'Name',
        'RecordTypeId',
        'VCC_Case__c',
        'VCC_Child_Case__c',
        'VCC_VISN__c'
    };

    /**
     * @description The VCR_CaseMetricRepo is an Apex class constructor.
     * It is used for initializing the VCR_CaseMetricRepo object with the SObjectType VCC_Case_Metrics__c and adding 'VCC_Case__c' to the defaultSelectFields list.
     */
    public VCR_CaseMetricRepo() {
        super(VCC_Case_Metrics__c.SObjectType);
        this.defaultSelectFields.addAll(DEFAULT_FIELDS);
    }

    /**
     * @description Fetches a specific VCC_Case_Metrics__c record by its Id.
     * @param ids The Id of the VCC_Case_Metrics__c record that needs to be fetched.
     * @return VCC_Case_Metrics__c Returns the VCC_Case_Metrics__c record that matches the provided Id.
     */
    public VCC_Case_Metrics__c fetchCaseMetricById(Id ids) {
        return (VCC_Case_Metrics__c) fetchById(ids);
    }

    /**
     * @description Fetches  VCC_Case_Metrics__c records by a given set of Case Ids.
     * @param caseIds The set of CaseIds that corresponds to the desired VCC_Case_Metrics__c records to fetch
     * @return List<VCC_Case_Metrics__c> Returns a list of VCC_Case_Metrics__c record that matches the provided Ids.
     */
    public List<VCC_Case_Metrics__c> fetchCaseMetricByCaseId(Set<Id> caseIds) {
        List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();
        if (
            VCC_Case_Metrics__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() &&
            Schema.SObjectType.VCC_Case_Metrics__c.fields.Id.isAccessible() &&
            Schema.SObjectType.VCC_Case_Metrics__c.fields.Name.isAccessible() &&
            Schema.SObjectType.VCC_Case_Metrics__c.fields.VCC_Case__c.isAccessible()
        ) {
            Set<String> fields = new Set<String>{ 'Id', 'Name', 'VCC_Case__c' };

            String selectString = this.calculateSelectClause(fields);
            String fromString = this.calculateFromClause();
            String whereString = 'WHERE VCC_Case__c IN :caseIds';
            String queryString = selectString + ' ' + fromString + ' ' + whereString;
            caseMetrics = this.fetch(queryString, new Map<String, Object>{ 'caseIds' => caseIds });
        }

        return caseMetrics;
    }

    /**
     * @description Handles the upsert operation for a list of case metrics
     * @param caseMetrics List of VCC_Case_Metrics__c records for upsert
     * @return List of Database.UpsertResult, results of the upsert operation
     */
    public List<Database.UpsertResult> upsertCaseMetrics(List<VCC_Case_Metrics__c> caseMetrics) {
        return this.doUpsert(caseMetrics);
    }

    /**
     * @description Fetches a list of VCC_Case_Metrics__c records by their VCC_Case__c Ids
     * @param caseIds List of VCC_Case__c Ids to fetch VCC_Case_Metrics__c records
     * @return List of VCC_Case_Metrics__c records that match the provided VCC_Case__c Ids
     */
    public List<VCC_Case_Metrics__c> getScheduleCaseMetrics(List<Id> caseIds) {
        String selectString = getSelectClause();
        String fromString = this.calculateFromClause();
        String whereString = 'WHERE VCC_Case__c IN :caseIds';
        String orderByString = 'ORDER BY CreatedDate ASC';
        String queryString = selectString + ' ' + fromString + ' ' + whereString + ' ' + orderByString;
        return this.fetch(queryString, new Map<String, Object>{ 'caseIds' => caseIds });
    }

    /**
     * @description Constructs and returns a SOQL SELECT clause with all fields of a specified SObjectType
     * @return String of the SELECT clause for SOQL queries
     */
    @TestVisible
    private String getSelectClause() {
        List<String> fieldNames = new List<String>(DEFAULT_FIELDS);
        List<String> fieldNamesList = new List<String>();
        for (String fieldName : fieldNames) {
            fieldNamesList.add(fieldName);
        }
        return 'SELECT ' + String.join(fieldNamesList, ', ');
    }
}
