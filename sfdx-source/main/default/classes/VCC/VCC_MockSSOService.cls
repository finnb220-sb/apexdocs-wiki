/**
 * Deprecated 9/15/2022 see VCC_MockSSOServiceV2
 */
public with sharing class VCC_MockSSOService {
    private static final String NOT_CONFIGURED_MSG = 'A Mock SSO Setting has not been configured.';

    public static Boolean isMockSSOEnabled() {
        return (new VCC_OrgSettingsSelector()).selectByOrgId(UserInfo.getOrganizationId()).Enable_SSO_Mocking__c;
    }

    public static VCC_Mock_SSO_Settings__c getMockSSOSetting() {
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
            throw new MockSSOException(NOT_CONFIGURED_MSG);
        }

        return msso;
    }

    public static String getMockSSOToken() {
        return getMockSSOSetting().VCC_SSO_Token__c;
    }

    public class MockSSOException extends Exception {
    }
}
