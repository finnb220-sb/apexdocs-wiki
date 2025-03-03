/**
 * @description Example implementation of an extension from the VTC_BaseRepo
 * @author Booz Allen
 * @modified October 17, 2024
 * @justification This class is designed to encapsulate all CRUD operations on the Account object. At times, this means the methods in this class may need to be run in a `without sharing` context.
 *      However, the goal is to minimize those as much as possible. Therefore, this class is marked as `inherited sharing`. This allows the calling code to dictate the sharing context in which the methods are run.
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_AccountRepo memoizedAccountRepo;
 *    whitespace change made to test ci
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_AccountRepo accountRepo {
 *     get {
 *          if (memoizedAccountRepo == null) {
 *                 memoizedAccountRepo = new VCR_AccountRepo();
 *              }
 *            return memoizedAccountRepo;
 *         }
 *     }
 *
 *
 *
 *
 *     @AuraEnabled
 *     public static List<Account> getPersonAccountsForLWC(){
 *         try {
 *             return accountRepo.fetchPersonAccountsWithContactInfo();
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
 *  VCR_AccountRepo repo = new VCR_AccountRepo();
 *  List<Account> accounts = repo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * VCR_AccountRepo repo = new VCR_AccountRepo();
 * Set<String> myAdditionalFields = new Set<String>{'PersonContactId'};
 * List<Account> accs = repo.fetchById(recordId, myAdditionalFields);
 */

public virtual inherited sharing class VCR_AccountRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AccountRepo. Calls super constructor which sets this.sObjectType to 'Account'
     *  Adds additional defaultSelectFields
     */
    public VCR_AccountRepo() {
        super(Account.SObjectType);
        this.defaultSelectFields.add('Name');
    }

    /**
     * @description This method inserts a list of Accounts
     * @param accounts This is the list of accounts to be added to the database
     * @return List of Database.SaveResult, results of the create operation
     */
    public List<Database.SaveResult> insertAccountsAllOrNoneFalse(List<Account> accounts) {
        this.allOrNone = false;
        return this.doCreate(accounts);
    }

    /**
     * @description This method deletes a list of Accounts
     * @param accounts This is the list of accounts to be deleted from the database
     * @return List of Database.DeleteResult, results of the delete operation
     */
    public List<Database.DeleteResult> deleteAccountsAllOrNoneFalse(List<Account> accounts) {
        this.allOrNone = false;
        return this.doDelete(accounts);
    }

    // Other queries can be copy pasted here.

    /**
     * @description Example:
     * @return List<Account> returns a list of Person accounts with contact information.
     */
    public List<Account> fetchPersonAccountsWithContactInfo() {
        String selectClause = 'SELECT ID, FirstName, LastName, PersonContactId, PersonEmail';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsPersonAccount = true';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';
        return this.fetch(query);
    }

    /**
     * @description Query via ICN/MVI:
     * @param icns  `Set<String>` Set of ICNS to query for
     * @return List<Account> returns a list of Person accounts that match the ICN passed in
     */
    public List<Account> fetchPersonAccountsViaICN(Set<String> icns) {
        String selectClause = 'SELECT ID, Date_of_Birth__pc, VCC_MVI_External_Id__pc';
        String listClause = '\'' + String.join(new List<String>(icns), '\', \'') + '\'';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VCC_MVI_External_Id__pc IN (' + listClause + ')';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';
        return this.fetch(query);
    }

    /**
     * @description Query for Deceased Patient Info:
     * @param accountIds  `Set<String>` Set of account Ids to query for
     * @return List<Account> returns a list of Person accounts
     */
    public List<Account> fetchDeceasedPersonAccounts(Set<String> accountIds) {
        String selectClause = 'SELECT Id, HealthCloudGA__DeceasedDate__pc, Date_of_Birth__pc, Name';
        String listClause = '\'' + String.join(new List<String>(accountIds), '\', \'') + '\'';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id IN (' + listClause + ')';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';
        return this.fetch(query);
    }
}
