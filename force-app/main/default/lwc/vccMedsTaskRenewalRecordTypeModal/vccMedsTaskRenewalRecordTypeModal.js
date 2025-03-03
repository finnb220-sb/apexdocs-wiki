import LightningModal from 'lightning/modal';
import { radioValues } from './constants';
import { api } from 'lwc';
/**
 * @description This is the modal used by vccMedsTaskRenewalList. It uses this LWC rather than the baseModal because
 * baseModal is expecting objects and is mostly used in different circumstances. This method simply needs to
 * capture a string
 */
export default class VccMedsTaskRenewalRecordTypeModal extends LightningModal {
    @api
    headerLabel = 'Default Header Label';
    isShowModal = false;
    radioButtonValues = radioValues;
    rtRadioValue = '';
    rtId = '';

    /**
     * @description this method is used to open the modal
     */
    showModal() {
        this.isShowModal = true;
    }

    /**
     * @description this method is used to close the modal
     */
    closeModal() {
        this.close(this.rtRadioValue);
    }

    /**
     * @description this method captures whenever a radio button is selected
     */
    handleRadioChange(event) {
        this.rtRadioValue = event.detail.value;
    }

    /**
     * @description this method closes the modal once 'Create Progress Note' button is selected
     */
    handleSubmit() {
        this.closeModal();
    }
}
