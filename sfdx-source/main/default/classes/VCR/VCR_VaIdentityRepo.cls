/**
 * @description Shared repository for VA_Identity__c data
 * @author Booz Allen Hamilton
 *
 * @see VCR_VaIdentityRepo dedicated test for this class
 */
public virtual inherited sharing class VCR_VaIdentityRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_VaIdentityRepo. Calls super constructor which sets this.sObjectType to 'VA_Identity__c'
     *  Adds additional defaultSelectFields
     */
    public VCR_VaIdentityRepo() {
        super(VA_Identity__c.SObjectType);
    }

    /**
     * @description Overloaded constructor that allows for the execution of unsafe DML operations per business requirements.
     * @param blnAllowUnsafe Boolean flag to allow unsafe DML operations
     */
    public VCR_VaIdentityRepo(Boolean blnAllowUnsafe) {
        super(VA_Identity__c.SObjectType, blnAllowUnsafe);
    }

    /**
     * @description This method inserts a list of VA_Identity__c's
     * @param vaIdentityRecords This is the list of VA_Identity__c's to be added to the database
     * @return List of Database.SaveResult, results of the create operation
     */
    public List<Database.SaveResult> updateVAIdentitiesAllOrNoneFalse(List<VA_Identity__c> vaIdentityRecords) {
        this.allOrNone = false;
        return this.doUpdate(vaIdentityRecords);
    }

    /**
     * @description Query for VA Identities:
     * @param vaIdentityIds  `Set<String>` Set of VA Identity Ids to query for
     * @return List<VA_Identity__c> returns a list of VA Identities
     */
    public List<VA_Identity__c> fetchVAIdentityRecordsByIds(Set<String> vaIdentityIds) {
        String selectClause = 'SELECT Id, MPI_Correlation_Status__c, Cerner_specific_ICN__c, Salesforce_Contact_Id__c';
        String listClause = '\'' + String.join(new Set<String>(vaIdentityIds), '\', \'') + '\'';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id IN (' + listClause + ')';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';
        return this.fetch(query);
    }

    /**
     * @description returns the query locator for the given query.  Assumes the query is safe to run in system mode.
     * @param query - Query string returned from getStaleApptQueryString.
     * @return `Database.QueryLocator` - List of <VA_Identity__c> records to return to start method of batch class.
     * @see VCC_BatchMPICorrelate
     * @see VCC_MpiRetrieveBatch
     */
    public Database.QueryLocator getQueryLocatorUnsafe(String query) {
        if (String.isBlank(query)) {
            return null;
        } else {
            return Database.getQueryLocator(query, AccessLevel.SYSTEM_MODE);
        }
    }

    /**
     * @description      getQueryLocator for batch with bind params
     * @param query      query string
     * @param bindParams Map with the Waiting and Failed labels to filter records by MPI_Correlation_Status__c
     * @return           `Database.QueryLocator`
     */
    public Database.QueryLocator getQueryLocatorWithBinds(String query, Map<String, Object> bindParams) {
        if (String.isBlank(query) || bindParams == null || bindParams.isEmpty()) {
            return null;
        } else {
            return Database.getQueryLocatorWithBinds(query, bindParams, AccessLevel.USER_MODE);
        }
    }
}
