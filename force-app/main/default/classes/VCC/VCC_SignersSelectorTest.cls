@IsTest
public with sharing class VCC_SignersSelectorTest {
    @isTest
    public static void addSObjectFieldsTest() {
        VCC_SignersSelector signersSelector = new VCC_SignersSelector();
        System.assert(!signersSelector.getSObjectFieldList().contains(VCC_Signers__c.SystemModStamp), 'SObject field list already contains this field.');
        Test.startTest();
        signersSelector.addSObjectFields(new List<SObjectField>{ VCC_Signers__c.SystemModStamp });
        Test.stopTest();
        System.assert(signersSelector.getSObjectFieldList().contains(VCC_Signers__c.SystemModStamp), 'SObject field was not added as expected.');
    }

    @isTest
    public static void selectSignersByAddendumIdTest() {
        Case c = new Case(RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId());
        insert c;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            VCC_Case__c = c.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage_Note_Progress_Note').getRecordTypeId()
        );
        insert pn;
        VCC_Addendum__c addendum = new VCC_Addendum__c(VCC_Related_Note__c = pn.Id, VCC_Addendum__c = 'Hello World');
        insert addendum;
        insert new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_Addendum__c = addendum.Id) };

        Test.startTest();
        List<VCC_Signers__c> signers = (new VCC_SignersSelector()).selectSignersByAddendumId(addendum.Id);
        System.assert(signers.size() == 1, 'Expected one signer.');
        Test.stopTest();
    }

    @isTest
    public static void selectSignersByProgressNoteIdTest() {
        Case c = new Case(RecordTypeId = Case.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId());
        insert c;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            VCC_Case__c = c.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage_Note_Progress_Note').getRecordTypeId()
        );
        insert pn;
        insert new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_Progress_Note__c = pn.Id) };

        Test.startTest();
        List<VCC_Signers__c> signers = (new VCC_SignersSelector()).selectSignersByProgressNoteId(pn.Id);
        System.assert(signers.size() == 1, 'Expected one signer.');
        Test.stopTest();
    }
}
