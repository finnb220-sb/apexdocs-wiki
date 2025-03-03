/**
 * @description        This class is to test the VCC_ViewAlerts
 * @author             Booz Allen Hamilton
 *
 * @see VCC_ViewAlerts
 **/
@IsTest
private class VCC_ViewAlertsTest {
    private static final User VAVET_BASE_USER;
    private static final User SYS_ADMIN_USER;

    static {
        VAVET_BASE_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_Medical_Provider')
            .withStandardData()
            .build(true);

        SYS_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Insert test data
     */
    @TestSetup
    static void makeData() {
        //Create IAM_SSOi_Vista_Instance_to_User_DUZ__c Data
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaDuzSettings = new IAM_SSOi_Vista_Instance_to_User_DUZ__c();
        vistaDuzSettings.Name = '200.12692^';
        vistaDuzSettings.DUZ__c = '123';
        vistaDuzSettings.User_Id__c = VAVET_BASE_USER.ID;
        vistaDuzSettings.VistA_Instance__c = '982';

        VCC_Mock_SSO_Settings__c mockSSO = new VCC_Mock_SSO_Settings__c(
            VCC_VistA_Instance__c = '982',
            VCC_SSO_Token__c = '12345',
            VCC_DUZ__c = '123'
        );

        System.runAs(SYS_ADMIN_USER) {
            VATEST_SObjectFactory.createSObject(vistaDuzSettings, true);
            VATESt_SObjectFactory.createSObject(mockSSO, true);
        }
    }

    @IsTest
    private static void unitTestRefreshAlertsPostive() {
        IAM_SSOi_Vista_Instance_to_User_DUZ__c iamSSOi = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            Name = '200.12692^',
            DUZ__c = '123',
            User_Id__c = VAVET_BASE_USER.ID,
            VistA_Instance__c = '982'
        );
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> iamSSOis = new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>{
            iamSSOi
        };
        VCC_ViewAlerts.iamSSOiVistaInstanceToUserDUZRepo = createIAMSSORepoMock(VAVET_BASE_USER.Id, iamSSOis);

        VCC_Org_Settings__mdt orgSetting = new VCC_Org_Settings__mdt(
            Enable_SSO_Mocking__c = true,
            label = 'sandbox',
            vccType__c = 'QA',
            vccOrgId__c = UserInfo.getOrganizationId(),
            vccIntegrationUser__c = 'test@test.org'
        );
        List<VCC_Org_Settings__mdt> orgSettings = new List<VCC_Org_Settings__mdt>{ orgSetting };
        VCC_ViewAlerts.orgSettingsRepo = createOrgSettingRepoMock(UserInfo.getOrganizationId(), orgSettings);

        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'parseAlert' => true,
            'ssoToken' => '12345',
            'facilityId' => new List<String>{ '982' }
        };
        VCC_ViewAlerts.alertRepo = createAlertRepoMock(args, new VTC_RecordModel());
        VTC_RecordModel alertResponse;
        System.runAs(VAVET_BASE_USER) {
            Test.startTest();
            alertResponse = VCC_ViewAlerts.refreshAlerts();
            Test.stopTest();
        }
        Assert.isTrue(alertResponse != null, 'Expected valid non-null model to be returned.');
    }
    @IsTest
    private static void unitTestIAMSSOIVistaInstanceToUserDUZRepoPostive() {
        VCR_IAMSSOiVistaInstToUserDUZRepo repo;
        System.runAs(VAVET_BASE_USER) {
            Test.startTest();
            repo = VCC_ViewAlerts.iamSSOiVistaInstanceToUserDUZRepo;
            Test.stopTest();
        }
        Assert.isNotNull(repo, 'Expected initialized Repo to be returned.');
    }
    @IsTest
    private static void unitTestOrgSettingsRepoNegative() {
        VCR_SSOMockingRepo repo;
        System.runAs(VAVET_BASE_USER) {
            Test.startTest();
            repo = VCC_ViewAlerts.orgSettingsRepo;
            Test.stopTest();
        }
        Assert.isNotNull(repo, 'Expected initialized Repo to be returned.');
    }

    private static VCR_IAMSSOiVistaInstToUserDUZRepo createIAMSSORepoMock(
        Id arg,
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> returnValue
    ) {
        return (VCR_IAMSSOiVistaInstToUserDUZRepo) new VATEST_StubBuilder(VCR_IAMSSOiVistaInstToUserDUZRepo.class)
            .mockingMethodCall('fetchByUserId')
            .withParameterTypes(Id.class)
            .withParameterValues(arg)
            .returning(returnValue)
            .defineStub();
    }
    private static VCR_SSOMockingRepo createOrgSettingRepoMock(Id arg, List<VCC_Org_Settings__mdt> returnValue) {
        return (VCR_SSOMockingRepo) new VATEST_StubBuilder(VCR_SSOMockingRepo.class)
            .mockingMethodCall('fetchByOrgId')
            .withParameterTypes(Id.class)
            .withParameterValues(arg)
            .returning(returnValue)
            .defineStub();
    }
    private static VCR_AlertRepo createAlertRepoMock(Map<String, Object> arg, VTC_RecordModel returnValue) {
        return (VCR_AlertRepo) new VATEST_StubBuilder(VCR_AlertRepo.class)
            .mockingMethodCall('fetchAlerts')
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(arg)
            .returning(returnValue)
            .defineStub();
    }
}
