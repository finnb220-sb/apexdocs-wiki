/**
 * @description Repository class for the PushTopic object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public virtual inherited sharing class VCR_PushTopicRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_PushTopicRepo. Calls super constructor which sets this.sObjectType to 'PushTopic'
     */
    public VCR_PushTopicRepo() {
        super(PushTopic.sObjectType);
    }

    /**
     * @description retrieves a list of PushTopics with the given name
     * @param name  name string to match on for the Push Topic records
     * @return      `List<PushTopic>` list of push topics with the provided Name
     */
    public List<PushTopic> getPushTopicsByName(String name) {
        String selectClause = 'SELECT Id, Name';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Name = :name';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ORDER BY CreatedDate DESC';
        return (List<PushTopic>) this.fetch(query, new Map<String, Object>{ 'name' => name });
    }

    /**
     * @description retrieves singular PushTopic most recently created with the given name
     * @param name  name of the Push Topic
     * @return      `PushTopic` most recent push topic with the given name
     */
    public PushTopic getMostRecentPushTopicByName(String name) {
        List<PushTopic> queriedPushTopics = this.getPushTopicsByName(name);
        return queriedPushTopics.isEmpty() ? new PushTopic() : queriedPushTopics[0];
    }
}
