@isTest
public with sharing class VCC_TriageControllerTest {
    private static String username = 'tcTest';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testUser);
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void getVitalsTest() {
        Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId());
        insert c;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage_Note_Progress_Note').getRecordTypeId(),
            VCC_Systolic_Blood_Pressure__c = 123,
            VCC_Gender__c = 'F',
            VCC_Case__c = c.id
        );
        insert pn;

        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c vit = VCC_TriageController.getVitals(pn.Id)[0];
            System.assert(vit.VCC_Systolic_Blood_Pressure__c == 123, 'Expected 123');
        }
        Test.stopTest();
    }

    @IsTest
    static void getTriageStatusTestCondition1() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case c = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                OwnerId = getTestUser().Id
            );
            insert c;
            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Triage_Complete__c = true, VCC_Signed__c = false, VCC_Case__c = c.Id);
            insert pn;
            VCC_TriageController.TriageStatus ts = VCC_TriageController.getTriageStatus(pn.Id);
            System.assert(ts.isStartable == false, 'Expected false.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getTriageStatusTestCondition2() {
        Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId());
        insert c;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Triage_Complete__c = true, VCC_Signed__c = false, VCC_Case__c = c.Id);
        insert pn;

        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_TriageController.TriageStatus ts = VCC_TriageController.getTriageStatus(pn.Id);
            System.assert(ts.isStartable == false, 'Expected false.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getTriageStatusTestCondition3() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case c = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                OwnerId = getTestUser().Id
            );
            insert c;
            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Triage_Complete__c = false, VCC_Signed__c = true, VCC_Case__c = c.Id);
            insert pn;
            VCC_TriageController.TriageStatus ts = VCC_TriageController.getTriageStatus(pn.Id);
            System.assert(ts.isStartable == false, 'Expected false.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getTriageStatusTestCondition4() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case ca = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                OwnerId = getTestUser().Id
            );
            insert ca;
            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Triage_Complete__c = false, VCC_Signed__c = false, VCC_Case__c = ca.Id, VCC_Relative_Type__c = 'Self');
            insert pn;
            pn.VCC_Date_of_Birth__c = Date.newInstance(1994, 10, 10);
            update pn;
            VCC_TriageController.TriageStatus ts = VCC_TriageController.getTriageStatus(pn.Id);
            System.assert(ts.isStartable == true, 'Expected true.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getTriageStatusTestConditionException() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Case c = new Case(
                RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
                OwnerId = getTestUser().Id
            );
            insert c;
            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Triage_Complete__c = false, VCC_Signed__c = false, VCC_Case__c = c.Id, VCC_Relative_Type__c = 'Self');
            insert pn;
            VCC_TriageController.TriageStatus ts = VCC_TriageController.getTriageStatus(pn.Id);
            Assert.isNotNull(ts.isNotStartableReason, 'Exception true');
        }
        Test.stopTest();
    }
}
