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
    title: 'Imaging/Radiology',
    icon: 'custom:custom21'
};

/** columns for datatable within frame component */
const columns = [
    {
        label: 'Image Type',
        fieldName: 'imagingTypeName',
        type: 'button',
        sortable: true,
        initialWidth: 250,
        typeAttributes: {
            label: { fieldName: 'imagingTypeName' },
            title: 'Click to View Imaging Details',
            name: 'imageTypeClick',
            variant: 'base',
            type: 'text'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Image Name', fieldName: 'name', type: 'text', sortable: true, initialWidth: 300 },
    {
        label: 'Date/Time',
        fieldName: 'xdateTime',
        type: 'date',
        typeAttributes: {
            month: 'numeric',
            day: 'numeric',
            year: 'numeric',
            hour: 'numeric',
            minute: '2-digit',
            timeZone: 'UTC'
        },
        sortable: true
    },
    { label: 'Provider', fieldName: 'providerName', type: 'text', sortable: true },
    { label: 'Facility Name', fieldName: 'facilityName', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true }
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
