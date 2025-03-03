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
    title: 'Orders',
    icon: 'standard:orders'
};

const columns = [
    {
        label: 'Date of Order',
        fieldName: 'start',
        type: 'date',
        sortable: true,
        initialWidth: 100,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },
    { label: 'Type', fieldName: 'type', type: 'text', sortable: true, initialWidth: 100 },
    {
        label: 'Status',
        fieldName: 'statusName',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'statusName' },
            title: 'Click to View More',
            name: 'displayOrderDetails',
            variant: 'base',
            type: 'text'
        },
        initialWidth: 125
    },
    { label: 'Flagged', fieldName: 'flag', type: 'text', sortable: true, initialWidth: 70 },
    { label: 'Provider', fieldName: 'providerName', type: 'text', sortable: true, initialWidth: 150 },
    {
        label: 'Date of Test',
        fieldName: 'signed',
        type: 'date',
        sortable: true,
        initialWidth: 100,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },
    { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true, initialWidth: 150 },
    { label: 'Content', fieldName: 'content', type: 'text', sortable: true, initialWidth: 500 }
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
