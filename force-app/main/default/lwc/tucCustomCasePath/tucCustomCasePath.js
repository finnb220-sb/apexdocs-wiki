import { LightningElement, track, api } from 'lwc';
import { subscribe } from 'lightning/empApi';
import getCaseData from '@salesforce/apex/TUC_CustomCasePathController.getCaseData';
import getPickListLabels from '@salesforce/apex/TUC_CustomCasePathController.getPickListLabels';
import updateCaseWithJSONString from '@salesforce/apex/TUC_CustomCasePathController.updateCaseWithJSONString';
import isTedMP from '@salesforce/customPermission/TED_Medical_Provider';
import isTedRN from '@salesforce/customPermission/TED_RN';
import isTeleTCT from '@salesforce/customPermission/Tele_EC_TCT_User';
import currentUserId from '@salesforce/user/Id';

/**
 * @description LWC to add a custom Path component for the Tele-EC Case page. It includes custom actions for progressing the case between various statuses.
 * @author            : Booz Allen
 */
export default class TucCustomCasePath extends LightningElement {
    @api statusAPIList;
    @api recordId;
    @track statusList = [];
    @track pathMap = [];
    @track caseRecord;
    currentStatus = 'New';
    selectedStatus;
    statusListReady = false;
    isLoading = true;
    isShowMsg = false;
    isDisabled = true;
    hasData = false;
    buttonDisable = true;
    _interval;
    msg;

    genModal = false;
    flowModal = false;
    modalTitle = 'Update Record';
    modalMessage = 'Are you sure you want to update this record?';
    targetClose = false;
    readyForMpNurse = false;
    reassignToQueue = false;
    updateOwner = false;
    modalButtonLabel = 'Update';
    modalButtonDisable = false;
    modalButtonShow = true;
    flowName;
    flowInputVar;
    flowBlockRefresh = false;

    /**
     * @description Runs on page load, gets case data to load the path correctly, and fetches a list of Tele-EC statuses to build the path out.
     */
    connectedCallback() {
        this.fetchCaseData();
        this.setStatusList();
        this.handleSubscribe();
    }

    /**
     * @description Runs from load. Retrieves case data from Apex using the recordId. This data is used to set the current status.
     */
    fetchCaseData() {
        getCaseData({
            caseId: this.recordId
        })
            .then((result) => {
                this.error = undefined;
                this.isLoading = false;
                if (result === undefined || result.length === 0) {
                    this.msg = 'No Case was returned';
                    this.isShowMsg = true;
                    this.hasData = false;
                } else {
                    this.hasData = true;
                    this.isShowMsg = false;
                    this.caseRecord = result;
                    this.currentStatus = result.Status;
                }
            })
            .catch((error) => {
                this.error = error;
                this.caseRecord = undefined;
                this.isLoading = false;
                this.isShowMsg = true;
                this.hasData = false;
                this.msg = 'There was an issue while fetching the Case';
                const logger = this.template.querySelector('c-logger');
                logger.error(this.msg);
                logger.error(' --> ' + JSON.stringify(this.error.message));
                logger.saveLog();
            });
    }

    /**
     * @description Runs on load. Retrieves a list of Tele-EC statuses set by property on the page.
     * These statuses are then retrieved from Apex to get the correct API names and then embedded into the path component.
     */
    setStatusList() {
        try {
            let statusString = this.statusAPIList;
            if (statusString === undefined) {
                statusString = 'New,Patient Call Back,TED Nurse Encounter,Ready for MP,TED MP Encounter,Closed';
            }
            this.statusList = statusString.toString().split(',');

            getPickListLabels({
                providedValues: this.statusList
            })
                .then((result) => {
                    this.error = undefined;
                    this.isLoading = false;
                    if (result === undefined || result.length === 0) {
                        this.msg = 'No Statuslist was returned';
                        this.isShowMsg = true;
                        this.hasData = false;
                    } else {
                        this.hasData = true;
                        this.isShowMsg = false;
                        this.pathMap = result;
                        this.statusListReady = true;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.pathMap = undefined;
                    this.isLoading = false;
                    this.isShowMsg = true;
                    this.hasData = false;
                    this.msg = 'There was an issue while fetching the Statuses';
                    const logger = this.template.querySelector('c-logger');
                    logger.error(this.msg);
                    logger.error(' --> ' + JSON.stringify(this.error.message));
                    logger.saveLog();
                });
        } catch (err) {
            this.msg = err.message;
            const logger = this.template.querySelector('c-logger');
            logger.error(this.msg);
            logger.error(' --> ' + JSON.stringify(err.message));
            logger.saveLog();
        }
    }

    /**
     * @description Handles setting the selected status when the user clicks on the Path panels.
     * @param event The event variable from the Path component when users click on different Statuses.
     */
    handlePathClick(event) {
        this.selectedStatus = event.target.value;
        if (this.selectedStatus === this.currentStatus) {
            this.buttonDisable = true;
        } else {
            this.buttonDisable = false;
        }
    }

    /**
     * @description Contains logic that sets the action to be taken depending on the selected status and current status.
     * Depending on the action, the modal that pops up will have different states and additional submenus.
     */
    handleStatusComplete() {
        var keyword = 'Update';
        var insufficientPriv = false;
        this.targetClose = false;

        //insufficient privileges first
        if (this.selectedStatus === 'TED MP Encounter' && !isTedMP) {
            insufficientPriv = true;
        } else if (
            (this.selectedStatus === 'TED Nurse Encounter' || this.selectedStatus === 'Ready for MP') &&
            !isTedRN &&
            !isTeleTCT
        ) {
            insufficientPriv = true;
        }

        //anything coming out of New or PCB should update Owner
        if (this.currentStatus === 'New' || this.currentStatus === 'Patient Call Back') {
            this.updateOwner = true;
        }

        //going to Ready for MP uses readyForMP flow
        if (this.selectedStatus === 'Ready for MP') {
            this.readyForMpNurse = true;
        }

        //going back to New or PCB uses the reassignToQueue flow
        if (this.selectedStatus === 'New' || this.selectedStatus === 'Patient Call Back') {
            this.reassignToQueue = true;
        }

        //going to close is a special scenario
        if (this.selectedStatus === 'Closed') {
            let noPerms = !isTedMP && !isTedRN;
            let tedMpNotNewOrMpEncounter =
                (this.currentStatus === 'New' || this.currentStatus === 'TED MP Encounter') && !isTedMP;
            let tedRnNotNewOrRnEncounter =
                (this.currentStatus === 'New' || this.currentStatus === 'TED Nurse Encounter') && !isTedRN;
            if (noPerms || (tedMpNotNewOrMpEncounter && tedRnNotNewOrRnEncounter)) {
                insufficientPriv = true;
            } else {
                keyword = 'Close';
                this.targetClose = true;
            }
        }

        //set fields based on privilege check
        if (insufficientPriv) {
            this.modalTitle = 'Insufficient Privileges';
            this.modalMessage = 'You cannot perform this action.';
            this.modalButtonLabel = 'Disabled';
            this.modalButtonDisable = true;
            this.modalButtonShow = false;
        } else {
            this.modalTitle = keyword + ' Record';
            this.modalMessage = 'Are you sure you want to ' + keyword + ' this record?';
            this.modalButtonLabel = keyword;
        }

        this.openGenModal();
    }

    /**
     * @description Toggles the general modal boolean.
     */
    openGenModal() {
        this.genModal = true;
    }

    /**
     * @description Toggles the flow modal boolean.
     */
    openFlowModal() {
        this.genModal = false;
        this.flowModal = true;
        this.flowBlockRefresh = true;
    }

    /**
     * @description Called by the close button on the modals to reset attributes.
     */
    handleClose() {
        this.resetAttributes();
    }

    /**
     * @description Handler for the confirm button on the general modal.
     * Will consider which action state the modal is in and triggers that action.
     */
    handleConfirm() {
        if (this.reassignToQueue) {
            this.handleAssignToQueue();
        } else if (this.readyForMpNurse) {
            this.handleMpFlow();
        } else if (this.targetClose && isTedRN) {
            this.handleRNCloseFlow();
        } else if (this.targetClose && isTedMP) {
            this.handleMPCloseFlow();
        } else {
            this.handleUpdateStatus();
        }
    }

    /**
     * @description This method is the standard action to update the Case with new data.
     * It builds out a Map for the fields and values for the update, then sends that to Apex to run.
     * Additional fields are put in the map depending on which status is being targeted.
     */
    handleUpdateStatus() {
        let fieldObj = {};
        fieldObj.Status = this.selectedStatus;
        if (this.updateOwner) {
            fieldObj.OwnerId = currentUserId;
        }
        let fieldsJSON = JSON.stringify(fieldObj);

        try {
            updateCaseWithJSONString({
                recordId: this.recordId,
                fieldsJSON: fieldsJSON
            })
                .then((result) => {
                    this.error = undefined;
                    this.isLoading = false;
                    this.genModal = false;
                    this.flowModal = false;
                    if (result === undefined || result.length === 0) {
                        this.msg = 'No update returned';
                    } else {
                        //this.doReload();
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.pathMap = undefined;
                    this.isLoading = false;
                    this.isShowMsg = true;
                    this.hasData = false;
                    this.msg = 'There was an issue while updating the status';
                    const logger = this.template.querySelector('c-logger');
                    logger.error(this.msg);
                    logger.error(' --> ' + JSON.stringify(this.error.message));
                    logger.saveLog();
                });
        } catch (err) {
            this.msg = err.message;
            const logger = this.template.querySelector('c-logger');
            logger.error(this.msg);
            logger.error(' --> ' + JSON.stringify(err.message));
            logger.saveLog();
        }
    }

    /**
     * @description This method is called in order to trigger the Re-assign to Queue Flow
     */
    handleAssignToQueue() {
        this.flowName = 'TED_Re_Assign_to_Queue';
        this.flowInputVar = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            },
            {
                name: 'destinationStatus',
                type: 'String',
                value: this.selectedStatus
            }
        ];
        this.openFlowModal();
    }

    /**
     * @description This method is called in order to trigger the Ready for Consultation Flow.
     */
    handleMpFlow() {
        this.flowName = 'TED_Ready_for_Consultation';
        this.flowInputVar = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
        this.openFlowModal();
    }

    /**
     * @description This method is called in order to trigger the Ready for Consultation Flow.
     */
    handleRNCloseFlow() {
        this.flowName = 'TED_Close_Tele_EC_Case_RN';
        this.flowInputVar = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
        this.openFlowModal();
    }

    /**
     * @description This method is called in order to trigger the Ready for Consultation Flow.
     */
    handleMPCloseFlow() {
        this.flowName = 'TED_Close_Tele_EC_Case_MP';
        this.flowInputVar = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
        this.openFlowModal();
    }
    /**
     * @description This method is triggered by the flows when complete to reset and reload the component and page.
     */
    flowChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.resetAttributes();
            this.doReload();
        }
    }

    /**
     * @description A reload method that reloads the page after a short interval.
     */
    doReload() {
        window.location.reload();
    }

    /**
     * @description Resets all the values on the component back to a base form.
     */
    resetAttributes() {
        this.delInfo = undefined;
        this.modalButtonDisable = false;
        this.modalButtonShow = true;
        this.modalTitle = 'Update Record';
        this.modalMessage = 'Are you sure you want to update this record?';
        this.modalButtonLabel = 'Update';

        this.targetDelete = false;
        this.targetClose = false;

        this.updateOwner = false;
        this.readyForMpNurse = false;
        this.reassignToQueue = false;

        this.genModal = false;
        this.flowModal = false;
        this.flowBlockRefresh = false;
    }

    channelName = '/topic/TeleECCaseStatusTopic';
    subscription;

    /**
     * @description - handles the platform event subscriptions called during the connected callback
     */
    handleSubscribe() {
        if (this.channelName) {
            subscribe(this.channelName, -1, () => {
                if (!this.flowBlockRefresh) {
                    this.fullRefresh();
                }
            }).then((response) => {
                this.subscription = response;
            });
        }
    }

    /**
     * @description - Calls the reset attributes then fetches
     */
    fullRefresh() {
        this.isLoading = true;
        this.resetAttributes();
        this.fetchCaseData();
    }
}
