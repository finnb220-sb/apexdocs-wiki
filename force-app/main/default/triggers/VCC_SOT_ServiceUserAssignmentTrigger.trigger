trigger VCC_SOT_ServiceUserAssignmentTrigger on VCC_Service_User_Assignment__c(before insert, before update) {
    VCC_SOT_ServiceUserAssignTriggerHandler.dupSUAError(Trigger.new);
}
