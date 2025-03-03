import { LightningElement, api } from 'lwc';
import getDeceasedInfo from '@salesforce/apex/VCC_DeceasedPatientController.getDeceasedInfo';

export default class VccDeceasedPatient extends LightningElement {
    @api
    recordId;
    contactId;

    isShowPopup = false;
    userName;
    dateStr;
    resolve;

    /**
     * Called by vccOnPersonAccountRead. If Patient is Deceased, Modal pops up
     * @param resolve - Promise passed from vccOnPersonAccountRead
     */
    @api
    async open(resolve) {
        let deceasedInfo = await getDeceasedInfo({ accountId: this.recordId });
        if (typeof deceasedInfo?.deceasedDate != 'string') {
            resolve();
            return;
        }
        this.userName = deceasedInfo.patientName;
        this.dateStr = deceasedInfo.birthWithDeceasedDateFormatted;
        this.isShowPopup = true;
        this.resolve = resolve;
    }

    /**
     * Closes Modal After End-User Selects Acknowledge and Continue Button
     */
    closePopup() {
        this.isShowPopup = false;
        this.resolve();
    }
}
