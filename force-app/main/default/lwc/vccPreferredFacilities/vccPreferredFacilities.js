import { LightningElement, api, track, wire } from 'lwc';
import getFacilityNames from '@salesforce/apex/VCC_OnPatientLoadController.getFacilityNames';
import getUserVistaList from '@salesforce/apex/VCC_OnPatientLoadController.userVistAs';
import vccAvailableFacilities from '@salesforce/label/c.VCC_Available_Facilities';
import vccMPINoRecordsReturned from '@salesforce/label/c.vccEeNoFacilities';
import vccNoAvailableFacilitiesReturned from '@salesforce/label/c.VCC_No_Available_Facilities_Returned';
import vccNoUnavailableFacilitiesReturned from '@salesforce/label/c.VCC_No_Unavailable_Facilities_Returned';
import vccPatientRegisteredFacilitiesTitle from '@salesforce/label/c.VCC_Patient_Registered_Facilities_Title';
import vccUnavailableFacilities from '@salesforce/label/c.VCC_Unavailable_Facilities';
import { MPISharedState } from 'c/scdMPISharedState';
import { debounce } from 'c/bahToolKit';

const columns = [
    { label: 'Name', fieldName: 'facilityName', type: 'text', wrapText: true, hideDefaultAction: true },
    { label: 'Station', fieldName: 'facilityCode', type: 'text', hideDefaultAction: true, initialWidth: 125 }
];

export default class VccPreferredFacilities extends LightningElement {
    columns = columns;

    @track isLoading = false;
    error = false;
    errorMsg = vccMPINoRecordsReturned;
    _mpiData;
    labels = {
        vccPatientRegisteredFacilitiesTitle,
        vccAvailableFacilities,
        vccNoAvailableFacilitiesReturned,
        vccUnavailableFacilities,
        vccNoUnavailableFacilitiesReturned
    };
    selectedRows = [];
    tableDataAccessible;
    tableDataInAccessible;
    userVistAList;
    @api preselectedrows = [];
    @api hasError = false;
    //Adding back public property for package ancestory error
    @api availFacilityLabel;
    @api unavailfacilitylabel;
    @api esrData;
    @api hidecheckboxcolumn;
    @api tableData = [];
    @api mpiData;

    @api
    set showSelectionColumn(val) {
        this._showSelectionColumns = val;
    }
    get showSelectionColumn() {
        if (this._showSelectionColumns === undefined) {
            return true;
        }
        return !this._showSelectionColumns;
    }

    medicalCenterFacilitiesWithoutNamesJson;
    facilitiesWithNamesResult;
    @wire(getFacilityNames, { facilityListJson: '$medicalCenterFacilitiesWithoutNamesJson' })
    getFacilityNames(result) {
        this.facilitiesWithNamesResult = result;
        if (this.mpiData === null || typeof this.mpiData !== 'object') {
            return;
        }
        const { data /*, error */ } = result;
        if (data) {
            let medicalFacilities = JSON.parse(data);
            this.parseFacilities(
                medicalFacilities,
                this.mpiData.ee?.eeExtendedResponse?.demographics?.preferredFacilities
            );
            //setting MPI Data with Name included in Medical Facility Array
            this.setMPIData(medicalFacilities);
        } else {
            this.error = true;
        }
    }

    /**
     * @description Set the MPI Data with a one second debounce to allow other components that rely on it to render on the page and subscribe to the message channel.
     * @param {Object} medicalFacilities
     */
    setMPIData = debounce((medicalFacilities) => {
        if (this.mpiData && this.mpiData.mvi) {
            //Using JSON.parse(JSON.stringify(data)) instead of spread operator due to problems with @wire and immutability errors
            let mpiClone = JSON.parse(JSON.stringify(this.mpiData));
            mpiClone.mvi.medicalCenterFacilities = medicalFacilities;
            MPISharedState.setData(mpiClone);
        }
    }, 1000);

    renderedCallback() {
        if (this.mpiData !== null && typeof this.mpiData === 'object') {
            this.medicalCenterFacilitiesWithoutNamesJson = JSON.stringify(this.mpiData?.mvi?.medicalCenterFacilities);
        }
        if (this.preselectedrows.length) {
            this.selectedRows = this.preselectedrows;
        }
        if (this.hasError) {
            this.error = true;
        }
    }

    handleFacilityError(error) {
        let err = error?.body?.message ? JSON.parse(error?.body?.message) : null;
        if (err?.statusCode === 404) {
            this.displayError('No records found by patient ICN.');
        } else {
            this.displayError();
        }
    }

    displayError(msg) {
        this.error = true;
        if (typeof msg == 'string' && msg.length > 0) {
            this.errorMsg = msg;
        } else {
            this.errorMsg = 'An unexpected error has occurred.';
        }
    }

    hideError() {
        this.error = false;
        this.errorMsg = '';
    }

    async parseFacilities(medicalFacilities, preferredFacilities) {
        let facilitiesMap = new Map();
        if (medicalFacilities?.length) {
            //facilityName, isPrimary
            for (let i = 0; i < medicalFacilities.length; i++) {
                let { facilityId, personId, facilityName } = medicalFacilities[i];
                facilitiesMap.set(facilityId, {
                    patientLocalPid: personId,
                    facilityCode: facilityId,
                    facilityName: facilityName,
                    isPreferred: false
                });
            }
            if (preferredFacilities?.length) {
                // filters out duplicates from preferredFacilities
                const ids = preferredFacilities.map(({ preferredFacility }) => preferredFacility);
                const uniquePreferredFacilities = preferredFacilities.filter(
                    ({ preferredFacility }, index) => !ids.includes(preferredFacility, index + 1)
                );
                const length = uniquePreferredFacilities.length;
                for (let i = 0; i < length; i++) {
                    let { preferredFacility } = preferredFacilities[i];
                    preferredFacility = parseInt(preferredFacility, 10).toString();
                    let facility = facilitiesMap.get(preferredFacility);
                    if (facility == null || facility === undefined) {
                        continue;
                    }
                    facilitiesMap.get(preferredFacility).isPreferred = true;
                }
            }
        }
        this.userVistAList = await getUserVistaList();
        try {
            let availFacilities = [];
            let unavailFacilities = [];
            for (let [key, value] of facilitiesMap.entries()) {
                if (this.userVistAList.includes(key)) {
                    availFacilities.push(value);
                } else {
                    unavailFacilities.push(value);
                }
            }
            if (availFacilities?.length) {
                this.tableDataAccessible = availFacilities;
            }
            if (unavailFacilities?.length) {
                this.tableDataInAccessible = unavailFacilities;
            }

            // Facility Access Code
            let customEvent = new CustomEvent('afterload', {
                detail: {
                    tableDataAccessible: this.tableDataAccessible,
                    tableDataInAccessible: this.tableDataInAccessible
                }
            });
            this.dispatchEvent(customEvent);
        } catch (e) {
            this.error = true;
        }
    }

    /**
     * @description handleRowSelect passes the details of the Selected Row to the parent component.
     * @param {Object} event
     */
    handleRowSelect(event) {
        if (event?.detail?.selectedRows?.length && event?.detail?.selectedRows[0]?.facilityName) {
            this.selectedRows = [event?.detail?.selectedRows[0]?.facilityName];
            let customEvent = new CustomEvent('rowselect', {
                detail: {
                    row: event.detail.selectedRows[0]
                }
            });
            this.dispatchEvent(customEvent);
        }
    }
}
