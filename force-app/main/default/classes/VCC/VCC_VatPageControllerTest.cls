@IsTest
public with sharing class VCC_VatPageControllerTest {
    private static String username = 'vatpagecontroller';

    /**
     * @description setup test user with perm sets
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Vdif');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    /**
     * @description retrieves the test user Id
     *
     * @return  `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void getTokenTestHappy() {
        VCC_Stub mockSsoServiceStub = VCC_MockSSOServiceV2.stub();
        mockSsoServiceStub.setReturnValue('isMockSSOEnabled', true);
        mockSsoServiceStub.setReturnValue('getMockSSOToken', '12345');

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_VatPageController.getToken() == '12345', 'Expected correct token.');
        }
        mockSsoServiceStub.assertInvoked('isMockSSOEnabled');
        mockSsoServiceStub.assertInvoked('getMockSSOToken');
        Test.stopTest();
    }

    @IsTest
    static void getTokenTestSad() {
        VCC_Stub mockSsoServiceStub = VCC_MockSSOServiceV2.stub();

        mockSsoServiceStub.setReturnValue('isMockSSOEnabled', true);
        mockSsoServiceStub.setException('getMockSSOToken');

        Test.startTest();
        System.runAs(getTestUser()) {
            AuraHandledException expectedException;
            try {
                VCC_VatPageController.getToken();
            } catch (AuraHandledException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'Expected an AuraHandledException.');
        }

        mockSsoServiceStub.assertInvoked('isMockSSOEnabled');
        mockSsoServiceStub.assertInvoked('getMockSSOToken');
        Test.stopTest();
    }

    @IsTest
    static void getRecordTypeIdTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(
                VCC_VatPageController.getRecordTypeId() ==
                VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
                'Expected record type Id\'s to match.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void getUserSitesTestHappy() {
        VCC_Stub providerServiceStub = VCC_ProviderServiceV2.stub();
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> returnValue = new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>{ new IAM_SSOi_Vista_Instance_to_User_DUZ__c() };

        providerServiceStub.setReturnValue('getVistaInstanceSettings', returnValue);

        Test.startTest();
        System.runAs(getTestUser()) {
            List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> sites = VCC_VatPageController.getUserSites();
            System.assert(sites === returnValue, 'Expected exact match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getUserSitesTestSad() {
        VCC_Stub providerServiceStub = VCC_ProviderServiceV2.stub();
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> returnValue;

        providerServiceStub.setReturnValue('getVistaInstanceSettings', returnValue);

        Test.startTest();
        System.runAs(getTestUser()) {
            List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> sites = VCC_VatPageController.getUserSites();
            System.assert(sites.isEmpty(), 'Expected an empty list.');
        }
        Test.stopTest();
    }

    @IsTest
    static void runTestForSiteTestSadFailInsert() {
        Map<String, Object> runTestForSiteParameters = new Map<String, Object>{ 'serviceApiName' => '', 'siteCode' => '', 'esig' => '', 'token' => '', 'duz' => '' };

        VCC_Stub testRunServiceStub = VCC_ModuleService.stubModule(VCC_TestRunService.class);
        VCC_Stub testConfigurationDataSelectorStub = new VCC_Stub(VCC_TestConfigurationDataSelector.class);
        VCC_Stub testRunDomain = new VCC_Stub(VCC_TestRunDomain.class);
        VCC_Stub vdifParametersDomain = new VCC_Stub(VCC_VdifParametersDomain.class);

        runTestForSiteParameters.put('testConfigDataSelector', (VCC_TestConfigurationDataSelector) testConfigurationDataSelectorStub.instance);
        runTestForSiteParameters.put('testRunDomain', (VCC_TestRunDomain) testRunDomain.instance);
        runTestForSiteParameters.put('vdifParametersDomain', (VCC_VdifParametersDomain) vdifParametersDomain.instance);
        testRunServiceStub.setReturnValue('validateVdifTestConfiguration', null);

        testConfigurationDataSelectorStub.setReturnValue(
            'selectVdifTestPatientDataByServiceAndSite',
            new List<VCC_Test_Configuration_Data__c>{ new VCC_Test_Configuration_Data__c() }
        );
        testRunServiceStub.setException('insertTestRun');

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_VatPageController.runTestForSite(runTestForSiteParameters).success == false, 'Expected false.');
        }
        Test.stopTest();
    }

    @IsTest
    static void runTestForSiteTestHappy() {
        VCC_VatPageController.RunTestForSiteParameters runTestForSiteParameters = new VCC_VatPageController.RunTestForSiteParameters(
            new Map<String, Object>{ 'serviceApiName' => '', 'siteCode' => '', 'esig' => '', 'token' => '', 'duz' => '' }
        );

        VCC_Stub testRunServiceStub = VCC_ModuleService.stubModule(VCC_TestRunService.class);
        VCC_Stub testConfigurationDataSelectorStub = new VCC_Stub(VCC_TestConfigurationDataSelector.class);
        VCC_Stub vdifParametersDomain = new VCC_Stub(VCC_VdifParametersDomain.class);

        runTestForSiteParameters.testConfigDataSelector = (VCC_TestConfigurationDataSelector) testConfigurationDataSelectorStub.instance;
        runTestForSiteParameters.vdifParametersDomain = (VCC_VdifParametersDomain) vdifParametersDomain.instance;

        VCC_Test_Configuration_Data__c testConfigData = new VCC_Test_Configuration_Data__c(VCC_Note_Title_IEN__c = 'test', VCC_ICN__c = '1234151', VCC_Location_IEN__c = 'test');

        insert testConfigData;

        testConfigurationDataSelectorStub.setReturnValue('selectVdifTestPatientDataByServiceAndSite', new List<VCC_Test_Configuration_Data__c>{ testConfigData });

        testRunServiceStub.setReturnValue('validateVdifTestConfiguration', null);
        testRunServiceStub.setReturnValue('insertTestRun', null);
        testRunServiceStub.setReturnValue('updateTestRun', null);
        testRunServiceStub.setReturnValue('addCalloutData', null);

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_VatPageController.runTestForSite(runTestForSiteParameters).success == true, 'Expected true.');
        }
        Test.stopTest();
    }

    @IsTest
    static void runTestForSiteTestSadNoConfig() {
        Map<String, Object> runTestForSiteParameters = new Map<String, Object>{ 'serviceApiName' => '', 'siteCode' => '', 'esig' => '', 'token' => '', 'duz' => '' };

        VCC_Stub testRunServiceStub = VCC_ModuleService.stubModule(VCC_TestRunService.class);
        VCC_Stub testConfigurationDataSelectorStub = new VCC_Stub(VCC_TestConfigurationDataSelector.class);
        VCC_Stub testRunDomain = new VCC_Stub(VCC_TestRunDomain.class);
        VCC_Stub vdifParametersDomain = new VCC_Stub(VCC_VdifParametersDomain.class);

        runTestForSiteParameters.put('testConfigDataSelector', (VCC_TestConfigurationDataSelector) testConfigurationDataSelectorStub.instance);
        runTestForSiteParameters.put('testRunDomain', (VCC_TestRunDomain) testRunDomain.instance);
        runTestForSiteParameters.put('vdifParametersDomain', (VCC_VdifParametersDomain) vdifParametersDomain.instance);

        testConfigurationDataSelectorStub.setReturnValue('selectVdifTestPatientDataByServiceAndSite', new List<VCC_Test_Configuration_Data__c>{});
        testRunDomain.setReturnValue('getTestRunCategory', 'test');
        testRunDomain.setReturnValue('getTestRunSubCategory', 'test');

        testRunServiceStub.setReturnValue('validateVdifTestConfiguration', null);
        testRunServiceStub.setReturnValue('insertTestRun', null);
        testRunServiceStub.setReturnValue('updateTestRun', null);
        testRunServiceStub.setReturnValue('addCalloutData', null);

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_VatPageController.runTestForSite(new VCC_VatPageController.RunTestForSiteParameters(runTestForSiteParameters)).success == false, 'Expected false.');
        }
        Test.stopTest();
    }
}
