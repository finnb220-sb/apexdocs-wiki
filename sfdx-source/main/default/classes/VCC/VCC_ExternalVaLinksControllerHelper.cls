/**
 * @description Helper class for the VCC_ExternalVaLinksController
 * @author Booz Allen Hamilton
 * @since 05/2024
 *
 */
public with sharing class VCC_ExternalVaLinksControllerHelper {
    @TestVisible
    private static Datetime testingDatetime;

    /**
     * @description creates and returns a User UI Event
     * @return User_UI_Event__c - Object for creating
     */
    public User_UI_Event__c createUserUIEventRecord() {
        User_UI_Event__c clickedLink = new User_UI_Event__c();
        clickedLink.UserUI_Time_e911_Link_was_Clicked__c = testingDatetime ?? System.now();
        clickedLink.UserUI_Provider_s_VISN__c = tucCommonUtils.getUserDivisionVISN();
        clickedLink.UserUI_Provider_s_Name__c = UserInfo.getUserId();
        return clickedLink;
    }
}
