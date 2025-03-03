@IsTest
public with sharing class VCC_AddendumRelatedListControllerTest {
    private static String testMviId = '1013429125V999999';

    @TestSetup
    private static void makeData() {
        // get the record type id for Person Accounts
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        // create and insert a new account, which also creates a contact
        Account a = new Account(FirstName = 'Testly', LastName = 'Person Accounted', RecordTypeId = rtId, VCC_MVI_External_Id__pc = testMviId);
        insert a;

        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId();
        Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Tier_III_Progress_Note').getRecordTypeId();
        //Retreive contact created in testSetup to update the MVI External Id
        Contact con = [SELECT Id, VCC_MVI_External_Id__c FROM Contact LIMIT 1];
        //Set External Id to static variable
        con.VCC_MVI_External_Id__c = testMviId;
        update con;
        //Create Pharmacy Case
        Case c1 = new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Pharmacy', ContactId = con.Id, Description = 'First');
        insert c1;
        //Create Pharmacy Progress Note
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c1.Id, RecordTypeId = pnRecTypeId);
        insert pn;
        //Addendums
        List<VCC_Addendum__c> addendumList = new List<VCC_Addendum__c>();
        Integer count = 0;
        for (Integer i = 0; i < 6; i++) {
            VCC_Addendum__c addendum = new VCC_Addendum__c(VCC_Related_Note__c = pn.Id, VCC_Addendum__c = 'Test text' + String.valueOf(count));
            addendumList.add(addendum);
            count++;
        }
        insert addendumList;

        Id caseRecTypeId2 = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId();
        //Create Other Pharmacy Case
        Case c2 = new Case(RecordTypeId = caseRecTypeId2, VCC_Case_Type__c = 'Symptom', ContactId = con.Id, Description = 'No Progress Notes, No Addendums');
        insert c2;
    }

    @IsTest
    private static void requestDataFromCaseWithAddendums_Success() {
        User u = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', u);
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');

        Case c = [SELECT Id FROM Case WHERE VCC_Case_Type__c = 'Pharmacy' LIMIT 1];

        List<VCC_Addendum__c> addendums = new List<VCC_Addendum__c>();
        Exception caughtException;

        Test.startTest();
        System.runAs(u) {
            try {
                addendums = VCC_AddendumRelatedListController.getRelatedAddendums(c.Id);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }
        }
        Test.stopTest();

        System.debug('results size: ' + addendums.size());

        System.assert(caughtException == null, 'An exception was thrown.');
        System.assert(addendums != null, 'Data not returned as expected.');
        System.assert(addendums.size() == 6, 'Expected 6 results.');
    }

    @IsTest
    private static void requestDataFromCaseWithNoAddendums_Success() {
        User u = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', u);
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');

        Case c = [SELECT Id FROM Case WHERE VCC_Case_Type__c = 'Symptom' LIMIT 1];

        List<VCC_Addendum__c> addendums = new List<VCC_Addendum__c>();
        Exception caughtException;

        Test.startTest();
        System.runAs(u) {
            try {
                addendums = VCC_AddendumRelatedListController.getRelatedAddendums(c.Id);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }
        }
        Test.stopTest();

        System.debug('results size: ' + addendums.size());

        System.assert(caughtException == null, 'An exception was thrown.');
        System.assert(addendums != null, 'Data not returned as expected.');
        System.assert(addendums.size() == 0, 'Expected no results.');
    }

    @IsTest
    private static void requestDataUsingBadId_Failure() {
        User u = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', u);
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');

        Case c = [SELECT Id FROM Case LIMIT 1];

        List<VCC_Addendum__c> addendums = new List<VCC_Addendum__c>();
        Exception caughtException;

        Test.startTest();
        System.runAs(u) {
            try {
                addendums = VCC_AddendumRelatedListController.getRelatedAddendums('badId');
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }
        }
        Test.stopTest();

        System.debug('results size: ' + addendums.size());

        System.assert(caughtException != null, 'An exception was not thrown.');
        System.assert(addendums.size() < 1, 'Results returned.');
    }

    @IsTest
    private static void requestDataUsingIncorrectUserAccess_Failure() {
        User u = VCC_TestDataFactory.insertUser('Standard User');

        Case c = [SELECT Id FROM Case WHERE VCC_Case_Type__c = 'Pharmacy' LIMIT 1];

        List<VCC_Addendum__c> addendums = new List<VCC_Addendum__c>();
        Exception caughtException;

        Test.startTest();
        System.runAs(u) {
            try {
                addendums = VCC_AddendumRelatedListController.getRelatedAddendums(c.Id);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }
        }
        Test.stopTest();

        System.debug('results size: ' + addendums.size());

        System.assert(caughtException != null, 'An exception was not thrown.');
        System.assert(addendums.size() < 1, 'Results returned.');
    }
}
