/**
 * @description Repository class for the FeedItem object to hold its respective query and DML logic for Provider Connect.
 * @author Booz Allen
 * @since 2024
 */
public inherited sharing class PC_FeedItemRepo extends VCR_FeedItemRepo {
    /**
     * @description Constructor function for PC_FeedItemRepo. Calls super constructor which sets this.sObjectType to 'FeedItem'
     */
    public PC_FeedItemRepo() {
        super();
    }
}
