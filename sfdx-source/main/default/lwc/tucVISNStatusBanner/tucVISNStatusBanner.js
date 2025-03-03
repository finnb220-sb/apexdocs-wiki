import { LightningElement } from 'lwc';
import { subscribe } from 'lightning/empApi';

import getCurrentStatusRecord from '@salesforce/apex/TUC_EscalatePauseButtonController.getCurrentStatusRecord';
import getVISNData from '@salesforce/apex/TUC_EscalatePauseButtonController.getVISNData';

/**
 * @description - LWC that displays Status Messages for the current User's VISN on a page based on the queues.
 * @author            : Booz Allen
 */
export default class TucVISNStatusBanner extends LightningElement {
    visnResult;
    highStatusResult;
    intermediateStatusResult;
    highAcuityPaused = false;
    intermediateAcuityPaused = false;
    highAcuityReturn = false;
    intermediateAcuityReturn = false;
    hasData = false;
    initialized = false;

    isLoading = true;
    msg;

    /**
     * @description - Runs on page load, gets VISN data and handles platform event subscription
     */
    connectedCallback() {
        this.fetchParentVISNData();
        this.handleSubscribe();
    }

    /**
     * @description - Retrieves VISN data for the user and fetches the status for each queue providing the VISN and queue type
     */
    fetchParentVISNData() {
        getVISNData({})
            .then((result) => {
                if (result === undefined || result === null) {
                    this.hasData = false;
                    this.isLoading = false;
                } else {
                    this.visnResult = result;
                    this.hasData = true;
                    this.fetchVISNStatus(this.visnResult, 'High Acuity');
                    this.fetchVISNStatus(this.visnResult, 'Intermediate Acuity');
                }
            })
            .catch((error) => {
                this.error = error;
                this.visnResult = undefined;
                this.isLoading = false;
                this.hasData = false;
                this.msg = 'There was an issue while fetching VISN for user';
            });
    }

    /**
     * @description - Retrieves status for a Queue based on provided VISN and type
     * @param providedVISN - the VISN being requested
     * @param queueType - the queue type being requested
     */
    fetchVISNStatus(providedVISN, queueType) {
        getCurrentStatusRecord({
            providedVISN: providedVISN,
            queueType: queueType
        })
            .then((result) => {
                let queueStatus;
                if (result === undefined || result === null) {
                    queueStatus = 'Resumed'; //set to resumed to mock up an open status
                } else {
                    queueStatus = result.TUC_Status_Type__c;
                }
                if (queueType === 'High Acuity') {
                    this.highStatusResult = queueStatus;
                    if (queueStatus === 'Paused') {
                        this.highAcuityPaused = true;
                    } else {
                        this.highAcuityPaused = false;
                    }
                    this.highAcuityReturn = true;
                } else if (queueType === 'Intermediate Acuity') {
                    this.intermediateStatusResult = queueStatus;
                    if (queueStatus === 'Paused') {
                        this.intermediateAcuityPaused = true;
                    } else {
                        this.intermediateAcuityPaused = false;
                    }
                    this.intermediateAcuityReturn = true;
                }
                this.checkStatuses();
            })
            .catch((error) => {
                this.error = error;
                this.currentVisnStatus = undefined;
                this.isCurrentlyPaused = false;
                this.isLoading = false;
                this.msg = 'There is an issue while fetching current status for VISN ' + providedVISN + ' ' + queueType;
            });
    }

    /**
     * @description - checks if both Queues have returned data and sets message data if both are loaded
     */
    checkStatuses() {
        if (this.highAcuityReturn && this.intermediateAcuityReturn) {
            this.setMessages();
        }
    }

    combinedReport = false;
    separateReport = false;

    /**
     * @description - checks if both Queues have the same status and calls either the combined or separate message set
     */
    setMessages() {
        if (this.highAcuityPaused === this.intermediateAcuityPaused) {
            this.combinedReport = true;
            this.setCombinedMessage();
        } else {
            this.separateReport = true;
            this.setSeparateMessages();
        }
    }

    pausedHexColor = '#ba0517';
    openHexColor = '#032d60';
    pausedIcon = 'warning';
    openIcon = 'info';

    highAcuityMessage;
    highAcuityIcon;
    highAcuityColor;
    highAcuityTextStyle;
    highAcuityIconStyle;
    highAcuityTitle;

    intermediateAcuityMessage;
    intermediateAcuityIcon;
    intermediateAcuityColor;
    intermediateAcuityTextStyle;
    intermediateAcuityIconStyle;
    intermediateAcuityTitle;

    combinedMessage;
    combinedIcon;
    combinedTextStyle;
    combinedIconStyle;
    combinedTitle;

    /**
     * @description - Sets the attributes for a combined message report
     */
    setCombinedMessage() {
        this.combinedMessage =
            'Tele-EC High and Intermediate Acuity queues for VISN ' + this.visnResult + ' are currently';
        if (this.highAcuityPaused === true) {
            this.combinedMessage = 'IMPORTANT: ' + this.combinedMessage + ' paused.';
            this.combinedIcon = this.pausedIcon;
            this.combinedColor = this.pausedHexColor;
            this.combinedTitle = 'Paused';
        } else {
            this.combinedMessage = 'NOTE: ' + this.combinedMessage + ' open.';
            this.combinedIcon = this.openIcon;
            this.combinedColor = this.openHexColor;
            this.combinedTitle = 'Open';
        }
        this.combinedTextStyle = 'color:' + this.combinedColor;
        this.combinedIconStyle = '--sds-c-icon-color-foreground-default:' + this.combinedColor;

        this.setInitialized();
    }

    /**
     * @description - Sets the attributes for separate message reports
     */
    setSeparateMessages() {
        this.highAcuityMessage = 'Tele-EC High Acuity queue for VISN ' + this.visnResult + ' is currently';
        if (this.highAcuityPaused === true) {
            this.highAcuityMessage = 'IMPORTANT: ' + this.highAcuityMessage + ' paused.';
            this.highAcuityIcon = this.pausedIcon;
            this.highAcuityColor = this.pausedHexColor;
            this.highAcuityTitle = 'Paused';
        } else {
            this.highAcuityMessage = 'NOTE: ' + this.highAcuityMessage + ' open.';
            this.highAcuityIcon = this.openIcon;
            this.highAcuityColor = this.openHexColor;
            this.highAcuityTitle = 'Open';
        }
        this.highAcuityTextStyle = 'color:' + this.highAcuityColor;
        this.highAcuityIconStyle = '--sds-c-icon-color-foreground-default:' + this.highAcuityColor;

        this.intermediateAcuityMessage =
            'Tele-EC Intermediate Acuity queue for VISN ' + this.visnResult + ' is currently';
        if (this.intermediateAcuityPaused === true) {
            this.intermediateAcuityMessage = 'IMPORTANT: ' + this.intermediateAcuityMessage + ' paused.';
            this.intermediateAcuityIcon = this.pausedIcon;
            this.intermediateAcuityColor = this.pausedHexColor;
            this.intermediateAcuityTitle = 'Paused';
        } else {
            this.intermediateAcuityMessage = 'NOTE: ' + this.intermediateAcuityMessage + ' open.';
            this.intermediateAcuityIcon = this.openIcon;
            this.intermediateAcuityColor = this.openHexColor;
            this.intermediateAcuityTitle = 'Open';
        }
        this.intermediateAcuityTextStyle = 'color:' + this.intermediateAcuityColor;
        this.intermediateAcuityIconStyle = '--sds-c-icon-color-foreground-default:' + this.intermediateAcuityColor;
        this.setInitialized();
    }

    /**
     * @description - Called after the message data is set to stop the loading spinner and show the message cards
     */
    setInitialized() {
        this.initialized = true;
        this.isLoading = false;
    }

    /**
     * @description - returns an html icon name for the high acuity queue
     */
    get highAcuityIconName() {
        return 'utility:' + this.highAcuityIcon;
    }

    /**
     * @description - returns an html icon name for the intermediate acuity queue
     */
    get intermediateAcuityIconName() {
        return 'utility:' + this.intermediateAcuityIcon;
    }

    /**
     * @description - returns an html icon name for a combined message
     */
    get combinedIconName() {
        return 'utility:' + this.combinedIcon;
    }

    statusChannelName = '/event/TED_Autorefresh_Case_Flow_Control__e';
    subscription;
    statusSubscription = {};

    /**
     * @description - handles the platform event subscriptions called during the connected callback
     */
    handleSubscribe() {
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

    /**
     * @description - Resets attributes and calls the loading fetch after.
     */
    fullRefresh() {
        this.isLoading = true;
        this.initialized = false;
        this.hasData = false;
        this.highAcuityPaused = false;
        this.intermediateAcuityPaused = false;
        this.highAcuityReturn = false;
        this.intermediateAcuityReturn = false;
        this.combinedReport = false;
        this.separateReport = false;
        this.fetchParentVISNData();
    }
}
