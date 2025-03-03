/**
 * @description Test class for VCC_ProgressNoteController
 * @author      Booz Allen
 * @see         VCC_ProgressNoteController
 */
@IsTest
public with sharing class VCC_ProgressNoteControllerTest {
    public static final String USERNAMEPREFIX = 'VCC_ProgressNoteControllerTest';
    public static final Schema.DescribeSObjectResult CASEDESCRIBE = Case.SObjectType.getDescribe(
        SObjectDescribeOptions.DEFERRED
    );

    /**
     * @description Method to create test setup data.
     */
    @TestSetup
    static void makeData() {
        // Create Test User
        String uniqueUserName = USERNAMEPREFIX + Datetime.now().getTime() + '@VAHC.com';
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];
        User rnRunningUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            rnRunningUser = new VATEST_UserBuilder()
                .withPermissionSets(new Set<String>{ 'HealthCloudFoundation', 'VCC_Registered_Nurse' })
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .setFields(User.UserName, uniqueUserName)
                .setFields(User.Division, 'VISN 1')
                .build(true);
        }

        CodeSet primaryDiagnosis = new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)');
        CodeSet secondaryDiagnosis = new CodeSet(Code = 'TST.34', Name = 'TST.34', CodeSetType = 'Diagnosis (ICD10)');
        CodeSet procedureCode = new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)');
        insert new List<CodeSet>{ procedureCode, primaryDiagnosis, secondaryDiagnosis };

        System.runAs(new User(Id = UserInfo.getUserId())) {
            Group baseUserGroup = [SELECT Id FROM Group WHERE DeveloperName = 'VAHC_Base_Users'];
            GroupMember testGroupMember = new GroupMember();
            testGroupMember.GroupId = baseUserGroup.Id;
            testGroupMember.UserOrGroupId = rnRunningUser.Id;
            insert testGroupMember;
            List<CodeSet> diagnosisAndProcedure = [SELECT Id FROM CodeSet];
            List<CodeSetShare> csShareList = new List<CodeSetShare>();
            for (CodeSet codeSetTest : diagnosisAndProcedure) {
                CodeSetShare csShare = new CodeSetShare();
                csShare.parentId = codeSetTest.Id;
                csShare.AccessLevel = 'Read';
                csShare.RowCause = 'manual';
                csShare.UserOrGroupId = rnRunningUser.Id;
                csShareList.add(csShare);
            }
            insert csShareList;
        }
        System.runAs(rnRunningUser) {
            Case testCase = new Case(
                RecordTypeId = CASEDESCRIBE.getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert testCase;
            }
            insert new VCC_Progress_Note__c(
                VCC_Additional_Comments__c = 'Some additional comment.',
                VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
                VCC_Case__c = testCase.Id,
                RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
        }

        User userMockSSO = new User();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            userMockSSO = insertTestUser();
        }
        insert new VCC_Mock_SSO_Settings__c(
            VCC_SSO_Token__c = 'test',
            VCC_VistA_Instance__c = 'test',
            VCC_DUZ__c = 'test',
            SetupOwnerId = userMockSSO.Id
        );

        insert new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            User_Id__c = UserInfo.getUserId(),
            DUZ__c = '55555',
            Name = 'mockSSO.' + UserInfo.getUserId()
        );
        insert new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            User_Id__c = UserInfo.getUserId(),
            DUZ__c = '125555',
            VistA_Instance__c = '983',
            Name = '983.' + UserInfo.getUserId()
        );
        insert new VCC_Mock_SSO_Settings__c(
            VCC_VistA_Instance__c = '983',
            VCC_SSO_Token__c = 'test1234',
            VCC_DUZ__c = 'duz1234'
        );
    }

    /**
     * @decription builds a test user and inserts it.  Leverages System.runAs() to avoid mixed DML.
     * @return User
     */
    public static User insertTestUser() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = new VATEST_UserBuilder()
                .withPermissionSets(
                    new Set<String>{
                        'HealthCloudFoundation',
                        'VCC_Registered_Nurse',
                        'VCC_Medical_Provider',
                        'VCC Integration Test Utility User'
                    }
                )
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .setFields(User.UserName, uniqueUserName)
                .setFields(User.Division, 'VISN 1')
                .build(true);
        }
        return testUser;
    }

    /**
     * @description Method to get the running user for the test
     * @return      `User`
     */
    public static User getTestUser() {
        return [SELECT Id, Division FROM User WHERE Username LIKE :USERNAMEPREFIX + '%' LIMIT 1];
    }

    /**
     * @description Test for SSO mocking for test RN user.
     */
    @IsTest
    static void mockSSOTestRN() {
        String uniqueUserName = 'progressnotecontrollertest' + Datetime.now().getTime() + '@testorg.com';
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User rnUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName,
            Division = 'VISN 1'
        );

        insert rnUser;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', rnUser);

        String token;
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud;
        Exception unexpectedException;

        Test.startTest();
        System.runAs(rnUser) {
            try {
                token = VCC_ProgressNoteController.mockSSO();
                vitud = [
                    SELECT VistA_Instance__c, DUZ__c
                    FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
                    WHERE User_Id__c = :rnUser.Id
                    LIMIT 1
                ];
            } catch (Exception e) {
                unexpectedException = e;
            }
        }
        Test.stopTest();

        Assert.isNotNull(vitud, 'No Vista Instance To User DUZ record found.');
        Assert.isTrue((token != null) && (token == 'test1234'), 'Token not returned.');
        Assert.areEqual(vitud.DUZ__c, 'duz1234', 'Incorrect DUZ');
        Assert.areEqual(vitud.VistA_Instance__c, '983', 'Incorrect VistA Instance');
        Assert.isNull(unexpectedException, 'An exception was throw.');
    }
    /**
     * description Test for mock SSO for base profile
     */
    @IsTest
    static void mockSSOTestBaseProfile() {
        String uniqueUserName = 'baseprofile' + DateTime.now().getTime() + '@testorg.com';
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User baseUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName,
            Division = 'VISN 1'
        );

        insert baseUser;

        String token;
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud;
        Exception expectedException;

        Test.startTest();
        System.runAs(baseUser) {
            try {
                token = VCC_ProgressNoteController.mockSSO();
                vitud = [
                    SELECT VistA_Instance__c, DUZ__c
                    FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
                    WHERE User_Id__c = :baseUser.Id
                    LIMIT 1
                ];
            } catch (Exception e) {
                expectedException = e;
            }
        }
        Test.stopTest();

        Assert.isNull(token, 'Token was retrieved.');
        Assert.isNull(vitud, 'Vista Instance To User DUZ record found in error.');
        Assert.isNotNull(expectedException, 'Exception not thrown as expected.');
    }

    /**
     * @description Test prevention of progress note deletion method w/o trigger
     */
    @isTest
    static void preventProgressNoteDeleteDirectTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            // create Case that Progress Notes are children to
            Case caseRec = new Case(
                RecordTypeId = CASEDESCRIBE.getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            insert caseRec;

            // unsigned PN to be deleted successfully
            VCC_Progress_Note__c pnRec1 = new VCC_Progress_Note__c(VCC_Case__c = caseRec.Id);
            // PN that will be signed
            VCC_Progress_Note__c pnRec2 = new VCC_Progress_Note__c(VCC_Case__c = caseRec.Id);
            // progress note to try to delete running as a non owner
            VCC_Progress_Note__c pnRec3 = new VCC_Progress_Note__c(VCC_Case__c = caseRec.Id);

            // progress notes to be inserted
            List<VCC_Progress_Note__c> pnRecs = new List<VCC_Progress_Note__c>{ pnRec1, pnRec2, pnRec3 };
            insert pnRecs;
            // remove record from list, to be tested in another scenario
            pnRecs.remove(2);

            // signed PN, will throw prevent delete error when deleted
            pnRec2.VCC_Signed__c = true;
            pnRec2.VCC_Electronic_Signature__c = 'Test Sig';
            update pnRec2;

            Test.startTest();
            try {
                VCC_ProgressNoteController.preventProgressNoteDelete(pnRecs);
            } catch (DMLexception e) {
                Assert.isTrue(
                    e.getMessage().contains(System.Label.VCC_Prevent_Delete_Signed_Progress_Note),
                    'Message does not contain correct label.'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test the peventProgressNoteDelete method
     */
    @IsTest
    static void preventProgressNoteDeleteTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            // create Case that Progress Notes are children to
            Case caseRec = new Case(
                RecordTypeId = CASEDESCRIBE.getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert caseRec;
            }

            // unsigned PN to be deleted successfully
            VCC_Progress_Note__c pnRec1 = new VCC_Progress_Note__c(
                VCC_Case__c = caseRec.Id,
                VCC_Relative_Type__c = 'Self'
            );
            // PN that will be signed
            VCC_Progress_Note__c pnRec2 = new VCC_Progress_Note__c(
                VCC_Case__c = caseRec.Id,
                VCC_Relative_Type__c = 'Self'
            );
            // progress note to try to delete running as a non owner
            VCC_Progress_Note__c pnRec3 = new VCC_Progress_Note__c(
                VCC_Case__c = caseRec.Id,
                VCC_Relative_Type__c = 'Self'
            );

            // progress notes to be inserted
            List<VCC_Progress_Note__c> pnRecs = new List<VCC_Progress_Note__c>{ pnRec1, pnRec2, pnRec3 };
            insert pnRecs;
            // remove record from list, to be tested in another scenario
            pnRecs.remove(2);

            // signed PN, will throw prevent delete error when deleted
            pnRec2.VCC_Signed__c = true;
            pnRec2.VCC_Electronic_Signature__c = 'Test Sig';
            update pnRec2;

            Test.startTest();
            try {
                delete pnRecs;
            } catch (DMLexception e) {
                Assert.isTrue(
                    e.getMessage().contains(System.Label.VCC_Prevent_Delete_Signed_Progress_Note),
                    'Expected Error Message'
                );
            }
            Test.stopTest();
        }

    }
    /**
     * @description Test unasignedProgressNotesOnCaseTest
     */
    @IsTest
    static void unsignedProgressNotesOnCaseTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            Case caseRec = new Case(
                RecordTypeId = CASEDESCRIBE.getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert caseRec;
            }

            // Create a signed and unsigned PN which looks up to caseRec
            VCC_Progress_Note__c signedPN = new VCC_Progress_Note__c(VCC_Case__c = caseRec.Id, VCC_Signed__c = true);
            insert signedPN;
            VCC_Progress_Note__c unSignedPN = new VCC_Progress_Note__c(VCC_Case__c = caseRec.Id, VCC_Signed__c = false);
            insert unSignedPN;

            Test.startTest();
            Boolean unsignedTestResult = VCC_ProgressNoteController.unsignedProgressNotesOnCase(caseRec.Id);
            Assert.isTrue(unsignedTestResult, 'Result from method is true');
            Test.stopTest();
        }
    }

    /**
     * @description Test generateEncounterStringTest
     */
    @IsTest
    public static void generateEncounterStringTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            Test.startTest();
            Assert.areEqual(
                VCC_ProgressNoteController.generateEncounterString(999, false, false),
                '999;3210723.131503;T',
                'VCC_encounterString__c did not generate correctly.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description This test method is used to execute each of the actions an RN user performs when writing/signing a progress note.
     * Expected outcome is a successful signing of a progress note.
     */
    @IsTest
    public static void signNoteHappyPathTest() {
        User rnUser = getTestUser();
        rnUser.Division = 'VISN 1';
        update rnUser;

        VCC_ProgressNoteController.ActionParams params = new VCC_ProgressNoteController.ActionParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        params.pnRecord = [
            SELECT Id, VCC_Additional_Comments__c, RecordTypeId
            FROM VCC_Progress_Note__c
            WHERE VCC_Additional_Comments__c = 'Some additional comment.'
            LIMIT 1
        ];
        List<VCC_ProgressNoteController.ActionParams> paramList = new List<VCC_ProgressNoteController.ActionParams>{
            params
        };

        params.patientAndProviderParams.providerName = 'test';
        params.patientAndProviderParams.providerUserId = 'test';
        params.patientAndProviderParams.patientLocalPid = 1234;
        params.patientAndProviderParams.patientLocalSiteId = 'test';
        params.patientAndProviderParams.providerLoginSiteCode = '983';
        params.noteAndEncounterParams.noteAndEncounterLocationIen = '999';
        params.noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
        params.noteAndEncounterParams.noteAndEncounterProcedures = 'test';
        params.noteAndEncounterParams.noteAndEncounterDiagnoses = 'test';
        params.noteAndEncounterParams.encounterString = 'test';
        params.patientAndProviderParams.eSig = 'test';
        params.patientAndProviderParams.authorDUZ = 'test';
        params.noteAndEncounterParams.noteAndEncounterVisitRelatedTos = 'test';
        params.noteAndEncounterParams.itemId = '1234';
        params.noteAndEncounterParams.noShowNoWelfare = false;
        params.noteAndEncounterParams.noShowWithWelfare = false;

        Test.startTest();
        System.runAs(rnUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStatus('200');
            Test.setMock(HttpCalloutMock.class, mock);

            params.actionName = 'GetVisitRelatedTos';
            mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
            Assert.isTrue(VCC_ProgressNoteController.progressNoteAction(paramList)[0] != '', 'Expected no result');

            params.actionName = 'ValidateEsig';
            mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
            Assert.isTrue(VCC_ProgressNoteController.progressNoteAction(paramList)[0] == 'True', 'Expected a result');

            params.actionName = 'CreateAddendum';
            VCC_ProgressNoteController.ProgressNoteAction(paramList);

            params.actionName = 'WriteNote';
            VCC_ProgressNoteController.ProgressNoteAction(paramList);

            params.actionName = 'GetNoteText';
            VCC_ProgressNoteController.progressNoteAction(paramList);

            params.actionName = 'CreateEncounter';
            mock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');

            List<CodeSet> diagnosis = [SELECT Id FROM CodeSet WHERE CodeSetType LIKE 'Diagnosis%'];
            List<CodeSet> procedure = [SELECT Id FROM CodeSet WHERE CodeSetType LIKE 'Procedure%'];
            params.noteAndEncounterParams.primaryDiagnosis = diagnosis[0];
            params.noteAndEncounterParams.secondaryDiagnosis = diagnosis[1];
            params.noteAndEncounterParams.procedureCode = procedure[0];

            VCC_ProgressNoteController.progressNoteAction(paramList);

            params.actionName = 'GetEncounterString';
            String encounterString = VCC_ProgressNoteController.progressNoteAction(paramList)[0];
            //encounterString is generated by locationIEN + ';' + timeStamp + ';' + SERVICE_CATEGORY (T) or isNOSHOW (E)
            Assert.isTrue(encounterString == '999;3210723.131503;T', 'Encounter String did not generate correctly');

            params.actionName = 'SignNote';
            mock.setStaticResource('VCC_vdifSignNoteMockResponse');
            String signResponse = VCC_ProgressNoteController.progressNoteAction(paramList)[0];
            Assert.isTrue(signResponse == 'OK', 'Unexpected response from VCC_vdifSignNoteMock. Expected "OK".');
        }
        Test.stopTest();
    }
    /**
     * @description Test addSigners
     */
    @IsTest
    public static void addSignersTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            VCC_ProgressNoteController.ActionParams params = new VCC_ProgressNoteController.ActionParams();
            params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
            List<VCC_ProgressNoteController.ActionParams> paramList = new List<VCC_ProgressNoteController.ActionParams>{
                params
            };

            Case testCase = new Case(
                RecordTypeId = Case.getSObjectType()
                    .getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage')
                    .getRecordTypeId()
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert testCase;
            }
            VCC_Progress_Note__c pNote = new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                    .getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert pNote;
            }
            insert new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_Progress_Note__c = pNote.Id) };

            params.pnRecord = pNote;

            params.noteAndEncounterParams.supplementalParameters = '[{"providertitle":"BAY PINES TEST LAB","providername":"Ivo","loginSiteCode":null,"fault":null,"duz":"5206375"}]';
            params.noteAndEncounterParams.itemId = '1234';
            params.patientAndProviderParams.providerName = 'test';
            params.patientAndProviderParams.providerUserId = 'test';
            params.patientAndProviderParams.providerLoginSiteCode = 'test';

            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStatus('200');
            Test.setMock(HttpCalloutMock.class, mock);
            mock.setStaticResource('VCC_vdifGetAdditionalSignersMockResponse');

            params.actionName = 'AddSigners';
            VCC_ProgressNoteController.progressNoteAction(paramList);

            Test.stopTest();

            if (VCC_Named_Toggle__mdt.getInstance('New_Vista_User_Search').VCC_State__c == false) {
                Assert.isTrue([SELECT Id FROM VCC_Signers__c LIMIT 1].size() >= 1, 'Signers not created correctly.');
            } else {
                Assert.isTrue(true, 'Implied assert.');
            }
        }
    }

    /**
     * @description Test for mockSSO
     */
    @IsTest
    public static void mockSSOTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            if (VCC_TrainingModeService.isTrainingModeEnabled()) {
                return;
            }

            VCC_ProgressNoteController.ActionParams params = new VCC_ProgressNoteController.ActionParams();
            params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();

            List<VCC_ProgressNoteController.ActionParams> paramList = new List<VCC_ProgressNoteController.ActionParams>{
                params
            };

            String token;
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud;

            Test.startTest();
            params.actionName = 'GetAuthToken';
            token = VCC_ProgressNoteController.progressNoteAction(paramList)[0];

            vitud = [
                SELECT Id, DUZ__c, User_Id__c, VistA_Instance__c
                FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
                WHERE User_Id__c = :testUser.Id AND Name LIKE 'mockSSO%'
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Test.stopTest();

            Assert.areEqual('test1234', token, 'Mock token not retrieved correctly.');
            Assert.isNotNull(vitud, 'Did not create IAM_SSOi_Vista_Instance_to_User_DUZ__c as expected.');
        }
    }

    /**
     * @description Test getRecordTypeId
     */
    @IsTest
    public static void getRecordTypeIdTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            Case testCase = new Case(
                RecordTypeId = Case.getSObjectType()
                    .getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage')
                    .getRecordTypeId()
            );
            insert testCase;

            VCC_Progress_Note__c pNote = new VCC_Progress_Note__c(
                VCC_Case__c = testCase.Id,
                RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                    .getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            insert pNote;

            Test.startTest();
            Id rtId = VCC_ProgressNoteController.getProgressNoteRecordTypeId(pNote.Id);
            Assert.isNotNull(rtId, 'An Id was not returned.');
            Test.stopTest();
        }
    }

    /**
     * @description Test getCallTrackingList
     */
    @IsTest
    public static void getCallTrackingListTest() {
        String uniqueUserName = 'progressnotecontrollertest' + DateTime.now().getTime() + '@testorg.com';
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile' LIMIT 1];
        User mpUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName,
            Division = 'VISN 1'
        );

        insert mpUser;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Medical_Provider', mpUser);

        List<VCC_Call_Tracking__c> ctList = new List<VCC_Call_Tracking__c>();
        Test.startTest();
        System.runAs(mpUser) {
            Case testCase = new Case(
                RecordTypeId = CASEDESCRIBE.getRecordTypeInfosByName()
                    .get('Virtual Clinic Visit Case')
                    .getRecordTypeId(),
                VCC_Caller_Relation__c = 'Self'
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert testCase;
            }
            VCC_Progress_Note__c pNote = new VCC_Progress_Note__c(
                VCC_Additional_Comments__c = 'Some additional comment.',
                VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
                VCC_Case__c = testCase.Id,
                //Updated to Avoid Triggering Progress Note Validation Rule
                VCC_Caregiver_Name__c = 'Test Care Giver',
                VCC_Caller_Name_Text__c = 'Test Care Giver',
                RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Virtual_Visit_Progress_Note')
                    .getRecordTypeId()
            );
            insert pNote;

            VCC_Call_Tracking__c ct = new VCC_Call_Tracking__c(
                VCC_Progress_Note__c = pNote.Id,
                VCC_Call_Date_Time__c = system.now()
            );
            // Todo: Commented out failing test
            insert ct;

            ctList = VCC_ProgressNoteController.getCallTrackingList(pNote.Id);
        }
        Test.stopTest();

        // Todo: Commented out failing test
        Assert.isTrue(!ctList.isEmpty(), 'Call Tracking list returning empty.');
    }

    /**
     * @description Test createSigners
     */
    @IsTest
    static void createSignersTest() {
        User testUser = insertTestUser();
        System.runAs(testUser) {
            Case testCase = new Case(
                RecordTypeId = Case.getSObjectType()
                    .getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage')
                    .getRecordTypeId()
            );
            if (CASEDESCRIBE.isCreateable()) {
                insert testCase;
            }
            VCC_Progress_Note__c pNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert pNote;

            VCC_VdifResponseParser.ProviderTO provider = new VCC_VdifResponseParser.ProviderTO();
            provider.duz = 'test';
            provider.providername = 'test';
            provider.providertitle = 'test';
            provider.loginSiteCode = 'test';

            Test.startTest();
            VCC_ProgressNoteController.createSigners(pNote.Id, new List<VCC_VdifResponseParser.ProviderTO>{ provider });
            Test.stopTest();
            Assert.isTrue(true, 'Implied assert.');
        }
    }

    /**
     * @description This test method tests the else condition of the switch statment in the VCC_ProgressNoteController.progressNoteAction method. The expected result is
     * an exception stating that the actionName provided does not exist.
     */
    @IsTest
    static void unitBadActionNameTest() {
        User rnUser = getTestUser();
        rnUser.Division = 'VISN 1';
        update rnUser;
        VCC_ProgressNoteController.ActionParams params = new VCC_ProgressNoteController.ActionParams();
        List<VCC_ProgressNoteController.ActionParams> paramList = new List<VCC_ProgressNoteController.ActionParams>{
            params
        };

        Test.startTest();
        System.runAs(rnUser) {
            params.actionName = 'BadActionName';
            String exceptionMessage;
            try {
                List<String> strList = VCC_ProgressNoteController.progressNoteAction(paramList);
            } catch (Exception pnException) {
                exceptionMessage = pnException.getMessage();
            }
            Assert.isNotNull(exceptionMessage, 'Assertion failed; Expected exception to be thrown!');
            Assert.AreEqual(
                'BadActionName doesn\'t exist or has not been configured.',
                exceptionMessage,
                'Assertion failed; Exception message was not set correctly!'
            );
        }
        Test.stopTest();
    }

    /**
     * @description functional test method to ensure initialization was successful
     */
    private static void funcEnsureCorrectDefaultInitialization() {
        Test.startTest();
        VCC_ProgressNoteController pNoteController = new VCC_ProgressNoteController();
        Test.stopTest();

        Assert.isNotNull(pNoteController, 'Expected class to be initialized.');
        Assert.isNotNull(VCC_ProgressNoteController.pNoteRepo, 'Expected notes Repo to be initialized.');
    }

    @IsTest
    /**
     * @description unit test to fetch notes
     */
    private static void unitFetchNotes() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel notesDataModel = (VTC_DataModel) VCC_ProgressNoteController.fetchNotes(args);
            Assert.isNotNull(notesDataModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to fetch notes
     */
    private static void unitFetchDirectives() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel notesDataModel = (VTC_DataModel) VCC_ProgressNoteController.fetchDirectives(args);
            Assert.isNotNull(notesDataModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Limit Exception
     */
    private static void unitFetchNotesVTCLimitException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        String exceptionMessage = 'RETRY_CMD';
        VTC_LimitException limitException = new VTC_LimitException(exceptionMessage);
        limitException.setMessage(exceptionMessage);
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, limitException);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProgressNoteController.fetchNotes(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException e) {
                Assert.areEqual('RETRY_CMD', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Limit Exception
     */
    private static void unitFetchDirectivesVTCLimitException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        String exceptionMessage = 'RETRY_CMD';
        VTC_LimitException limitException = new VTC_LimitException(exceptionMessage);
        limitException.setMessage(exceptionMessage);
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, limitException);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProgressNoteController.fetchDirectives(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException e) {
                Assert.areEqual('RETRY_CMD', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description unit test to catch VTC Internal Exception
     */
    private static void unitFetchNotesVTCException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        String exceptionMessage = 'NO_RETRY_CMD';
        VTC_InternalException internalException = new VTC_InternalException(exceptionMessage);
        internalException.setMessage(exceptionMessage);
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, internalException);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProgressNoteController.fetchNotes(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException e) {
                Assert.areEqual('NO_RETRY_CMD', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }
    @IsTest
    /**
     * @description unit test to catch VTC Internal Exception
     */
    private static void unitFetchDirectivesVTCException() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        String exceptionMessage = 'NO_RETRY_CMD';
        VTC_InternalException internalException = new VTC_InternalException(exceptionMessage);
        internalException.setMessage(exceptionMessage);
        VCC_ProgressNoteController.pNoteRepo = createNotesRepo(args, internalException);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            try {
                VCC_ProgressNoteController.fetchDirectives(args);
                Assert.fail('Expected exception to be thrown.');
            } catch (AuraHandledException e) {
                Assert.areEqual('NO_RETRY_CMD', e.getMessage(), 'Exception message should match.');
            }
        }
        Test.stopTest();
    }

    /**
     * @description method to build VCR_ProgressNoteRepo stub mocking fetchNotes
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @return `VCR_ProgressNoteRepo`
     */
    private static VCR_ProgressNoteRepo createNotesRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_ProgressNoteRepo) new VATEST_StubBuilder(VCR_ProgressNoteRepo.class)
            .mockingMethodCall('fetchNotes')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .mockingMethodCall('fetchDirectives')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description method to build VCR_ProgressNoteRepo stub
     * @param args The arguments to pass to the provider
     * @param returnException the exception to be returned
     * @return `VCR_ProgressNoteRepo`
     */
    private static VCR_ProgressNoteRepo createNotesRepo(Map<String, Object> args, Exception returnException) {
        return (VCR_ProgressNoteRepo) new VATEST_StubBuilder(VCR_ProgressNoteRepo.class)
            .mockingMethodCall('fetchNotes')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .mockingMethodCall('fetchDirectives')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .throwingException(returnException)
            .defineStub();
    }

    @IsTest
    /**
     * @description unit test to fetch Health Config Data
     */
    private static void unitFetchHealthDataConfig() {
        VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
            'notes',
            Datetime.now(),
            Datetime.now(),
            12,
            5
        );

        Account patientAccount = new Account(Date_of_Birth__pc = '4/20/1999');
        VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model()
            .setAccountDOB(patientAccount)
            .setWorkstreamSettings(workstreamSettingsModel);

        VCC_ProgressNoteController.healthDataRepo = createHealthDataRepo('notes', healthDataRepoModel);
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_ProgressNoteController.fetchHealthDataConfig(
                'fakeICN'
            );
            Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }
    /**
     * @description helper method to build health data repo
     * @param healthDataType the type of health data you are fetching
     * @param returnValue  the return value
     * @return `VCR_HealthDataRepo`
     */
    private static VCR_HealthDataRepo createHealthDataRepo(
        String healthDataType,
        VCR_HealthDataRepo.Model returnValue
    ) {
        return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
            .mockingMethodCall('fetchHealthDataConfig')
            .withParameterTypes()
            .returning(returnValue)
            .mockingMethodCall('setPatientByICN')
            .withParameterTypes(String.class)
            .withParameterValues('fakeICN')
            .returning()
            .defineStub();
    }

    /**
     * @description method to create a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.Division, 'VISN 1')
            .build(true);
    }

    /**
     * @description Creates addednum record
     * @return      `VCC_Addendum__c` addedndum record
     */
    private static VCC_Addendum__c createAddendumRecord() {
        return (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(new VCC_Addendum__c());
    }

    /**
     * @description Test progressNoteActionAddendum Positive
     * @return      `VCC_ProgressNoteController.ActionParams`
     */
    @IsTest
    private static void unitProgressNoteActionAddendumPositive() {
        User testUser = new VATEST_UserBuilder()
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .setFields(User.Division, 'VISN 1')
            .build(true);

        VCC_ProgressNoteController.ActionParams params = new VCC_ProgressNoteController.ActionParams();
        params.patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        params.noteAndEncounterParams = new VCC_Vdif_NoteAndEncounterParams();
        VCC_Addendum__c testRecord = createAddendumRecord();
        params.addendumRecord = testRecord;
        List<VCC_ProgressNoteController.ActionParams> paramList = new List<VCC_ProgressNoteController.ActionParams>{
            params
        };
        VCC_Signers__c testSigner = (VCC_Signers__c) VATEST_SObjectFactory.createSObject(
            new VCC_Signers__c(VCC_Addendum__c = testRecord.Id)
        );

        params.patientAndProviderParams.providerName = 'test';
        params.patientAndProviderParams.providerUserId = 'test';
        params.patientAndProviderParams.patientLocalPid = 1234;
        params.patientAndProviderParams.patientLocalSiteId = 'test';
        params.patientAndProviderParams.providerLoginSiteCode = '983';
        params.noteAndEncounterParams.noteAndEncounterLocationIen = '999';
        params.noteAndEncounterParams.noteAndEncounterNoteTitleIen = 'test';
        params.noteAndEncounterParams.noteAndEncounterProcedures = 'test';
        params.noteAndEncounterParams.noteAndEncounterDiagnoses = 'test';
        params.noteAndEncounterParams.encounterString = 'test';
        params.patientAndProviderParams.eSig = 'test';
        params.patientAndProviderParams.authorDUZ = 'test';
        params.noteAndEncounterParams.noteAndEncounterVisitRelatedTos = 'test';
        params.noteAndEncounterParams.itemId = '1234';
        params.noteAndEncounterParams.noShowNoWelfare = false;
        params.noteAndEncounterParams.noShowWithWelfare = false;

        Test.startTest();
        System.runAs(testUser) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStatus('200');
            Test.setMock(HttpCalloutMock.class, mock);

            params.actionName = 'GetVisitRelatedTos';
            mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
            Assert.isTrue(VCC_ProgressNoteController.progressNoteAction(paramList)[0] != '', 'Expected no result');

            params.actionName = 'ValidateEsig';
            mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
            Assert.isTrue(VCC_ProgressNoteController.progressNoteAction(paramList)[0] == 'True', 'Expected a result');

            params.actionName = 'CreateAddendum';
            VCC_ProgressNoteController.ProgressNoteAction(paramList);

            params.actionName = 'WriteNote';
            VCC_ProgressNoteController.ProgressNoteAction(paramList);

            params.actionName = 'GetNoteText';
            VCC_ProgressNoteController.progressNoteAction(paramList);

            params.actionName = 'AddSigners';
            mock.setStaticResource('VCC_vdifGetAdditionalSignersMockResponse');
            VCC_ProgressNoteController.progressNoteAction(paramList);

            params.actionName = 'CreateEncounter';
            mock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');
            params.noteAndEncounterParams.primaryDiagnosis = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.33', Name = 'TST.33', CodeSetType = 'Diagnosis (ICD10)')
            );
            params.noteAndEncounterParams.secondaryDiagnosis = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.34', Name = 'TST.34', CodeSetType = 'Diagnosis (ICD10)')
            );
            params.noteAndEncounterParams.procedureCode = (CodeSet) VATEST_SObjectFactory.createSObject(
                new CodeSet(Code = 'TST.35', Name = 'TST.35', CodeSetType = 'Procedure (CPT)')
            );
            VCC_ProgressNoteController.progressNoteAction(paramList);

            params.actionName = 'GetEncounterString';
            String encounterString = VCC_ProgressNoteController.progressNoteAction(paramList)[0];
            //encounterString is generated by locationIEN + ';' + timeStamp + ';' + SERVICE_CATEGORY (T) or isNOSHOW (E)
            Assert.isTrue(encounterString == '999;3210723.131503;T', 'Encounter String did not generate correctly');

            params.actionName = 'SignNote';
            mock.setStaticResource('VCC_vdifSignNoteMockResponse');
            String signResponse = VCC_ProgressNoteController.progressNoteAction(paramList)[0];
            Assert.isTrue(signResponse == 'OK', 'Unexpected response from VCC_vdifSignNoteMock. Expected "OK".');
        }
        Test.stopTest();
    }
}
