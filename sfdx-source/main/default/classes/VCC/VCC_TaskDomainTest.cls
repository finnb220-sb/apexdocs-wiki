@IsTest
public with sharing class VCC_TaskDomainTest {
    @IsTest
    private static void createFutureRenewalTaskFromCase() {
        // Create a test Case
        Case testCase = new Case();
        testCase.Subject = 'Test Case';
        testCase.Status = 'New';
        testCase.Origin = 'Phone';
        insert testCase;

        // Create a test Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'John';
        testContact.LastName = 'Doe';
        insert testContact;

        // Set up test data for parameters
        String facilityName = 'Test Facility';
        String facilityData = 'Test Data';
        Date renewalDate = Date.today();
        Id taskRTId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy_FRR').getRecordTypeId();
        Id visnId = UserInfo.getUserId();

        // Call the method to be tested
        Test.startTest();
        Task createdTask = new VCC_TaskDomain().createFutureRenewalTaskFromCase(testCase, facilityName, facilityData, renewalDate, taskRTId, visnId, 'VISN 8');
        Test.stopTest();

        // Verify that the task is created with the correct data
        System.assertEquals(facilityName + ' - Pharmacy Future Renewal Request', createdTask.Subject, 'Expected subjects to match.');
        System.assertEquals(renewalDate, createdTask.ActivityDate, 'Expected Activity Date to match.');
        System.assertEquals(facilityData, createdTask.Description, 'Expected Description to match.');
        System.assertEquals(testCase.Id, createdTask.WhatId, 'Expected WhatId to match.');
        System.assertEquals(testCase.ContactId, createdTask.WhoId, 'Expected WhoId to match.');
        System.assertEquals(taskRTId, createdTask.RecordTypeId, 'Expected RecordTypeId to match.');
        System.assertEquals(visnId, createdTask.OwnerId, 'Expected OwnerId to match.');
    }
}
