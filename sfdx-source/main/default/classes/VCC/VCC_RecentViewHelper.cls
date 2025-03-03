/**
 * @author VAHC Liberty IT
 * @since 08/2023
 * @description class to create, retrive and acknowlege recent view records
 * @group
 */
public with sharing class VCC_RecentViewHelper {
    public static final string TYPE_FLAGS = 'Flags';
    public static final string TYPE_SENSITIVE_PATIENT = 'SensitivePatient';
    public static final string TYPE_VERIFY_PATIENT = 'VerifyPatient';
    public static final string TYPE_IN_PATIENT = 'InPatient';
    public static final string TYPE_FACILITY_ACCESS = 'FacilityAccess';

    /**
     * @description call to generate or get the latest recent view record for the current user.
     * @param recordId
     *
     * @return VCC_Recent_View__c
     */
    public static VCC_Recent_View__c getRecentView(string recordId) {
        VCC_Recent_View__c recentView;
        List<VCC_Recent_View__c> recentViewList = [
            SELECT
                Id,
                VCC_Account__c,
                VCC_User__c,
                VCC_Type_Facility_Access__c,
                VCC_Type_Flags__c,
                VCC_Type_In_Patient__c,
                VCC_Type_Sensitive_Patient__c,
                VCC_Type_Verify_Patient__c,
                VCC_Is_Acknowledged__c,
                VCC_Pharmacy_Verify_Addresses__c,
                CreatedDate,
                LastModifiedDate,
                UserRecordAccess.HasEditAccess
            FROM VCC_Recent_View__c
            WHERE VCC_User__c = :UserInfo.getUserId()
            WITH USER_MODE
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];

        if (!recentViewList.isEmpty() && recentViewList[0].VCC_Account__c == recordId) {
            recentView = recentViewList[0];
        }

        if (recentView == null) {
            recentView = new VCC_Recent_View__c();
            recentView.VCC_User__c = UserInfo.getUserId();
            recentView.VCC_Account__c = recordId;
            recentView.VCC_Type_Facility_Access__c = false;
            recentView.VCC_Type_Flags__c = false;
            recentView.VCC_Type_In_Patient__c = false;
            recentView.VCC_Type_Sensitive_Patient__c = false;
            recentView.VCC_Type_Verify_Patient__c = false;
            recentView.VCC_Is_Acknowledged__c = false;

            if (Schema.sObjectType.VCC_Recent_View__c.isCreateable()) {
                Database.insert(recentView, AccessLevel.USER_MODE);
            }
        }

        return recentView;
    }

    /**
     * @description call to acknowledge a recent view type.
     * @param recordId
     * @param type
     *
     * @return Boolean
     */
    public static boolean acknowledge(string recordId, string vccType) {
        VCC_Recent_View__c recentView = getRecentView(recordId);

        if (vccType == TYPE_FLAGS)
            recentView.VCC_Type_Flags__c = true;
        if (vccType == TYPE_SENSITIVE_PATIENT)
            recentView.VCC_Type_Sensitive_Patient__c = true;
        if (vccType == TYPE_VERIFY_PATIENT)
            recentView.VCC_Type_In_Patient__c = true;
        if (vccType == TYPE_FACILITY_ACCESS)
            recentView.VCC_Type_Facility_Access__c = true;
        if (vccType == TYPE_IN_PATIENT)
            recentView.VCC_Type_In_Patient__c = true;

        recentView.VCC_Is_Acknowledged__c = (recentView.VCC_Type_Facility_Access__c &&
        recentView.VCC_Type_Flags__c &&
        recentView.VCC_Type_In_Patient__c &&
        recentView.VCC_Type_Sensitive_Patient__c &&
        recentView.VCC_Type_Verify_Patient__c);

        if (recentView.UserRecordAccess.HasEditAccess && Schema.sObjectType.VCC_Recent_View__c.isUpdateable()) {
            Database.SaveResult result = Database.update(recentView);
            return result.isSuccess();
        }

        return false;
    }

    /**
     * @description call to generate or get the latest recent view record for the current user for use in Flow.
     * @param recordId
     * @param type
     *
     * @return VCC_Recent_View__c
     */
    @InvocableMethod(Label='Get Recent View Record' Description='Get the recent view record for this account.')
    public static List<VCC_Recent_View__c> getRecentView(List<String> recordIds) {
        VCC_Recent_View__c recentView = VCC_RecentViewHelper.getRecentView(recordIds[0]);
        return new List<VCC_Recent_View__c>{ recentView };
    }
}
