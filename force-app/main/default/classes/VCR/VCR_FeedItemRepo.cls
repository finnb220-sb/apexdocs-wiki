/**
 * @description Repository class for the FeedItem object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since 2024
 */
public virtual inherited sharing class VCR_FeedItemRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_FeedItemRepo. Calls super constructor which sets this.sObjectType to 'FeedItem'
     */
    public VCR_FeedItemRepo() {
        super(FeedItem.sObjectType);
    }
}
