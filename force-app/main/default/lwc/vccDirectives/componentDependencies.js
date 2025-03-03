/**
 * @author Booz Allen
 * @description: This file contains the dependencies for the vccdirectives component
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
    title: 'Directives',
    icon: 'standard:metrics'
};

/** columns for datatable within frame component */
const columns = [
    {
        label: 'Date',
        fieldName: 'dateCreatedFormatted',
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'dateCreatedFormatted' },
            variant: 'base'
        },
        sortable: true
    },
    { label: 'Local Title', fieldName: 'localTitle', type: 'text', sortable: true },
    { label: 'Type', fieldName: 'nationalTitleType', type: 'text', sortable: true },
    { label: 'Encounter Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true }
];

const errMessageTitle = 'There was an error retrieving records.';
const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;

export const componentDependencies = {
    ...healthDataService,
    columns,
    settings,
    actionsComponent,
    errMessageTitle,
    errSubMessage
};
