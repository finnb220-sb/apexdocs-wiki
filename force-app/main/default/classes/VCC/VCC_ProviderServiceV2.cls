public with sharing class VCC_ProviderServiceV2 {
    public static VCC_ProviderServiceV2 instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_ProviderServiceV2();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_ProviderServiceV2 privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub providerServiceStub = new VCC_Stub(VCC_ProviderServiceV2.class);
        VCC_ProviderServiceV2.privateInstance = (VCC_ProviderServiceV2) providerServiceStub.instance;
        return providerServiceStub;
    }

    public String getProviderDuz(Id userId, String vistaInstance) {
        if (userId != null && userId.getSObjectType() == User.SObjectType) {
            VCC_VistaInstanceToUserDUZSelector vistaToUserDuzSelector = new VCC_VistaInstanceToUserDUZSelector();

            if (VCC_MockSSOService.isMockSSOEnabled() || Test.isRunningTest()) {
                return vistaToUserDuzSelector.selectByName('mockSSO.' + userId)?.DUZ__c;
            } else {
                return vistaToUserDuzSelector.selectByUserIdAndVistaInstance(userId, vistaInstance)?.DUZ__c;
            }
        } else {
            return null;
        }
    }

    public List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> getVistaInstanceSettings(Id userId) {
        if (userId == null || userId.getSobjectType() != User.SObjectType) {
            return null;
        }
        VCC_VistaInstanceToUserDUZSelector vistaSettingsSelector = new VCC_VistaInstanceToUserDUZSelector();
        return vistaSettingsSelector.selectByUserId(userId);
    }

    public Boolean validateEsig(Id userId, String vistaInstance, String eSig, String token, Id recordId) {
        User provider = (new VCC_UserSelector()).selectById(new Set<Id>{ userId })[0];

        VCC_VdifIsValidEsigRQ isValidEsigRQ = new VCC_VdifIsValidEsigRQ(
            vistaInstance,
            provider.LastName + ', ' + provider.FirstName,
            token,
            eSig
        );
        isValidEsigRQ.recordId = recordId;

        VCC_VdifIsValidEsigRS isValidEsigRS = (new VCC_VdifClient()).isValidEsig(isValidEsigRQ);

        return (isValidEsigRS?.isValidEsigTextTO?.text != null &&
            isValidEsigRS?.isValidEsigTextTO?.text == 'True')
            ? true
            : false;
    }
}
