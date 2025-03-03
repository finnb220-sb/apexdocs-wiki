/**
 * @author Booz Allen
 * @date 12/2024
 * @description Test Class for the VCC_ProgressNoteServiceTest methods
 */
@isTest
public with sharing class VCC_ProgressNoteServiceTest {
    /**
     * @description creates test data including user, case, and progress note for testing
     */
    @TestSetup
    static void makeData() {
        User testUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VAHC_Standard_VCC_User', 'VAHC_Write_Clinical_Triage_Progress_Note' })
            .withStandardData()
            .build(true);

        System.runAs(testUser) {
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage').Id
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c(
                    VCC_Case__c = testCase.Id,
                    RecordTypeId = new VCR_ProgressNoteRepo()
                        .recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage_Note_Progress_Note')
                        .Id
                ),
                true
            );
        }
    }

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [
            SELECT Id, Title
            FROM User
            WHERE Email LIKE 'Testuser@test.example.com%'
            LIMIT 1
        ];
    }

    /**
     * @description test retrieving the progress note layout positive
     */
    @isTest
    public static void funcGetLayoutByNamePositive() {
        System.runAs(getTestUser()) {
            Metadata.Layout layout;
            Test.startTest();
            layout = VCC_ProgressNoteService.getLayoutByName('VCC Virtual Visit Progress Note');
            Test.stopTest();

            Assert.isNotNull(layout, 'Expected Metadata.Layout, got null');
        }
    }

    /**
     * @description test retrieving config when record type id is not present positive
     */
    @isTest
    public static void funcGetConfigWithoutRecordTypeIdTestPositive() {
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c progressNote = [
                SELECT Id
                FROM VCC_Progress_Note__c
                LIMIT 1
            ];

            VCC_Progress_Note_Configuration__mdt config;
            Test.startTest();
            config = VCC_ProgressNoteService.getConfig(progressNote);
            Test.stopTest();

            Assert.isNotNull(config, 'Expected VCC_Progress_Note_Configuration__mdt, got null');
        }
    }

    /**
     * @description test retrieving config when record type id is present positive
     */
    @isTest
    public static void funcGetConfigWithRecordTypeIdTestPositive() {
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c progressNote = [
                SELECT Id, RecordTypeId
                FROM VCC_Progress_Note__c
                LIMIT 1
            ];

            VCC_Progress_Note_Configuration__mdt config;
            Test.startTest();
            config = VCC_ProgressNoteService.getConfig(progressNote);
            Test.stopTest();

            Assert.isNotNull(config, 'Expected VCC_Progress_Note_Configuration__mdt, got null');
        }
    }

    /**
     * @description test creating a progress note positive
     */
    @IsTest
    static void funcCreateProgressNotePositive() {
        PermissionSetGroup psgTierI = [
            SELECT Id, Status
            FROM PermissionSetGroup
            WHERE DeveloperName = 'VCC_Pharmacy_I'
        ];
        if (psgTierI.Status != 'Updated') {
            Test.calculatePermissionSetGroup(psgTierI.Id);
        }

        User frrUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(
                new Set<String>{ 'VCC_Pharmacy_I', 'VAHC_Access_Future_Renewal_Request', 'HealthCloudFoundation' }
            )
            .withStandardData()
            .build(true);

        System.runAs(frrUser) {
            Test.startTest();
            String testMviId = '1013429125V999999';
            // create and insert a new account, which also creates a contact
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id,
                    VCC_MVI_External_Id__pc = testMviId
                ),
                true
            );
            Contact testContact = new VCR_ContactRepo().getContactFromAccountId(testAccount.Id)[0];

            //Create a Pharmacy Case
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id,
                    VCC_Case_Type__c = 'Pharmacy',
                    ContactId = testContact.Id,
                    Status = 'Pending Future Renewal Request',
                    VCC_Case_Sub_Type__c = 'Pharmacy',
                    VCC_Case_Reason_Multi__c = 'Medication Refill',
                    VCC_Case_Outcome__c = 'Pharmacist Resolved'
                ),
                true
            );

            Task tsk = (Task) VATEST_SObjectFactory.createSObject(
                new Task(
                    Subject = 'Test',
                    Description = 'test',
                    WhatId = testCase.Id,
                    WhoId = testCase.ContactId,
                    RecordTypeId = new VCR_TaskRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy_FRR').Id,
                    VISN__c = 'VISN 8'
                ),
                true
            );

            String pnString = 'test';
            Boolean controlled = false;
            Boolean nonControlled = true;
            String recordId = tsk.Id;
            String newDescription = 'test';
            VCC_Progress_Note__c progressNote = new VCC_ProgressNoteService()
                .createProgressNote(pnString, controlled, nonControlled, recordId, newDescription, 'a test facility');
            Assert.isNotNull(progressNote, 'There was a problem creating a progress note');
            Test.stopTest();
        }
    }
}
