/**
 * @description Repository class for the PC_Chat_Push_Event__c object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since 2024
 */
public inherited sharing class PC_ChatPushEventRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_ChatPushEventRepo. Calls super constructor which sets this.sObjectType to 'PC_Chat_Push_Event__c'
     */
    public PC_ChatPushEventRepo() {
        super(PC_Chat_Push_Event__c.sObjectType);
    }
}
