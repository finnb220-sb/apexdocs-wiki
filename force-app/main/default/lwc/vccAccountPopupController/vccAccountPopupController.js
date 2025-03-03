/**
 * @author Booz Allen Hamilton
 * @description JS Module for the similarly named Apex class VCC_AccountPopupController
 * @see vccOnPersonAccountRead
 */
import apex_acknowledgeRecentView from '@salesforce/apex/VCC_AccountPopupController.acknowledgeRecentView';
import apex_getsertRecentView from '@salesforce/apex/VCC_AccountPopupController.getsertRecentView';
import apex_getPopupFlags from '@salesforce/apex/VCC_AccountPopupController.getPopupFlags';
import apex_showOwnAccountPopup from '@salesforce/apex/VCC_AccountPopupController.showOwnAccountPopup';

export const RECENT_VIEW_TYPE = {
    SensitivePatient: 'SensitivePatient',
    VerifyPatient: 'VerifyPatient',
    InPatient: 'InPatient',
    FacilityAccess: 'FacilityAccess',
    Flags: 'Flags'
};

export async function showOwnAccountPopup(accountId) {
    return apex_showOwnAccountPopup({ accountId: accountId });
}

export async function getsertRecentView({ accountId, recentViewType }) {
    return apex_getsertRecentView({
        accountId: accountId,
        recentViewType: recentViewType
    });
}

export async function acknowledgeRecentView({ accountId, recentViewType }) {
    return apex_acknowledgeRecentView({
        accountId: accountId,
        recentViewType: recentViewType
    });
}

/**
 * @description Return structure of function getPopupFlags.
 * Essentially a 'copy' of Apex class VCC_AccountPopupController.PopupResponseDTO.
 * Import this class with getPopupFlags to construct a 'typed' response from its return value.
 */
export class PopupResponseDTO {
    isShowSensitivePatientPopup;
    isShowVerifyPatientPopup;
    isFacilityAccessPopup;
    isShowOwnPatientRecordPopup;
    isShowFlagsPopup;
    isBypassVerifyCaller;
    isShowVerifyPatientAddressPopup;

    /**
     * The structure of the result from getPopupFlags
     * @param {Object} getPopupFlagsResponse the response object from getPopupFlags
     * @param {boolean} getPopupFlagsResponse.isShowSensitivePatientPopup flag from the response
     * @param {boolean} getPopupFlagsResponse.isShowVerifyPatientPopup flag from the response
     * @param {boolean} getPopupFlagsResponse.isFacilityAccessPopup flag from the response
     * @param {boolean} getPopupFlagsResponse.isShowOwnPatientRecordPopup flag from the response
     * @param {boolean} getPopupFlagsResponse.isShowFlagsPopups flag from the response
     * @param {boolean} getPopupFlagsResponse.isBypassVerifyCaller flag from the response
     * @param {boolean} getPopupFlagsResponse.isShowVerifyPatientAddressPopup flag from the response
     */
    constructor({
        isShowSensitivePatientPopup = true,
        isShowVerifyPatientPopup = true,
        isFacilityAccessPopup = true,
        isShowOwnPatientRecordPopup = true,
        isShowFlagsPopup = true,
        isShowVerifyPatientAddressPopup = true,
        isBypassVerifyCaller = false
    } = {}) {
        this.isShowSensitivePatientPopup = isShowSensitivePatientPopup;
        this.isShowVerifyPatientPopup = isShowVerifyPatientPopup;
        this.isFacilityAccessPopup = isFacilityAccessPopup;
        this.isShowVerifyPatientAddressPopup = isShowVerifyPatientAddressPopup;
        this.isShowOwnPatientRecordPopup = isShowOwnPatientRecordPopup;
        this.isShowFlagsPopup = isShowFlagsPopup;
        this.isBypassVerifyCaller = isBypassVerifyCaller;
    }
}

/**
 * This function calls apex to access the database for the latest VCC_Recent_View__c record for the given account Id
 * as well as which pop-ups to display.
 * @param { accountId } `Object` containing the account Id under tag name "accountId"
 * @returns `PopupResponseDTO` containing each popup flag
 */
export async function getPopupFlags({ accountId }) {
    return apex_getPopupFlags({ accountId: accountId });
}
