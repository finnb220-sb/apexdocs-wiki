/**
 * @author VAHC Liberty IT
 * @since 9/2/2021
 * @description
 * @group
 */
public with sharing class VCC_RecentViewModule extends VCC_ModuleService.Module {
    VCC_AccountModule accountModule = (VCC_AccountModule) VCC_ModuleService.getModule(VCC_AccountModule.class);
    VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

    public static final String TYPE_SENSITIVE_PATIENT = 'SensitivePatient';
    public static final String TYPE_VERIFY_PATIENT = 'VerifyPatient';
    public static final String TYPE_IN_PATIENT = 'InPatient';
    public static final String TYPE_FACILITY_ACCESS = 'FacilityAccess';
    public static final String TYPE_FLAGS = 'Flags';

    @TestVisible
    private final String INVALID_VIEW_TYPE_MSG = 'The VCC_Type__c value specified is invalid. Ensure the picklist value exists for VCC_Recent_View__c.VCC_Type__c.';
    @TestVisible
    private final String INVALID_ID_MSG = 'The record Id provided is not a VCC_Recent_View__c Id';

    /**
     * @description
     * @param type
     *
     * @return Boolean
     */
    public Boolean isValidRecentViewType(String type) {
        List<Schema.PicklistEntry> picklistEntries = VCC_Recent_View__c.VCC_Type__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) {
            if (picklistEntry.getLabel() == type) {
                return true;
            }
        }
        return false;
    }

    /**
     * @description
     * @param type
     *
     * @return
     */
    public void validateRecentViewType(String type) {
        if (!isValidRecentViewType(type)) {
            throw new RecentViewModuleException(INVALID_VIEW_TYPE_MSG);
        }
    }

    // public void validateRecentViewId(Object recordId){
    //     if (!idModule.isIdOfType(recordId, VCC_Recent_View__c.getSObjectType())){
    //         throw new RecentViewModuleException(INVALID_ID_MSG);
    //     }
    // }

    /**
     * @description call to acknowledge recent view record for a specified patien.
     * @param recordId
     * @param type
     *
     * @return
     */
    public void acknowledgeRecentView(string recordId, string vccType) {
        validateRecentViewType(vccType);

        VCC_Recent_View__c recentView = VCC_RecentViewHelper.getRecentView(recordId);
        VCC_RecentViewHelper.acknowledge(recordId, vccType);
    }

    // public VCC_Recent_View__c getRunningUsersMostRecentViewOfType(String type){

    //     return

    // }

    /**
     * @description call to generate or get the latest recent view record for the current user.
     * @param recordId
     * @param type
     *
     * @return VCC_Recent_View__c
     */
    public VCC_Recent_View__c insertNewRecentView(Object accountId, String type) {
        accountModule.validateAccountId(accountId);
        validateRecentViewType(type);

        VCC_Recent_View__c recentView = new VCC_Recent_View__c(
            VCC_Account__c = (Id) accountId,
            VCC_Type__c = type,
            VCC_User__c = UserInfo.getUserId(),
            VCC_Is_Acknowledged__c = false
        );

        Database.insert(recentView, AccessLevel.USER_MODE);

        return recentView;
    }

    /**
     * @author VAHC Liberty IT
     * @since 9/2/2021
     * @description
     * @group
     */
    public class RecentViewModuleException extends Exception {
    }
}
