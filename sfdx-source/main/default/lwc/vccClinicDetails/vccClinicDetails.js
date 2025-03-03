/**
 * @description vccClinicDetails is used to get the Clinic Details for the Clinic that is currently being viewed.
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 */
import { LightningElement, api, track } from 'lwc';
import getClinicByIEN from '@salesforce/apex/VCC_ScheduleAppointmentRequestController.getClinicByIEN';

export default class VccClinicDetails extends LightningElement {
    @track clinicInfo;
    @api siteId;
    loading = false;
    error = false;
    /**
     * @description Obligitory getter. No functional purpose.
     */
    get clinicIEN() {
        return null;
    }

    /**
     * @description Setter for clinicIEN. When the clinicIEN value is received by the component, it will call getClinicByIEN to retrieve the clinic details.
     * @param value The clinicIEN to search by
     */
    @api
    set clinicIEN(value) {
        if (value) {
            this.getClinicByIEN(value);
        }
    }

    /**
     * @description getClinicByIEN calls the Apex method to get the Clinic Details for the clinic.
     * @param clinicId the ClinicIEN to search by
     */
    async getClinicByIEN(clinicId) {
        try {
            this.loading = true;
            let result = await getClinicByIEN({
                siteId: this.siteId,
                clinicIEN: clinicId
            });
            if (result && result instanceof Object) {
                this.handleClinicByIENResult(result);
            }
        } catch (error) {
            const logger = this.template.querySelector('c-logger');
            if (logger) {
                if (error instanceof Error) {
                    logger.error(error.message);
                    logger.error(error.stack);
                } else {
                    logger.error(JSON.stringify(error));
                }
                logger.saveLog();
            }
            this.error = true;
        } finally {
            this.loading = false;
        }
    }

    /**
     * @description Handler function for the Clinic Details once received. References the details of the first Provider in the fullProviderList array and passes that back to the parent component. If
     * the Appointment Request is Requested by Patient, this provider will be used as the default provider for the provider tab.
     * @param {*} result
     */
    handleClinicByIENResult(result) {
        this.clinicInfo = result;
        if (
            this.clinicInfo?.providers &&
            this.clinicInfo?.providers instanceof Array &&
            this.clinicInfo?.providers.length
        ) {
            let ien = this.clinicInfo?.providers[0]?.ien;
            let name = this.clinicInfo?.providers[0]?.name;
            this.dispatchEvent(
                new CustomEvent('defaultprovider', { detail: { providerIEN: ien, providerName: name } })
            );
        }
        this.dispatchEvent(new CustomEvent('clinicdetails', { detail: { clinicDetails: this.clinicInfo } }));
    }

    /**
     * @description getter for the clinicName property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get clinicName() {
        return this.clinicInfo?.name;
    }

    /**
     * @description getter for the provider property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get providers() {
        if (this.clinicInfo?.providers !== undefined && this.clinicInfo?.providers instanceof Array) {
            let providerNames = this.clinicInfo.providers.map((provider) => {
                return provider?.name;
            });
            return providerNames.join('\n');
        }
        return '';
    }

    /**
     * @description getter for the address property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get address() {
        return this.clinicInfo?.physicalLocation;
    }

    /**
     * @description getter for the phone property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get phone() {
        return this.clinicInfo?.telephoneNumber;
    }

    /**
     * @description getter for the extenstion property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get extension() {
        return this.clinicInfo?.telephoneExtension;
    }

    /**
     * @description getter for the specialInstructions property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get specialInstructions() {
        if (
            this.clinicInfo?.specialInstructions !== undefined &&
            this.clinicInfo?.specialInstructions instanceof Array
        ) {
            let specialInstructionList = this.clinicInfo.specialInstructions.map((element) => {
                return element?.specialInstruction;
            });
            return specialInstructionList.join('\n');
        }
        return '';
    }

    /**
     * @description getter for the overbookingLimit property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get overbookingLimit() {
        return this.clinicInfo?.maxOverBooksPerDay;
    }

    /**
     * @description getter for the variableLengthAppointments property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get variableLengthAppointments() {
        return this.clinicInfo?.isVariableLengthAppointment;
    }

    /**
     * @description getter for the timeZone property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get timeZone() {
        return this.clinicInfo?.timezone;
    }

    /**
     * @description getter for the appointmentLength property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get appointmentLength() {
        return this.clinicInfo?.lengthOfAppointment;
    }

    /**
     * @description getter for the activeFlag property. References the appropriate property from the returned clinicInfo. This is referenced in the HTML.
     */
    get activeFlag() {
        return this.clinicInfo?.isActive;
    }
}
