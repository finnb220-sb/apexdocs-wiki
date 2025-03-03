import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import LightningConfirm from 'lightning/confirm';

import NoHeader from '@salesforce/resourceUrl/NoHeader';

import Id from '@salesforce/user/Id';
import phone from '@salesforce/schema/User.Phone';
import ext from '@salesforce/schema/User.Extension';
import fullName from '@salesforce/schema/User.Name';
import userTimeZone from '@salesforce/schema/User.TimeZoneSidKey';
import userLocale from '@salesforce/schema/User.LocaleSidKey';

import PC_CASE_OBJECT from '@salesforce/schema/PC_Case__c';

import isDebugEnabled from '@salesforce/customPermission/PC_Enable_Debug';

import { showToast } from 'c/helpersLWC';

import createSuperScreenPTs from '@salesforce/apex/PC_ChatStreamController.createSuperScreenPTs';

import getSkills from '@salesforce/apex/PC_ProviderConnectController.getSkills';
import createCase from '@salesforce/apex/PC_ProviderConnectController.createCaseNew';
import getAssignedAgent from '@salesforce/apex/PC_ProviderConnectController.getAssignedAgent';
import cancelCaseRoutingError from '@salesforce/apex/PC_ProviderConnectController.cancelCaseRoutingError';
import createPcSpecialistUnavailability from '@salesforce/apex/PC_ProviderConnectController.createPcSpecialistUnavailability';

import CaseModal from 'c/pcTeleHealthCaseModal';
import PhoneModal from 'c/pcTeleHealthPhoneModal';

import CometDSubscriptionFailureMessage from '@salesforce/label/c.PC_Availability_Matrix_CometD_Connection_Failure_Message';

const MIN_CAPACITY = 20;
let CASE_CHANNEL_CHAT = 'Chat';
let CASE_CHANNEL_SHORT = 'chat';

export default class TeleHealthConsultation extends NavigationMixin(LightningElement) {
    @api refreshSeconds = 10;
    @api minimumSkillLevel = 0;
    @track initiationMsg;

    // emp api prototype
    subscription = {};
    channelName = '/topic/pcSuperScreen';
    empApiErrorAlertTriggered = false;

    @track caseData = {
        sobjectType: 'PC_Case__c',
        Specialty__c: null,
        Channel__c: null,
        Case_Details__c: null,
        Callback_Number__c: null,
        Patient_Account__c: null,
        PC_General_Question__c: false
    };

    @track skillsAndButtons = [];
    skillsAndButtonsOriginalSort;

    channelShort = null;
    isGeneralShort = null;
    caseDetailsChars = 0;
    maxDetailsChars = 32000;

    showSpinner = false;
    progressLabel = 'Loading...';

    currentUser = {};
    callback;
    callbackExt;
    error;

    caseObj = {};
    currentClosedCase = {};
    pcCases = [];

    cancelCaseRoutingErrorResult;
    modalIsClosed = true;

    currentLocationId = '';

    context = 'lwc';

    agent;

    searchBarSettings = {
        label: 'Search Specialties',
        variant: 'standard'
    };

    searchProp = 'skillName';

    @wire(getObjectInfo, { objectApiName: PC_CASE_OBJECT })
    pcCaseObjectInfo;

    @wire(getRecord, { recordId: Id, fields: [phone, ext, fullName, userTimeZone, userLocale] })
    userDetails({ error, data }) {
        if (data) {
            this.currentUser = { Id: data.id, Name: data.fields.Name.value };
            this.callback = data.fields.Phone.value;
            this.callbackExt = data.fields.Extension.value;
        } else if (error) {
            this.error = error;
            this.logError(error);
        }
    }

    get detailsCharsRemaining() {
        return this.maxDetailsChars - this.caseDetailsChars;
    }

    get connectButtonDisable() {
        this.skillsAndButtons.reduce((pres, skill) => pres || skill.skillHasPresence, false);
        return (
            this.caseData.Channel__c === null ||
            this.caseData.Specialty__c === null ||
            this.caseData.Channel__c === 'Unavailable'
        );
    }

    get isChat() {
        return this.caseData.Channel__c === CASE_CHANNEL_SHORT;
    }

    get isPhone() {
        return this.caseData.Channel__c === 'Phone';
    }

    get isTeams() {
        return this.caseData.Channel__c === 'Teams';
    }

    get showTable() {
        return this.skillsAndButtons?.length && this.skillsAndButtonsOriginalSort?.length;
    }

    get showSpecialtySearchBar() {
        return this.skillsAndButtonsOriginalSort?.length;
    }

    get pcCaseDetailsFieldLabel() {
        return this.pcCaseObjectInfo?.data?.fields?.Case_Details__c?.label ?? 'Case Details';
    }

    get pcGeneralQuestionFieldLabel() {
        return this.pcCaseObjectInfo?.data?.fields?.PC_General_Question__c?.label ?? 'General Question';
    }

    connectedCallback() {
        loadStyle(this, NoHeader).then((result) => {
            this.loadStyleResult = result;
        }); // Loading Static Resource to remove Page Header

        if (isDebugEnabled) {
            setDebugFlag(true);
            isEmpEnabled().then(function (isEmpEnabledResult) {
                console.log('Is Emp Enabled? pcTeleHealthConsult: ' + isEmpEnabledResult);
            });
        }
        this.registerErrorListener();
        this.createPushTopicAndSubscribe();
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    // emp api prototype
    createPushTopicAndSubscribe() {
        createSuperScreenPTs()
            .then((result) => {
                this.createPushTopicResult = result;
                this.handleSubscribe(this);
            })
            .catch((error) => {
                showToast(this, 'Error', 'Something went wrong. Please refresh the page.', 'error');
                this.logError(error);
            });
    }

    // Handles subscribe button click
    handleSubscribe(comp) {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            if (isDebugEnabled) {
                console.log('Callback from Push Topic');
                console.log(JSON.stringify(response));
            }
            // Response contains the payload of the new message received
            let data = response.data.sobject;

            //rebuild skill table
            comp.buildSkillOptions();

            let caseJson = {};
            if (data.CaseClosedJSON__c) {
                caseJson = JSON.parse(data.CaseClosedJSON__c);
            }
            Object.keys(caseJson).forEach(function (key) {
                let tempCase = {};
                tempCase.CreatedBy = {};
                tempCase.Parent = {};
                tempCase.show = true;
                tempCase.Status__c = data.CaseClosedStatus__c;
                tempCase.ParentId = key;
                tempCase.Id = key;
                tempCase.Parent.Name = caseJson[key];
                tempCase.CreatedBy.Name = data.CaseClosedByName__c;
                if (key === comp.caseObj.Id) {
                    comp.currentClosedCase = tempCase;
                }
                comp.pcCases.push(tempCase);
            });

            if (data.NewCaseOwner__c) {
                comp.agent.Name = data.NewCaseOwner__c;
                comp.agent.Title = data.NewOwnerTitle__c;
                comp.agent.Department = data.NewOwnerDepartment__c;
                comp.agent.City = data.NewOwnerCity__c;
                comp.agent.State = data.NewOwnerState__c;
                comp.agent.MediumPhotoUrl = data.NewOwnerMediumPhotoUrl__c;
                comp.agent.Email = data.NewOwnerEmail__c;
            }
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(comp.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            comp.subscription = response;
            if (isDebugEnabled) {
                console.log('%cSubscribe pcTeleHealthConsult: ' + JSON.stringify(response), 'color: blue');
            }

            //build skill table
            comp.buildSkillOptions();
        });
    }

    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        try {
            unsubscribe(this.subscription, (response) => {
                if (isDebugEnabled) {
                    console.log('%cUnsubscribe pcTeleHealthConsult: ' + JSON.stringify(response), 'color: blue');
                }
            });
        } catch (error) {
            this.logError(error);
            if (isDebugEnabled) {
                console.log('%cUnsubscribe Error pcTeleHealthConsult: ' + JSON.stringify(error), 'color: red');
            }
        }
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            // Error contains the server-side error
            this.logError(error);
            if (isDebugEnabled) {
                console.log(
                    '%cError from empAPI CometD Server - pcTeleHealthConsult: ' + JSON.stringify(error),
                    'color: red'
                );
            }

            let isRelatedToPcSuperScreenPT = error ? JSON.stringify(error).includes('pcSuperScreen') : false;

            if (isRelatedToPcSuperScreenPT && !this.empApiErrorAlertTriggered) {
                //only trigger pop-up once per page load
                this.empApiErrorAlertTriggered = true;
                LightningConfirm.open({
                    message: CometDSubscriptionFailureMessage,
                    theme: 'info', // a info theme intended for info states - alert User refresh is needed
                    label: 'Availability Matrix Refresh Needed' // this is the header text
                }).then((result) => {
                    if (result) {
                        window.location.reload();
                    }
                });
            }
        });
    }

    buildSkillOptions() {
        getSkills({ context: this.context })
            .then((result) => {
                this.skillsAndButtons = [];
                result.forEach((skill) => {
                    this.skillsAndButtons.push({
                        skillName: skill.skillName,
                        skillHasPresence: skill.hasPresence,
                        skillNameFormat:
                            !skill.hasPresence || skill.minCapacity === MIN_CAPACITY
                                ? 'slds-text-color_inverse-weak'
                                : 'custom-specialty-color',
                        minCapacity: skill.minCapacity,
                        general: {
                            disabled: skill.generalDisabled,
                            variant:
                                skill.skillName === this.caseData.Specialty__c &&
                                this.channelShort === CASE_CHANNEL_SHORT &&
                                this.isGeneralShort === 'general'
                                    ? 'brand'
                                    : 'neutral'
                        },
                        patientSpecific: {
                            disabled: skill.patientSpecificDisabled,
                            variant:
                                skill.skillName === this.caseData.Specialty__c &&
                                this.channelShort === CASE_CHANNEL_SHORT
                                    ? 'brand'
                                    : 'neutral'
                        },
                        unavailable: {
                            disabled: !skill.patientSpecificDisabled || !skill.generalDisabled,
                            variant:
                                skill.skillName === this.caseData.Specialty__c && this.channelShort === 'unavailable'
                                    ? 'brand'
                                    : 'neutral'
                        },
                        //used to calculate sort order and resort if available
                        consultantsOnline: skill.consultantsOnline ? skill.consultantsOnline : 0
                    });
                });

                this.skillsAndButtonsOriginalSort = this.skillsAndButtons.map((a) => {
                    return { ...a };
                });

                function compare(a, b) {
                    if (a.consultantsOnline <= 0 && b.consultantsOnline > 0) {
                        return 1;
                    }
                    if (a.consultantsOnline > 0 && b.consultantsOnline <= 0) {
                        return -1;
                    }
                    return 0;
                }

                this.skillsAndButtons.sort(compare);
            })
            .catch((error) => {
                this.logError(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body ? error.body.message : error.message,
                        title: 'Error occurred trying to retrieve specialty list',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
                //Reset skill table arrays
                this.skillsAndButtons = [];
                this.skillsAndButtonsOriginalSort = [];
            });
    }

    handleButtonSelection(event) {
        if (this.caseData.Specialty__c !== null && this.channelShort !== null)
            this.skillsAndButtons.find((element) => element.skillName === this.caseData.Specialty__c)[
                this.channelShort
            ].variant = 'neutral';

        this.caseData.Specialty__c = event.target.getAttribute('data-skill');
        this.caseData.Channel__c = CASE_CHANNEL_CHAT;
        this.channelShort = event.target.getAttribute('data-channel-short');
        this.caseData.PC_General_Question__c = event.target.getAttribute('data-is-general');
        this.isGeneralShort = event.target.getAttribute('data-is-general-short');

        this.skillsAndButtons.find((element) => element.skillName === this.caseData.Specialty__c)[
            this.channelShort
        ].variant = 'brand';
        if (this.channelShort === 'unavailable') {
            this.caseData.Channel__c = event.target.getAttribute('data-channel');
            this.skillsAndButtons.find((element) => element.skillName === this.caseData.Specialty__c)[
                this.channelShort
            ].disabled = true;
            createPcSpecialistUnavailability({ speciality: this.caseData.Specialty__c })
                .then((data) => {
                    if (data) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Specialty is marked as unavailable, consider submitting an eConsult.',
                                variant: 'success',
                                mode: 'sticky'
                            })
                        );
                    }
                })
                .catch((error) => {
                    this.logError(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: error.body ? error.body.message : error.message,
                            title: 'Error occurred trying to create PC Specialist Unavailability record',
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                });
        } else {
            if (this.caseData.Case_Details__c === null || this.caseData.Case_Details__c === '') {
                this.template.querySelector('[data-id="case-details"]').focus(); //Wont focus if text area is disabled, waiting for logic to enable the text area
            } else {
                this.template.querySelector('[data-id="route-button"]').focus();
            }
        }
    }

    handleCaseDetails(event) {
        this.caseData.Case_Details__c = event.detail.value;
        this.caseDetailsChars = event.detail.value.length;
    }

    handleSubmit() {
        if (!this.isValid()) {
            showToast(this, 'Required field missing', 'Please fill out all required fields before routing.', 'warning');
            return;
        }

        if (this.caseData.Channel__c === 'Phone' && this.modalIsClosed) {
            this.modalIsClosed = false;
            this.showPhoneModalDialog();
        } else {
            this.showSpinner = true;
            this.progressLabel = 'Creating case...';
            let combinedCallback = this.callback + (this.callbackExt ? ' Ext. ' + this.callbackExt : '');
            this.caseData.Callback_Number__c = combinedCallback;
            createCase({
                newCase: this.caseData
            })
                .then((result) => {
                    this.progressLabel = 'Routing to consultant...';
                    this.caseObj = result;
                    try {
                        this.waitForRouting();
                    } catch (e) {
                        //Fail silently
                    }
                })
                .catch((error) => {
                    this.logError(error);

                    let variant = '';
                    let title = '';
                    if (
                        error.body &&
                        error.body.message.includes('The specialist you requested may no longer be available,')
                    ) {
                        variant = 'warning';
                        title = 'Double Booked';
                    } else {
                        variant = 'error';
                        title = 'Error occurred trying to create case.';
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: title,
                            message: error.body ? error.body.message : error.message,
                            variant: variant,
                            mode: 'sticky'
                        })
                    );
                    this.showSpinner = false;
                });
        }
    }

    async showPhoneModalDialog() {
        const res = await PhoneModal.open({
            size: 'medium',
            callback: this.callback,
            callbackExt: this.callbackExt
        });

        if (res === undefined) {
            this.resetPage();
        } else if (res.value === 'SUBMIT') {
            this.callback = res.callback;
            this.callbackExt = res.callbackExt;
            this.handleSubmit();
        }
        this.modalIsClosed = true;
    }

    waitForRouting() {
        this.interval = setInterval(this.getAgent.bind(this), 1000);
    }

    intervalCounter = 0;
    getAgent() {
        this.intervalCounter++;
        if (this.intervalCounter >= 5) {
            this.intervalCounter = 0;
            let skill = this.skillsAndButtons.find((s) => s.skillName === this.caseData.Specialty__c);
            let isChannelDisabled;
            if (this.caseData.Channel__c === CASE_CHANNEL_CHAT) {
                isChannelDisabled = skill.chat.disabled;
            }
            if (isChannelDisabled) {
                clearInterval(this.interval);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Double Booked',
                        message: 'The specialist you requested may no longer be available, please try again.',
                        variant: 'warning',
                        mode: 'sticky'
                    })
                );
                cancelCaseRoutingError({ caseId: this.caseObj.Id })
                    .then((result) => {
                        getRecordNotifyChange([{ recordId: this.caseObj.Id }]);
                        this.caseObj = {};
                        this.currentClosedCase = {};
                        this.caseData.Specialty__c = null;
                        this.caseData.Channel__c = null;
                        this.channelShort = null;
                        this.showSpinner = false;
                        this.cancelCaseRoutingErrorResult = result;
                    })
                    .catch((error) => {
                        this.logError(error);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                message: `${JSON.stringify(error)}`,
                                title: 'Error occurred trying to cancel this case',
                                variant: 'error',
                                mode: 'sticky'
                            })
                        );
                    })
                    .finally(() => {
                        this.showSpinner = false;
                    });
            }
        } else {
            getAssignedAgent({ caseId: this.caseObj.Id })
                .then((result) => {
                    if (result.agent && this.caseObj.Id) {
                        this.intervalCounter = 0;
                        this.progressLabel = '';
                        //clear recurring apex call to prevent infinite loop
                        clearInterval(this.interval);
                        this.showSpinner = false;
                        this.agent = { ...result.agent };
                        this.chatId = result.chatId;

                        if (this.isTeams) {
                            this.launchTeamsVideo();
                        } else if (this.isPhone) {
                            let combinedCallback =
                                this.callback + (this.callbackExt ? ' Ext. ' + this.callbackExt : '');
                            this.initiationMsg =
                                '-*- Specialist ' +
                                this.agent.Name +
                                ' will contact you at ' +
                                combinedCallback +
                                ', please use the chat before or after the call as needed. -*-';
                        }

                        this.showCaseModalDialog();
                    }
                })
                .catch((error) => {
                    this.logError(error);
                    if (isDebugEnabled) {
                        console.log('getAssignedAgent error: ' + JSON.stringify(error));
                    }
                });
        }
    }

    async showCaseModalDialog() {
        const res = await CaseModal.open({
            size: 'medium',
            currentClosedCase: this.currentClosedCase,
            isTeams: this.isTeams,
            countDownInt: this.countdownInt,
            isPhone: this.isPhone,
            callback: this.callback,
            callbackExt: this.callbackExt,
            agent: this.agent,
            caseObj: this.caseObj,
            chatId: this.chatId,
            initiationMsg: this.initiationMsg
        });

        if (res.value === 'NAVIGATE') {
            this.navigateToCase(res.event);
        } else if (res === 'CLOSED' || res === undefined) {
            this.resetPage();
        }
    }

    @track countdownInt = 5;
    launchTeamsVideo() {
        this.initiationMsg = 'Teams Video initiated please use Chat as needed.';
        this.countdownInt = 5;
        this.countdownInterval = setInterval(this.countdown.bind(this), 1000);
    }

    countdown() {
        this.countdownInt--;
        if (this.countdownInt <= 0) {
            this.countdownInt = 0;
            clearInterval(this.countdownInterval);
            window.open('https://teams.microsoft.com/l/call/0/0?users=' + this.agent.Email, '_blank');
            this.caseData.Channel__c = CASE_CHANNEL_CHAT;
        }
    }

    handleCloseAlert(event) {
        event.target.closest('div[data-id="' + event.target.dataset.id + '"]').style.display = 'none';
    }

    navigateToCase(event) {
        let id = event.target.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,
                objectApiName: 'PC_Case__c',
                actionName: 'view'
            }
        });
    }

    resetPage() {
        this.caseObj = {};
        this.currentClosedCase = {};
        this.caseData.Specialty__c = null;
        this.caseData.Channel__c = null;
        this.channelShort = null;
        this.template.querySelector('[data-id="case-details"]').value = null;
        this.caseDetailsChars = 0;
        this.caseData.Patient_Account__c = null;
    }

    handleSearch(event) {
        const searchResults = JSON.parse(event.detail) || null;
        const baseSearchBar = this.template.querySelector('c-base-search-bar');

        // handle clearing
        if (!baseSearchBar.inputLength()) {
            this.setRecords(this.skillsAndButtonsOriginalSort);
            return;
        }

        if (searchResults?.length) {
            this.setRecords(searchResults);
        } else {
            //set specialty table display to empty when no records returned
            this.setRecords([]);
        }
    }

    setRecords(list) {
        this.skillsAndButtons = list;
    }

    onLocationChanged(event) {
        this.currentLocationId = event.detail.prcUser.Current_Location__c;
        //Rebuild the skill options with new location in mind
        this.buildSkillOptions();
    }

    handleSelectPatient(event) {
        this.caseData.Patient_Account__c = event?.detail?.selectedCrmResult?.Id;
    }

    handleBackToPatientSearch() {
        this.caseData.Patient_Account__c = null;
    }

    /**
     * Checks that the required input fields are valid
     */
    isValid() {
        let isValid = true;
        if (!this.refs.caseDetailsTextArea.checkValidity()) {
            this.refs.caseDetailsTextArea.reportValidity();
            isValid = false;
        }
        return isValid;
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging.
     * @param {*} incomingError - object/string that represents the error that has occurred
     */
    logError(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) {
            return;
        }
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
