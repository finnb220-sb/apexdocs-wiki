/**
 * @description
 * @author Kumar Balan
 * @since 5/20/2021
 * @group Helpers/Utilities
 */
public inherited sharing class VCC_ApiSettingUtility {
    public static final String ENV_PROD = 'PROD';
    public static final String ENV_TEST = 'TEST';

    private static VCC_API_Setting__mdt apiSetting;

    /**
     * @description Returns the VCC API custom setting.
     * @return VCC_API_Setting__mdt
     */
    public static VCC_API_Setting__mdt getInstance() {
        if (apiSetting == null) {
            apiSetting = new VCC_ApiSettingUtility().getApiSetting();
        }
        return apiSetting;
    }

    /**
     * @description Returns the VCC Environment as a string.
     * @return String
     */
    public static String getEnviornment() {
        return getInstance().VCC_Enviornment__c;
    }

    /**
     * @description Performs SOQL to retrieve the VCC API Setting.
     * @return VCC_API_Setting__mdt
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public VCC_API_Setting__mdt getApiSetting() {
        VCC_API_Setting__mdt apiSettingObj = [
            SELECT Id, VCC_AssigningAuthority__c, VCC_Callout_Timeout__c, VCC_Enviornment__c
            //VCC_Api_Key__c
            FROM VCC_API_Setting__mdt
            WHERE DeveloperName = 'VCC_Credentials'
        ];
        return apiSettingObj;
    }
}
