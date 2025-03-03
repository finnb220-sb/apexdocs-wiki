/* eslint-disable no-constant-condition */
/* eslint-disable @lwc/lwc/no-api-reassignments */ //eslint-disable-line
import { api, track, LightningElement } from "lwc";
import { processESR, mainArea, insurance, healthBenefitPlans, benefits } from "./vccInsuranceHelper";

import { proxyTool } from "c/helpersLWC"; //eslint-disable-line
import vccMPINoRecordsReturned from "@salesforce/label/c.vccMPINoRecordsReturned"; //eslint-disable-line
import noResultsMessage from "@salesforce/label/c.VCC_Generic_message_for_null_search_results"; //eslint-disable-line
import noResultsSubMessage from "@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results"; //eslint-disable-line
import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";

export default class VccInsuranceAndEligibility extends LightningElement {
    @api esrData;
    @api mviData;
    //---9/9/2021--- Matthew Zolp --- Re-added eligibilityVerification public property to resolve package ancestory error
    @api eligibilityVerification;
    showBottom = false;

    loading;

    @track nav = {
        showInsurance: false,
        showHealthPlans: false,
        showEligibilities: false,
        showBenefits: false,
        isEnrolled: null
    };

    @track display = {
        main: null,
        insurance: null,
        associations: null,
        demographics: null,
        eligibility: null,
        enrollment: null,
        healthBenefitPlans: null,
        benefits: null
    };

    /** empty state */
    isDebugMode = false;
    noResults = false;
    noConnection = false;
    labels = {
        noResultsMessage: "No Insurance or Eligibility Data Available For This Patient.",
        noResultsSubMessage: "",
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    connectedCallback() {
        if (this.esrData && !this.isDebugMode) {
            this.loading = true;
            this.esrData = processESR(this.esrData);
            this.display.main = mainArea(this.esrData);
            this.display.insurance = insurance(this.esrData);
            this.display.healthBenefitPlans = healthBenefitPlans(this.esrData);
            this.display.benefits = benefits(this.esrData);

            if (this.esrData?.eeExtendedResponse?.enrollmentDetermination?.enrollmentStatus) {
                let status = this.esrData?.eeExtendedResponse?.enrollmentDetermination?.enrollmentStatus;

                if (status.toLowerCase().includes("pending")) {
                    this.nav.isEnrolled = false;
                } else if (status.toLowerCase().includes("verified")) {
                    this.nav.isEnrolled = true;
                }
            }
            this.loading = false;
        } else {
            this.noResults = true;
        }
    }

    handleClick() {
        // let id = event.target.id;
        this.showHide();
    }
    handleKeyDownInsurance(event) {
        if (event.keyCode === 13 || 32) {
            this.handleToggleInsurance();
        }
    }

    handleKeyDownHealthPlans(event) {
        if (event.keyCode === 13 || 32) {
            this.handleHealthPlans();
        }
    }
    handleKeyDownBenefits(event) {
        if (event.keyCode === 13 || 32) {
            this.handleBenefits();
        }
    }
    showHide() {
        this.showBottom = !this.showBottom;
    }

    handleToggleInsurance() {
        this.nav.showInsurance = !this.nav.showInsurance;
    }

    handleHealthPlans() {
        this.nav.showHealthPlans = !this.nav.showHealthPlans;
    }

    handleEligibility() {
        this.nav.showEligibilities = !this.nav.showEligibilities;
    }

    handleBenefits() {
        this.nav.showBenefits = !this.nav.showBenefits;
    }
}
