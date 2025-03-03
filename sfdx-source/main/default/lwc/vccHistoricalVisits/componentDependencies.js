/**
 * @author Booz Allen
 * @description: This file contains the dependencies for the vccRediologyList component
 * NOTE: any methods/variables that do not need access to the class instance and are specific to this component should be stored here
 * NOTE: any wired methods or lightning modal references must be made on the class that extends 'lightningElement', those cannot be stored here
 *
 * NOTE: If you are experiencing an error message with the following text: "Looks like there's a problem.
 * Unfortunately, there was a problem. Please try again. If the problem continues, get in touch with your administrator with the error ID shown here and any other related details." Check
 * this file for any syntax errors or missing imports
 *
 */

import { healthDataService } from 'c/services';

const actionsComponent = {
    name: 'c/vccHdrDatatableActions',
    props: {
        showAddToNote: false,
        options: []
    }
};

const settings = {
    title: 'Historical Visits',
    icon: 'standard:location_permit'
};

/** columns for datatable within frame component */
const columns = [
    {
        label: 'Date/Time',
        fieldName: 'dateTimeOfVisitFormattedString',
        type: 'button',
        sortable: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: 'dateTimeOfVisitFormattedString' },
            title: 'Click to View Historical Visits Details',
            name: 'historicalVisitsDetailClick',
            variant: 'base',
            type: 'date'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Visit Type', fieldName: 'typeName', type: 'text', sortable: true },
    { label: 'Reason', fieldName: 'reasonName', type: 'text', sortable: true },
    { label: 'Patient Class', fieldName: 'patientClassName', type: 'text', sortable: true },
    { label: 'Facility Name', fieldName: 'facilityName', type: 'text', sortable: true },
    { label: 'Provider Name', fieldName: 'providerName', type: 'text', sortable: true }
];

export const errMessageTitle = 'There was an error retrieving records.';
export const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;

export const componentDependencies = {
    ...healthDataService,
    columns,
    settings,
    actionsComponent
};
