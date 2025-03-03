import { LightningElement, track, api } from "lwc";
import LightningModal from "lightning/modal";
import getTemplateInfo from "@salesforce/apex/VCC_HeartbeatTemplateController.getTemplateInfo";
import runTest from "@salesforce/apex/VCC_HeartbeatTemplateController.runTest";

export default class VccHeartbeatRun extends LightningModal {
    @track _recordId;
    @api set recordId(value) {
        this._recordId = value;
        this.collectData();
        // do your thing right here with this.recordId / value
    }
    get recordId() {
        return this._recordId;
    }

    @track model = new Object();
    @track hasResult = false;
    @track result = new Object();
    @track isBusy = false;
    @track modalTitle = "Heartbeat Run";

    collectData() {
        this.setBusy(true);
        getTemplateInfo({ recordId: this.recordId })
            .then((response) => {
                this.model = JSON.parse(response);
                this.modalTitle = "Heartbeat Run (" + this.model.name + ")";
                this.setBusy(false);

                console.log("EXPECTED:" + this.model.expectedResponse);
            })
            .catch((error) => {
                this.setBusy(false);
            });
    }

    setBusy(busy) {
        this.isBusy = busy;
    }

    runSampleTest(event) {
        this.setBusy(true);
        this.result = new Object();
        this.hasResult = false;

        let testInfo = new Object();
        testInfo.id = this.recordId;
        testInfo.endpoint = this.model.endpoint;
        testInfo.method = this.model.method;
        testInfo.expectedResponse = this.model.expectedResponse;
        testInfo.params = [];

        for (var i = 0; i < this.model.params.length; i++) {
            let param = new Object();
            param.name = this.model.params[i].name;
            param.type = this.model.params[i].dataType;
            param.format = this.model.params[i].format;

            let inputName = "[data-name=" + this.model.params[i].name + "]";
            param.value = this.template.querySelector(inputName).value;
            testInfo.params.push(param);
        }

        runTest({ testData: JSON.stringify(testInfo) })
            .then((response) => {
                console.log("***RESPONSE:" + response);
                this.result = JSON.parse(response);
                this.hasResult = true;
                this.setBusy(false);
            })
            .catch((error) => {
                this.setBusy(false);
                //this.notifyUser('API Error', 'An error occured while attempting to run the template.', 'error');
            });
    }

    okImDone() {
        console.log("DONE:CLICKED");
        this.close("okay");
    }
}
