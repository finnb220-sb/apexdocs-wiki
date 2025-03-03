/**
 * Author:Jaren Yach
 *  Created Date 04/27/2022
 *  Purpose: This modifies the original DeactivateUsers class written by Jaya Dabbara on 01/25/2017.  The Below code is for updating users
 *  who haven't logged in for 90 days or were created 90 days ago and never logged in.  It is called by DeactivateUsers1.
 */
public class DeactivateUsers2 implements Database.Batchable<SObject> {
    //User Ids to query for deactivation
    private Set<Id> userIds;

    public DeactivateUsers2(Set<Id> userIdsToDeactivate) {
        this.userIds = userIdsToDeactivate;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM User WHERE Id IN :this.userIds]);
    }

    //Process each batch of records.  200 is the default
    public void execute(Database.BatchableContext bc, List<User> scope) {
        List<User> deactivateList = new List<User>();
        //Loop through each user record passed into the batch
        for (User u : scope) {
            u.IsActive = false;
            u.Deactivation_Date__c = System.now();
            deactivateList.add(u);
        }

        //Deactivate the users
        if (deactivateList.size() > 0) {
            List<Database.SaveResult> results = Database.update(deactivateList, false);
        }
    }

    public void finish(Database.BatchableContext bc) {
        DTCUtils.sendCompletedBatchJobEmail(bc.getJobId());
    }
}
