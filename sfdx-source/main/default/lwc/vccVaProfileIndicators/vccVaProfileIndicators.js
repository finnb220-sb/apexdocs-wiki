import { api, LightningElement, track } from "lwc";
import vccVaProfileNoIndicators from "@salesforce/label/c.vccVaProfileNoIndicators";
import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";
import fFIndicator from "@salesforce/label/c.VCC_financial_Fraud_Indicator";
import fidIndicator from "@salesforce/label/c.VCC_fiduciary_Indicator";
import aPIndicator from "@salesforce/label/c.VCC_active_Prescription_Indicator";
import sPIndicator from "@salesforce/label/c.VCC_sensitive_Patient_Indicator";

const indicatorLabelMap = {
    financialFraudIndicator: fFIndicator,
    fiduciaryIndicator: fidIndicator,
    activePrescriptionIndicator: aPIndicator,
    sensitivityFlag: sPIndicator
};

export default class VccVaProfileIndicators extends LightningElement {
    indicatorLabelMap = indicatorLabelMap;
    vccVaProfileNoIndicators = vccVaProfileNoIndicators;

    @track
    indicators = [];

    /** empty state */
    noResults = false;
    labels = {
        noResultsMessage: vccVaProfileNoIndicators,
        noResultsSubMessage: "",
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    @api
    set vaProfileData(val) {
        if (val && Object.keys(val).includes("vaProfilePersonAttributes") && Object.keys(val).includes("vaProfileIdentity")) {
            this.processIndicators(val);
        } else {
            this.noResults = true;
        }
    }
    get vaProfileData() {
        return true;
    }

    processIndicators(vaProfile) {
        // this.recursiveObjectSearch(vaProfile);
        let vaProfilePersonAttributes = vaProfile?.vaProfilePersonAttributes;
        let vaProfileIdentity = vaProfile?.vaProfileIdentity;

        this.indicators.push({
            label: indicatorLabelMap.sensitivityFlag,
            value: !!vaProfileIdentity?.sensitivityInformation?.sensitivityFlag
        });
        this.indicators.push({
            label: indicatorLabelMap.financialFraudIndicator,
            value: !!vaProfilePersonAttributes?.financialFraudInformation?.financialFraudIndicator
        });
        this.indicators.push({
            label: indicatorLabelMap.fiduciaryIndicator,
            value: !!vaProfilePersonAttributes?.fiduciaryInformation?.fiduciaryIndicator
        });
        this.indicators.push({
            label: indicatorLabelMap.activePrescriptionIndicator,
            value: !!vaProfilePersonAttributes?.activePrescriptionBio?.activePrescriptionIndicator
        });
    }

    recursiveObjectSearch(obj) {
        for (let prop in obj) {
            if (prop && obj[prop] && typeof obj[prop] == "object" && !!Object.keys(obj[prop]).length) {
                this.recursiveObjectSearch(obj[prop]);
            } else {
                if (this.indicatorLabelMap[prop]) {
                    let indicator = {
                        label: this.indicatorLabelMap[prop],
                        value: obj[prop]
                    };
                    this.indicators.push(indicator);
                }
            }
        }
    }
}
