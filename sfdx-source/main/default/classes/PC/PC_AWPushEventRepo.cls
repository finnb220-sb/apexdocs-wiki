/**
 * @description Repository class for the PC_AWPushEvent__c object to hold its respective query and DML logic for Provider Connect.
 * @author Booz Allen Hamilton
 * @justification the PC_ChatStreamController.invokePushTopic invocable method can be called from record-triggered flows triggered by FLPs or Specialists and although the flow and apex run with system context for the permissions, sharing rules are still observed based on the user who triggered the flow. In order to ensure existing AW Push Events are updated successfully, FLPs that do not have sharing access to the Specialist's AW Push Events must be able to update them, so an unsafe operation is necessary
 */
public inherited sharing class PC_AWPushEventRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_AWPushEventRepo. Calls super constructor which sets this.sObjectType to 'PC_AWPushEvent__c'
     */
    public PC_AWPushEventRepo() {
        super(PC_AWPushEvent__c.sObjectType);
    }

    /**
     * @description      Constructor function for PC_AWPushEventRepo. Calls super constructor which sets this.sObjectType to 'PC_AWPushEvent__c' and allows setting value of allowUnsafe to TRUE/FALSE (see @justification above)
     * @param allowUnsafe allows for database operations to perform in System.Mode
     */
    public PC_AWPushEventRepo(Boolean allowUnsafe) {
        super(PC_AWPushEvent__c.sObjectType, allowUnsafe);
    }

    /**
     * @description   get list of AWPush Event records owned by a specific set of users, in order of creation per user (so we can easily find the most recently created per user)
     * @param userIds list of sf User Ids
     * @return        `List<PC_AWPushEvent__c>` AWPush Event records owned by the provided users
     */
    public List<PC_AWPushEvent__c> getAWPushEventsByOwners(Set<String> userIds) {
        String selectClause = 'SELECT Id, OwnerId, CaseClosedJSON__c, CaseClosedStatus__c, NewCaseOwner__c, SkillName__c, HasPresence__c, ConsultantsOnline__c, MinCapacity__c, GeneralDisabled__c, PatientSpecificDisabled__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE OwnerId In :userIds';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ORDER BY OwnerId, CreatedDate DESC';
        return (List<PC_AWPushEvent__c>) this.fetch(query, new Map<String, Object>{ 'userIds' => userIds });
    }

    /**
     * @description Performs unsafe Upsert in System Mode (see @justification above).
     * @param recordList PC_AWPushEvent__c records to be upserted unsafely.
     * @exception Exception thrown when the doUpsert fails
     */
    public void performUpsertUnsafe(List<PC_AWPushEvent__c> recordList) {
        try {
            this.doUpsertUnsafe(recordList);
        } catch (Exception caughtException) {
            Logger.error('performUpsertUnsafe failed to upsert PC_AWPushEvent__c records', caughtException);
            throw new PC_CustomException(caughtException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
