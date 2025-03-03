import { LightningElement, api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import vccUIUpdate from '@salesforce/messageChannel/vccUIUpdate__c';
import vccAddToNoteAllergies from '@salesforce/messageChannel/vccAddToNoteAllergies__c';
import vccBaseAddToNote from '@salesforce/messageChannel/vccBaseAddToNote__c';
import vccMessageChannel from '@salesforce/messageChannel/vccMessageChannel__c';
import vccProgressNoteAddSigner from '@salesforce/messageChannel/vccProgressNoteAddSigner__c';
import vccAppointmentRequestFacilities from '@salesforce/messageChannel/vccAppointmentRequestFacilities__c';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';
export default class VccLMSPublisher extends LightningElement {
    // Create the context
    @wire(MessageContext)
    messageContext;

    // This will be mapped to an imported message channel
    messageChannel;

    // Parameters for which channel to publish on the LMS and the payload to be published
    @api channel;
    @api payload;

    connectedCallback() {
        if (this.channel && this.payload) {
            try {
                this.publishMessage(this.channel, JSON.parse(this.payload));
            } catch (e) {
                console.log('Error calling publishMessage from connectedCallback ', e);
            }
        }
    }

    selectMessageChannel(channel) {
        switch (channel) {
            case 'vccUIUpdate':
                this.messageChannel = vccUIUpdate;
                break;
            case 'vccAddToNoteAllergies':
                this.messageChannel = vccAddToNoteAllergies;
                break;
            case 'vccBaseAddToNote':
                this.messageChannel = vccBaseAddToNote;
                break;
            case 'vccMessageChannel':
                this.messageChannel = vccMessageChannel;
                break;
            case 'vccProgressNoteAddSigner':
                this.messageChannel = vccProgressNoteAddSigner;
                break;
            case 'vccAppointmentRequestFacilities':
                this.messageChannel = vccAppointmentRequestFacilities;
                break;
            case 'vccOnPersonAccountRead':
                this.messageChannel = vccOnPersonAccountRead;
                break;
            default:
                break;
        }
    }

    @api publishMessage(channel, message) {
        try {
            this.selectMessageChannel(channel);
            publish(this.messageContext, this.messageChannel, message);
            return true;
        } catch (error) {
            const logger = this.template.querySelector('c-logger');
            if (error instanceof Error) {
                logger.error(error.message);
                logger.error(error.stack);
            } else {
                logger.error(JSON.stringify(error));
            }
            return false;
        }
    }
}
