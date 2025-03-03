import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getChannelAvailability from '@salesforce/apex/PC_ChannelSelectionController.getChannelAvailability';
import setChannelAvailability from '@salesforce/apex/PC_ChannelSelectionController.setChannelAvailability';

/**
 * @description This component is displayed in the Specialist omni-channel toolbar and allows them to change their availability to accept PrC Cases using the following channels: Chat, Phone, and Teams
 */
export default class PcChannelSelection extends LightningElement {
    @track channels = {};
    @track showSpinner = true;

    /**
     * @description gets the running user's availability information for each channel skill to appropriately display each channel's buttons as selected/unselected
     * @param {*} result resulting AvailableChannels wrapper class containing the channel availability info for the running user
     */
    @wire(getChannelAvailability)
    channelAvailability(result) {
        this.result = result;
        if (result.data) {
            this.channels = result.data;
            this.chatVariant = this.channels.chat ? 'brand' : 'neutral';
            this.phoneVariant = this.channels.phone ? 'brand' : 'neutral';
            this.teamsVariant = this.channels.teams ? 'brand' : 'neutral';
            this.showSpinner = false;
        } else if (result.error) {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: result.error.body.message,
                    variant: 'error',
                    mode: 'sticky'
                })
            );
        }
    }

    /**
     * @description handles the user selecting/deselecting a channel
     * @param {*} event event for channel selection click
     */
    handleButtonSelection(event) {
        //Toggle boolean was causing issues
        this.showSpinner = true;

        if (!event?.target?.dataset?.value) {
            this.showSpinner = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        'Failed to change your availability to a valid value. Please contact your System Administrator.',
                    variant: 'error'
                })
            );
            return;
        }

        let value;
        if (event.target.dataset.value === true || event.target.dataset.value === 'true') {
            value = false;
        } else {
            value = true;
        }

        setChannelAvailability({ channel: event.target.name, channelAvailable: value })
            .then((result) => {
                this.handleRefresh();
                if (result !== 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error Loading Page',
                        message:
                            'Something went wrong setting your availability, please contact your system administrator.',
                        variant: 'error'
                    })
                );
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    /**
     * @description refreshes the channel availability display
     */
    handleRefresh() {
        refreshApex(this.result);
    }
}
