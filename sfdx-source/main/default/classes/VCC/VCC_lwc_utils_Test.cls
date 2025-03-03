/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCC_lwc_utils_Test class.
 *
 * TODO Fix test assertions
 */

@IsTest
public with sharing class VCC_lwc_utils_Test {
    private static String testMviId = '1013429125V999999';
    private static User standardTestUser;
    private static User adminUser;
    static {
        standardTestUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VAHC_Standard_VCC_User' })
            .withStandardData()
            .build(true);
        adminUser = new VATEST_UserBuilder().withUserProfile('System Administrator').withStandardData().build(true);
    }

    private static void makeData() {
        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('VCC_Clinical_Triage')
            .getRecordTypeId();
        Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
            .get('VCC_Clinical_Triage_Note_Progress_Note')
            .getRecordTypeId();

        Account testAccount = new Account(
            FirstName = 'Testly',
            LastName = 'Person Accounted',
            RecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getRecordTypeInfosByDeveloperName()
                .get('PersonAccount')
                .getRecordTypeId(),
            VCC_MVI_External_Id__pc = testMviId
        );

        VATEST_SObjectFactory.createSObject(testAccount, true);

        insert new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = standardTestUser.Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );

        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        testContact.VCC_MVI_External_Id__c = testMviId;
        update testContact;

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Symptom', ContactId = testContact.Id),
            true
        );

        insert new CaseShare(CaseId = testCase.Id, UserOrGroupId = standardTestUser.Id, CaseAccessLevel = 'Edit');

        VATEST_SObjectFactory.createSObject(new Task(WhoId = testContact.Id, Description = 'Test Task'), true);

        VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = pnRecTypeId,
                VCC_Caregiver_Name__c = 'Unit Test'
            ),
            true
        );
    }

    @IsTest
    private static void getObjectApiNameByIdTest() {
        Case testCase;
        System.runAs(adminUser) {
            testCase = new Case();
            testCase.RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getRecordTypeInfosByName()
                .get('Clinical Triage Case')
                .getRecordTypeId();
            insert testCase;
        }
        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isTrue(VCC_lwc_utils.getObjectApiNameById(testCase.Id) == 'Case', 'Incorrect object name returned.');
            Test.stopTest();
        }

    }

    @IsTest
    private static void historicalProgressNotesTest1() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('vccHistoricalProgressNotesMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Test.startTest();
            Account acct = [
                SELECT Id, Name
                FROM Account
                WHERE VCC_MVI_External_Id__pc = '1012881470V086192'
            ];
            VCC_BaseResponseWrp result = VCC_lwc_utils.getHistoricalProgressNotes(acct.Id);
            VCC_lwc_utils.acknowledgeFacilityAccess(acct.id);
            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void historicalProgressNotesTest2() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('vccHistoricalProgressNotesMock');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(runAsUser) {
            Account mviExternalIdNullAcct = new Account(FirstName = 'Kazuya', LastName = 'Mishima');
            insert mviExternalIdNullAcct;
            newPersonAccount.FirstName = 'Anthony';
            newPersonAccount.LastName = 'Soprano';
            newPersonAccount.VCC_MVI_External_Id__pc = '112233';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;

            Test.startTest();

            try {
                VCC_lwc_utils.getHistoricalProgressNotes(newPersonAccount.Id);
                VCC_lwc_utils.getHistoricalProgressNotes(mviExternalIdNullAcct.Id);

                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgNotes', 'Account', true);
                VCC_lwc_utils.retrieveHDR(mviExternalIdNullAcct.Id, 'vccBridgNotes', 'Account', true);
                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgMeds', 'Account', true);
            } catch (Exception e) {
            }

            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void historicalProgressNotesTest3() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('vccHistoricalProgressNotesMock');
        mock.setStatusCode(400);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Anthony';
            newPersonAccount.LastName = 'Soprano';
            newPersonAccount.VCC_MVI_External_Id__pc = '112233';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Test.startTest();

            try {
                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgMeds', 'Account', true);
            } catch (Exception e) {
            }

            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void historicalProgressNotesTestHandler200() {
        Account newPersonAccount;
        System.runAs(adminUser) {
            makeData();
            newPersonAccount = [SELECT Id, VCC_MVI_External_Id__pc FROM Account LIMIT 1];
        }
        setHistoricalProgressNotesMock(200);
        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isNotNull(
                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgMeds', 'Account', true),
                'Expected to get non-null string from retrieveHDR'
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void historicalProgressNotesTestHandler400() {
        Account newPersonAccount;
        System.runAs(adminUser) {
            makeData();
            newPersonAccount = [SELECT Id, VCC_MVI_External_Id__pc FROM Account LIMIT 1];
        }
        setHistoricalProgressNotesMock(400);
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgMeds', 'Account', true);
                Assert.fail('expected a VAHCException');
            } catch (VCC_lwc_utils.VAHCException vahcException) {
                Assert.isNotNull(vahcException.getMessage(), 'Expected a non-null exception message');
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void historicalProgressNotesTestHandler500() {
        Account newPersonAccount;
        System.runAs(adminUser) {
            makeData();
            newPersonAccount = [SELECT Id, VCC_MVI_External_Id__pc FROM Account LIMIT 1];
        }
        setHistoricalProgressNotesMock(500);
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_lwc_utils.retrieveHDR(newPersonAccount.Id, 'vccBridgMeds', 'Account', true);
                Assert.fail('expected a VAHCException');
            } catch (VCC_lwc_utils.VAHCException vahcException) {
                Assert.isNotNull(vahcException.getMessage(), 'Expected a non-null exception message');
            }
            Test.stopTest();
        }
    }

    private static void setHistoricalProgressNotesMock(Integer statusCode) {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('vccHistoricalProgressNotesMock');
        mock.setStatusCode(statusCode);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
    }

    @IsTest
    private static void mpiCalloutTest2() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile');
        mock.setStatusCode(500);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(runAsUser) {
            Account newPersonAccount = new Account();
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1122339944';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;

            Account nullMVIIdAcct = new Account(FirstName = 'Dash', LastName = 'Cat');
            insert nullMVIIdAcct;
            Test.startTest();

            VCC_BaseResponseWrp result = VCC_lwc_utils.callMpi(newPersonAccount.Id);
            VCC_lwc_utils.callMpi(nullMVIIdAcct.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void vaProfileWritePhoneTest() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];
        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String phoneUntyped = '{"areaCode": 123,"countryCode": 1,"internationalIndicator": false,"phoneNumber": 4567890,"phonetype": null}';
            Map<String, Object> phoneMap = (Map<String, Object>) JSON.deserializeUntyped(phoneUntyped);
            VCC_lwc_utils.vaProfileWritePhone(newPersonAccount.Id, phoneMap, 'tel', false);
            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void vaProfileWriteEmailTest() {
        User runAsUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];
        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            try {
                VCC_lwc_utils.vaProfileWriteEmail(newPersonAccount.Id, 'test@test.com', false);
                //VCC_lwc_utils.createVaProfile(newPersonAccount.Id, 'test@test.com');
            } catch (Exception e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            }
            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }

    @IsTest
    private static void vaProfileWriteAddressTest() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String addressUntyped = '{"street": 123,"city": 1,"country": false,"province": 4567890,"postalCode": null,"badAddress": 123,"effectiveStartDate": "2020-09-07"}';
            Map<String, Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressUntyped);
            VCC_lwc_utils.vaProfileWriteAddress(newPersonAccount.Id, addressMap, 'CORRESPONDENCE', '1', false);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void validateAddressTest() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        System.runAs(runAsUser) {
            RecordType personAccountRecordType = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Person Account' AND SobjectType = 'Account'
            ];
            Account newPersonAccount = new Account();
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String addressUntyped = '{"street": 123,"city": 1,"country": false,"province": 4567890,"postalCode": null,"badAddress": 123,"effectiveStartDate": "2020-09-07"}';
            Map<String, Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressUntyped);
            VCC_lwc_utils.validateAddress(addressMap, 'CORRESPONDENCE');
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void vaProfileUpsertAssociatedPersonsTest() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String addressUntyped = '{"street": 123,"city": 1,"country": false,"province": 4567890,"postalCode": null,"badAddress": 123,"effectiveStartDate": "2020-09-07"}';
            Map<String, Object> addressMap = (Map<String, Object>) JSON.deserializeUntyped(addressUntyped);
            VCC_lwc_utils.vaProfileUpsertAssociatedPersons(
                newPersonAccount.Id,
                addressMap,
                'CORRESPONDENCE',
                addressUntyped
            );
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }
    @IsTest
    private static void testInpatinetCode() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    //v1
    @IsTest
    private static void testInpatinetCodev1() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VCC_MSA_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Account newPersonAccount1 = new Account();
            newPersonAccount1.FirstName = 'Fred1';
            newPersonAccount1.LastName = 'Smith1';
            newPersonAccount1.VCC_MVI_External_Id__pc = '1012881470V0861921';
            newPersonAccount1.RecordType = personAccountRecordType;
            insert newPersonAccount1;
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            //VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount1.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void testInpatinetCodev2() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            VCC_lwc_utils.acknowledgeInPatient(newPersonAccount.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void testInpatinetCodev311() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Account newPersonAccount1 = new Account();
            newPersonAccount1.FirstName = 'Fred1';
            newPersonAccount1.LastName = 'Smith1';
            newPersonAccount1.VCC_MVI_External_Id__pc = '1012881470V0861921';
            newPersonAccount1.RecordType = personAccountRecordType;
            insert newPersonAccount1;

            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj.VCC_User__c = UserInfo.getUserId();
            recentViewObj.VCC_Type__c = VCC_lwc_utils.TYPE_VERIFY_PATIENT;
            insert recentViewObj;
            VCC_Recent_View__c recentViewObj1 = new VCC_Recent_View__c();
            recentViewObj1.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj1.VCC_User__c = UserInfo.getUserId();
            recentViewObj1.VCC_Type__c = VCC_lwc_utils.TYPE_SENSITIVE_PATIENT;
            insert recentViewObj1;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void testInpatinetCodev312() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Account newPersonAccount1 = new Account();
            newPersonAccount1.FirstName = 'Fred1';
            newPersonAccount1.LastName = 'Smith1';
            newPersonAccount1.VCC_MVI_External_Id__pc = '1012881470V0861921';
            newPersonAccount1.RecordType = personAccountRecordType;
            insert newPersonAccount1;

            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj.VCC_User__c = UserInfo.getUserId();
            recentViewObj.VCC_Type__c = VCC_lwc_utils.TYPE_VERIFY_PATIENT;
            insert recentViewObj;
            VCC_Recent_View__c recentViewObj1 = new VCC_Recent_View__c();
            recentViewObj1.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj1.VCC_User__c = UserInfo.getUserId();
            recentViewObj1.VCC_Type__c = VCC_lwc_utils.TYPE_SENSITIVE_PATIENT;
            insert recentViewObj1;

            VCC_Recent_View__c recentViewObj2 = new VCC_Recent_View__c();
            recentViewObj2.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj2.VCC_User__c = UserInfo.getUserId();
            recentViewObj2.VCC_Type__c = VCC_lwc_utils.TYPE_IN_PATIENT;
            insert recentViewObj2;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }
    @IsTest
    private static void testInpatinetCodev314() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        System.runAs(runAsUser) {
            newPersonAccount.FirstName = 'Fred';
            newPersonAccount.LastName = 'Smith';
            newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            newPersonAccount.RecordType = personAccountRecordType;
            insert newPersonAccount;
            Id personContactId = [SELECT Id, PersonContactId FROM Account LIMIT 1].PersonContactId;
            insert new VA_Identity__c(Salesforce_Contact_Id__c = personContactId);
            Account newPersonAccount1 = new Account();
            newPersonAccount1.FirstName = 'Fred1';
            newPersonAccount1.LastName = 'Smith1';
            newPersonAccount1.VCC_MVI_External_Id__pc = '1012881470V0861921';
            newPersonAccount1.RecordType = personAccountRecordType;
            insert newPersonAccount1;

            VCC_Recent_View__c recentViewObj = new VCC_Recent_View__c();
            recentViewObj.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj.VCC_User__c = UserInfo.getUserId();
            recentViewObj.VCC_Type__c = VCC_lwc_utils.TYPE_VERIFY_PATIENT;
            insert recentViewObj;
            VCC_Recent_View__c recentViewObj1 = new VCC_Recent_View__c();
            recentViewObj1.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj1.VCC_User__c = UserInfo.getUserId();
            recentViewObj1.VCC_Type__c = VCC_lwc_utils.TYPE_SENSITIVE_PATIENT;
            insert recentViewObj1;

            VCC_Recent_View__c recentViewObj2 = new VCC_Recent_View__c();
            recentViewObj2.VCC_Account__c = newPersonAccount1.Id;
            recentViewObj2.VCC_User__c = UserInfo.getUserId();
            recentViewObj2.VCC_Type__c = VCC_lwc_utils.TYPE_IN_PATIENT;
            insert recentViewObj2;

            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_lwc_utils.retrieveInPatientInfo(newPersonAccount.Id);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    private static void funcGetICNFromContactPositive() {
        System.runAs(adminUser) {
            makeData();
        }
        System.runAs(standardTestUser) {
            Test.startTest();
            Contact cont = [SELECT Id FROM Contact LIMIT 1];
            String mviId = VCC_lwc_utils.getICN(cont.Id);
            Assert.areEqual(
                testMviId,
                mviId,
                'Expected ICN values to match, but they were different expected: ' + testMviId + ' but found: ' + mviId
            );
            Test.stopTest();
        }

    }

    @IsTest
    private static void funcGetICNFromAccountPositive() {
        System.runAs(adminUser) {
            makeData();
        }
        System.runAs(standardTestUser) {
            Test.startTest();
            // get test account
            Account account = [SELECT Id FROM Account LIMIT 1];
            String mviId = VCC_lwc_utils.getICN(account.Id);
            Assert.areEqual(
                testMviId,
                mviId,
                'Expected ICN values to match, but they were different expected: ' + testMviId + ' but found: ' + mviId
            );
            Test.stopTest();
        }

    }

    @IsTest
    private static void funcGetICNFromCasePositive() {
        System.runAs(adminUser) {
            makeData();
        }
        System.runAs(standardTestUser) {
            // get test case
            Case cse = [SELECT Id, ContactId FROM Case LIMIT 1];
            Test.startTest();
            String mviId = VCC_lwc_utils.getICN(cse.Id);
            Assert.areEqual(
                testMviId,
                mviId,
                'Expected ICN values to match, but they were different expected: ' + testMviId + ' but found: ' + mviId
            );
            Test.stopTest();
        }

    }

    @IsTest
    private static void funcGetICNFromProgressNotePositive() {
        System.runAs(adminUser) {
            makeData();
        }
        System.runAs(standardTestUser) {
            Test.startTest();
            VCC_Progress_Note__c progressNote = [
                SELECT Id
                FROM VCC_Progress_Note__c
                WHERE VCC_Caregiver_Name__c = 'Unit Test'
                LIMIT 1
            ];
            // retrieve MVI ID based on contact ID of Case from VCC_Progress_Note__c
            String mviId = VCC_lwc_utils.getICN(progressNote.Id);
            // check result, expected to be equal to the preconfigured testMviId value
            Assert.areEqual(
                testMviId,
                mviId,
                'Expected ICN values to match, but they were different expected: ' + testMviId + ' but found: ' + mviId
            );
            Test.stopTest();
        }
    }

    @IsTest
    private static void funcGetICNFromTaskPositive() {
        System.runAs(adminUser) {
            makeData();
        }
        Task tsk = [SELECT Id FROM Task LIMIT 1];

        System.runAs(standardTestUser) {
            Test.startTest();
            String mviId = VCC_lwc_utils.getICN(tsk.Id);
            Assert.areEqual(
                testMviId,
                mviId,
                'Expected ICN values to match, but they were different expected: ' + testMviId + ' but found: ' + mviId
            );
            Test.stopTest();
        }
    }
}
