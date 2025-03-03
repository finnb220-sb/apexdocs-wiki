@isTest
public with sharing class VCC_PatientServiceV2Test {
    private static String username = 'patientserv2';

    @TestSetup
    static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testUser);
        testUser.Username = username + testUser.Username;
        update testUser;
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    /**
     * @description Creates progress note record
     * @return      `Id` record Id
     */
    private static Id createProgressNoteId() {
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            )
        );
        return testProgressNote.Id;
    }

    @IsTest
    static void getPidForSiteTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            Account a = new Account(
                VCC_MVI_External_Id__pc = 'hi',
                LastName = 'hi',
                RecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount')
                    .getRecordTypeId()
            );
            insert a;
            HttpResponse mockResponse = new HttpResponse();
            mockResponse.setBody(JSON.serialize(new VCC_MpiRetrieveRS()));
            VCC_HttpOverride_Mock.mockAll(mockResponse);
            String s = VCC_PatientServiceV2.instance.getLocalPidForSite(a.Id, '999');
            VCC_PatientServiceV2.instance.getLocalPidForSite('testval', '999');
            // We are getting a null value back from these callouts because VCCMPIClient.mpiRetrieve() is set up to always throw an excpetion when Test.isRunningTest()
            System.assert(s == null, 'PID was not successfully retrieved');
        }
        Test.stopTest();
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub patientServiceStub = VCC_PatientServiceV2.stub();

            System.assert(
                VCC_PatientServiceV2.instance === (VCC_PatientServiceV2) patientServiceStub.instance,
                'Expected to find stubbed object.s'
            );
        }
        Test.stopTest();
    }

    @IsTest
    public static void getAllVisitsTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVisitMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<VCC_PatientVisit> patientVisits;
        System.runAs(getTestUser()) {
            Test.startTest();
            patientVisits = VCC_PatientServiceV2.instance.getAllVisits('mvi_id');
            Test.stopTest();

            System.assert(patientVisits != null, 'Visits not returned.');
        }
    }

    @IsTest
    public static void getVisitsByDateTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVisitMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            List<VCC_PatientVisit> patientVisits;
            Test.startTest();
            patientVisits = VCC_PatientServiceV2.instance.getVisitsByDate(
                'mvi_id',
                Datetime.newInstance(0, 0, 0),
                Datetime.newInstance(0, 0, 0)
            );
            Test.stopTest();

            System.assert(patientVisits != null, 'Visits not returned.');
        }
    }

    @IsTest
    public static void getAllergiesTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAllergyMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<VCC_PatientAllergy> patientAllergies;

        System.runAs(getTestUser()) {
            Test.startTest();
            patientAllergies = VCC_PatientServiceV2.instance.getAllergies('mvi_id');
            Test.stopTest();

            System.assert(patientAllergies != null, 'Allergies not returned.');
        }
    }

    @IsTest
    public static void unitGetVisitRelatedTosPositive() {
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
        patientAndProviderParams.providerLoginSiteCode = 'test';
        patientAndProviderParams.providerName = 'test';
        patientAndProviderParams.providerUserId = 'test';
        patientAndProviderParams.patientLocalPid = 12345;
        patientAndProviderParams.patientLocalSiteId = 'test';

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            VCC_VdifSelectPatientRS.VisitRelatedTO visitrelatedTos;
            Test.startTest();
            visitrelatedTos = VCC_PatientServiceV2.instance.getVisitRelatedTos(
                patientAndProviderParams,
                createProgressNoteId()
            );
            Test.stopTest();

            System.assert(
                visitrelatedTos.serviceConnected == true,
                'Expected serviceConnected to be "true" from static resource.'
            );
        }
    }
}
