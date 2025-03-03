import { api, LightningElement, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import SERVICES_FIELD from "@salesforce/schema/VCC_Test_Configuration_Data__c.VCC_Service__c";
import { getRecordTypeId } from "c/vccVatPageController";

export default class VccVatPageServices extends LightningElement {
    initialized = false;
    isLoading = true;

    recordTypeId;
    picklistVals;
    defaultPicklistVal;

    @api
    getChosenService() {
        let radioGroup = this.template.querySelector("lightning-radio-group");
        if (radioGroup == null || radioGroup == undefined) {
            return null;
        }
        return radioGroup.value;
    }

    async renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.recordTypeId = await getRecordTypeId();
        this.initialized = true;
    }

    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: SERVICES_FIELD })
    handlePicklistWire(response) {
        if (this.recordTypeId == null || this.recordTypeId == undefined) {
            return;
        }
        if (response.data != undefined) {
            this.picklistVals = response?.data?.values;
            this.defaultPicklistVal = this.picklistVals[0].value;
        } else {
            console.warn(response.error);
        }
        this.isLoading = false;
    }
}
