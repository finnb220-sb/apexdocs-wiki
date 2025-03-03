@SuppressWarnings('PMD.ApexDoc')
@IsTest
public with sharing class VCC_TransferFDACheckToPicklistValuesTest {
    @TestSetup
    static void makeData() {
        User sysAdmin = DTCTestUtil.createSysAdminUser();
        sysAdmin.LastName = 'test12345';
        update sysAdmin;

        PermissionSet disableTriggerFlagPermSet = new PermissionSet(Name = 'Disable_Trigger_Flag', Label = 'Disable Trigger Flag');
        insert disableTriggerFlagPermSet;
        CustomPermission customPerm = [SELECT ID FROM CustomPermission WHERE MasterLabel = 'DisableTriggersFlag' LIMIT 1];

        SetupEntityAccess assignCustomPermToPermSet = new SetupEntityAccess(ParentId = disableTriggerFlagPermSet.id, SetupEntityId = customPerm.id);
        insert assignCustomPermToPermSet;

        PermissionSetAssignment assignPermSetToUser = new PermissionSetAssignment(AssigneeId = sysAdmin.id, PermissionSetId = disableTriggerFlagPermSet.id);
        insert assignPermSetToUser;
    }

    @SuppressWarnings('PMD.ApexDoc')
    @IsTest
    static void testTransferFDABatch() {
        User sysAdmin = [SELECT Id FROM User WHERE LastName = 'test12345' LIMIT 1];

        Account a = new Account(LastName = 'test', RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a;

        Id contactId = [SELECT PersonContactId FROM Account WHERE Id = :a.Id LIMIT 1].PersonContactId;

        Task t = new Task(WhoId = contactId, VCC_Name__c = 'Test', VCC_Relative_Type_Picklist__c = 'Self', Type = 'Call');
        insert t;

        Case c = new Case(
            AccountId = a.Id,
            ContactId = contactId,
            RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId()
        );
        insert c;

        Id progressNoteClinicalTriageRecordTypeId = VCC_Progress_Note__c.SObjectType
            .getDescribe()
            .getRecordTypeInfosByDeveloperName()
            .get('VCC_Clinical_Triage_Note_Progress_Note')
            .getRecordTypeId();

        List<VCC_Progress_Note__c> pnList = new List<VCC_Progress_Note__c>();
        for (Integer i = 0; i < 50; i++) {
            VCC_Progress_Note__c pnForInsert = new VCC_Progress_Note__c(VCC_Case__c = c.Id, RecordTypeId = progressNoteClinicalTriageRecordTypeId);
            pnList.add(pnForInsert);
            if ((i | 1) != i) {
                pnForInsert.VCC_CS_FDA_authorized_test_kit__c = false;
            } else {
                pnForInsert.VCC_CS_FDA_authorized_test_kit__c = true;
            }
        }
        insert pnList;

        Test.startTest();

        System.runAs(sysAdmin) {
            Database.executeBatch(new VCC_TransferFDACheckToPicklistValues(), 50);
        }

        Test.stopTest();

        List<VCC_Progress_Note__c> pnlistNonFDA = [SELECT Id FROM VCC_Progress_Note__c WHERE VCC_CS_Checked_FDA_Authorized_Test_Kit__c = 'Non-FDA authorized test kit used'];
        List<VCC_Progress_Note__c> pnlistFDA = [SELECT Id FROM VCC_Progress_Note__c WHERE VCC_CS_Checked_FDA_Authorized_Test_Kit__c = 'FDA authorized test kit used'];

        System.assertEquals(25, pnlistNonFDA.size(), 'Non-FDA progress note list size does not equal to expected');
        System.assertEquals(25, pnlistFDA.size(), 'FDA progress note list size does not equal to expected');
    }
}
