/* eslint-disable no-extra-boolean-cast */
// disabling the rule that disallows the use of the  double bang operator to evaluate if something is truthy or not, the method setUpGraph uses (!!) in ternary operators to determines whether or not use defaults

/**
 * @author Booz Allen
 * @description: This file contains the dependencies for the vccVitals component
 * NOTE: any methods/variables that do not need access to the class instance and are specific to this component should be stored here
 * NOTE: any wired methods or lightning modal references must be made on the class that extends 'lightningElement', those cannot be stored here
 *
 * NOTE: If you are experiencing an error message with the following text: "Looks like there's a problem.
 * Unfortunately, there was a problem. Please try again. If the problem continues, get in touch with your administrator with the error ID shown here and any other related details." Check
 * this file for any syntax errors or missing imports
 *
 */

import { healthDataService } from 'c/services';
import { properCase } from 'c/helpersLWC';

const actionsComponent = {
    name: 'c/vccHdrDatatableActions',
    props: {
        showAddToNote: false,
        options: []
    }
};

const settings = {
    title: 'Vitals',
    icon: 'standard:feed'
};

const columns = [
    {
        label: 'Date/Time',
        fieldName: 'taken',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'takenFormatted' },
            title: 'Click to measurements taken on this date',
            name: 'DateTimeButtonClicked',
            variant: 'base',
            type: 'date'
        }
    },
    {
        label: 'Temperature (\u2109)',
        fieldName: 'temperature',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'temperature' },
            title: 'Click to View Temperature Metrics',
            name: 'TemperatureButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Pulse (beats/min)',
        fieldName: 'pulse',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'pulse' },
            title: 'Click to View Pulse Metrics',
            name: 'PulseButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Blood Pressure (mm[Hg])',
        fieldName: 'bloodPressure',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'bloodPressure' },
            title: 'Click to View Pulse Metrics',
            name: 'BloodPressureButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Respiration (breaths/min)',
        fieldName: 'respiration',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'respiration' },
            title: 'Click to View Respiration Metrics',
            name: 'RespirationButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Pain (0-10)',
        fieldName: 'pain',
        type: 'text',
        sortable: true
    },
    {
        label: 'Weight (lbs)',
        fieldName: 'weight',
        type: 'button',
        sortable: true,

        typeAttributes: {
            label: { fieldName: 'weight' },
            title: 'Click to View Weight Metrics',
            name: 'WeightButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Height (in)',
        fieldName: 'height',
        type: 'text',
        sortable: true
    },
    {
        label: 'Body Mass Index (BMI)',
        fieldName: 'bmi',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'bmi' },
            title: 'Click to View BMI Metrics',
            name: 'BMIButtonClicked',
            variant: 'base',
            type: 'text'
        }
    },
    {
        label: 'Pulse Oximetry',
        fieldName: 'pulseOximetry',
        type: 'text',
        sortable: true
    },
    {
        label: 'Circumference/Girth',
        fieldName: 'circumferenceGirth',
        type: 'text',
        sortable: true
    },
    {
        label: 'Central Venous Pressure',
        fieldName: 'centralVenousPressure',
        type: 'text',
        sortable: true
    }
];

export function formatForDatatable(data) {
    const flatRecords = [];

    data.sites.forEach((site) => {
        site.records.forEach((record) => {
            const flatRecord = {
                vtcId: record.vtcId,
                taken: record.taken,
                takenFormatted: record.takenFormatted,
                facilityName: record.facilityName,
                facilityCode: record.facilityCode,
                pain: null,
                temperature: null,
                pulse: null,
                bloodPressure: null,
                height: null,
                weight: null,
                bmi: null,
                respiration: null,
                pulseOximetry: null,
                circumferenceGirth: null,
                centralVenousPressure: null
            };

            record.measurements.forEach((measurement) => {
                switch (measurement.name) {
                    case 'PAIN':
                        flatRecord.pain = measurement.value || '\u2014';
                        break;
                    case 'TEMPERATURE':
                        flatRecord.temperature = measurement.value || '\u2014';
                        flatRecord.temperatureHigh = measurement.high ?? '';
                        flatRecord.temperatureLow = measurement.low ?? '';
                        break;
                    case 'PULSE':
                        flatRecord.pulse = measurement.value || '\u2014';
                        flatRecord.pulseHigh = measurement.high ?? '';
                        flatRecord.pulseLow = measurement.low ?? '';
                        break;
                    case 'BLOOD PRESSURE':
                        flatRecord.bloodPressure = measurement.value || '\u2014';
                        flatRecord.bloodPressureHigh = measurement.high ?? '';
                        flatRecord.bloodPressureLow = measurement.low ?? '';
                        break;
                    case 'HEIGHT':
                        flatRecord.height = measurement.value || '\u2014';
                        break;
                    case 'WEIGHT':
                        flatRecord.weight = measurement.value || '\u2014';
                        flatRecord.bmi = measurement.bmi || '\u2014'; // make sure that this is a parsable number, remove the extra star
                        break;
                    case 'RESPIRATION':
                        flatRecord.respiration = measurement.value || '\u2014';
                        flatRecord.respirationHigh = measurement.high ?? '';
                        flatRecord.respirationLow = measurement.low ?? '';
                        break;
                    case 'PULSE OXIMETRY':
                        flatRecord.pulseOximetry = measurement.value || '\u2014';
                        flatRecord.pulseOximetryHigh = measurement.high ?? '';
                        flatRecord.pulseOximetryLow = measurement.low ?? '';
                        break;
                    case 'CIRCUMFERENCE/GIRTH':
                        flatRecord.circumferenceGirth = measurement.value || '\u2014';
                        break;
                    case 'CENTRAL VENOUS PRESSURE':
                        flatRecord.centralVenousPressure = measurement.value || '\u2014';
                        flatRecord.centralVenousPressureHigh = measurement.high ?? '';
                        flatRecord.centralVenousPressureLow = measurement.low ?? '';
                        break;
                    default:
                        break;
                }
            });

            flatRecords.push(flatRecord);
        });
    });

    return flatRecords;
}

/**
 * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
 * @param event Event from BaseHDRFrame when a row is selected
 * @param hdrFrameComponentName Name of the custom frame component to query state from
 * @param detailComponentName Name of the detail component to render in the modal
 */
function renderGraphFrame() {
    const listeners = [
        {
            name: 'onclose',
            method: this.closeModal
        }
    ];
    const body = {
        name: 'c/vccHealthDataGraphFrame',
        props: {
            graphConfig: this.graphConfig,
            dataTableIconAndTitle: this.dataTableIconAndTitle,
            iconName: settings.icon,
            title: this.title,
            chartTitle: this.chartTitle,
            displayReferenceRange: this.referenceRange,
            measurementsToDisplay: this.selectedMeasurements,
            isBloodPressure: this.isBloodPressure,
            componentToRender: this.componentToRender,
            vitalTypeSelected: this.vitalTypeSelected
        }
    };

    const footer = {
        name: 'c/baseButtonList',
        props: {
            buttons: [
                {
                    name: 'close',
                    buttonProps: {
                        label: 'Close',
                        value: 'close',
                        name: 'close'
                    }
                }
            ]
        }
    };

    healthDataService.renderBaseLightningModal.call(this, { body, listeners, footer, size: 'medium' });
}

/**
 *
 * // TODO: remove defaults and move this method to a more generic helper file
 *
 * @param vitalType determines which property on the "additionalDetails" object to query against, e.g. WEIGHT queries against the weight array for labels and data
 * @param chartType type of chart to render e.g bar vs line
 * @param chartColor color of the visualization
 * @param datasets
 * @param options
 */
function setUpGraph({ vitalType, chartType, chartColor, datasets, labels, options }) {
    this.graphConfig = {
        chartType: !!chartType ? chartType : 'line', // defaulting to line
        labels: labels?.length
            ? labels
            : this.additionalData[vitalType]
                  .map((vital) => vital.takenFormatted)

                  .slice(0, 5)
                  .reverse(),
        datasets: datasets?.length
            ? datasets
            : [
                  {
                      label: properCase(vitalType),
                      data: this.additionalData[vitalType].map((vital) => parseFloat(vital.value, 10)).slice(0, 5),
                      fill: false,
                      backgroundColor: chartColor,
                      borderColor: chartColor
                  }
              ],
        options: options
    };
}

function calculateReading({ high, low, value }) {
    if (parseFloat(value, 10) > parseFloat(high, 10)) {
        return {
            message: '(High)',
            icon: 'utility:arrowup',
            class: 'icon-high'
        };
    }

    if (parseFloat(value, 10) < parseFloat(low, 10)) {
        return {
            message: '(low)',
            icon: 'utility:arrowdown',
            class: 'icon-low'
        };
    }

    return {
        message: '(Normal)',
        icon: 'utility:check',
        class: 'icon-normal'
    };
}

export const errMessageTitle = 'There was an error retrieving records.';
export const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;

export const componentDependencies = {
    ...healthDataService,
    calculateReading,
    setUpGraph,
    renderGraphFrame,
    formatForDatatable,
    columns,
    settings,
    actionsComponent
};
