/**
 * @description This repository is for Organization Database Operations
 * @author Booz Allen
 *
 * @example
 * public class MyLWCController{
 *  @TestVisible
 *  private static VCR_OrgRepo memoizedOrgRepo;
 *
 *
 *    An internally available getter that returns the memoized version if available.
 *    This allows us to only have one instance of the repo at a time
 *
 *  private static VCR_OrgRepo OrgRepo {
 *     get {
 *          if (memoizedOrgRepo == null) {
 *                 memoizedOrgRepo = new VCR_OrgRepo();
 *              }
 *            return memoizedOrgRepo;
 *         }
 *     }
 */
public inherited sharing class VCR_OrgRepo extends VTC_BaseRepo {
    @TestVisible
    private static Organization privateOrgInfo;

    /**
     * @description Constructor function for VCR_OrgRepo. Calls super constructor which sets this.sObjectType to 'Organization'
     */
    public VCR_OrgRepo() {
        super(Organization.SObjectType);
    }

    /**
     * @description Property to get current environment Organization info
     * @return privateOrgInfo returns all standard fields available for the current organization
     */
    public Organization orgInfo {
        get {
            if (privateOrgInfo == null) {
                privateOrgInfo = [SELECT FIELDS(STANDARD) FROM Organization LIMIT 1];
            }
            return privateOrgInfo;
        }
        private set;
    }
}
