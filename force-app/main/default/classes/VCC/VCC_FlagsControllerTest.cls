/**
 * @author Booz Allen Hamilton
 * @description Test class for `VCC_FlagsController`
 * @see `VCC_FlagsController`
 */

@IsTest
private with sharing class VCC_FlagsControllerTest {
    private static final User RN_USER;
    private static final Set<String> CONTACT_FIELDS;
    private static final Set<String> CASE_FIELDS;
    private static final Set<String> PROGRESS_NOTE_FIELDS;
    private static final Set<String> ACCOUNT_FIELDS;
    private static VCC_Progress_Note__c progressNote;
    private static Case caseRecord;
    private static Account accountRecord;
    private static Account accountRecord2;

    static {
        RN_USER = new VATEST_UserBuilder()
            .withPermissionSets(
                new Set<String>{
                    'HealthCloudFoundation',
                    'VCC_Registered_Nurse',
                    'VAHC_RN_User',
                    'VAHC_Write_Clinical_Triage_Progress_Note',
                    'VAHC_Standard_VCC_User'
                }
            )
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        CONTACT_FIELDS = new Set<String>{ 'AccountId', 'VCC_Emergency_Contact__c', 'VCC_Emergency_Contact_Phone__c' };
        CASE_FIELDS = new Set<String>{ 'VCC_Call_back_phone_number__c', 'ContactId' };
        PROGRESS_NOTE_FIELDS = new Set<String>{
            'VCC_Date_of_Birth__c',
            'VCC_Patient_Age__c',
            'VCC_Gender__c',
            'VCC_Current_Location__c',
            'VCC_Case__c'
        };
        ACCOUNT_FIELDS = new Set<String>{ 'VCC_Gender_Identity__c' };
    }

    /**
     * @description Creates test data including Account, Case, and Progress Note records.
     */
    private static void makeData() {
        Id personAccountRecTypeId = new VCR_AccountRepo()
            .recordTypeConstant.developerNameToRecordType.get('PersonAccount')
            .Id;
        // Create test Account
        accountRecord = new Account();
        accountRecord.FirstName = 'Test Account First';
        accountRecord.LastName = 'Last Name';
        accountRecord.put('VCC_Gender_Identity__c', 'Female');
        accountRecord.RecordTypeId = personAccountRecTypeId;
        Assert.isNotNull(RN_USER, 'RN_USER was not created');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(accountRecord, true);
        }
        // Create second test Account
        accountRecord2 = new Account();
        accountRecord2.FirstName = 'Test Account 2 First';
        accountRecord2.LastName = 'Last Name ' + System.now();
        accountRecord2.put('VCC_Gender_Identity__c', 'Female');
        accountRecord2.RecordTypeId = personAccountRecTypeId;
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(accountRecord2, true);
        }
        // Create test Case
        caseRecord = new Case();
        caseRecord.ContactId = accountRecord.PersonContactId;
        caseRecord.Subject = 'Test Case';
        caseRecord.put('VCC_Call_back_phone_number__c', '123-456-7890');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(caseRecord, true);
        }

        // Create test Progress Note
        progressNote = new VCC_Progress_Note__c();
        progressNote.VCC_Case__c = caseRecord.Id;
        progressNote.put('VCC_Date_of_Birth__c', Date.newInstance(1990, 1, 1));
        progressNote.put('VCC_Gender__c', 'M');
        progressNote.put('VCC_Current_Location__c', 'Test Location');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(progressNote, true);
        }
    }

    @IsTest
    private static void funcAcknowledgeAndGetFlagsDifferentEnvsPositive() {
        makeData();
        System.runAs(RN_USER) {
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];
            VCC_FlagsController.acknowledgeFlag(accounts[1].Id);
            VCC_FlagsController.acknowledgeFlag(accounts[0].Id);
            Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
            Test.startTest();
            VCC_FlagLightningRequestWrp flagReqWrp = new VCC_FlagLightningRequestWrp();
            flagReqWrp.recordId = accounts[0].Id;
            flagReqWrp.facility = '613';
            flagReqWrp.startDate = '1950-01-01';
            flagReqWrp.endDate = '2050-01-01';
            VCC_FlagService.enviornment = 'PROD';
            VCC_FlagResponseWrp flagResWrp = VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp.statusCode,
                'Expected a different value than 202 from getFlags() but observed them to be the same'
            );

            VCC_FlagService.enviornment = 'TEST';
            flagResWrp = VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp.statusCode,
                'Expected a different value than 202 from getFlags() after changing environment to TEST but observed them to be the same'
            );

            Test.stopTest();
        }
    }

    @IsTest
    private static void funcGetFlagsForMostRecentViewAcctPositive() {
        makeData();
        System.runAs(RN_USER) {
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];
            Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = accounts[0].Id;
            recentViewObj.VCC_User__c = RN_USER.Id;
            insert recentViewObj;
            Test.startTest();
            VCC_FlagLightningRequestWrp flagReqWrp = new VCC_FlagLightningRequestWrp();

            flagReqWrp = new VCC_FlagLightningRequestWrp();
            flagReqWrp.recordId = accounts[1].Id;
            flagReqWrp.facility = '613';
            flagReqWrp.startDate = '1950-01-01';
            flagReqWrp.endDate = '2050-01-01';
            VCC_FlagService.enviornment = 'PROD';
            VCC_FlagResponseWrp flagResWrp1 = VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp1.statusCode,
                'Expected a different value than 202 from getFlags() for PROD but observed them to be the same'
            );
            Test.stopTest();
        }
    }
    @IsTest
    private static void funcGetFlagsForChangeToRecentViewAcctWithoutGetFlagStatusPositive() {
        makeData();
        System.runAs(RN_USER) {
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];
            Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = accounts[1].Id;
            recentViewObj.VCC_Type__c = 'Flags';
            recentViewObj.VCC_User__c = RN_USER.Id;
            insert recentViewObj;
            Test.startTest();
            VCC_FlagLightningRequestWrp flagReqWrp = new VCC_FlagLightningRequestWrp();

            flagReqWrp = new VCC_FlagLightningRequestWrp();
            flagReqWrp.recordId = accounts[0].Id;
            flagReqWrp.facility = '613';
            flagReqWrp.startDate = '1950-01-01';
            flagReqWrp.endDate = '2050-01-01';
            VCC_FlagService.enviornment = 'PROD';
            VCC_FlagResponseWrp flagResWrp1 = VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp1.statusCode,
                'Expected a different value than 202 from getFlags() for PROD but observed them to be the same'
            );

            Test.stopTest();
        }
    }
    @IsTest
    private static void funcGetFlagsForChangeToRecentViewAcctPositive() {
        makeData();
        System.runAs(RN_USER) {
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];
            Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = accounts[1].Id;
            recentViewObj.VCC_Type__c = 'Flags';
            recentViewObj.VCC_User__c = UserInfo.getUserId();
            insert recentViewObj;
            Test.startTest();
            VCC_FlagLightningRequestWrp flagReqWrp = new VCC_FlagLightningRequestWrp();

            flagReqWrp = new VCC_FlagLightningRequestWrp();
            flagReqWrp.recordId = accounts[0].Id;
            flagReqWrp.facility = '613';
            flagReqWrp.startDate = '1950-01-01';
            flagReqWrp.endDate = '2050-01-01';
            VCC_FlagService.enviornment = 'PROD';
            VCC_FlagsController.getFlagStatus(new List<String>{ accounts[0].Id });

            VCC_FlagResponseWrp flagResWrp = new VCC_FlagResponseWrp();
            flagResWrp = VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp.statusCode,
                'Expected a different value than 202 from getFlags() but observed them to be the same'
            );

            Test.stopTest();
        }
    }
    @IsTest
    private static void funcGetFlagsForChangeToRecentViewAcctWithRelatedDataPositive() {
        makeData();
        System.runAs(RN_USER) {
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];

            Case testCase = new Case(
                AccountId = accounts[0].Id,
                RecordTypeId = new VCR_CaseRepo()
                    .recordTypeConstant.developerNameToRecordType.get('VCC_Clinical_Triage')
                    .Id
            );
            insert testCase;
            insert new VCC_Progress_Note__c(
                VCC_Additional_Comments__c = 'Some additional comment.',
                VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
                VCC_Case__c = testCase.Id,
                RecordTypeId = new VCR_ProgressNoteRepo()
                    .recordTypeConstant.developerNameToRecordType.get('VCC_Clinical_Triage_Note_Progress_Note')
                    .Id
            );

            Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = accounts[1].Id;
            recentViewObj.VCC_Type__c = 'Flags';
            recentViewObj.VCC_User__c = UserInfo.getUserId();
            insert recentViewObj;
            Test.startTest();
            VCC_FlagLightningRequestWrp flagReqWrp = new VCC_FlagLightningRequestWrp();

            flagReqWrp = new VCC_FlagLightningRequestWrp();
            flagReqWrp.recordId = accounts[0].Id;
            flagReqWrp.facility = '613';
            flagReqWrp.startDate = '1950-01-01';
            flagReqWrp.endDate = '2050-01-01';
            VCC_FlagService.enviornment = 'PROD';
            VCC_FlagsController.getFlagStatus(new List<String>{ testCase.Id });

            VCC_FlagResponseWrp flagResWrp = new VCC_FlagResponseWrp();
            VCC_FlagsController.getFlags(flagReqWrp);
            Assert.areNotEqual(
                202,
                flagResWrp.statusCode,
                'Expected a different value than 202 from getFlags() but observed them to be the same'
            );

            Test.stopTest();
        }
    }
    @IsTest
    private static void funcGetFlagsByAccountIdFromTrainingServicePositive() {
        makeData();
        System.runAs(RN_USER) {
            Test.startTest();
            List<Account> accounts = [
                SELECT Id
                FROM Account
                LIMIT 2
            ];

            Case testCase = new Case(
                AccountId = accounts[0].Id,
                RecordTypeId = new VCR_CaseRepo()
                    .recordTypeConstant.developerNameToRecordType.get('VCC_Clinical_Triage')
                    .Id
            );
            insert testCase;
            insert new VCC_Progress_Note__c(
                VCC_Additional_Comments__c = 'Some additional comment.',
                VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
                VCC_Case__c = testCase.Id,
                RecordTypeId = new VCR_ProgressNoteRepo()
                    .recordTypeConstant.developerNameToRecordType.get('VCC_Clinical_Triage_Note_Progress_Note')
                    .Id
            );
            String recordId = accounts[0].Id;
            String responseBody = '';
            responseBody = VCC_TrainingModeService.getFlagsByAccountId(recordId);
            Integer responseCode = 0;
            responseCode = 200;
            Assert.areEqual(
                200,
                responseCode,
                'Expected a successful HTTP status code for getFlagsByAccountId() but observed a different value'
            );
            Test.stopTest();
        }
    }
}
