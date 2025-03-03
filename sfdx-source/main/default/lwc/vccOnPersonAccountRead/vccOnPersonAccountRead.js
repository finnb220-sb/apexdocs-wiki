/**
 * @description Resides on the Lightning Record Page for VAHC PersonAccount's and does 3 main things:
 * 1. Perform a callout to retrieve veteran information from MPI (and display that information, see LWC vccMPITabset)
 * 2. Update the current PersonAccount record with fresh veteran info from MPI (see 'deferredMPIUpdates' use in this file)
 * 3. Display pop-ups
 *
 * Popups in the order in which they are displayed:
 * 1. Own Record - vccOwnPatientRecord
 * 2. Sensitive Patient - vccSensitivePatient
 * 3. Verify Patient - vccVerifyCaller
 * 4. Address Management - vccVistaAddressManagement
 * 5. Deceased Patient - vccDeceasedPatient
 * 6. User Accessible Facilities - vccFacilityAccessModal
 * 7. Inpatient - vccInPatient
 * 8. Flags - vccFlagsModalLauncher
 *
 * @author Booz Allen Hamilton
 */
import { LightningElement, api, track, wire } from 'lwc';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';
import deferredMPIUpdates from '@salesforce/apex/VCC_OnPatientLoadController.deferredMPIUpdates';
import { getPopupFlags, PopupResponseDTO } from 'c/vccAccountPopupController';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import VccSensitivePatient from 'c/vccSensitivePatient';

//LMS
import { publish, subscribe, unsubscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';

import genericError from '@salesforce/label/c.VCC_Generic_Error';
import genericSubError from '@salesforce/label/c.VCC_Generic_Sub_error';

import { MPISharedState } from 'c/scdMPISharedState';
export { MPISharedState } from 'c/scdMPISharedState';

//nebula logger
import LoggerMixin from 'c/loggerMixin';
import ExposedPromise from 'c/exposedPromise';
import AddressesModal from 'c/vccVistaAddressManagement';
import { NavigationMixin } from 'lightning/navigation';

import isEnabled from '@salesforce/apex/VTC_FF.isEnabled';
import getUserVistaList from '@salesforce/apex/VCC_OnPatientLoadController.userVistAs';
export default class VccOnPersonAccountRead extends LoggerMixin(NavigationMixin(LightningElement)) {
    hasBlurredInitially = false;
    isInitialLoad = true;
    isLoading = true;

    latestServiceDate;
    spouseName;

    @track mpiData;

    facilityData;
    userVistaList;
    accessToFacilities;

    @track branchData;
    @track association;

    retrieveVetInfoResult;
    popupFlags = new PopupResponseDTO();

    @api recordId;
    @api isDebugMode; //deprecated
    @api vccOwnAccountWarningTitle; //no modification, goes straight to vccOwnPatientRecord
    @api vccOwnAccountWarningBody; //no modification, goes straight to vccOwnPatientRecord

    subscription = null;
    /**
     * @description Wire the message context from the message service.
     */
    @wire(MessageContext)
    messageContext;
    /**
     * @description Returns isEnabled value from FF library to determine if logged in user should see address management modal.
     */
    hasPharmAddressPermission() {
        return this.wiredIsPharmacyAddressEnabled?.data;
    }

    noConnection = false;
    labels = {
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    connectedCallback() {
        //Subscribe to message channel
        this.subscribeToMessageChannel();
    }

    /**
     * @description disconnectedCallback for vccOnPersonAccountRead. Unsubscribes to the message channel.
     */
    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /**
     * @description A subscription that allows other components to communicate their need for the MPI Data to vccOnPersonAccountRead
     */
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccOnPersonAccountRead,
                (message) => {
                    if (message.callingFor === 'mpiData') {
                        this.publishMPIData();
                    }
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     *@description Publishes the mpiData to the vccOnPersonAccountRead message channel
     */
    publishMPIData() {
        if (this.mpiData) {
            let message = { mpiData: MPISharedState.getData() };
            publish(this.messageContext, vccOnPersonAccountRead, message);
        }
    }

    /**
     * @description Refreshes the state this.mpiData on vccOnPersonAccountRead.
     */
    refreshMPIState() {
        this.mpiData = MPISharedState.getData();
    }
    mpiDataModified;
    facilityList;

    /**
     * @description Wire the isEnabled result from Feature Flagging framework to determine if user should see modals.
     */
    @wire(isEnabled, { featureName: 'VCC_Pharmacy_Address_Management' })
    wiredIsPharmacyAddressEnabled;

    /**
     * @description Method used to retrieve list of Vistas logged in user can access from the OnPatientLoadController.
     * @param data No actual params sent to function, just user context
     * @param error Any errors returned from wired function.
     */
    @wire(getUserVistaList)
    wiredUserVistaList({ data, error }) {
        if (data) {
            let response = data;
            this.userVistaList = [...new Set(response)];
        }
        if (error) {
            this.Logger.error('Error receiving current users Vista access: ', error);
            this.Logger.saveLog();
        }
    }

    /**
     * @description Updates the state of the MPISharedState object. Stores the mpiData in an accessible location.
     * Also calls refreshMPIState to update vccOnPersonAccountRead's mpiData, and publishes the new MPI data for any
     * component that is listening for it.
     */
    updateMPIState(newMPI) {
        MPISharedState.setData(newMPI);

        this.refreshMPIState();
        this.publishMPIData();
    }

    @wire(retrieveVetInfo, { recordId: '$recordId' })
    retrieveVetInfo(result) {
        this.retrieveVetInfoResult = result;
        if (typeof this.recordId !== 'string' || this.recordId.length === 0) {
            return;
        }
        const { data, error } = result;
        if (data) {
            try {
                /**
                 * round-trip stringify/parse below to create a clone of 'data' because its a cached read-only value
                 * intentionally not using safe navigator or null checks so that an error is thrown/handled if data is malformed JSON, or the vetsV3 array is not an array
                 */
                [this.mpiData] = JSON.parse(JSON.stringify(data)).vetsV3;
                this.isLoading = false;
            } catch (anyError) {
                this.handleRetrieveVetInfoError(anyError);
            }
        } else {
            this.handleRetrieveVetInfoError(error);
        }
    }

    /**
     * @description Logs and displays an error recieved from wired retrieveVetInfo method - also, hides blur and loading spinner
     * @param {Object} error Error recieved from wired retrieveVetInfo method
     */
    handleRetrieveVetInfoError(error) {
        this.noConnection = true;
        this.labels.noConnectionMessage = genericError.replace('{0}', 'Connection Error');
        this.refs.blur.hide();
        this.isLoading = false;
        this.Logger.error('Error when retrieving veteran info.');
        this.Logger.error(JSON.stringify(error));
        this.Logger.saveLog();
    }

    async renderedCallback() {
        if (this.hasBlurredInitially === false) {
            this.hasBlurredInitially = true;
            this.refs.blur.show();
        }
        if (this.mpiData === null || typeof this.mpiData !== 'object') {
            return;
        }
        try {
            this.sortContactInformation(this.mpiData);
            this.branchData = this.mpiData.ee?.serviceBranches;
            this.association = this.mpiData.ee?.eeExtendedResponse?.associations;
            if (this.isInitialLoad === true) {
                this.isInitialLoad = false;
                const updateAccountPromise = this.updateAccountWithMpiData();
                const popupFlagsPromise = this.getAndSetPopupFlags();
                await updateAccountPromise;
                await popupFlagsPromise;
                await this.doPopups();
            }
        } catch (anyError) {
            this.refs.blur.hide();
            this.Logger.error(JSON.stringify(anyError));
        } finally {
            this.Logger.saveLog();
        }
    }

    //pop-up order: Own Record -> Sensitive Patient -> Verify Patient -> Deceased -> Facilities -> Inpatient -> Flags
    async doPopups() {
        await this.ownRecord();
        await this.sensitive();
        await this.verify();
        this.filterFacilityListbyPatientandUser();

        if (
            this.hasPharmAddressPermission() &&
            this.accessToFacilities &&
            this.popupFlags.isShowVerifyPatientAddressPopup
        ) {
            if (!(await this.addresses())) {
                return;
            }
        }

        await this.deceased();
        await this.facilities();
        await this.inpatient();
        await this.flags();
        this.refs.blur.hide();
    }

    //#region pop-up methods
    async ownRecord() {
        let popupPromise = new ExposedPromise();

        try {
            this.template.querySelector('c-vcc-own-patient-record').open(popupPromise);
        } catch (e) {
            this.Logger.debug(String(e));
            popupPromise.resolve();
        }

        return popupPromise;
    }
    /**
     * @description We must filter the list of facilities by both patient and user before we display them.
     * This method ensures that we only display what we are allowed to display based on both the user and the patient access.
     */
    filterFacilityListbyPatientandUser() {
        this.mpiDataModified = this.mpiData.mvi.medicalCenterFacilities.filter((item) => {
            return this.userVistaList.includes(item.facilityId);
        });
        this.accessToFacilities = this.mpiDataModified.length > 0;
    }

    async sensitive() {
        return new Promise((resolve) => {
            try {
                //may need to rethink... when MPI is down the patient still may be sensitive,
                //so instead of possibly displaying a sensitive patient, should we give an error???
                if (!this.mpiData) {
                    this.Logger.debug('no mpi data, cannot display sensitive patient pop-up');
                    resolve();
                    return;
                }

                //if sensitive patient, show sensitive patient
                if (this.isSensitivePatient(this.mpiData) && this.popupFlags.isShowSensitivePatientPopup) {
                    this.Logger.debug('sensitive popup');
                    //pass size:undefined to prevent modal "size" property from defaulting to "medium", but also be smaller than the "small" size
                    VccSensitivePatient.open({
                        recordId: this.recordId,
                        label: 'Sensitive Patient',
                        description: 'Sensitive Patient Warning: This is a restricted record',
                        size: undefined
                    }).then((acknowledged) => {
                        if (acknowledged === true) {
                            resolve();
                        } else {
                            this.returnHome();
                        }
                    });
                } else {
                    this.Logger.debug('not showing sensitive pop-up.');
                    resolve();
                }
            } catch (e) {
                this.Logger.debug(String(e));
                resolve();
            }
        });
    }

    async verify() {
        return new Promise((resolve) => {
            try {
                if (this.popupFlags.isShowVerifyPatientPopup) {
                    if (Array.isArray(this.branchData) && this.branchData?.length) {
                        this.sortBranches(this.branchData);
                    }
                    if (Array.isArray(this.association) && this.association?.length) {
                        this.spouseAssociation(this.association);
                    }
                    this.Logger.debug('verify popup');
                    this.template.querySelector('c-vcc-verify-caller').open(resolve);
                } else {
                    this.Logger.debug('not showing verify pop-up');
                    resolve();
                }
            } catch (e) {
                this.Logger.debug(String(e));
                resolve();
            }
        });
    }

    /**
     * @description This will be used to open our address verification modal.
     */
    async addresses() {
        const result = await AddressesModal.open({
            label: 'Address Modal',
            size: 'medium',
            recordId: this.recordId,
            mpiData: this.mpiData
        });
        // if modal closed with X or cancel button, promise returns result = 'undefined' need to program when cancel is clicked just do .close() with no arguments
        if (!result) {
            this.returnHome();
        }
        return result;
    }

    /**
     * @description Navigates user to home page.
     */
    returnHome() {
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    /**
     * @description This will be used to open the address verification modal from button press
     */
    handleAddressModal() {
        AddressesModal.open({
            label: 'Address Modal',
            size: 'medium',
            recordId: this.recordId,
            mpiData: this.mpiData,
            isAccountPage: true
        });
    }

    async deceased() {
        return new Promise((resolve) => {
            try {
                this.Logger.debug('deceased popup');
                this.template.querySelector('c-vcc-deceased-patient').open(resolve);
            } catch (e) {
                this.Logger.debug(String(e));
                resolve();
            }
        });
    }

    async facilities() {
        return new Promise((resolve) => {
            try {
                if (this.popupFlags.isFacilityAccessPopup === true) {
                    this.template.querySelector('c-vcc-facility-acces-modal').show(resolve);
                    this.Logger.debug('open facility pop-up');
                    return;
                }
                this.Logger.debug('do not open facility pop-up');
                resolve();
            } catch (e) {
                this.Logger.debug(String(e));
                resolve();
            }
        });
    }

    async inpatient() {
        let popupPromise = new ExposedPromise();

        try {
            this.Logger.debug('inpatient popup');
            this.template.querySelector('c-vcc-in-patient').open(popupPromise);
        } catch (e) {
            this.Logger.debug(JSON.stringify(e));
        }

        return popupPromise;
    }

    async flags() {
        try {
            if (!this.popupFlags.isShowFlagsPopup) {
                return;
            }
            await this.template.querySelector('c-vcc-flags-modal-launcher').open();
        } catch (thrownError) {
            this.Logger.debug('Failed to open Flag Acknowledgement modal');
            this.Logger.debug(JSON.stringify(thrownError));
        }
    }
    //#endregion

    /**
     * Calls VCC_lwc_utils.deferredMPIUpdates() and waits for all wire adapters to update
     * @returns `Promise` that resolves when all affected wire adapters are updated
     */
    async updateAccountWithMpiData() {
        try {
            await deferredMPIUpdates({
                accountId: this.recordId,
                responseDataString: JSON.stringify(this.retrieveVetInfoResult.data)
            });
            //notify UI that record may have changed and wait until updated information is sent to all affected wire adapters
            return notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        } catch (anyError) {
            this.Logger.debug('Partial or full failure to update account with MPI data');
            this.Logger.debug(JSON.stringify(anyError));
            return Promise.resolve();
        }
    }

    async getAndSetPopupFlags() {
        // no try/catch because popup flags are needed before proceeding with display of popups and the calling method (rendered callback) will catch and log the error
        this.popupFlags = new PopupResponseDTO(await getPopupFlags({ accountId: this.recordId }));
    }

    // Function to dynamically sort phone numbers and addresses using only one iteration
    sortContactInformation(mpiData) {
        const phoneTypePriority = ['HOME', 'MOBILE', 'WORK', 'FAX'];
        const addressPurposePriority = ['CORRESPONDENCE', 'RESIDENCE'];
        let vet = mpiData;
        if (vet?.vaProfileV2?.vaProfileContactInfo) {
            if (Array.isArray(vet.vaProfileV2.vaProfileContactInfo.telephones)) {
                vet.vaProfileV2.vaProfileContactInfo.telephones.sort(
                    (a, b) => phoneTypePriority.indexOf(a.phoneType) - phoneTypePriority.indexOf(b.phoneType)
                );
            }
            if (Array.isArray(vet.vaProfileV2.vaProfileContactInfo.addresses)) {
                vet.vaProfileV2.vaProfileContactInfo.addresses.sort(
                    (a, b) =>
                        addressPurposePriority.indexOf(a.addressPurposeOfUse) -
                        addressPurposePriority.indexOf(b.addressPurposeOfUse)
                );
            }
        }
    }

    async handlePost() {
        this.isLoading = true;
        await refreshApex(this.retrieveVetInfoResult);
    }

    isSensitivePatient(mpiData) {
        // Check for sensitivityFlag or if the account belongs to an employee.
        return (
            mpiData?.vaProfileV2?.vaProfileIdentity?.sensitivityInformation?.sensitivityFlag ||
            RegExp('EMP').test(mpiData?.mvi?.personType)
        );
    }

    /**
     * @description Sorts Branch Data returned by MPI by descending dates
     * @param branchData -  military branch data returned from mpi
     */

    sortBranches(branchData) {
        let objArray = [];
        branchData.forEach((obj) => {
            const newObj = {};
            newObj.serviceEntryDate = obj?.serviceEntryDate;
            newObj.serviceExitDate = obj?.serviceExitDate;
            newObj.serviceBranch = obj?.serviceBranch;
            newObj.serviceNumber = obj?.serviceNumber;
            objArray.push(newObj);
        });

        if (objArray.length) {
            this.latestServiceDate = objArray.reduce((a, b) => (a.serviceEntryDate > b.serviceEntryDate ? a : b));
        }
    }

    /**
     * @description Filters spouse data returned by mpi by either husband or wife
     * @param association - Vet association returned fom mpi
     */
    spouseAssociation(association) {
        let spouseData = association.filter((x) => x.relationship === 'WIFE' || x.relationship === 'HUSBAND');
        let objArray = [];
        spouseData.forEach((obj) => {
            const newObj = {};
            newObj.givenName = obj?.givenName;
            newObj.familyName = obj?.familyName;
            objArray.push(newObj);
        });

        if (objArray.length === 1) {
            this.spouseName = objArray;
        }
    }
}
