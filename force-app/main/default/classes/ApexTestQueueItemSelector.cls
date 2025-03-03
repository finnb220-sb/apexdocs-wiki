/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Selector Class for ApexTestQueueItem
 */
public inherited sharing class ApexTestQueueItemSelector {
    /**
     * Gets records by Id
     * @param recIds - Set of recordids
     * @return List<ApexTestQueueItem>
     */
    public List<ApexTestQueueItem> getRecordsById(Set<Id> recIds) {
        return [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id IN :recIds];
    }

    /**
     * Gets record by ParentJobId
     *
     * @param parentJobIds - Set of ParentJobIds
     *
     * @return List<ApexTestQueueItem>
     */
    public List<ApexTestQueueItem> getRecordByParentJobIds(List<String> parentJobIds) {
        List<ApexTestQueueItem> queueItems = [
            SELECT ApexClass.Name, Status, ExtendedStatus, ParentJobId
            FROM ApexTestQueueItem
            WHERE ParentJobId IN :parentJobIds
        ];

        return queueItems;
    }
}
