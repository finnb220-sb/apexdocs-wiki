import { LightningElement, api, track, wire } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import FEEBACK_ANSWER_OBJECT from '@salesforce/schema/PC_Case_Feedback_Answer__c';
import ANSWER_FIELD from '@salesforce/schema/PC_Case_Feedback_Answer__c.PC_Answer__c';

import getIsSubmitted from '@salesforce/apex/PC_CaseFeedbackController.getIsSubmitted';
import getFeedbackQuestions from '@salesforce/apex/PC_CaseFeedbackController.getFeedbackQuestions';
import submitFeedback from '@salesforce/apex/PC_CaseFeedbackController.submitFeedback';

export default class PcCaseFeedback extends LightningElement {
    @api recordId;
    @api role;

    @track isSubmitted = false;

    @track feedbackList = [];
    @track answerFieldOptions = [];

    _submittedMessage = 'Feedback submitted.';
    _noQuestionsMessage = 'No feedback questions available.';

    get cardTitle() {
        return this.role ? this.role + ' Feedback' : 'Feedback';
    }

    get showQuestions() {
        return !this.isSubmitted && this.feedbackList?.length > 0;
    }

    get showSubmittedMsg() {
        return this.isSubmitted && this.feedbackList?.length > 0;
    }

    get showNoQuestionsMsg() {
        return this.feedbackList?.length === 0;
    }

    @wire(getObjectInfo, { objectApiName: FEEBACK_ANSWER_OBJECT })
    feedbackAnswerMetadata;

    @wire(getPicklistValues, {
        recordTypeId: '$feedbackAnswerMetadata.data.defaultRecordTypeId',
        fieldApiName: ANSWER_FIELD
    })
    wiredAnswerFieldOptions({ error, data }) {
        if (data) {
            //console.log(data);
            this.answerFieldOptions = data.values;
        } else if (error) {
            //console.log(error.body.message);
            this.showToast('Error', error.body.message, 'error', 'sticky');
        }
    }

    @wire(getIsSubmitted, { recordId: '$recordId', role: '$role' })
    wiredIsSubmitted({ error, data }) {
        if (data) {
            //console.log(data);
            this.isSubmitted = data;
        } else if (error) {
            //console.log(error.body.message);
            this.showToast('Error', error.body.message, 'error', 'sticky');
        }
    }

    @wire(getFeedbackQuestions, { recordId: '$recordId', role: '$role' })
    wiredFeedbackQuestions({ error, data }) {
        if (data) {
            //console.log(data);
            this.feedbackList = data;
        } else if (error) {
            //console.log(error.body.message);
            this.showToast('Error', error.body.message, 'error', 'sticky');
        }
    }

    handleAnswerChange(event) {
        //console.log(event.target.dataset.index);
        //console.log(event.target.value);

        let tempPicklist = JSON.parse(JSON.stringify(this.feedbackList));
        tempPicklist[event.target.dataset.index].PC_Answer__c = event.target.value;
        this.feedbackList = tempPicklist;
    }

    handleSubmitFeedback() {
        const allValid = [...this.template.querySelectorAll('lightning-combobox')].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            // eslint-disable-next-line no-restricted-globals, no-alert
            if (confirm('Are you sure you want to submit this feedback? This action cannot be undone.')) {
                console.log(JSON.stringify(this.feedbackList));

                submitFeedback({ feedbackAnswersJSON: JSON.stringify(this.feedbackList) })
                    .then(() => {
                        this.showToast('Success', this._submittedMessage, 'success', 'dismissible');
                        this.isSubmitted = true;
                    })
                    .catch((error) => {
                        this.showToast('Error', error.body.message, 'error', 'sticky');
                    });
            }
        } else {
            this.showToast('Incomplete', 'Please answer all questions before submitting.', 'error', 'dismissible');
        }
    }

    showToast(title, message, variant, mode) {
        //variants are error/warning/success/info
        //modes are dismissible, pester, sticky
        this.dispatchEvent(
            new ShowToastEvent({
                message: message,
                title: title,
                variant: variant ? variant : 'info',
                mode: mode ? mode : 'dismissible'
            })
        );
    }
}
