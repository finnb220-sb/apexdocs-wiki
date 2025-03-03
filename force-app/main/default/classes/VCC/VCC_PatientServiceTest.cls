@IsTest
public with sharing class VCC_PatientServiceTest {
    private static String username = 'patientserv';

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

    /**
     * @description Creates an admin test user
     * @return      `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
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
            .build(true);
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
        Account a = new Account(
            VCC_MVI_External_Id__pc = 'hi',
            LastName = 'hi',
            RecordTypeId = Account.SObjectType.getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('PersonAccount')
                .getRecordTypeId()
        );
        insert a;
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                HttpResponse mockResponse = new HttpResponse();
                mockResponse.setBody(JSON.serialize(new VCC_MpiRetrieveRS()));
                VCC_HttpOverride_Mock.mockAll(mockResponse);
                Assert.isNull(
                    VCC_PatientService.getLocalPidForSite(a.Id, '999'),
                    'Expected getLocalPidForSite to return null.'
                );
                Assert.isNull(
                    VCC_PatientService.getLocalPidForSite('testval', '999'),
                    'Expected getLocalPidForSite to return null.'
                );
            } catch (Exception thrownException) {
                Assert.fail(
                    'Unexpected exception: ' + thrownException.getMessage() + thrownException.getStackTraceString()
                );
            }
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

        Test.startTest();
        patientVisits = VCC_PatientService.getAllVisits('mvi_id');
        Test.stopTest();

        System.assert(patientVisits != null, 'Visits not returned.');
    }

    @IsTest
    public static void getVisitsByDateTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVisitMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<VCC_PatientVisit> patientVisits;
        Test.startTest();
        patientVisits = VCC_PatientService.getVisitsByDate(
            'mvi_id',
            Datetime.newInstance(0, 0, 0),
            Datetime.newInstance(0, 0, 0)
        );
        Test.stopTest();

        System.assert(patientVisits != null, 'Visits not returned.');
    }

    @IsTest
    public static void getAllergiesTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAllergyMockResponse');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        List<VCC_PatientAllergy> patientAllergies;

        Test.startTest();
        patientAllergies = VCC_PatientService.getAllergies('mvi_id');
        Test.stopTest();

        System.assert(patientAllergies != null, 'Allergies not returned.');
    }

    @IsTest
    public static void unitGetVisitRelatedTosPositive() {
        System.runAs(createTestAdminUser()) {
            VCC_Vdif_PatientAndProviderParams patientAndProviderParams = new VCC_Vdif_PatientAndProviderParams();
            patientAndProviderParams.providerLoginSiteCode = 'test';
            patientAndProviderParams.providerName = 'test';
            patientAndProviderParams.providerUserId = 'test';
            patientAndProviderParams.patientLocalPid = 552164224;
            patientAndProviderParams.patientLocalSiteId = 'test';

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            VCC_VdifSelectPatientRS.VisitRelatedTO visitrelatedTos;
            Test.startTest();
            visitrelatedTos = VCC_PatientService.getVisitRelatedTos(patientAndProviderParams, createProgressNoteId());
            Test.stopTest();

            Assert.isTrue(
                visitrelatedTos.serviceConnected,
                'Expected serviceConnected to be "true" from static resource.'
            );
        }
    }

    @IsTest
    public static void getSELECTPatientDataTest() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifSelectPatientMockResponse');
            Test.setMock(HttpCalloutMock.class, mock);

            List<VCC_PatientService.PatientToAura> selectData;
            List<String> localPIDList = new List<String>{ '552164224', '552163951' };
            Test.startTest();
            selectData = VCC_PatientService.getSELECTPatientData(
                'test',
                'test',
                'test',
                localPIDList,
                'test',
                createProgressNoteId()
            );
            Test.stopTest();

            Assert.isTrue(selectData[0].ssn == '666780987', 'Expected ssn to be 666780987 from static resource.');
        }
    }

    @isTest
    public static void getVitalsAsStringTest() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgVitalsMock');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        try {
            Assert.isNotNull(
                VCC_PatientService.getVitalsAsString('test', 'test'),
                'Expected getVitalsAsString to not return null.'
            );
            Assert.isNull(
                VCC_PatientService.getLocalPidForSite('test', 'test'),
                'Expected getLocalPidForSite to return null. '
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Unexpected exception: ' + thrownException.getMessage() + thrownException.getStackTraceString()
            );
        }

        Test.stopTest();
    }

    @IsTest
    static void patientToAuraTest() {
        Test.startTest();
        VCC_DASSelectPatientRS.PatientTO patientTo = new VCC_DASSelectPatientRS.PatientTO();
        try {
            VCC_PatientService.PatientToAura p2a = new VCC_PatientService.PatientToAura(patientTo);
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
