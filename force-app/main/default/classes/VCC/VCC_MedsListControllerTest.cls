@IsTest
private class VCC_MedsListControllerTest {
    private static String testMviId = '1013429125V999999';
    private static final String TEST_USERNAME_NAME = 'standardUserTest' + Datetime.now().getTime() + '@VAHC.com';
    @TestSetup
    private static void makeData() {
        User testUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .setFields(User.Username, TEST_USERNAME_NAME)
            .withPermissionSets(new Set<String>{ 'VCC_Registered_Nurse', 'HealthCloudFoundation' })
            .build(true);

        // get the record type id for Person Accounts
        Id personAccountRtId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id;

        System.runAs(testUser) {
            // create and insert a new account, which also creates a contact
            Account account = new Account(
                FirstName = 'Testly',
                LastName = 'Person Accounted',
                RecordTypeId = personAccountRtId,
                VCC_MVI_External_Id__pc = testMviId
            );
            insert account;

            Id caseRecTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage').Id;
            Id pnRecTypeId = new VCR_ProgressNoteRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Clinical_Triage_Note_Progress_Note')
                .Id;
            Contact con = [SELECT Id, VCC_MVI_External_Id__c FROM Contact LIMIT 1];
            con.VCC_MVI_External_Id__c = testMviId;
            update con;
            //Create Clinical Triage Case
            Case cse = new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Symptom', ContactId = con.Id);
            insert cse;
            // Create a Task
            Task task = new Task(WhoId = con.Id, Description = 'Test Task');
            insert task;
            //Create Clinical Triage Progress Note
            VCC_Progress_Note__c progNote = new VCC_Progress_Note__c(
                VCC_Case__c = cse.Id,
                RecordTypeId = pnRecTypeId,
                VCC_Caregiver_Name__c = 'Unit Test'
            );
            insert progNote;
        }
    }

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE 'standardUserTest%' LIMIT 1];
    }

    @IsTest
    private static void testGetWorkstreamSettings() {
        System.runAs(getTestUser()) {
            Test.startTest();
            Map<String, VCC_Workstream_Settings__mdt> workstreamSettings = VCC_MedsListController.getWorkstreamSettings();
            VCC_Workstream_Settings__mdt pharmacySettings = workstreamSettings.get('Pharmacy');
            VCC_Workstream_Settings__mdt rNSettings = workstreamSettings.get('RN');
            VCC_Workstream_Settings__mdt mSASettings = workstreamSettings.get('MSA');
            VCC_Workstream_Settings__mdt vCVSettings = workstreamSettings.get('VCV');
            Assert.isTrue(
                pharmacySettings.Medication_Retrieval_Length_days__c != null,
                'Pharmacy record is not populated'
            );
            Assert.isTrue(rNSettings.Medication_Retrieval_Length_days__c != null, 'RN record is not populated');
            Assert.isTrue(mSASettings.Medication_Retrieval_Length_days__c != null, 'MSA record is not populated');
            Assert.isTrue(vCVSettings.Medication_Retrieval_Length_days__c != null, 'VCV record is not populated');
            Test.stopTest();
        }
    }

    @IsTest
    private static void testRefillRequest() {
        System.runAs(getTestUser()) {
            //Retreive RecordTypeIds for creating Case and Progress Note
            Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId();
            Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId();
            //Retrieve contact created in testSetup to update the MVI External Id
            Contact con = [SELECT Id, VCC_MVI_External_Id__c FROM Contact LIMIT 1];
            //Set External Id to static variable
            con.VCC_MVI_External_Id__c = testMviId;
            update con;
            //Create Clinical Triage Case
            Case cse = new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Symptom', ContactId = con.Id);
            insert cse;
            //Create Clinical Triage Progress Note
            VCC_Progress_Note__c progNote = new VCC_Progress_Note__c(VCC_Case__c = cse.Id, RecordTypeId = pnRecTypeId);
            insert progNote;

            VCC_MedsListController.ObjectInfo info = new VCC_MedsListController.ObjectInfo();
            VCC_MedsListController.RequestData requestD = new VCC_MedsListController.RequestData();
            Exception except;
            //info.id = '5003R000003GT6NQAW';'5003R000003GT5oQAG''VCC_Progress_Note__c'
            info.id = progNote.Id;
            info.sObjectType = 'VCC_Progress_Note__c';
            requestD.requestJSON = '[{"facilityId":"541","prescriptionId":"6224084","prescriptionName":"ALBUTEROL 0.083% INHL SOLN","icn":"1012660666V427556"}]';

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('vccMockRefillSuccess');
            mock.setStatusCode(200);
            mock.setStatus('Found');
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            VCC_MedsService.MedRefillResponse response1 = new VCC_MedsService.MedRefillResponse();
            try {
                response1 = VCC_MedsListController.handleRefillRequest(info, requestD);
            } catch (Exception caughtException) {
                except = caughtException;
            }
            Test.stopTest();
            Assert.areEqual(true, response1.allSuccessful, 'Expected refill to be successfull');
        }
    }

    @IsTest
    private static void unitNegativeRefillRequestTest() {
        System.runAs(getTestUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('vccMockRefillSuccess');
            mock.setStatusCode(400);
            mock.setStatus('failed');
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_MedsListController.RequestData requestData = new VCC_MedsListController.RequestData();
            VCC_MedsListController.ObjectInfo info = new VCC_MedsListController.ObjectInfo();

            info.sObjectType = 'VCC_Progress_Note__c';
            requestData.requestJSON = '[{"badData": "IsBad}]';

            Test.startTest();
            try {
                VCC_MedsListController.handleRefillRequest(info, requestData);
            } catch (Exception error) {
                Assert.areEqual(
                    'Script-thrown exception',
                    error.getMessage(),
                    'Expected Script Exception due to bad data'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void testFetchMedsDataSuccess() {
        // Get our RN test user - need specific context to pass VCC_Prevent_Incorrect_Progress_Note_Type validation rule
        User pnUser = getTestUser();

        // get test account
        Account account = [SELECT Id FROM Account LIMIT 1];

        //Run code in RN Context
        System.runAs(pnUser) {
            Test.startTest();
            // set up mock response
            VCC_MedsMockHttpResponse mockResponse = new VCC_MedsMockHttpResponse();
            mockResponse.resCode = 200;
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // get response data from meds controller, passing test account id
            String medsResponseData = VCC_MedsListController.fetchMedsData(account.Id, false);

            // check result, expected to be {"testResult":"OK"}
            Assert.areEqual('{"testResult":"OK"}', medsResponseData, 'Expected values to match');
            Test.stopTest();
        }
    }

    @IsTest
    private static void testFetchMedsDataMviError() {
        //Run code in RN Context
        System.runAs(getTestUser()) {
            Test.startTest();

            // set up mock response
            VCC_MedsMockHttpResponse mockResponse = new VCC_MedsMockHttpResponse();
            mockResponse.resCode = 200;
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // get response data from meds controller, passing nonexistant user id
            String medsResponseData = VCC_MedsListController.fetchMedsData('005000000000000000', true);

            // check result, expected to contain the VCC_MedsListController.mviIdError
            Assert.areEqual(
                medsResponseData,
                '{"apexError":"An MPI ID could not be found for this record."}',
                'Expected values to match'
            );

            Test.stopTest();
        }

    }

    @IsTest
    private static void testFetchMedsDataServerError() {
        //Create new user to run in Registered Nurse Context. Need specific context to pass VCC_Prevent_Incorrect_Progress_Note_Type validation rule
        //        User pnUser = new User(Id = UserInfo.getUserId());
        //        //Assign RN Perm set
        //        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE Name = 'VAHC_Standard_VCC_User'];
        //        Database.insert(new PermissionSetAssignment(AssigneeId = pnUser.Id, PermissionSetId = pSet.Id), false);

        // get test account
        Account account = [SELECT Id FROM Account LIMIT 1];

        System.runAs(getTestUser()) {
            // pnUser) {
            Test.startTest();

            // set up mock response
            VCC_MedsMockHttpResponse mockResponse = new VCC_MedsMockHttpResponse();
            mockResponse.resCode = 400;
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // get response data from meds controller, passing test account id
            String medsResponseData = VCC_MedsListController.fetchMedsData(account.Id, false);

            // check result, expected to contain a 400 error
            Assert.areEqual(medsResponseData, '{"apexError":"400 error"}', 'Expected values to match');

            Test.stopTest();
        }

    }

    @IsTest
    private static void testCalloutSuccess() {
        //Create new user to run in Registered Nurse Context. Need specific context to pass VCC_Prevent_Incorrect_Progress_Note_Type validation rule
        //        User pnUser = new User(Id = UserInfo.getUserId());
        //        //Assign RN Perm set
        //        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE Name = 'VAHC_Standard_VCC_User'];
        //        Database.insert(new PermissionSetAssignment(AssigneeId = pnUser.Id, PermissionSetId = pSet.Id), false);

        System.runAs(getTestUser()) {
            // pnUser) {
            Test.startTest();
            // set up mock response
            VCC_MedsMockHttpResponse mockResponse = new VCC_MedsMockHttpResponse();
            mockResponse.resCode = 200;
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // perform mocked callout
            Map<String, String> res = VCC_MedsListController.doMedsApiCallout(testMviId);

            // check results, expecting a value of {"testResult":"OK"} and null error value
            Assert.areEqual(res.get('value'), '{"testResult":"OK"}', 'Expected values to match');
            Assert.areEqual(res.get('error'), null, 'Expected values to match');
            Test.stopTest();
        }
    }

    @IsTest
    private static void testCalloutError() {
        //Create new user to run in Registered Nurse Context. Need specific context to pass VCC_Prevent_Incorrect_Progress_Note_Type validation rule
        //        User pnUser = new User(Id = UserInfo.getUserId());
        //        //Assign RN Perm set
        //        PermissionSet pSet = [SELECT Id FROM PermissionSet WHERE Name = 'VAHC_Standard_VCC_User'];
        //        Database.insert(new PermissionSetAssignment(AssigneeId = pnUser.Id, PermissionSetId = pSet.Id), false);

        System.runAs(getTestUser()) {
            // pnUser) {
            Test.startTest();

            // set up mock response
            VCC_MedsMockHttpResponse mockResponse = new VCC_MedsMockHttpResponse();
            mockResponse.resCode = 400;
            Test.setMock(HttpCalloutMock.class, mockResponse);

            // perform mocked callout
            Map<String, String> res = VCC_MedsListController.doMedsApiCallout(testMviId);

            // check results, expecting an error and a null value
            Assert.areEqual(res.get('value'), null, 'Expected values to match');
            Assert.isTrue(res.get('error') != null, 'Expected values to match');

            Test.stopTest();
        }

    }

    @IsTest
    private static void unitGetMedsWithParamsPositiveTest() {
        System.runAs(getTestUser()) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('vccHistoricalProgressNotesMock');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Test.setMock(HttpCalloutMock.class, mock);
            String icn = '00332288991';
            String startDate = '2022-04-21';

            VCC_MedsListController.MedsWrapper meds = VCC_MedsListController.getMedsWithParams(icn, startDate);
            Assert.isTrue(meds != null, 'Expected meds var to be populated');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetMedsWithParamsWithNegativeTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MedicationJsonExample');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

            Test.setMock(HttpCalloutMock.class, mock);

            String icn = '00332288991';
            String startDate = '2022-04-21';

            VCC_MedsListController.MedsWrapper meds = VCC_MedsListController.getMedsWithParams(icn, startDate);
            Test.stopTest();

            Assert.areEqual(
                'Exceeded Max Records',
                meds.errors[0],
                'Expected medswrapper to return exceeeded max records error'
            );
        }
    }

    @IsTest
    private static void unitGetMedsWithNoProductsNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                StaticResource medsRSJSON = [SELECT Body FROM StaticResource WHERE Name = 'vccMedsNoProducts'];

                VCC_BridgMedsRS vccBridgMedsRS = (VCC_BridgMedsRS) JSON.deserialize(
                    medsRSJSON.Body.toString(),
                    VCC_BridgMedsRS.class
                );

                Object result = VCC_Adapter_BridgToLWC.vccMedicationList(vccBridgMedsRS);

                Assert.isNotNull(result, ' Call to VCC_Adapter_BridgToLWC.vccMedicationList did not return data ');
            } catch (Exception unexpectedProductException) {
                Assert.fail(
                    'Expected VCC_BridgMedsResponseParser.Medication to catch succeed without errors but instead an exception was thrown.'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    private static void funcGetRequesterNamePositive() {
        User testUser = getTestUser();
        System.runAs(testUser) {
            User returnUser = new User();
            Exception caughtException;

            Test.startTest();
            try {
                returnUser = VCC_MedsListController.getRequesterName(testUser.Id);
            } catch (Exception error) {
                caughtException = error;
            }
            Test.stopTest();

            Assert.isNull(
                caughtException,
                'Expected successful retrieval of user for valid User, but instead observed an exception being thrown : ' +
                caughtException
            );
            Assert.isNotNull(
                returnUser,
                'Expected User to be retrieved & returned but instead observed no data being returned.'
            );
            Assert.isNotNull(
                returnUser.Name,
                'Expected User with Name field populated to be returned but instead observed a null Name property.'
            );
        }
    }

    @isTest
    private static void getCaseInfoTest() {
        System.runAs(getTestUser()) {
            Case sCase = [SELECT Id FROM Case WHERE VCC_Case_Type__c = 'Symptom' LIMIT 1];

            Case cse = new Case();
            Exception caughtException;

            Test.startTest();
            try {
                cse = VCC_MedsListController.getCaseInfo(sCase.Id);
            } catch (Exception error) {
                caughtException = error;
            }
            Test.stopTest();

            Assert.isTrue(caughtException == null, 'An exception was thrown.');
            Assert.isTrue(cse != null, 'Data not returned as expected.');
        }
    }

    @isTest
    private static void getAccountInfoTest() {
        System.runAs(getTestUser()) {
            Case cse = [SELECT Id FROM Case WHERE VCC_Case_Type__c = 'Symptom' LIMIT 1];

            Account acc = new Account();
            Exception caughtException;

            Test.startTest();
            try {
                acc = VCC_MedsListController.getAccountInfo(cse.Id);
            } catch (Exception error) {
                caughtException = error;
            }
            Test.stopTest();

            Assert.isTrue(caughtException == null, 'An exception was thrown.');
            Assert.isTrue(acc != null, 'Data not returned as expected.');
        }
    }

    @isTest
    private static void unitPositiveGetProgressNoteInfoTest() {
        User user = getTestUser();
        System.runAs(user) {
            VCC_Progress_Note__c progNote = [
                SELECT Id, VCC_Facility__c
                FROM VCC_Progress_Note__c
                WHERE VCC_Caregiver_Name__c = 'Unit Test'
                LIMIT 1
            ];
            // VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c();
            Test.startTest();
            VCC_Progress_Note__c progressNote = VCC_MedsListController.getProgressNoteInfo(progNote.Id);
            Test.stopTest();
            Assert.areEqual(progNote.Id, progressNote.Id, 'Expected to return data for the test Progress Note');
        }
    }

    @isTest
    private static void unitNegativeGetProgressNoteInfoTest() {
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c progNote = [
                SELECT Id
                FROM VCC_Progress_Note__c
                WHERE VCC_Caregiver_Name__c = 'Unit Test'
                LIMIT 1
            ];

            Test.startTest();
            try {
                VCC_MedsListController.getProgressNoteInfo(progNote.Id);
            } catch (Exception error) {
                Assert.areEqual(
                    error.getMessage(),
                    'Insufficient permissions: secure query included inaccessible field',
                    'Expected query to fall due to no read permission for field: VCC_Facility__c'
                );
            }
            Test.stopTest();
        }
    }

    @SuppressWarnings('PMD.ApexDoc, PMD.CognitiveComplexity')
    @isTest
    private static void fetchPharmacyLog() {
        System.runAs(getTestUser()) {
            StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
            staticResourceMock.setStaticResource('VCCActivityLogMock');
            staticResourceMock.setHeader('Content-Type', 'application/json');
            staticResourceMock.setStatusCode(200);
            Test.setMock(HttpCalloutMock.class, staticResourceMock);

            Test.startTest();
            Map<String, Object> jsObject = new Map<String, Object>{ 'facilityId' => '420', 'prescriptionId' => '69' };

            VCC_DivaResponse res = VCC_MedsListController.fetchPharmacyLog('ACTIVITY', jsObject);
            Assert.isTrue(res != null, 'expected successful call');

            try {
                staticResourceMock.setStatusCode(404);
                VCC_MedsListController.fetchPharmacyLog('ACTIVITY', jsObject);
            } catch (Exception ex) {
                Assert.isTrue(
                    ex.getTypeName().contains('System.AuraHandledException'),
                    'Expected Aura Handled Exception'
                );
            }

            // handle 500s
            try {
                staticResourceMock.setStatusCode(500);
                VCC_MedsListController.fetchPharmacyLog('ACTIVITY', jsObject);
            } catch (Exception ex) {
                Assert.isTrue(
                    ex.getTypeName().contains('System.AuraHandledException'),
                    'Expected Aura Handled Exception'
                );
            }

            try {
                VCC_MedsListController.fetchPharmacyLog('TEST_EXECUTION', jsObject);
            } catch (Exception ex) {
                Assert.isTrue(
                    ex.getTypeName().contains('System.AuraHandledException'),
                    'Expected Aura Handled Exception'
                );
            }

            try {
                jsObject = new Map<String, Object>{ 'facilityId' => null, 'prescriptionId' => null };
                VCC_MedsListController.fetchPharmacyLog('ACTIVITY', jsObject);
            } catch (Exception ex) {
                Assert.isTrue(
                    ex.getTypeName().contains('System.AuraHandledException'),
                    'Expected Aura Handled Exception'
                );
            }

            Test.stopTest();
        }
    }

    @isTest
    static void unitGetPatientAsSFRecordPositiveTest() {
        System.runAs(getTestUser()) {
            Account tstAccount = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];
            Test.startTest();
            Account acc = VCC_MedsListController.getPatientasSFRecord('1234560');
            Test.stopTest();
            Assert.areEqual(tstAccount.FirstName, acc.FirstName, 'Expected Account returned to match test data');
        }
    }

    @isTest
    static void unitGetPatientAsSFRecordNegativeTest() {
        System.runAs(getTestUser()) {
            VCC_TestDataFactory.generateVccPersonAccounts(1);
            Test.startTest();
            try {
                VCC_MedsListController.getPatientAsSFRecord('5555555555');
            } catch (Exception error) {
                Assert.areEqual(
                    'Script-thrown exception',
                    error.getMessage(),
                    'Expected to throw error due to matching data'
                );
            }
            Test.stopTest();
        }
    }

    @isTest
    static void unitFetchDemographicsByVistaPositiveTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_HDRClient.bypassCallout = true;
            VCC_VISTAModel vistaModel = VCC_MedsListController.fetchDemographicsByVista(
                new Map<String, String>{ 'facilityId' => '123456789', 'ien' => '654321' }
            );
            Assert.areEqual('123', vistaModel.facilityId, 'Expected to return test facilityId');
            Test.stopTest();
        }
    }

    @isTest
    static void unitFetchDemographicsByVistaNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_HDRClient.bypassCallout = true;
            try {
                VCC_MedsListController.fetchDemographicsByVista(new Map<String, String>{ 'badData' => '000000000' });
            } catch (Exception error) {
                Assert.areEqual(
                    'Script-thrown exception',
                    error.getMessage(),
                    'Expected to throw script exception for bad inputs'
                );
            }
            Test.stopTest();
        }
    }
    @isTest
    static void unitGetFacilityIensPositive() {
        System.runAs(getTestUser()) {
            Map<String, String> params = new Map<String, String>{ 'icn' => '12345', 'facilityId' => '456678' };
            Test.startTest();
            VCC_FacilityIenCalloutMock mockResponse = new VCC_FacilityIenCalloutMock();
            mockResponse.resCode = 200;
            Test.setMock(HttpCalloutMock.class, mockResponse);
            String returnVal = VCC_MedsListController.getFacilityIens(params);
            Assert.areEqual('98765432', returnVal, 'Expected callout return to equal mock value');
            Test.stopTest();
        }
    }

    @isTest
    static void unitGetFacilityIensNegative() {
        System.runAs(getTestUser()) {
            Map<String, String> params = new Map<String, String>{ 'icn' => '12345', 'facilityId' => '456678' };
            Test.startTest();
            VCC_FacilityIenCalloutMock mockResponse = new VCC_FacilityIenCalloutMock();
            mockResponse.resCode = 400;
            Test.setMock(HttpCalloutMock.class, mockResponse);
            try {
                VCC_MedsListController.getFacilityIens(params);
            } catch (Exception error) {
                Assert.areEqual(
                    error.getTypeName(),
                    'System.AuraHandledException',
                    'should throw aura handled exception for bad request'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void testReleaseDateFormat() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User pnUser = builder.withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MedsReleaseDateTestData');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(pnUser) {
            List<VCC_MedsListController.FormattedMed> formattedMeds;
            VCC_MedsListController.MedsWrapper response;
            Exception except;
            String icn = '00332288991';
            String startDate = '2022-04-21';

            Test.startTest();

            try {
                response = VCC_MedsListController.getMedsWithParams(icn, startDate);
                formattedMeds = (List<VCC_MedsListController.FormattedMed>) JSON.deserialize(
                    response.medsResponse,
                    List<VCC_MedsListController.FormattedMed>.class
                );
            } catch (Exception caughtException) {
                except = caughtException;
            }

            Assert.isTrue(except == null, 'An exception was thrown.');
            Assert.areEqual(
                '2024-01-01',
                formattedMeds[0].fillsReleaseDate,
                'Medication release date not formatted as expected.'
            );
            Assert.areEqual(
                'January',
                formattedMeds[0].fillsReleaseDateMonth,
                'Medication release month not formatted as expected.'
            );

            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetTemporaryAddressPositive() {
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'facilityId' => '123',
            'icn' => 'fakeICN'
        };
        Boolean makeCallout = true;
        VCC_MedsListController.pharmacyRepo = createPharmacyRepo(args, new VTC_RecordModel());
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_RecordModel tempAddressRecordModel = (VTC_RecordModel) VCC_MedsListController.getTemporaryAddress(
                args,
                makeCallout
            );
            Assert.isTrue(tempAddressRecordModel != null, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetTemporaryAddressMemoizationPositive() {
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_PharmacyRepo createRepo = VCC_MedsListController.pharmacyRepo;
            VCR_PharmacyRepo compareRepo = VCC_MedsListController.pharmacyRepo;
            Assert.isTrue(createRepo == compareRepo, 'Expected repo to be the same.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetTemporaryAddressCreateMemoPositive() {
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VCR_PharmacyRepo createRepo = VCC_MedsListController.pharmacyRepo;
            Assert.isTrue(createRepo != null, 'Expected repo to be created by getter in VCC_MedsListController.');
        }
        Test.stopTest();
    }

    private static VCR_PharmacyRepo createPharmacyRepo(Map<String, Object> args, Object returnValue) {
        return (VCR_PharmacyRepo) new VATEST_StubBuilder(VCR_PharmacyRepo.class)
            .mockingMethodCall('getTemporaryAddress')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }

    /**
     * @description HTTP Mock class for getFacilityIen tests
     */
    public class VCC_FacilityIenCalloutMock implements HttpCalloutMock {
        public Integer resCode;

        /**
         * @description Response method for mock class
         * @param req `HttpRequest` Test payload request to "send"
         * @return `HTTPResponse` Mock response from Http endpoint to given req
         */
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(resCode);
            if (resCode == 200) {
                res.setBody('{"patientIdAtFacility": "98765432"}');
            } else {
                res.setStatus(resCode + 'badRequest');
            }
            return res;
        }
    }
}
