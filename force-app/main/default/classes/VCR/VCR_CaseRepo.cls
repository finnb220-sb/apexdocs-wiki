/**
 * @description This repository is for Case Database Operations
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_CaseRepo memoizedCaseRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_CaseRepo caseRepo {
 *     get {
 *          if (memoizedCaseRepo == null) {
 *                 memoizedCaseRepo = new VCR_CaseRepo();
 *              }
 *            return memoizedCaseRepo;
 *         }
 *     }
 *
 *
 * Using FetchById with defaultSelectFields
 * List<Case> cases = caseRepo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * Set<String> myAdditionalFields = new Set<String>{'FieldName'};
 * List<Case> cases = caseRepo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_CaseRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_CaseRepo. Calls super constructor which sets this.sObjectType to 'Case'
     *  Adds additional defaultSelectFields
     */
    public VCR_CaseRepo() {
        super(Case.SObjectType);
        this.defaultSelectFields.add('CaseNumber');
    }

    /**
     * @description Used to set the context for the databasequerylocator in metriclogic and genericbatch
     * @return String representing the query string to be used in the fetch method.
     */
    @TestVisible
    private String getQueryString() {
        String selectClause = 'SELECT ';
        String caseFieldNames = 'CreatedDate, Id, ParentId, RecordTypeId, OwnerId';
        String typeOfClause = 'TYPEOF Owner WHEN User THEN Name, Division WHEN Group THEN DeveloperName END';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE RecordType.DeveloperName IN :developerNames';
        String orderByClause = 'ORDER BY CreatedDate ASC';
        String innerQuery = '(SELECT ' + caseFieldNames + ', ' + typeOfClause + ' FROM Cases)';
        String relatedInnerQuery = '(SELECT Id, VCC_Case__c,VCC_VISN__c, VCC_Child_Case__c, RecordTypeId, VCC_Child_Case_Record_Type__c FROM Case_Metrics__r)';

        String query =
            selectClause + // SELECT
            caseFieldNames + //CreatedDate, Id, ParentId, RecordTypeId, OwnerId
            ', ' +
            typeOfClause + // TYPEOF Owner WHEN User THEN Name, Division WHEN Group THEN DeveloperName END
            ', ' +
            innerQuery + // (SELECT CreatedDate, Id, ParentId, RecordTypeId, OwnerId, TYPEOF Owner WHEN User THEN Name, Division WHEN Group THEN DeveloperName END FROM Cases)
            ', ' +
            relatedInnerQuery + // (SELECT Id, VCC_Case__c,VCC_VISN__c, VCC_Child_Case__c, RecordTypeId, VCC_Child_Case_Record_Type__c FROM Case_Metrics__r)
            ' ' +
            fromClause + // From Case
            ' ' +
            whereClause + // WHERE RecordType.DeveloperName IN :developerNames
            ' ' +
            orderByClause; // ORDER BY CreatedDate ASC

        return query;
    }
    /**
     * @description Used to set the context for the databasequerylocator in metriclogic and genericbatch
     * @return String representing the query string to be used in the fetch method.
     */
    public String getQueryLocatorString() {
        return this.getQueryString();
    }

    /**
     * @description
     * @param query query string to be used in the query locator.
     * @param bindParams representing the bind parameters to be used in the query, record types.
     * @return Database.QueryLocator representing a complex query with bind parameters on the Case object
     */
    public Database.QueryLocator getQueryLocator(String query, Map<String, Object> bindParams) {
        if ([SELECT Name, Id FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name != 'System Administrator') {
            throw new HandledException('Only System Administrators can run this query');
        }
        if (bindParams != null && String.isNotBlank(query) && !bindParams.isEmpty()) {
            return Database.getQueryLocatorWithBinds(query, bindParams, AccessLevel.SYSTEM_MODE);
        } else {
            return null;
        }
    }

    /**
     * @description This method inserts a list of cases
     * @param cases This is the list of cases to be added to the database
     * @return List of Database.UpsertResult, results of the upsert operation
     */
    public List<Database.UpsertResult> upsertCasesAllOrNoneFalse(List<Case> cases) {
        this.allOrNone = false;
        return this.doUpsert(cases);
    }
}
