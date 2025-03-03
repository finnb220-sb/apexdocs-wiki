import { api, LightningElement } from 'lwc';
import getLocationName from '@salesforce/apex/VCC_DischargeSummaryController.getLocationName';

export default class VccDischargeLocation extends LightningElement {
    isLoading = true;

    @api
    recordId;

    @api
    visitUid;

    @api vtcArgs;

    locationName;

    errorMsg = '';

    initialized = false;

    async renderedCallback() {
        if (this.initialized) {
            return;
        }

        this.initialized = true;
        try {
            this.locationName = await getLocationName({ args: this.vtcArgs });
        } catch (e) {
            this.errorMsg = 'Unable to resolve location due to: ';
            if (typeof e?.body?.message == 'string') {
                this.errorMsg += e.body.message;
            } else {
                this.errorMsg += 'An unhandled fault.';
            }
        } finally {
            this.isLoading = false;
        }
    }
}
