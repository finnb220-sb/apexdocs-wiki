import { LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { runTestForSite, getToken } from "c/vccVatPageController";
export default class VccVatPage extends LightningElement {
    //components on page
    vistaListComponent; //c-vcc-vat-page-vista-list
    headerComponent; //c-vcc-vat-page-header
    servicesComponent; //c-vcc-vat-page-services

    isLoading = false;
    token; //vdif token

    renderedCallback() {
        if (this.vistaListComponent != null && this.headerComponent != null && this.servicesComponent != null) {
            return;
        }

        if (this.vistaListComponent == null) {
            this.vistaListComponent = this.template.querySelector("c-vcc-vat-page-vista-list");
        }

        if (this.headerComponent == null) {
            this.headerComponent = this.template.querySelector("c-vcc-vat-page-header");
        }

        if (this.servicesComponent == null) {
            this.servicesComponent = this.template.querySelector("c-vcc-vat-page-services");
        }
    }

    getService() {
        return this.servicesComponent.getChosenService();
    }

    getAllSiteDetails() {
        return this.vistaListComponent.getAllSiteDetails();
    }

    getDefaultEsig() {
        return this.headerComponent.esig;
    }

    dispatchErrorToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                variant: "error",
                title: "Error",
                message: "An error has occurred, check the browser console for more info"
            })
        );
    }

    async handleTestAll(e) {
        try {
            this.isLoading = true;

            let siteDetails = this.getAllSiteDetails();

            if (!Array.isArray(siteDetails) || siteDetails.length === 0) {
                return;
            }

            let defaultEsig = this.getDefaultEsig();

            this.vistaListComponent.clearSiteStatuses();

            if (typeof this.token != "string" || this.token.length == 0) {
                this.token = await getToken();
            }

            let promises = siteDetails.flatMap((siteDetail) => {
                if ((typeof siteDetail.esig != "string" || siteDetail.esig.length === 0) && (typeof defaultEsig != "string" || defaultEsig.length === 0)) {
                    return [];
                }

                let esig = typeof siteDetail.esig != "string" || siteDetail.esig.length === 0 ? defaultEsig : siteDetail.esig;

                return runTestForSite({
                    serviceApiName: this.getService(),
                    siteCode: siteDetail.site,
                    esig: esig,
                    token: this.token,
                    duz: siteDetail.duz
                });
            });

            (await Promise.allSettled(promises)).forEach((result) => {
                let {
                    // status,
                    value
                } = result;

                this.setSiteRunTestResult(value);
            });
        } catch (e) {
            console.warn(e);
            this.dispatchErrorToast();
        } finally {
            this.isLoading = false;
        }
    }

    setSiteRunTestResult(runTestResult) {
        this.vistaListComponent.setSiteRunTestResult(runTestResult);
    }

    async handleTestSite(e) {
        try {
            this.isLoading = true;

            let { site, esig, duz } = e.detail;

            if (typeof this.token != "string" || this.token.length == 0) {
                this.token = await getToken();
            }

            if (typeof site != "string" || site.length === 0 || typeof esig != "string" || esig.length === 0 || typeof duz != "string" || duz.length === 0) {
                return;
            }

            let result = await runTestForSite({
                serviceApiName: this.getService(),
                siteCode: site,
                esig: esig,
                duz: duz,
                token: this.token
            });

            this.setSiteRunTestResult(result);
        } catch (e) {
            console.warn(e);
            this.dispatchErrorToast();
        } finally {
            this.isLoading = false;
        }
    }

    handleTestModeChange(e) {
        this.vistaListComponent.runIndividualMode = e.detail.runIndividualMode;
    }
}
