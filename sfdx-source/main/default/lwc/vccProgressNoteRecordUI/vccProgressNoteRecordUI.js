import { LightningElement, api, wire } from "lwc";
import { getRecord, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";
import * as SudLabs from "./SudLabs";
import LoggerMixin from "c/loggerMixin";
import { Delay, Seconds } from "c/vccTime";
export default class VccProgressNoteRecordUI extends LoggerMixin(LightningElement) {
    @api
    recordId;
    initialized = false;

    renderedCallback() {
        if (this.initialized == true || typeof this.recordId != "string") {
            return;
        }
        this.Logger.debug("vccProgressNoteRecordUI " + this.recordId);
        this.initialized = true;
    }

    errorCallback(error, stack) {
        try {
            this.Logger.error(error.message);
            this.Logger.error(stack);
            this.Logger.saveLog();
        } catch (e) {
            console.error(e);
        }
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [...SudLabs.fields]
    })
    onGetRecord(dataOrError) {
        if (dataOrError.error != null && dataOrError.data != undefined) {
            this.Logger.error(JSON.stringify(dataOrError.error));
            this.Logger.saveLog();
            return;
        }
        if (dataOrError?.data?.fields == null || dataOrError?.data?.fields == undefined) {
            return;
        }
        SudLabs.onRecordUpdate(dataOrError?.data, this.refreshRecord.bind(this));
    }

    refreshDelay = Delay.for(Seconds(2)); // refresh max once every two seconds
    refreshRecord() {
        if (this.refreshDelay.isActive()) {
            return;
        }
        this.refreshDelay.start();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
    }
}
