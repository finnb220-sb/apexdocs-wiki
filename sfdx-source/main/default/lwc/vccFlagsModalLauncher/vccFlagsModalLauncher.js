/**
 * @author Booz Allen Hamilton
 * @description Fetches patient flags by PersonAccount.Id via wired 'getFlags' method, then opens vccFlagsModal if there are flags to display.
 * @see vccFlagsModal
 * @see vccOnPersonAccountRead
 */
import { LightningElement } from 'lwc';
import { api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFlags from '@salesforce/apex/VCC_FlagsController.getFlags';
import FlagsModal from 'c/vccFlagsModal';
import { transformFlagsData } from 'c/vccFlagsDataTransformer';
import ExposedPromise from 'c/exposedPromise';

const ERROR_TOAST_TITLE = 'Error: Flag Acknowlegement';
const ERROR_TOAST_MESSAGE = 'Failed to open Flag Acknowlegement window: ';
const ERROR_TOAST_VARIANT = 'error';
const ERROR_TOAST_MODE = 'sticky';

export default class VccFlagsModalLauncher extends LightningElement {
    allowFlagsModal = false;
    flagRequest = {
        recordId: null,

        // facility, startDate, and endDate are meaningless-
        // they're here to match the vccFlags 'flagsRequest' so we can benefit from client-side caching
        // if you change this request object, ensure the vccFlags request object matches so browser cache is used when apropriate
        facility: '613',
        startDate: '1950-01-01',
        endDate: '2050-01-01'
    };
    loadingPromise = new ExposedPromise();
    @api recordId;

    renderedCallback() {
        if (typeof this.recordId === 'string' && this.recordId !== '') {
            // trigger wired 'getFlags'
            this.flagRequest.recordId = this.recordId;
        }
    }

    @api
    async open() {
        try {
            await this.loadingPromise;
            if (!Array.isArray(this.flagsList) || this.flagsList.length === 0) {
                return;
            }
            await FlagsModal.open({
                recordId: this.recordId,
                flagsList: this.flagsList
            });
        } catch (thrownError) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: ERROR_TOAST_TITLE,
                    message: ERROR_TOAST_MESSAGE + JSON.stringify(thrownError).replaceAll('{', '').replaceAll('}', ''),
                    variant: ERROR_TOAST_VARIANT,
                    mode: ERROR_TOAST_MODE,
                    messageData: null
                })
            );
        }
    }

    @wire(getFlags, { flagReqWrp: '$flagRequest' })
    handleGetFlags({ error, data }) {
        if (typeof this.recordId !== 'string' || this.recordId === '') {
            return;
        }
        if (typeof data === 'object' && data !== null) {
            try {
                this.flagsList = transformFlagsData(data);
                this.loadingPromise.resolve();
            } catch (thrownError) {
                this.loadingPromise.reject(thrownError);
            }
        }
        this.loadingPromise.reject(error);
    }
}
