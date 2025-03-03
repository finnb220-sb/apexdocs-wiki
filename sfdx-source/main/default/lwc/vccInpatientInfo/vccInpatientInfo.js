import { LightningElement, api, track } from "lwc";
import retrieveInPatientInfo from "@salesforce/apex/VCC_lwc_utils.retrieveInPatientInfo";
import { getRecordNotifyChange } from "lightning/uiRecordApi";

import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";

export default class VccInpatientInfo extends LightningElement {
    @track
    isLoading;

    @track
    mpiData;
    @api recordId;

    init = true;

    @track
    inPatient;
    @track
    isShowInPatientPopup;
    @track isOpenPopup = false;

    @api sensitivePatient;

    /** empty state */
    noConnection = false;
    labels = {
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    @api
    isShowVerifyPatientPopup = false;

    facilityMovementType;
    mASMovementType;
    mASMovementTransaction;
    roomBed;
    facilityName;

    patientList;
    inpatientRecord;

    async mpiCallout() {
        try {
            await new Promise((resolve) => setTimeout(resolve, 600));

            if (!this.isDebugMode) {
                const response = await retrieveInPatientInfo({
                    recordId: this.recordId
                });
                let inpatientData = JSON.parse(JSON.parse(response).resBody);
                let patients = inpatientData?.clinicalData?.patientMovement?.patients?.patient;

                let patientList = [];
                for (let i = 0; i < patients.length; i++) {
                    let movementList = patients[i].movement;
                    let isInPatientRecord = true;
                    let admissionRecord;
                    // for(let j=0;j<movementList.length;j++){
                    for (let j = 0; j < 1; j++) {
                        let dateTime = this.getJsDateFromFileManDateTime(movementList[j].dateTime);
                        movementList[j].dateTimeVal = dateTime;
                        movementList[j].facilityName = patients[i].facility;
                        if (movementList[j].transactionTypeName == "DISCHARGE" || movementList[j].transactionTypeName == "CHECK-OUT LODGER") {
                            isInPatientRecord = false;
                        } else {
                            admissionRecord = movementList[j];
                            for (let k = 0; k < movementList.length; k++) {
                                if (movementList[k].transactionTypeName == "ADMISSION") {
                                    let dateTime1 = this.getJsDateFromFileManDateTime(movementList[k].dateTime);
                                    movementList[k].dateTimeVal = dateTime1;
                                    movementList[k].facilityName = patients[i].facility;
                                    // patientList.push(movementList[k]);
                                    admissionRecord.roomBed = movementList[k].roomBed;
                                    admissionRecord.roomBedName = movementList[k].roomBedName;
                                    patientList.push(admissionRecord);
                                    break;
                                }
                            }
                        }
                        // if(movementList[j].transactionTypeName == 'ADMISSION'){
                        //      admissionRecord = movementList[j];
                        //    }
                    }
                    if (isInPatientRecord == true) {
                        this.inpatientRecord = admissionRecord;
                    }
                }
                this.patientList = patientList;
                this.isShowInPatientPopup = JSON.parse(response).isShowInPatientPopup;
            }
            getRecordNotifyChange([{ recordId: this.recordId }]);

            if (!this.patientList) {
                // this.noConnection = true;
            }
        } catch (error) {
            this.noConnection = true;
        } finally {
            this.labels.noConnectionMessage = genericError.replace("{0}", "Connection Error");
        }
    }

    isInPatient() {
        if (this.inpatientRecord != undefined) {
            this.facilityName = this.inpatientRecord.facilityName;
            this.mASMovementTransaction = this.inpatientRecord.transactionTypeName;
            this.mASMovementType = this.inpatientRecord.masMovementTypeName;
            this.facilityMovementType = "";
            this.roomBed = this.inpatientRecord.roomBed;
            return true;
        }
        return false;
    }

    handleIPAcknowledge() {
        this.resolve();
    }

    resolve;
    @api
    async openPopup(resolve) {
        this.resolve = resolve;
        if (this.recordId) {
            await this.mpiCallout();

            if (this.patientList && this.init) {
                if (this.isInPatient(this.patientList)) {
                    this.inPatient = true;
                }
                if (!this.isShowInPatientPopup) {
                    this.inPatient = false;
                }
            }

            this.init = false;
        }

        if (this.isShowInPatientPopup && this.inPatient) {
            this.isOpenPopup = true;
        } else {
            this.resolve();
        }
    }

    getJsDateFromFileManDateTime(fileManDateTime) {
        let fileManDateTimeString = fileManDateTime + "";
        let year = parseInt(fileManDateTimeString.substring(0, 4));
        let month = parseInt(fileManDateTimeString.substring(4, 6)) - 1;
        let day = fileManDateTimeString.substring(6, 8);
        let hours = fileManDateTimeString.substring(8, 10);
        let minutes = fileManDateTimeString.substring(10, 12);
        return new Date(year, month, day, hours, minutes);
    }
}
