/**
 * @description This repository is for RecentView Database Operations
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_RecentViewRepo memoizedRecentViewRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_RecentViewRepo RecentViewRepo {
 *     get {
 *          if (memoizedRecentViewRepo == null) {
 *                 memoizedRecentViewRepo = new VCR_RecentViewRepo();
 *              }
 *            return memoizedRecentViewRepo;
 *         }
 *     }
 *
 *
 * Using FetchById with defaultSelectFields
 * List<VCC_Recent_View__c> recentviews = RecentViewRepo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * Set<String> myAdditionalFields = new Set<String>{'FirstName'};
 * List<VCC_Recent_View__c> recentView = RecentViewRepo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_RecentViewRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_RecentViewRepo. Calls super constructor which sets this.sObjectType to 'VCC_Recent_View__c'
     *  Adds additional defaultSelectFields
     */
    public VCR_RecentViewRepo() {
        super(VCC_Recent_View__c.sObjectType);
        this.defaultSelectFields.add('Name');
    }

    // Other queries can be copy pasted here.
    /**
     * @description retrieves VCC_Recent_View__c that is associated to the current UserId
     * @return List<VCC_Recent_View__c> - most recent view record matching the current UserId
     */
    public List<VCC_Recent_View__c> getRecentViewFromUser() {
        String userId = UserInfo.getUserId();
        String selectClause = 'SELECT Id, VCC_Account__c, VCC_User__c, VCC_Type_Facility_Access__c, VCC_Type_Flags__c, VCC_Type_In_Patient__c, VCC_Type_Sensitive_Patient__c, VCC_Type_Verify_Patient__c, VCC_Is_Acknowledged__c, CreatedDate, LastModifiedDate, UserRecordAccess.HasEditAccess ';
        String fromClause = 'FROM VCC_Recent_View__c ';
        String whereClause = 'WHERE VCC_User__c = :userId ';
        String orderByClause = 'ORDER BY LastModifiedDate DESC ';
        String limitClause = 'LIMIT 1';
        String query = selectClause + fromClause + whereClause + orderByClause + limitClause;
        return this.fetch(query, new Map<String, Object>{ 'userId' => userId });
    }
}
