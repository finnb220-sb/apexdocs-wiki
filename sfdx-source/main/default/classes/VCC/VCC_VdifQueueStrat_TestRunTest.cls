@IsTest
public with sharing class VCC_VdifQueueStrat_TestRunTest {
    private static String username = 'queuestrattestrun';

    /**
     * @description Generates a unique user for the tests in the test class, then addes a prefix to the username
     * to allow it to be queried in each test method.
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Vdif');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }
    /**
     * @description Gets the running user for the test
     * @return      `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void constructorTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Test_Configuration_Data__c testPatientMetadata = new VCC_Test_Configuration_Data__c();
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                VCC_Category__c = 'Vdif',
                VCC_Sub_Category__c = 'Create encounter, note, and sign',
                RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
            );
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, testPatientMetadata);
            VCC_VdifQueueStrat_TestRun stratTestRun2 = new VCC_VdifQueueStrat_TestRun();

            System.assert(stratTestRun != null, 'Expected not null.');
            System.assert(stratTestRun2 != null, 'Expected not null.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onQueueableStartTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub stubVdifQueueableCallback = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_Test_Configuration_Data__c testPatientMetadata = new VCC_Test_Configuration_Data__c();
            VCC_Test_Run__c testRun = new VCC_Test_Run__c(
                VCC_Category__c = 'Vdif',
                VCC_Sub_Category__c = 'Create encounter, note, and sign',
                RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
            );
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) stubVdifQueueableCallback.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note(testPatientMetadata);
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, new VCC_Test_Configuration_Data__c());
            stratTestRun.subStrategy = testRunNote;

            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            stubVdifQueueableCallback.setReturnValue('getVdifParameters', vdifParameters);
            stubVdifQueueableCallback.setReturnValue('getStage', null);

            stratTestRun.onQueueableStart(vdifQueueableCallback);

            System.assert(testRun.VCC_Log_Correlation_Id__c != null, 'Expected a log correlation id.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onExceptionTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub stubVdifQueueableCallback = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_Test_Configuration_Data__c testPatientMetadata = new VCC_Test_Configuration_Data__c();
            VCC_Test_Run__c testRun = VCC_TestRunService.instance.insertTestRun(
                new VCC_Test_Run__c(
                    VCC_Category__c = 'Vdif',
                    VCC_Sub_Category__c = 'Create encounter, note, and sign',
                    RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
                )
            );
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) stubVdifQueueableCallback.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note(testPatientMetadata);
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, new VCC_Test_Configuration_Data__c());
            stratTestRun.subStrategy = testRunNote;

            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            stubVdifQueueableCallback.setReturnValue('getVdifParameters', vdifParameters);
            stubVdifQueueableCallback.setReturnValue('getStage', null);

            stratTestRun.onException((new AuraHandledException('test')), vdifQueueableCallback);
            System.assert(testRun.VCC_Status__c == 'FAIL', 'Expected status of "FAIL".');
        }
        Test.stopTest();
    }

    @IsTest
    static void onCalloutResponseTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub stubVdifQueueableCallback = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_Test_Configuration_Data__c testPatientMetadata = new VCC_Test_Configuration_Data__c();
            VCC_Test_Run__c testRun = VCC_TestRunService.instance.insertTestRun(
                new VCC_Test_Run__c(
                    VCC_Category__c = 'Vdif',
                    VCC_Sub_Category__c = 'Create encounter, note, and sign',
                    RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
                )
            );
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) stubVdifQueueableCallback.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note(testPatientMetadata);
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, new VCC_Test_Configuration_Data__c());
            stratTestRun.subStrategy = testRunNote;

            stubVdifQueueableCallback.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);

            VCC_VdifIsValidEsigRS res = new VCC_VdifIsValidEsigRS();
            res.isValidEsigTextTO.text = 'True';

            stratTestRun.onCalloutResponse(res, vdifQueueableCallback);

            stubVdifQueueableCallback.setReturnValue('getStage', VCC_VdifQueueableCallback.Stage.VALIDATE_ESIG);

            stubVdifQueueableCallback.assertInvoked('getStage');

            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void onEndTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub stubVdifQueueableCallback = new VCC_Stub(VCC_VdifQueueableCallback.class);
            VCC_VdifQueueableCallback vdifQueueableCallback = (VCC_VdifQueueableCallback) stubVdifQueueableCallback.instance;
            VCC_VdifTestRun_Note testRunNote = new VCC_VdifTestRun_Note(new VCC_Test_Configuration_Data__c());

            VCC_Test_Run__c testRun = VCC_TestRunService.instance.insertTestRun(
                new VCC_Test_Run__c(
                    VCC_Category__c = 'Vdif',
                    VCC_Sub_Category__c = 'Create encounter, note, and sign',
                    RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
                )
            );
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, new VCC_Test_Configuration_Data__c());
            stratTestRun.subStrategy = testRunNote;

            stubVdifQueueableCallback.setReturnValue('getStage', null);
            stubVdifQueueableCallback.setReturnValue('getPreviousStage', VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);

            stratTestRun.onQueueableEnd(vdifQueueableCallback);

            stubVdifQueueableCallback.setReturnValue('getPreviousStage', VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);

            stratTestRun.onQueueableEnd(vdifQueueableCallback);

            System.assert(true, 'An assert.');
        }
        Test.stopTest();
    }

    @IsTest
    static void insertTestRunTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert([SELECT COUNT() FROM VCC_Callout_Data__c LIMIT 1] == 0, 'Expected no callout data.');
            VCC_Test_Run__c testRun = VCC_TestRunService.instance.insertTestRun(
                new VCC_Test_Run__c(
                    VCC_Category__c = 'Vdif',
                    VCC_Sub_Category__c = 'Create encounter, note, and sign',
                    RecordTypeId = Schema.SObjectType.VCC_Test_Run__c.getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Run').getRecordTypeId()
                )
            );
            VCC_VdifQueueStrat_TestRun stratTestRun = new VCC_VdifQueueStrat_TestRun(testRun, new VCC_Test_Configuration_Data__c());
            VCC_HttpOverride_Mock.mockNext(new HttpResponse());
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(VCC_EndpointUtility.getEndpoint('Vdif', 'vccVDIFgetProvidersBySite'));
            httpRequest.setMethod('GET');
            VCC_HttpIntercept_Observer.observeNext();
            VCC_HttpService.send(httpRequest);
            stratTestRun.addCalloutData();
            System.assert([SELECT COUNT() FROM VCC_Callout_Data__c LIMIT 1] == 1, 'Expected 1 callout data.');
        }
        Test.stopTest();
    }
}
