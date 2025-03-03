/*
 * @description :Calls 'VCC_Verify_Caller_2' flow which triggers a screen flow when a user goes into a person account. The html is also a modal container for the flow.
 * @author            : Booz Allen Hamilton
 */

import { LightningElement, api } from 'lwc';

export default class VccVerifyCaller extends LightningElement {
    initialized = false;

    isShowPopup = false;

    @api
    recordId;

    @api
    latestServiceDate;
    @api
    spouseName;

    spouse = '';
    serviceBranch = '';
    serviceNumber = '';
    serviceDate = '';

    @api
    open(resolve) {
        this.isShowPopup = true;
        this.resolve = resolve;
    }

    resolve;

    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        try {
            let lightningFlow = this.template.querySelector('lightning-flow');
            if (lightningFlow === null) {
                return;
            }
            if (this.spouseName) {
                this.checkSpouseData(this.spouseName);
            }
            if (this.latestServiceDate) {
                this.checkServiceData(this.latestServiceDate);
            }
            lightningFlow.flowApiName = 'VCC_Verify_Caller_2';
            lightningFlow.flowInputVariables = [
                {
                    name: 'recordId',
                    type: 'String',
                    value: this.recordId
                },

                {
                    name: 'mpiBranchOfService',
                    type: 'String',
                    value: this.serviceBranch
                },
                {
                    name: 'mpiMilitaryServiceNumber',
                    type: 'String',
                    value: this.serviceNumber
                },
                {
                    name: 'mpiServiceDates',
                    type: 'String',
                    value: this.serviceDate
                },
                {
                    name: 'mpiSpouseName',
                    type: 'String',
                    value: this.spouse
                }
            ];
            this.initialized = true;
        } catch (e) {
            const logger = this.template.querySelector('c-logger');
            if (e instanceof Error) {
                logger.error(e.message);
            }
            logger.saveLog();
        }
    }
    /**
     * @description Checks the data from vccOnPersonAccountRead.js and formats it in a way the flow can read
     * @param spouseInfo - Return data on the vet spouse
     */

    checkSpouseData(spouseInfo) {
        if (spouseInfo.length) {
            // eslint-disable-next-line no-magic-numbers
            this.spouse = `${this.spouseName[0]?.givenName} ${this.spouseName[0]?.familyName}`;
        } else {
            this.spouse = '';
        }
    }

    /**
     * @description Checks the data from vccOnPersonAccountRead.js and formats it in a way the flow can read
     * @param serviceInfo - Return data on the vet service
     */
    checkServiceData(serviceInfo) {
        if (typeof serviceInfo === 'object' && serviceInfo !== null) {
            if (serviceInfo?.serviceBranch) {
                this.serviceBranch = serviceInfo?.serviceBranch;
            } else {
                this.serviceBranch = '';
            }

            if (serviceInfo?.serviceNumber) {
                this.serviceNumber = serviceInfo?.serviceNumber;
            } else {
                this.serviceNumber = '';
            }
            if (serviceInfo.serviceExitDate && serviceInfo.serviceEntryDate) {
                //Format Exit Date
                const formattedExitDate = this.latestServiceDate?.serviceExitDate.replace(
                        /(\d{4})(\d{2})(\d{2})/,
                        '$2/$3/$1'
                    ),
                    //Format Entry Date
                    formattedEntryDate = this.latestServiceDate?.serviceEntryDate?.replace(
                        /(\d{4})(\d{2})(\d{2})/,
                        '$2/$3/$1'
                    );
                this.serviceDate = `${formattedEntryDate} - ${formattedExitDate}`;
            } else {
                this.serviceDate = '';
            }
        }
    }

    handleStatusChange(event) {
        // Disabling because it's an existing issue. Documented as tech debt.
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            let header = this.template.querySelector("[data-id='modal-heading-01']");
            if (header) {
                header.click();
            }
        }, 5000);

        if (event.detail.status === 'FINISHED') {
            this.isShowPopup = false;
            this.resolve();
        }
    }
}
