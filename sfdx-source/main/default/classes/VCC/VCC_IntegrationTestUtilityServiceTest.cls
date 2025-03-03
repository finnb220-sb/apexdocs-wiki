@IsTest
public with sharing class VCC_IntegrationTestUtilityServiceTest {
    private static String username = 'testRunService';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub stub = VCC_IntegrationTestUtilityService.stub();
        System.assert(VCC_IntegrationTestUtilityService.instance === stub.instance, 'Expected privateInstance to be stub.');
        Test.stopTest();
    }

    @IsTest
    static void assertTestSad() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_IntegrationTestUtilityService.AssertFailedException expectedException;

            try {
                VCC_IntegrationTestUtilityService.instance.assert(false, 'test');
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                expectedException = e;
            }

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains('test'), 'Expected exception message to be "test".');
        }
        Test.stopTest();
    }

    @IsTest
    static void assertTestHappy() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_IntegrationTestUtilityService.AssertFailedException unexpectedException;

            try {
                VCC_IntegrationTestUtilityService.instance.assert(true, 'test');
            } catch (VCC_IntegrationTestUtilityService.AssertFailedException e) {
                unexpectedException = e;
            }

            System.assert(unexpectedException == null, 'Expected no exception.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getVdifTestRunConfigDataStubTestHappy() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub testConfigSelectorStub = new VCC_Stub(VCC_TestConfigurationDataSelector.class);
            VCC_TestConfigurationDataSelector testConfigSelector = (VCC_TestConfigurationDataSelector) testConfigSelectorStub.instance;
            List<VCC_Test_Configuration_Data__c> configList = new List<VCC_Test_Configuration_Data__c>{
                new VCC_Test_Configuration_Data__c(
                    RecordTypeId = VCC_Test_Configuration_Data__c.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('VCC_Vdif_Test_Patient').getRecordTypeId(),
                    VCC_Service__c = 'PharmacyI',
                    VCC_Site_Code__c = '983',
                    VCC_Org_Type__c = (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).vccType__c,
                    VCC_ICN__c = 'test'
                )
            };

            testConfigSelectorStub.setReturnValue('selectVdifTestPatientData', configList);

            List<VCC_Test_Configuration_Data__c> returnValue = VCC_IntegrationTestUtilityService.instance.getVdifTestRunConfigData(new List<String>{ '' }, testConfigSelector);

            testConfigSelectorStub.assertInvoked('selectVdifTestPatientData');
            System.assert(returnValue === configList, 'Expected lists to match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getVdifTestRunConfigDataStubTestSad() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Stub testConfigSelectorStub = new VCC_Stub(VCC_TestConfigurationDataSelector.class);
            VCC_TestConfigurationDataSelector testConfigSelector = (VCC_TestConfigurationDataSelector) testConfigSelectorStub.instance;
            List<VCC_Test_Configuration_Data__c> configList = new List<VCC_Test_Configuration_Data__c>{};
            testConfigSelectorStub.setReturnValue('selectVdifTestPatientData', configList);

            List<VCC_Test_Configuration_Data__c> returnValue = VCC_IntegrationTestUtilityService.instance.getVdifTestRunConfigData(null, testConfigSelector);

            testConfigSelectorStub.assertNotInvoked('selectVdifTestPatientData');
            System.assert(true, 'Implied assert.');
        }
        Test.stopTest();
    }
}
