import { LightningElement, api } from "lwc";
import vccErrorDisplay_Default_Friendly_Mesage from "@salesforce/label/c.vccErrorDisplay_Default_Friendly_Mesage";

//templates
import tinyTemplate from "./tiny.html";
import defaultTemplate from "./defaultTemplate";

const VARIANT = {
    tiny: tinyTemplate
};

import LoggerMixin from "c/loggerMixin";

export default class VccErrorDisplay extends LoggerMixin(LightningElement) {
    @api
    variant = "default";

    @api
    userFriendly = vccErrorDisplay_Default_Friendly_Mesage;

    @api
    system;

    @api
    title = "Error";

    @api
    activeSections = ["Details"];

    @api
    recordData;

    @api
    recordId;

    @api
    objectName;

    get loggerData() {
        this.Logger.debug("START ERROR::" + this.objectName + " ID ==> " + this.recordData + " ---- " + this.system);
        this.Logger.saveLog();
        return null;
    }

    get either() {
        if (typeof this.system == "string") {
            return this.system;
        } else {
            return this.userFriendly;
        }
    }

    render() {
        if (VARIANT[this.variant] == undefined) {
            return defaultTemplate;
        } else {
            return VARIANT[this.variant];
        }
    }
}
