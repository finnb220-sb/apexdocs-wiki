import { LightningElement, track, api } from 'lwc';
import { calcTableHeight, calcDivMaxHeight } from './tucAssignFromQueueUtil';
import getObjectRecords from '@salesforce/apex/tucAssignFromQueue.getObjectRecords';
import updateSelectedRow from '@salesforce/apex/tucAssignFromQueue.updateSelectedRow';
import publishEvent from '@salesforce/apex/tucAssignFromQueue.publishEvent';
import getVISNData from '@salesforce/apex/TUC_EscalatePauseButtonController.getVISNData';
import createTeleEcStatusRecord from '@salesforce/apex/TUC_EscalatePauseButtonController.createTeleEcStatusRecord';
import getCurrentStatusRecord from '@salesforce/apex/TUC_EscalatePauseButtonController.getCurrentStatusRecord';
import { subscribe } from 'lightning/empApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import teleECReadOnlyPerm from '@salesforce/customPermission/Tele_EC_Read_Only';
import teleECPausePerm from '@salesforce/customPermission/TED_Pause_Permission';
import teleECTCTPerm from '@salesforce/customPermission/Tele_EC_TCT_User';
/**
 * @description - LWC to add a custom Path component for the Tele-EC Case page. It includes custom actions for progressing the case between various statuses.
 * @author            : Booz Allen
 */
export default class TucAssignFromQueue extends NavigationMixin(LightningElement) {
    @api objectAPI;
    @api channelName;
    @api timeToRefresh = 60; //interval at which the update ticks, in seconds
    @api orderBy;
    @api useStationFiltering;
    @api title;
    @api queueType;
    @api buttonName;
    @api filterClause;
    @api fieldAPIList;
    @api eventObject;
    @track listSize;
    @track records;
    @track sortDirection = '';
    @api sortBy;
    @api maxTableHeight;
    @api minTableHeight;
    @api rowHeight;
    @api wrapLineLimit;
    @api columnDefaultBehavior;
    @track tableHeight;
    columns;
    objectName;
    selectedRows;
    isLoading = true;
    isShow = true;
    isDisabled = true;
    hasData = false;
    msg;

    isCurrentlyPaused = false;
    isPauseButtonDisabled = true;
    isMultiVisnHideMessage = true;
    isInitialized = false;
    buttonLabel;
    statusMsg;
    statusString;
    buttonStyle;
    textStyle;
    openColor = '#286428';
    pausedColor = '#B60000';
    iconName = 'utility:success';
    iconAltText = 'Open';
    iconTitle = 'Open';
    iconStyle;
    visnResult;
    currentVisnStatus;
    hasSingleVisn = false;
    hasNoVisns = false;

    isFirstRender = true;

    picklistValue = 'selectVisn';
    picklistOptions;

    reasonSelected;
    isModalButtonDisabled = true;

    reasonOptions = [
        { label: 'Provider unavailable- service at capacity', value: 'Provider unavailable- service at capacity' },
        { label: 'Provider unavailable- on break', value: 'Provider unavailable- on break' },
        { label: 'Tele-EC closed (after hours)', value: 'Tele-EC closed (after hours)' },
        { label: 'Technical issue (i.e, power outage, wifi)', value: 'Technical issue (i.e, power outage, wifi)' }
    ];

    /**
     * @description Runs on page load, gets case data to load the path correctly, fetches a list of Tele-EC statuses to build the path out, and subscribes to events.
     */
    connectedCallback() {
        this.fetchObjectRecords();

        //Multiplied by 1000 to go from miliseconds -> seconds
        this.progress = this.timeToRefresh * 1000;
        //legacy code
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setInterval(() => {
            this.fullRefresh();
        }, this.progress);

        this.fetchUserVISNs();
        this.handleSubscribe();
        this.isInitialized = true;
    }

    /**
     * @description - variable that checks if the user is read-only or TCT to block accepting cases
     */
    get isAcceptButtonHidden() {
        if (teleECTCTPerm === true || teleECReadOnlyPerm === true) {
            return true;
        }
        return false;
    }

    /**
     * @description - This variable checks that the user has the custom permission to pause Tele-EC VISN escalation, and is not a read-only user
     */
    get isPauseButtonHidden() {
        if (teleECPausePerm === true && teleECReadOnlyPerm !== true) {
            return false;
        }
        return true;
    }

    /**
     * @description - returns a calculated integer for the height of the datatable calculated based on number of records to display
     */
    get datatableHeight() {
        return calcTableHeight(
            this.listSize,
            this.rowHeight,
            this.tableHeight,
            this.minTableHeight,
            this.maxTableHeight
        );
    }

    /**
     * @description - calculates the max height of the div containing the table based on the table height
     */
    get divMaxHeight() {
        return calcDivMaxHeight(this.tableHeight);
    }

    /**
     * @description - called when the user clicks on the accept button and runs an update action to update the record and owner data
     */
    updateRecordOwner() {
        this.isLoading = true;
        this.isDisabled = true;

        let recordId = this.selectedRows[0].Id;
        updateSelectedRow({ recordId: recordId, objectName: this.objectName })
            .then((result) => {
                if (result === 'success') {
                    this.sendUpdateEventThenNavigate(recordId);
                } else if (result.includes('_') && result.split('_')[0] === 'error') {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'The record has been already claimed by ' + result.split('_')[1],
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;
                } else if (result === 'error') {
                    const event = new ShowToastEvent({
                        title: 'Error',
                        message: 'The record is being claimed',
                        variant: 'error',
                        mode: 'sticky'
                    });
                    this.dispatchEvent(event);
                    this.isLoading = false;
                }
                this.fullRefresh();
            })
            .catch(() => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Unable to process claim',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.isLoading = false;
            });
        this.template.querySelector('lightning-datatable').selectedRows = [];
    }

    /**
     * @description - when a record is successfully claimed and updated, this method will send out a platform event that refreshes the page for other users.
     *                If this event was successful, it will then display a success toast and navigate to the newly claimed record after a 3 second delay.
     * @param recordId - the id of the record
     */
    sendUpdateEventThenNavigate(recordId) {
        publishEvent({ passingField: recordId, eventObject: this.eventObject })
            .then(() => {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record owner updated successfully!',
                    variant: 'success',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                //legacy code
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: recordId,
                            objectApiName: this.objectName,
                            actionName: 'view'
                        }
                    });
                }, 3000); //this is a delay on loading the object that was accepted, nominated in milliseconds. 3000 = 3 seconds
                this.isLoading = false;
            })
            .catch(() => {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Unable to process claim',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
                this.isLoading = false;
            });
    }

    /**
     * @description - sets the selected row and enables the accept button
     */
    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.isDisabled = false;
    }

    /**
     * @description - fetches the case data for the table based on parameters set on the page
     */
    fetchObjectRecords() {
        getObjectRecords({
            objectAPI: this.objectAPI,
            filterClause: this.filterClause,
            fieldAPIList: this.fieldAPIList,
            orderBy: this.orderBy,
            useStationFiltering: this.useStationFiltering
        })
            .then((result) => {
                this.records = result.recordFieldDetails;
                this.columns = result.columns;
                this.objectName = result.objectName;
                this.error = undefined;
                this.isLoading = false;
                if (this.records === undefined || this.records.length === 0) {
                    this.msg = 'No patients in the queue';
                    this.isShow = false;
                    this.hasData = false;
                } else {
                    this.hasData = true;
                    this.isShow = true;
                    this.listSize = this.records.length;
                }
            })
            .catch((error) => {
                this.error = error;
                this.records = undefined;
                this.listSize = undefined;
                this.isLoading = false;
                this.isShow = false;
                this.msg = 'There is an issue while fetching patients';
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error fetching records',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            });
    }

    /**
     * @description - sorts the table based on the column selected
     */
    doSorting(event) {
        const order = event.detail.fieldName;
        const sort = event.detail.sortDirection;
        this.sortData(order, sort);
    }

    /**
     * @description - called by doSorting, sets the record data to reflect desired sort pattern
     */
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.records));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.records = parseData;
    }

    /**
     * @description - returns an html icon name based on the object set in the parameters
     */
    get titleIconName() {
        return 'standard:' + this.objectAPI.toLowerCase();
    }

    /**
     * @description - when the pause button is clicked, sets a few booleans and opens the pause modal
     */
    clickPauseButton() {
        this.isLoading = true;
        this.isPauseButtonDisabled = true;
        this.openModal();
    }

    /**
     * @description - called by various locations when a pause action is taken to properly reset the button parameters and the parameters for the pause status
     */
    setButtonMsg() {
        if (this.isCurrentlyPaused) {
            this.buttonLabel = 'RESUME';
            this.statusMsg = 'Case flow for VISN ' + this.picklistValue + ' is currently';
            this.modalBody = 'Would you like to resume the case flow?';
            this.statusString = 'PAUSED';
            this.buttonStyle = '--sds-c-button-text-color:' + this.openColor;
            this.textStyle = 'color:' + this.pausedColor;
            this.iconName = 'utility:pause_alt';
            this.iconAltText = 'Paused';
            this.iconTitle = 'Paused';
            this.iconStyle = '--sds-c-icon-color-foreground-default:' + this.pausedColor;
        } else {
            this.buttonLabel = 'PAUSE';
            this.statusMsg = 'Case flow for VISN ' + this.picklistValue + ' is';
            this.modalBody = 'Would you like to pause the case flow?';
            this.statusString = 'OPEN';
            this.buttonStyle = '--sds-c-button-text-color:' + this.pausedColor;
            this.textStyle = 'color:' + this.openColor;
            this.iconName = 'utility:success';
            this.iconAltText = 'Open';
            this.iconTitle = 'Open';
            this.iconStyle = '--sds-c-icon-color-foreground-default:' + this.openColor;
        }
        this.isMultiVisnHideMessage = false;
        this.isLoading = false;
    }

    /**
     * @description - sets the selected visn from a picklist for multi-visn scenarios and enables pause functions
     */
    handleChange(event) {
        this.isLoading = true;
        this.picklistValue = event.detail.value;
        this.getVISNStatus();

        if (this.picklistValue === 'selectVisn') {
            this.isPauseButtonDisabled = true;
            this.isMultiVisnHideMessage = true;
        } else {
            this.isPauseButtonDisabled = false;
        }
    }

    /**
     * @description - returns a pause status for the current visn
     */
    getVISNStatus() {
        getCurrentStatusRecord({
            providedVISN: this.picklistValue,
            queueType: this.queueType
        })
            .then((result) => {
                if (result === undefined || result === null) {
                    //console.log('no status for '+this.picklistValue+' found');
                } else {
                    this.currentVisnStatus = result;
                    if (this.currentVisnStatus.TUC_Status_Type__c === 'Paused') {
                        this.isCurrentlyPaused = true;
                    } else {
                        this.isCurrentlyPaused = false;
                    }
                }
                this.setButtonMsg();
            })
            .catch((error) => {
                this.error = error;
                this.currentVisnStatus = undefined;
                this.isCurrentlyPaused = false;
                this.msg = 'There is an issue while fetching VISN';
                //console.log(' --> '+JSON.stringify(this.error.message));
            });
    }

    /**
     * @description - gets the current user's visn
     */
    fetchUserVISNs() {
        getVISNData({})
            .then((result) => {
                this.visnResult = result;
                this.setPicklistOptions(result);
                this.error = undefined;
                if (result === undefined || result === 0) {
                    this.msg = 'No VISNs returned';
                    this.isShow = false;
                    this.hasData = false;
                    this.hasNoVisns = true;
                    this.isLoading = false;
                } else {
                    this.hasData = true;
                    this.isShow = true;
                    this.hasNoVisns = false;
                    this.setButtonMsg();
                }
            })
            .catch((error) => {
                this.error = error;
                this.visnResult = undefined;
                this.isLoading = false;
                this.isShow = false;
                this.hasNoVisns = true;
                this.msg = 'There is an issue while fetching VISNs';
                //console.log(' --> '+JSON.stringify(this.error.message));
            });
    }

    /**
     * @description - if the user has multiple visns, sets those into combobox options for the mutli-visn picklist
     */
    setPicklistOptions(visnList) {
        var optionList = [{ label: 'Select VISN', value: 'selectVisn' }];

        if (visnList !== undefined) {
            this.picklistValue = visnList;
            this.hasNoVisns = false;
            this.hasSingleVisn = true;
            this.isPauseButtonDisabled = false;
            this.getVISNStatus();
        } else {
            this.hasNoVisns = true;
        }
        this.picklistOptions = optionList;
    }

    /**
     * @description - called by the pause modal, sends data to Apex to create a new escalation status record when called
     */
    createNewStatusRecord() {
        let fieldObj = {};
        fieldObj.providedVISN = this.picklistValue;
        fieldObj.queueType = this.queueType;
        fieldObj.pauseReason = this.reasonSelected;
        let fieldsJSON = JSON.stringify(fieldObj);
        createTeleEcStatusRecord({
            fieldsJSON: fieldsJSON
        }).then(() => {
            this.getVISNStatus();
            this.isPauseButtonDisabled = false;
            this.reasonSelected = '';
        });
    }

    statusChannelName = '/event/TED_Autorefresh_Case_Flow_Control__e';
    subscription;
    statusSubscription = {};

    /**
     * @description - handles the platform event subscriptions called during the connected callback
     */
    handleSubscribe() {
        if (this.channelName) {
            subscribe('/event/' + this.channelName, -1, () => {
                this.fullRefresh();
            }).then((response) => {
                this.subscription = response;
            });
        }
        subscribe(this.statusChannelName, -1, (response) => this.messageCallback(response)).then((response) => {
            this.statusSubscription = response;
        });
    }

    /**
     * @description - simple callback to refresh the visn data for the pause event
     */
    messageCallback(response) {
        var obj = JSON.parse(JSON.stringify(response));
        var objData = obj.data.payload;
        if (this.visnResult === objData.VISN__c) {
            this.fullRefresh();
        }
    }

    //----Modal Section----
    showModal = false;
    modalTitle = 'Warning';
    modalBody = 'Would you like to pause the case flow?';

    /**
     * @description - opens the pause modal
     */
    openModal() {
        if (this.isCurrentlyPaused) {
            this.isModalButtonDisabled = false;
        } else {
            this.isModalButtonDisabled = true;
        }
        this.showModal = true;
    }

    /**
     * @description - closes the pause modal
     */
    handleClose() {
        this.isLoading = false;
        this.reasonSelected = '';
        this.isModalButtonDisabled = true;
        this.isPauseButtonDisabled = false;
        this.showModal = false;
    }

    /**
     * @description - called by the confirmation button on the modal, sets off the escalation status creation and resets the pause status UI variables
     */
    handleContinue() {
        this.showModal = false;
        this.isCurrentlyPaused = !this.isCurrentlyPaused;
        this.createNewStatusRecord();
        this.setButtonMsg();
    }

    /**
     * @description Called by a picklist subaction on the modal
     * @param event The event data from the picklist event.
     */
    handleReason(event) {
        // This will contain the string of the "value" attribute of the selected reason
        this.reasonSelected = event.target.value;
        this.isModalButtonDisabled = false;
    }

    /**
     * @description The class renderedCallBack used, as a custom method that would be called inside the "openModal()"" method wasn't working, as the querySelector() was staying null
     */
    renderedCallback() {
        const modalFocus = this.template.querySelector('.slds-modal__header');
        if (modalFocus && this.isFirstRender) {
            modalFocus.focus();
            this.isFirstRender = false;
        } else {
            this.isFirstRender = true;
        }
    }

    /**
     * @description Calls both the case data refresh and visn refresh methods
     */
    fullRefresh() {
        this.fetchObjectRecords();
        this.fetchUserVISNs();
    }
}
