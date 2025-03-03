/**
 * Deprecated 9/15/2022 see VCC_ProviderServiceV2
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexDoc')
public with sharing class VCC_ProviderService {
    public static String getProviderDuz(Id userId, String vistaInstance) {
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

    public static List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> getVistaInstanceSettings(Id userId) {
        if (userId == null || userId.getSobjectType() != User.SObjectType) {
            return null;
        }
        VCC_VistaInstanceToUserDUZSelector vistaSettingsSelector = new VCC_VistaInstanceToUserDUZSelector();
        return vistaSettingsSelector.selectByUserId(userId);
    }

    /**
     * @description Used to create IsValidEsig RQ with recordId and calls vdifClient to send http request
     * @param userId `Id` user id
     * @param vistaInstance `String` vista facility/instance
     * @param eSig `String` user's eSignature
     * @param token `String` iam token
     * @param recordId `Id` of progress note or addendum record
     * @return              `Boolean`
     */
    public static Boolean validateEsig(Id userId, String vistaInstance, String eSig, String token, Id recordId) {
        User provider = (new VCC_UserSelector()).selectById(new Set<Id>{ userId })[0];

        VCC_VdifIsValidEsigRQ isValidEsigRQ = new VCC_VdifIsValidEsigRQ(
            vistaInstance,
            provider.LastName + ', ' + provider.FirstName,
            token,
            eSig
        );
        isValidEsigRQ.recordId = recordId;

        VCC_VdifIsValidEsigRS isValidEsigRS = (new VCC_VdifClient()).isValidEsig(isValidEsigRQ);
        if (isValidEsigRS?.isValidEsigTextTO?.text != null && isValidEsigRS?.isValidEsigTextTO?.text != 'True') {
            Logger.info('END ERROR:: response ' + isValidEsigRS);
            Logger.saveLog();
        }

        return (isValidEsigRS?.isValidEsigTextTO?.text != null &&
            isValidEsigRS?.isValidEsigTextTO?.text == 'True')
            ? true
            : false;
    }

    // public static List<Schema.Location> getFacilities(Id userId){
    //     if (userId != null && userId.getSObjectType() == User.SObjectType){

    //         VCC_VistaInstanceToUserDUZSelector vistaToUserDuzSelector = new VCC_VistaInstanceToUserDUZSelector();

    //         Set<String> vistaInstances = new Set<String>();

    //         for (IAM_SSOi_Vista_Instance_to_User_DUZ__c vitud : vistaToUserDuzSelector.selectByUserId(userId)){
    //             vistaInstances.add('vha_'+vitud.VistA_Instance__c);
    //         }

    //         return (List<Schema.Location>) [
    //             SELECT Id, VAF_Facility_ID__c, Name
    //             FROM Location
    //             WHERE VAF_Facility_ID__c IN :vistaInstances
    //         ];

    //     } else {
    //         return null;
    //     }
    // }
}
