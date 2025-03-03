/**
 * @description This repository is for Contact Database Operations
 * @author Booz Allen
 * @modified October 17, 2024
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_ContactRepo memoizedContactRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_ContactRepo contactRepo {
 *     get {
 *          if (memoizedContactRepo == null) {
 *                 memoizedContactRepo = new VCR_ContactRepo();
 *              }
 *            return memoizedContactRepo;
 *         }
 *     }
 *
 *
 * Using FetchById with defaultSelectFields
 * List<Contact> contacts = contactRepo.fetchById(recordId);
 *
 * Using FetchById with additional fields
 * Set<String> myAdditionalFields = new Set<String>{'FirstName'};
 * List<Contact> contacts = contactRepo.fetchById(recordId, myAdditionalFields);
 */
public virtual inherited sharing class VCR_ContactRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_ContactRepo. Calls super constructor which sets this.sObjectType to 'Contact'
     *  Adds additional defaultSelectFields
     */
    public VCR_ContactRepo() {
        super(Contact.SObjectType);
        this.defaultSelectFields.add('Name');
    }

    // Other queries can be copy pasted here.
    /**
     * @description retrieves Contact that is associted to the Account Id passed in
     * @param accountId - account id
     * @return List<Contact> - list of contacts matching the account id
     */
    public List<Contact> getContactFromAccountId(String accountId) {
        String selectClause = 'SELECT Id, Name, AccountId ';
        String fromClause = 'FROM Contact ';
        String whereClause = 'WHERE AccountId = \'' + accountId + '\'';
        String query = selectClause + fromClause + whereClause;

        return this.fetch(query, new Map<String, Object>{ 'accountId' => accountId });
    }

    /**
     * @description retrieves Contact that is associted to the Account Ids passed in
     * @param accountIdSet - set of account ids
     * @return List<Contact> - list of contacts matching the account id set
     */
    public List<Contact> getContactFromAccountSet(Set<String> accountIdSet) {
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('accountIdSet', accountIdSet);
        String selectClause = this.calculateSelectClause(new Set<String>{ 'Name', 'AccountId' });
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE AccountId IN :accountIdSet';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';

        return this.fetch(query, bindParams);
    }

    /**
     * @description retrieves Contact that is associted to the icnSet passed in
     * @param icnSet - set of icns
     * @return List<Contact> - list of contacts matching the icn set
     */
    public List<Contact> getContactFromIcnSet(Set<String> icnSet) {
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('icnSet', icnSet);
        String selectClause = this.calculateSelectClause(new Set<String>{ 'VCC_MVI_External_Id__c' });
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VCC_MVI_External_Id__c IN :icnSet';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 2000';

        return this.fetch(query, bindParams);
    }
}
