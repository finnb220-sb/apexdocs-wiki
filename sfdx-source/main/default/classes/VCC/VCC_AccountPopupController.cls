/**
 * @description This class contains AuraEnabled methods used in relation to popup modals that appear when first opening a Person Account in VAHC
 * @author Booz Allen Hamilton
 * @see VCC_AccountPopupControllerTest
 * @see VCC_AccountModule
 * @see VCC_RecentViewHelper
 */
public with sharing class VCC_AccountPopupController {
    private static VCC_AccountModule accountModule = (VCC_AccountModule) VCC_ModuleService.getModule(
        VCC_AccountModule.class
    );

    /**
     * @description If the given Account `Id` is for an Account that belongs to the running user this method returns `Boolean` 'true'.
     * Otherwise returns 'false'.
     * @param accountId The Account `Id` to check against the running user
     * @return `Boolean` whether or not to display the 'Own Account Popup'
     */
    @AuraEnabled
    public static Boolean showOwnAccountPopup(Id accountId) {
        return accountModule.isRunningUsersAccount(accountId);
    }

    /**
     * @description 'get' the most recent view of the specified recentViewType
     * if no record found, or record found does not match the given accountId
     * 'insert' a new recent view and return it.
     * @param accountId The Account `Id` where the popup was shown and acknowledged
     * @param recentViewType The type of popup that was acknowledged
     * @return `VCC_Recent_View__c` new or existing recent view record
     */
    @AuraEnabled
    public static VCC_Recent_View__c getsertRecentView(Id accountId, String recentViewType) {
        return VCC_RecentViewHelper.getRecentView(accountId);
    }

    /**
     * @description When an account popup is acknowledged (viewed and clicked 'ok' or 'next' but not 'cancel')
     * this method is called and the VCC_Recent_View__c record is updated to reflect that fact
     * @param accountId The Account `Id` where the popup was shown and acknowledged
     * @param recentViewType The type of popup that was acknowledged
     */
    @AuraEnabled
    public static void acknowledgeRecentView(Id accountId, string recentViewType) {
        VCC_RecentViewHelper.acknowledge(accountId, recentViewType);
    }

    /**
     * @description an inner class used to construct and serialize the response for the popup flags based on patient account id
     * Invoked from a lwc (vccOnPersonAccountRead) to determine which popups to show
     */
    public class PopupResponseDTO {
        /**
         * @description `Boolean` value indicating whether or not to show the 'Sensitive Patient' popup
         */
        @AuraEnabled
        public Boolean isShowSensitivePatientPopup;

        /**
         * @description `Boolean` value indicating whether or not to show the 'Verify Patient' popup
         */
        @AuraEnabled
        public Boolean isShowVerifyPatientPopup;

        /**
         * @description `Boolean` value indicating whether or not to show the 'Facility Access' popup
         */
        @AuraEnabled
        public Boolean isFacilityAccessPopup;

        /**
         * @description `Boolean` indicating whether or not to show the 'Own Patient Record' popup
         */
        @AuraEnabled
        public Boolean isShowOwnPatientRecordPopup;

        /**
         * @description `Boolean` indicating whether or not to show the 'flags' pop-up
         */
        @AuraEnabled
        public Boolean isShowFlagsPopup;

        /**
         * @description `Boolean` indicating whether or not to show the 'Verify Patient Address' popup
         */
        @AuraEnabled
        public Boolean isShowVerifyPatientAddressPopup;

        /**
         * @description `Boolean` indicating whether or not the running user has the custom permission VCC_Bypass_Caller_Verification
         */
        @AuraEnabled
        public Boolean isBypassVerifyCaller;

        /**
         * @description Determines if the verify caller modal can be bypassed.
         * Marked @TestVisible for unit testing this methods logic in isolation
         * @param recentView the VCC_Recent_View__c record used in part to determine if the verify caller modal should display
         * @param hasBypassPermission Boolean indicating if the running user has permission to bypass the verify caller modal
         */
        @TestVisible
        private void computeVerifyCaller(VCC_Recent_View__c recentView, Boolean hasBypassPermission) {
            this.isShowVerifyPatientPopup = !recentView.VCC_Type_Verify_Patient__c;
            this.isShowVerifyPatientAddressPopup = String.isBlank(recentView.VCC_Pharmacy_Verify_Addresses__c);
            this.isBypassVerifyCaller = hasBypassPermission;
            if (hasBypassPermission) {
                this.isShowVerifyPatientPopup = false;
                this.isShowVerifyPatientAddressPopup = false;
            } else if (recentview.LastModifiedDate < Datetime.now().addMinutes(-10)) {
                this.isShowVerifyPatientPopup = true;
                this.isShowVerifyPatientAddressPopup = true;
            }
        }

        /**
         * @description Constructor for the PopupResponseDTO class
         * @param recentView the `VCC_Recent_View__c` record to retrieve information from
         */
        public PopupResponseDTO(VCC_Recent_View__c recentView) {
            this.isShowSensitivePatientPopup = !recentView.VCC_Type_Sensitive_Patient__c;
            this.isFacilityAccessPopup = !recentView.VCC_Type_Facility_Access__c;
            this.isShowOwnPatientRecordPopup = !recentView.VCC_Type_In_Patient__c;
            this.isShowFlagsPopup = !recentView.VCC_Type_Flags__c;
            this.computeVerifyCaller(recentView, FeatureManagement.checkPermission('VCC_Bypass_Caller_Verification'));
        }

        /**
         * @description empty constructor for testing
         */
        @TestVisible
        private PopupResponseDTO() {
            return;
        }
    }

    /**
     * @description AuraEnabled method to get the popup flags based on the patient account id
     * @param accountId the `Id` of the account to retrieve information for
     * @return PopupResponseDTO object. Lwc will serialize this object to JSON for wire
     */
    @AuraEnabled
    public static PopupResponseDTO getPopupFlags(Id accountId) {
        PopupResponseDTO popupResponse;
        try {
            VCC_Recent_View__c recentView = VCC_RecentViewHelper.getRecentView(accountId);
            popupResponse = new PopupResponseDTO(recentView);
        } catch (Exception anyThrownException) {
            handleGetPopupFlagsException(anyThrownException);
        }
        return popupResponse;
    }

    /**
     * @description handles exceptions thrown from function getPopupFlags
     * Marked @TestVisible for unit testing in isolation from its calling function
     * @param caughtException the exception that was thrown/caught
     */
    @TestVisible
    private static void handleGetPopupFlagsException(Exception caughtException) {
        try {
            throw caughtException;
        } catch (DmlException dmlException) {
            Logger.error(
                'VCC_AccountPopupController.getPopupFlags threw a DmlException when inserting new VCC_Recent_View__c record',
                dmlException
            );
        } catch (QueryException queryException) {
            Logger.error(
                'VCC_AccountPopupController.getPopupFlags threw a QueryException when querying for VCC_Recent_View__c record',
                queryException
            );
        } catch (Exception anyOtherException) {
            Logger.error('VCC_AccountPopupController.getPopupFlags threw an unexpected exception', anyOtherException);
        } finally {
            Logger.saveLog();
            throw VCC_ExceptionUtils.createAuraHandledException(caughtException.getMessage());
        }
    }
}
