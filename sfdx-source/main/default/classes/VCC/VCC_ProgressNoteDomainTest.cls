@isTest
public with sharing class VCC_ProgressNoteDomainTest {
    @TestSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');

        User testUser = TestUtility.buildTestUserByFirstAndLastName('firstName', 'lastName');
        insert testUser;

        Account testAcct = TestUtility.createAccount('Account A');
        insert testAcct;

        Contact cont = TestUtility.createContact(testUser.Id, 'lastName', testAcct.Id);
        insert cont;

        Case testCase = new Case(
            RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.FULL).getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId(),
            VCC_Caller_Relation__c = 'Self'
        );
        if (Case.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()) {
            insert testCase;
        }

        insert new VCC_Progress_Note__c(
            VCC_Additional_Comments__c = 'Some additional comment.',
            VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
            VCC_Case__c = testCase.Id,
            RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage_Note_Progress_Note').getRecordTypeId()
        );
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    static void charLimitErrorTest() {
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c progNote = [SELECT Id FROM VCC_Progress_Note__c LIMIT 1];
            String str250 = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium.';

            progNote.VCC_Chief_Complaint__c = str250 + 'abcde';
            progNote.VCC_Patient_Stated_Symptoms__c = str250 + str250 + str250 + str250;

            Test.startTest();
            try {
                update progNote;
            } catch (Exception e) {
                Assert.isTrue(e.getMessage().contains('Chief_Complaint'), 'Expected Error to be thrown');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void newProgressNoteTest() {
        System.runAs(getTestUser()) {
            Case caseSample = [SELECT Id, VCC_Caller_Relation__c, VCC_Relation_Type_Other__c, VCC_Caller_Name__c FROM Case LIMIT 1];
            Test.startTest();
            VCC_ProgressNoteDomain progNoteDomain = new VCC_ProgressNoteDomain();
            VCC_Progress_Note__c progNote = progNoteDomain.newProgressNote(
                'progNoteString',
                true,
                false,
                caseSample,
                VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId(),
                'a test facility'
            );
            Test.stopTest();
            Assert.isNotNull(progNote, 'Expected Clinical Triage Progress Note to be created');
        }
    }
}
