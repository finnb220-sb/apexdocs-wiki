/**
 * @description Example implementation of an extension from the VTC_BaseRepo
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_bsConfigurationsAssignedUserRepo memoizedBSConfigRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_bsConfigurationsAssignedUserRepo BSCAURepo {
 *     get {
 *          if (memoizedBSConfigRepo == null) {
 *                 memoizedBSConfigRepo = new VCR_bsConfigurationsAssignedUserRepo();
 *              }
 *            return memoizedBSConfigRepo;
 *         }
 *     }
 *
 *
 *
 *
 *     @AuraEnabled
 *     public static List<cnx__Connects_Configuration_Assignment__c> getPersonAccountsForLWC(){
 *         try {
 *             return BSCAURepo.fetchPersonAccountsWithContactInfo();
 *         } catch (Exception e) {
 *             AuraHandledException except = new AuraHandledException(e.getMessage());
 *
 *             Sets the message so we can check it in  our test classes
 *
 *             except.setMessage(e.getMessage());
 *             throw except;
 *         }
 *     }
 * }
 *
 * Using FetchById with defaultSelectFields
 *  VCR_bsConfigurationsAssignedUserRepo repo = new VCR_bsConfigurationsAssignedUserRepo();
 *  List<-> bsRecords = repo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * VCR_bsConfigurationsAssignedUserRepo repo = new VCR_bsConfigurationsAssignedUserRepo();
 * Set<String> myAdditionalFields = new Set<String>{'PersonContactId'};
 * List<cnx__Connects_Configuration_Assignment__c> bsList = repo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_bsConfigurationsAssignedUserRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AccountRepo. Calls super constructor which sets this.sObjectType to 'Account'
     *  Adds additional defaultSelectFields
     */
    public VCR_bsConfigurationsAssignedUserRepo() {
        super(cnx__Connects_Configuration_Assignment__c.sObjectType);
        this.defaultSelectFields.add('Name');
    }

    // Other queries can be copy pasted here.

    /**
     * @description custom query for fetching record
     * @param runningUserID ID of running user
     * @return List<cnx__Connects_Configuration_Assignment__c> returns a list of cnx__Connects_Configuration_Assignment__c
     */
    public List<cnx__Connects_Configuration_Assignment__c> fetchAssociatedUser(String runningUserID) {
        String selectClause = 'SELECT ID, cnx__Assigned_User__r.Id';
        String fromClause = 'FROM cnx__Connects_Configuration_Assignment__c ';
        String whereClause = 'WHERE cnx__Assigned_User__r.Id = \'' + runningUserID + '\'';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';
        return this.fetch(query);
    }
}
