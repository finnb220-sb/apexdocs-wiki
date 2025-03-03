/**
 * This is an exact*** copy of VCC_MockSSOService.
 *
 *  ***modified into a "singleton" style class to allow for stubbing
 */
public with sharing class VCC_MockSSOServiceV2 {
    private final String NOT_CONFIGURED_MSG = 'A Mock SSO Setting has not been configured.';

    public static VCC_MockSSOServiceV2 instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_MockSSOServiceV2();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_MockSSOServiceV2 privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub mockSsoServiceStub = new VCC_Stub(VCC_MockSSOServiceV2.class);
        VCC_MockSSOServiceV2.privateInstance = (VCC_MockSSOServiceV2) mockSsoServiceStub.instance;
        return mockSsoServiceStub;
    }

    public Boolean isMockSSOEnabled() {
        return (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).Enable_SSO_Mocking__c;
    }

    // public Boolean isMockSSOEnabled(){
    //     return this.isMockSSOEnabled(new VCC_OrgSettingsSelector());
    // }

    // private Boolean isMockSSOEnabled(VCC_OrgSettingsSelector orgSettingsSelector){
    //     return orgSettingsSelector.selectByOrgId(UserInfo.getOrganizationId()).Enable_SSO_Mocking__c;
    // }

    public VCC_Mock_SSO_Settings__c getMockSSOSetting() {
        VCC_Mock_SSO_Settings__c msso = (new VCC_MockSSOSettingsSelector()).selectByUserId(UserInfo.getUserId());

        if (msso == null) {
            msso = (new VCC_MockSSOSettingsSelector()).selectByProfileId(UserInfo.getProfileId());
        } else {
            return msso;
        }

        if (msso == null) {
            msso = (new VCC_MockSSOSettingsSelector()).selectOrgDefault();
        } else {
            return msso;
        }

        if (msso == null) {
            throw new MockSSOException(this.NOT_CONFIGURED_MSG);
        }

        return msso;
    }

    public String getMockSSOToken() {
        return getMockSSOSetting().VCC_SSO_Token__c;
    }

    public class MockSSOException extends Exception {
    }
}
