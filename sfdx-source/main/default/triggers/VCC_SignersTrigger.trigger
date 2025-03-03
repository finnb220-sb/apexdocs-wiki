/*
 * Apex Master Trigger for the VCC_Signer__c Object
 */
trigger VCC_SignersTrigger on VCC_Signers__c(before delete) {
    // Check to see if its a before event
    if (Trigger.isBefore) {
        if (Trigger.IsDelete) {
            VCC_SignersTriggerHandler.Prevent_Deletion(Trigger.old);
        }
    }
}
