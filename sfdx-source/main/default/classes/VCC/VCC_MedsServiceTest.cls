/**
 * @description       : Test class for VCC_MedsService
 * @author            : Booz Allen Hamilton
 * @date              : 12/2024
 **/
@IsTest
private with sharing class VCC_MedsServiceTest {
    /**
     * @description creates test Pharm user
     */
    @TestSetup
    static void makeData() {
        new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VAHC_Standard_VCC_User', 'VCC_Pharmacy_I', 'HealthCloudFoundation' })
            .withStandardData()
            .build(true);
    }

    /**
     * @description gets test user generated in makedata
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
     * @description tests the constructor of MedRefillRequest positive
     */
    @IsTest
    private static void unitMedRefillRequestConstructPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MedsService.MedRefillRequest medRefillRequest = new VCC_MedsService.MedRefillRequest();
            Assert.isNotNull(medRefillRequest, 'Expected medRefillRequest class to be initialized.');
            Assert.isNull(medRefillRequest.facilityId, 'Expected facility id to not be initialized.');
            Assert.isNull(medRefillRequest.prescriptionId, 'Expected prescription id to not be initialized.');
            Assert.isNull(medRefillRequest.icn, 'Expected icn to not be initialized.');
            Assert.isNull(medRefillRequest.prescriptionName, 'Expected prescriptionName to not be initialized.');
            Test.stopTest();
        }
    }

    /**
     * @description tests the construction of MedRefillResponse positive
     */
    @IsTest
    private static void unitRefillMedicationsResponsePositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MedsService.MedRefillResponse medRefillResponse = new VCC_MedsService.MedRefillResponse();
            Assert.isNotNull(medRefillResponse, 'Expected MedRefillResponse class to be initialized.');
            Assert.isFalse(medRefillResponse.allSuccessful, 'Expected allSuccessful value to be false but was not');
            Assert.isNull(medRefillResponse.caseObject, 'Expected caseObject to be null but was not');

            VCC_DivaClient.RefillMedicationsRS refillMedicationsRS = new VCC_DivaClient.RefillMedicationsRS();
            VCC_DivaClient.ResponseJSON responseJSON = new VCC_DivaClient.ResponseJSON();
            responseJSON.prescriptionId = 'fakeId';
            responseJSON.success = false;
            responseJSON.message = 'Force unit test failure.';
            refillMedicationsRS.responseJSON.add(responseJSON);
            medRefillResponse = new VCC_MedsService.MedRefillResponse(refillMedicationsRS, new Case());

            Assert.isNotNull(medRefillResponse.allSuccessful, 'Expected allSuccessful value to not be null');
            Assert.isNotNull(medRefillResponse.caseObject, 'Expected caseObject to not be null');
            Test.stopTest();
        }
    }

    /**
     * @description tests refilling medications by case positive
     */
    @IsTest
    private static void funcRefillMedicationsByCasePositive() {
        System.runAs(getTestUser()) {
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id,
                    Subject = 'VCC_MedsServiceTest',
                    AccountId = testAccount.Id,
                    VCC_Caller_Relation__c = 'Self',
                    VCC_Caller_Name__c = 'Unit Test'
                ),
                true
            );
            VCC_MedsService.MedRefillResponse medRefillResponse;

            Test.startTest();
            medRefillResponse = VCC_MedsService.refillMedications(
                testCase,
                new List<VCC_MedsService.MedRefillRequest>()
            );
            Test.stopTest();

            Assert.isTrue(medRefillResponse.allSuccessful, 'Expected allSuccessful to be true but was not');
            Assert.areEqual(
                testCase.Id,
                medRefillResponse.caseObject.Id,
                'Expected caseObject from med refill to be equal to the original case from this test'
            );
        }
    }

    /**
     * @description tests refilling medications by case to result in expcetion when case is not found, negative
     */
    @IsTest
    private static void untiRefillMedicationsByCaseNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_MedsService.refillMedications(new Case(), new List<VCC_MedsService.MedRefillRequest>());
            } catch (VCC_MedsService.VCC_MedsServiceException e) {
                Assert.areEqual('Case Id is required', e.getMessage(), 'Expected exception messages to match.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests the refill medications by account positive
     */
    @IsTest
    private static void funcRfillMedicationsByAccountPositive() {
        System.runAs(getTestUser()) {
            StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
            staticResourceMock.setStaticResource('VCC_DivaClient_RefillMedicationsRS');
            staticResourceMock.setHeader('Content-Type', 'application/json');
            staticResourceMock.setStatusCode(200);
            Test.setMock(HttpCalloutMock.class, staticResourceMock);

            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );

            List<VCC_MedsService.MedRefillRequest> medRefillRequests = new List<VCC_MedsService.MedRefillRequest>();
            medRefillRequests.add(new VCC_MedsService.MedRefillRequest());
            VCC_MedsService.MedRefillResponse medRefillResponse;
            Test.startTest();
            medRefillResponse = VCC_MedsService.refillMedications(testAccount, medRefillRequests);
            Test.stopTest();

            Assert.isTrue(medRefillResponse.allSuccessful, 'Expected allSuccessful to be true but was not');
            Assert.areEqual(
                'Pharmacy',
                medRefillResponse.caseObject.VCC_Case_Sub_Type__c,
                'Expected caseObject from med refill to be of sub type Pharmacy but was not'
            );
            Assert.areEqual(
                'Processed Medication Refill',
                medRefillResponse.caseObject.VCC_Case_Outcome_Multi__c,
                'Expected caseObject from med refill to have Processed Medication Refill as case outcome but did not'
            );
            Assert.areEqual(
                'Medication Refill',
                medRefillResponse.caseObject.VCC_Case_Reason_Multi__c,
                'Expected caseObject from med refill to have Medication Refill as case reason but did not'
            );
        }
    }

    /**
     * @description tests the refill medications by account negative when account id is null
     */
    @IsTest
    private static void unitRefillMedicationsByAccountMissingIdNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_MedsService.refillMedications(new Account(), new List<VCC_MedsService.MedRefillRequest>());
            } catch (VCC_MedsService.VCC_MedsServiceException e) {
                Assert.areEqual('Account Id is required', e.getMessage(), 'Expected exception messages to match.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests the refill medications by account negative when account is not found
     */
    @IsTest
    private static void unitRefillMedicationsByAccountMissingAccountNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                Id fakAccountId = VATEST_IdFactory.get(Account.sObjectType);
                VCC_MedsService.refillMedications(
                    new Account(id = fakAccountId),
                    new List<VCC_MedsService.MedRefillRequest>()
                );
            } catch (VCC_MedsService.VCC_MedsServiceException e) {
                Assert.areEqual('Account not found', e.getMessage(), 'Expected exception messages to match.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests refill medications by progress note positive
     */
    @IsTest
    private static void funcRefillMedicationsByProgressNotePositive() {
        System.runAs(getTestUser()) {
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );
            Case testCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id,
                    Subject = 'VCC_MedsServiceTest',
                    AccountId = testAccount.Id,
                    VCC_Caller_Relation__c = 'Self',
                    VCC_Caller_Name__c = 'Unit Test'
                ),
                true
            );
            VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c(
                    VCC_Case__c = testCase.Id,
                    VCC_Relative_Type__c = 'Self',
                    VCC_Caller_Name_Text__c = 'Test',
                    VCC_Case__r = testCase
                ),
                true
            );

            VCC_MedsService.MedRefillResponse medRefillResponse;

            Test.startTest();
            medRefillResponse = VCC_MedsService.refillMedications(
                progressNote,
                new List<VCC_MedsService.MedRefillRequest>()
            );
            Test.stopTest();

            Assert.isTrue(medRefillResponse.allSuccessful, 'Expected allSuccessful to be true but was not');
            Assert.areEqual(
                testCase.Id,
                medRefillResponse.caseObject.Id,
                'Expected caseObject from med refill to be equal to the original case from this test'
            );
        }
    }

    /**
     * @description tests refill medications when flag is passed as true, positive
     */
    @IsTest
    private static void untiRefillMedicationWithBooleanPassedPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MedsService.MedRefillResponse medRefillResponse = new VCC_MedsService.MedRefillResponse(true);
            Assert.isNotNull(medRefillResponse.caseObject, 'Expected med refill case object to not be null');
            Assert.isNotNull(medRefillResponse, 'Expected class to be initialized.');
            Assert.isTrue(medRefillResponse.allSuccessful, 'Expected med response to be all successfull but was not');
            Test.stopTest();
        }
    }

    /**
     * @description tests refill medications by progress note when id is null, negative
     */
    @IsTest
    private static void refillMedicationsByProgressNoteException1() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_MedsService.refillMedications(
                    new VCC_Progress_Note__c(),
                    new List<VCC_MedsService.MedRefillRequest>()
                );
            } catch (VCC_MedsService.VCC_MedsServiceException e) {
                Assert.areEqual(
                    'Progress Note Id is required',
                    e.getMessage(),
                    'Expected exception messages to match.'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests refill medications by progress note when it doesnt exist, negative
     */
    @IsTest
    private static void refillMedicationsByProgressNoteException2() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                Id fakeProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.sObjectType);
                VCC_MedsService.refillMedications(
                    new VCC_Progress_Note__c(id = fakeProgressNoteId),
                    new List<VCC_MedsService.MedRefillRequest>()
                );
            } catch (VCC_MedsService.VCC_MedsServiceException e) {
                Assert.areEqual('Progress Note not found', e.getMessage(), 'Expected exception messages to match.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests the getPharmacyLog method when bad data is passed in expecting exception, negative
     */
    @isTest
    private static void unitGetPharmacyLogNegative() {
        System.runAs(getTestUser()) {
            VCC_DivaClient.bypassCallout = true;

            Test.startTest();
            VCC_DivaResponse phamacyLog = VCC_MedsService.getPharmacyLog(
                VCC_Enum.VCC_PharmacyLogType.ACTIVITY,
                new VCC_PharmacyLogRQ('123', '99')
            );
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.ERX, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.ECME, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.CMOP, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.COPAY, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.LABEL, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.REFILL, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.PARTIAL, new VCC_PharmacyLogRQ('123', '99'));
            VCC_MedsService.getPharmacyLog(VCC_Enum.VCC_PharmacyLogType.CMOPLOTLOG, new VCC_PharmacyLogRQ('123', '99'));

            Assert.isNull(phamacyLog, 'expected bypass flag to make service return null');

            try {
                VCC_MedsService.getPharmacyLog(null, new VCC_PharmacyLogRQ('123', '99'));
            } catch (Exception ex) {
                Assert.areEqual(
                    'VCC_MedsService.VCC_MedsServiceException',
                    ex.getTypeName(),
                    'Expected meds service exception to be thrown'
                );
            }

            Test.stopTest();
        }
    }
}
