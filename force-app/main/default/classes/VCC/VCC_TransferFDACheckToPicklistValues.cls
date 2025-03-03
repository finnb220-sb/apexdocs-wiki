@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_TransferFDACheckToPicklistValues implements Database.Batchable<sObject> {
    @SuppressWarnings('PMD.ApexDoc,PMD.ApexCRUDViolation,PMD.AvoidSoqlWithoutLimits')
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator([SELECT Id, VCC_CS_FDA_authorized_test_kit__c, VCC_CS_Checked_FDA_Authorized_Test_Kit__c FROM VCC_Progress_Note__c]);
    }

    @SuppressWarnings('PMD.ApexDoc')
    public void execute(Database.BatchableContext batchableContext, List<VCC_Progress_Note__c> scope) {
        List<VCC_Progress_Note__c> updateProgressNote = new List<VCC_Progress_Note__c>(); // not needed
        for (VCC_Progress_Note__c pn : scope) {
            Boolean isChecked = pn.VCC_CS_FDA_authorized_test_kit__c;

            if (!isChecked) {
                pn.VCC_CS_Checked_FDA_Authorized_Test_Kit__c = 'Non-FDA authorized test kit used'; // should be a custom label or at the very least a static final string
            } else {
                pn.VCC_CS_Checked_FDA_Authorized_Test_Kit__c = 'FDA authorized test kit used'; // should be a custom label or at the very least a static final string
            }
            updateProgressNote.add(pn); // not needed
        }
        update updateProgressNote; // could just perform an update on 'scope'
    }

    @SuppressWarnings('PMD.ApexDoc')
    public void finish(Database.BatchableContext batchableContext) {
        return;
    }
}
