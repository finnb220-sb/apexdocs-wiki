/**
 * @description This class is responsible for making HTTP callouts to an external service to retrieve alerts.
 *              It's designed to be used with Lightning Web Components (LWCs) for displaying alerts in Salesforce.
 *              The class includes methods for safely making callouts and handling responses.
 * @see VCC_ViewAlertsTest
 * @see VCR_AlertRepo
 * @see iamSSOiVistaInstanceToUserDUZRepo
 * @see  VCR_SSOMockingRepo
 */
public with sharing class VCC_ViewAlerts {
    private static final String APPLICATION = 'application';
    private static final String VAHC = 'VAHC';
    private static final String FACILITY_ID = 'facilityId';
    private static final String PARSE_ALERT = 'parseAlert';
    private static final String SSO_TOKEN = 'ssoToken';

    @TestVisible
    private static VCR_AlertRepo alertRepo = new VCR_AlertRepo();

    @TestVisible
    private static VTC_RecordModel response = new VTC_RecordModel();

    /**
     * @description Static instance of VCR_IAMSSOiVistaInstToUserDUZRepo.
     */
    @TestVisible
    private static VCR_IAMSSOiVistaInstToUserDUZRepo iamSSOiVistaInstanceToUserDUZRepo {
        get {
            if (iamSSOiVistaInstanceToUserDUZRepo == null) {
                iamSSOiVistaInstanceToUserDUZRepo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
            }
            return iamSSOiVistaInstanceToUserDUZRepo;
        }
        private set;
    }

    /**
     * @description Static instance of VCR_SSOMockingRepo.
     */
    @TestVisible
    private static VCR_SSOMockingRepo orgSettingsRepo {
        get {
            if (orgSettingsRepo == null) {
                orgSettingsRepo = new VCR_SSOMockingRepo();
            }
            return orgSettingsRepo;
        }
        private set;
    }

    /**
     * @description Makes an HTTP POST request to a predefined URL to retrieve alerts.
     *              This method handles the construction and sending of the request, including setting necessary headers.
     *              It returns an AlertResponse object that encapsulates the response data.
     *              Error handling is implemented to return a default response object in case of failure.
     *
     * @return VTC_RecordModel - Object containing alerts data or error message.
     */
    @AuraEnabled
    public static VTC_RecordModel refreshAlerts() {
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> listOfIAMSSOiVistaInstanceUserDUZ = iamSSOiVistaInstanceToUserDUZRepo.fetchByUserId(
            UserInfo.getUserId()
        );
        List<String> listOfFacilities = new List<String>();
        for (IAM_SSOi_Vista_Instance_to_User_DUZ__c iam : listOfIAMSSOiVistaInstanceUserDUZ) {
            listOfFacilities.add(iam.VistA_Instance__c);
        }
        VCC_Mock_SSO_Settings__c setting = VCC_Mock_SSO_Settings__c.getInstance(UserInfo.getUserId());
        Map<String, Object> args = new Map<String, Object>{ APPLICATION => VAHC, PARSE_ALERT => true };
        if (listOfIAMSSOiVistaInstanceUserDUZ != null & !listOfIAMSSOiVistaInstanceUserDUZ.isEmpty()) {
            args.put(FACILITY_ID, listOfFacilities);
        }

        String token;
        // The variable mockSSO determines whether the mock setting is used to login in with CPRS/VistA.
        Boolean mockSSO = true;
        mockSSO = (orgSettingsRepo.fetchByOrgId(UserInfo.getOrganizationId()))[0].Enable_SSO_Mocking__c;
        if (mockSSO == true) {
            //This is a hierarchical custom setting the fields are required so it will never be null.
            VCC_Mock_SSO_Settings__c primarySetting = VCC_Mock_SSO_Settings__c.getInstance(UserInfo.getUserId());
            token = primarySetting.VCC_SSO_Token__c;

            if (token != null && setting.VCC_SSO_Token__c != null && setting.VCC_VistA_Instance__c != null) {
                args.put(SSO_TOKEN, token);
                args.put(FACILITY_ID, new List<String>{ setting.VCC_VistA_Instance__c });
            }
        } else {
            token = IAM_SSOi_OAuthUtility.getVARefreshToken()[0];
            args.put(SSO_TOKEN, token);
        }
        response = alertRepo.fetchAlerts(args);
        return response;
    }
}
