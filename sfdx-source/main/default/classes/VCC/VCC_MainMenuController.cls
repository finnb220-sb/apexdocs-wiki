public with sharing class VCC_MainMenuController {
    public static String currentUserProfileId = UserInfo.getProfileId();
    public static String currentUserId = UserInfo.getUserId();

    @AuraEnabled
    public static VCC_MainMenuWrp initData() {
        //Profile profileObj = VCC_QuerySelector.getProfileById(currentUserProfileId);
        //String profileName = profileObj.Name;
        List<String> permissionSetNames = VCC_QuerySelector.getAssignedPermissionSetNames(currentUserId);
        List<String> accessSet = VCC_MainMenuAccessUtility.getAccessibleTabs(permissionSetNames);
        VCC_MainMenuWrp mainMenuWrp = new VCC_MainMenuWrp();
        mainMenuWrp.status = true;
        mainMenuWrp.tabs = accessSet;
        mainMenuWrp.errorMsg = '';
        return mainMenuWrp;
    }
}
