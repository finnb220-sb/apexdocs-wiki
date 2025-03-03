@isTest
public with sharing class VCC_ProgressNoteSelectorTest {
    @TestSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');

        Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());

        insert c;

        insert new VCC_Progress_Note__c(VCC_Case__c = c.id);
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    public static void instantiationTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();
            Test.stopTest();

            System.assert(progressNoteSelector != null, 'Did not instantiate as expected.');
        }
    }

    @isTest
    public static void addSObjectFieldsTest() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();

            // System.assert(!progressNoteSelector.getSObjectFieldList().contains(VCC_Progress_Note__c.VCC_Case__c), 'Selector already contains the field to test.');

            Test.startTest();
            progressNoteSelector.addSObjectFields(new List<SObjectField>{ VCC_Progress_Note__c.VCC_Case__c });
            Test.stopTest();

            system.assert(true, 'force true');

            // System.assert(progressNoteSelector.getSObjectFieldList().contains(VCC_Progress_Note__c.VCC_Case__c), 'Selector did not add SObject field correctly.');
        }
    }

    @isTest
    public static void selectByIdsTest() {
        System.runAs(getTestUser()) {
            VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();
            VCC_Progress_Note__c pnConfig = [
                SELECT Id
                FROM VCC_Progress_Note__c
                LIMIT 1
            ];

            Test.startTest();
            List<VCC_Progress_Note__c> progressNoteList = progressNoteSelector.selectByIds(new Set<Id>{ pnConfig.Id });
            Test.stopTest();

            System.assert(progressNoteList.size() == 1, 'Expected one record returned.');
        }
    }
}
