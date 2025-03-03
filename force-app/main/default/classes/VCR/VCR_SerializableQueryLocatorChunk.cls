/**
 * @description This class provides a viable way to chunk over a result set within a Queueable (or other context where
 * QueryLocator is not available as it is not serializable). It provides similar logic to the QueryLocator class.
 * Ultimately this will be replaced by the currently Beta release of Salesforce Apex Cursors.
 * See https://help.salesforce.com/s/articleView?id=release-notes.rn_apex_ApexCursors.htm&release=250&type=5
 *
 * Right now, we execute our queries directly in this class even though we do not extend VTC_BaseRepo because
 * we are technically not a Repository. The relationship is more of a containment pattern, allowing us to
 * make use of the SObjectType, query builder and query methods. But we want to preserve the ability to
 * dependency-inject the Repository from the class creating & using us so we cannot pass in the Repository
 *
 * Ultimately - we will want to update the base VTC_BaseRepo to expose the necessary variables/methods
 * but for now, they are separate due to time constraints.
 *
 * @example  This class is intended to be used in conjunction with a Queueable class.
 * `Integer position = 1;
 *  Integer chunkSize = 100;
 *  VCR_SerializableQueryLocatorChunk resultsIterator = new VCR_SerializableQueryLocatorChunk(ServiceTerritoryMember.SObjectType);
 *
 *  List<Id> territoryIds = new List<Id>();
 *  // Fetch data to query by populating territoryIds
 *
 *  resultsIterator.init('SELECT Id, ServiceTerritoryId, ServiceResourceId FROM ServiceTerritoryMember WHERE ServiceTerritoryId IN:queryArg',
 *      new Map<String, Object>{\'queryArg\' => territoryIds});
 *
 * List<ServiceTerritoryMember> members = (List<ServiceTerritoryMember>)resultsIterator.getRecords(position, chunkSize);
 *
 * // ... do something with the current set of members
 * if (resultsIterator.getNumRecords() > position) {
 *     // done processing entire set
 * } else {
 *     // enqueue next job
 * }`
 *
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentUtilQueueable for implementation
 * @see VTC_BaseRepo
 */
public inherited sharing class VCR_SerializableQueryLocatorChunk {
    @TestVisible
    private String whereClause;
    @TestVisible
    private String selectClause;
    private Map<String, Object> bindVars;
    private Integer maxNumRecords; // maximum number of records to query
    private Integer totalNumRecordsToProcess; // actual number of records in result set
    private final SObjectType sObjectTypeToQuery;

    // TODO: Move these constants to VTC_BaseRepo
    private static final String LIMIT_KEYWORD = 'LIMIT';
    private static final String OFFSET_KEYWORD = 'OFFSET';
    private static final String WHERE_KEYWORD = 'WHERE';
    private static final String FROM_KEYWORD = 'FROM';
    private static final String SELECT_KEYWORD = 'SELECT';
    private static final String SPACE = ' ';
    private static final Integer SF_MAXIMUM_LIMIT = 50000; // maximum # of records to be queried in a SF transaction

    /**
     * @description Default constructor that will allow the chunking of matching records
     *  returned for our query up to our configured maximum number of records
     *
     *  @param sObjectTypeToQuery TYpe of SObject for which we are chunking records
     */
    public VCR_SerializableQueryLocatorChunk(SObjectType sObjectTypeToQuery) {
        this.sObjectTypeToQuery = sObjectTypeToQuery;
    }

    /**
     * @description Initialize our instance, saving the query clause & dynamic bind variables
     * @param queryString `String` SOQL string to execute
     * @param bindVars `Map<String, Object>` map of name-value pairs to bind in queryString
     *
     * @throws IllegalArgumentException if queryString is empty or null OR bindVars is null (empty is ok)
     */
    public void init(String queryString, Map<String, Object> bindVars) {
        if (String.isBlank(queryString) || bindVars == null) {
            throw new IllegalArgumentException(
                'A non-null & non-empty queryString and a non-null bindVars (ok to be empty) are required to create a VCR_SerializableQueryLocatorChunk.'
            );
        }
        this.whereClause = WHERE_KEYWORD + queryString.substringAfter(WHERE_KEYWORD);
        this.whereClause = this.whereClause.indexOf(LIMIT_KEYWORD) != -1
            ? this.whereClause.substringBefore(LIMIT_KEYWORD)
            : this.whereClause;
        this.whereClause = this.whereClause.indexOf(OFFSET_KEYWORD) != -1
            ? this.whereClause.substringBefore(OFFSET_KEYWORD)
            : this.whereClause;
        this.selectClause = queryString.substringBefore(FROM_KEYWORD);
        this.bindVars = bindVars;
        this.maxNumRecords = (SF_MAXIMUM_LIMIT - 1);

        // get a count of all matching records so we can chunk over it
        initRecordCount();
    }

    /**
     * @description Main entry point to get records
     * @param offsetValue starting offset into result set to return
     * @param limitValue maximum number of records to return from result set
     *
     * @return `List<SObject>` List of matching records from result set
     */
    public List<SObject> getRecords(Integer offsetValue, Integer limitValue) {
        // we need to update queryString to take into account offset & limit
        String queryWithOffsetAndLimit =
            this.selectClause +
            SPACE +
            this.calculateFromClause() +
            SPACE +
            this.whereClause +
            SPACE +
            LIMIT_KEYWORD +
            SPACE +
            limitValue +
            SPACE +
            OFFSET_KEYWORD +
            SPACE +
            offsetValue;

        return this.fetch(queryWithOffsetAndLimit, this.bindVars);
    }

    /**
     * @description Return the total # of records in our result set
     * @return `Integer` Number of records in result set
     */
    public Integer getNumRecords() {
        return this.totalNumRecordsToProcess;
    }

    /**
     * @description Initialize our record count by calling a COUNT query for our SObject
     */
    private void initRecordCount() {
        String countQuery = SELECT_KEYWORD + ' COUNT()' + SPACE + this.calculateFromClause() + SPACE + this.whereClause;
        this.totalNumRecordsToProcess = Database.countQueryWithBinds(countQuery, this.bindVars, AccessLevel.USER_MODE);
    }

    /**
     * @description Query our object given the query string & bind arguments.
     * NOTE: This is borrowed from VTC_BaseRepo and where the refactoring would happen
     *
     * @param queryString `String` representing SOQL query to execute
     * @param bindParams `Map<String, Object>` Map of parameter values to parameter names/keys to bind in queryString
     *
     * @return `List<SObject>` List of matching records for our given queryString & bindParams
     */
    private List<SObject> fetch(String queryString, Map<String, Object> bindParams) {
        return Database.queryWithBinds(queryString, bindParams, AccessLevel.USER_MODE);
    }

    /**
     * @description Build our FROM clause using internal sObjectType value.
     * NOTE: This is duplicated from VTC_BaseRepo and where the refactoring would happen
     *
     * @return `String` Valid FROM clause for use in a SOQL query, including the FROM keyword
     */
    private String calculateFromClause() {
        return FROM_KEYWORD + SPACE + this.sObjectTypeToQuery;
    }
}
