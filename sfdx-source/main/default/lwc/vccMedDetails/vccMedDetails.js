/**
 * @description Component displaying individual medication details after user selects RX Number hyperlink from vccMedicationTable
 * @author Booz Allen Hamilton
 */
import { LightningElement, api } from 'lwc';
import { sharedDetails } from './constants';
import nonVAMarkup from './nonVA.html';
import vaMSAMarkup from './vaMSA.html';
import vaRNMarkup from './vaRN.html';
import vaMPMarkup from './vaMP.html';
import vaTEDMarkup from './vaTED.html';
import vaPharmMarkup from './vaPharm.html';
import { dateFormatter } from 'c/utils';

export default class VccMedDetails extends LightningElement {
    @api med;
    @api dose;
    @api emptyStateLabels;

    activityLogColumns;
    isPharmacyUser = false;
    isMSAUser = false;
    isRNUser = false;
    isMPUser = false;
    isTEDUser = false;

    showProviderComments = false;
    _logPermissions;
    _userPermissions;
    medDetails = [];

    /* _type = 'default';

    
    @api set type(val) {
        if (val?.length) {
            if (val === 'nonVA') return nonVA;
            else {
                if(this.isPharmacyUser) return vaPharm;
                if(this.isMSAUser) return vaMSA;
                if(this.isRNUser) return vaRN;
                if(this.isMPUser) return vaMP;
                if(this.isTEDUser) return vaTED;
            }
        }
    }

    get type() {
        return this._type;
    } */

    @api set userPermissions(val) {
        this._userPermissions = val;
        this.isPharmacyUser = this._userPermissions.pharmacyPHR.some((e) => e === true);
        this.isMSAUser = this._userPermissions.adminSchedulingMSA === true;
        this.isRNUser = this._userPermissions.clinicalTriageRN === true;
        this.isMPUser = this._userPermissions.virtualCareVisitMP === true;
        this.isTEDUser = this._userPermissions.teleUrgentTED === true;

        this.showProviderComments =
            this.isPharmacyUser || this._userPermissions.clinicalTriageRN || this._userPermissions.virtualCareVisitMP;
    }

    /**
     * @description Utilizes reusable date formatting through lwc:spread on the
     * lightning-formatted-date-time html tag
     * @returns {object} Date formatting options
     */
    get dateOptions() {
        return dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS;
    }

    get userPermissions() {
        return this._userPermissions;
    }

    // @api enableEmptyState;

    @api set logColumns(val) {
        this.activityLogColumns = (({ refillLogs, partialFillLogs }) => ({ refillLogs, partialFillLogs }))(val);
    }

    get logColumns() {
        return this.activityLogColumns;
    }

    @api set logPermissions(val) {
        this._logPermissions = (({ refillLog, partialLog }) => ({ refillLog, partialLog }))(val);
    }

    get logPermissions() {
        return this._logPermissions;
    }

    get canSeeActivityLogs() {
        return this._logPermissions.refillLog || this._logPermissions.partialLog;
    }

    /**
     * @description Populates pharm log request fields
     * @returns {Object}
     */
    get pharmLogRequest() {
        return {
            prescriptionId: this.med?.fullData?.prescription?.value,
            facilityId:
                this.med?.fullData?.facility?.code.length > 3
                    ? this.med?.fullData?.facility?.code.substring(0, 3)
                    : this.med?.fullData?.facility?.code,
            logType: this.logType
        };
    }

    renderedCallback() {
        if (this.med) this.processMed(this.med);
    }

    //? used when iteration plan is implemented
    processMed(med) {
        sharedDetails.forEach((detail) => {
            let obj = {};
            obj.title = detail.title;
            obj.infoValue = med[detail.info];
            obj.show = true;
            this.medDetails.push(obj);
        });
    }

    logType = 'refill';
    handleToggleSection(event) {
        // todo: handle multiple sections open at the same time
        const openSections = event.detail.openSections;

        // handle different log types on accordion
        switch (openSections) {
            case 'partialLog':
                this.logType = 'partial';
                break;

            case 'refillLog':
                this.logType = 'refill';
                break;

            default:
            // eslint default
        }
    }

    render() {
        switch (this.med?.fullData?.vaType?.value) {
            case 'N':
                return nonVAMarkup;

            case 'O':
                if (this.isMSAUser) {
                    return vaMSAMarkup;
                } else if (this.isRNUser) {
                    return vaRNMarkup;
                } else if (this.isMPUser) {
                    return vaMPMarkup;
                } else if (this.isTEDUser) {
                    return vaTEDMarkup;
                }
                return vaPharmMarkup;

            default:
                return vaPharmMarkup;
        }
    }
}
