/**
 * @description Repository class for the User Service Presence object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public virtual inherited sharing class VCR_UserServicePresenceRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_UserServicePresenceRepo. Calls super constructor which sets this.sObjectType to 'UserServicePresence'
     */
    public VCR_UserServicePresenceRepo() {
        super(UserServicePresence.sObjectType);
    }
}
