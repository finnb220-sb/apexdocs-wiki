/**
 * @description       : Trigger for PC_Service_Team_Member__c
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen Hamilton
 * @last modified on  : 08-16-2023
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   08-16-2023   Edwin Schaeffer                      Initial Version
 **/
trigger PC_ServiceTeamTrigger on PC_Service_Team_Member__c(before insert, before update) {
    PC_ServiceTeamMemberTriggerHandler stm = new PC_ServiceTeamMemberTriggerHandler();
    stm.checkIfTeamMembersExist(Trigger.New, Trigger.OldMap);
}
