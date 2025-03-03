trigger VCC_ProgressNoteTrigger on VCC_Progress_Note__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    // Run trigger-action-framework (TAF)
    // see custom metadatas: sObject_Trigger_Setting__mdt and Trigger_Action__mdt
    new MetadataTriggerHandler().run();
}
