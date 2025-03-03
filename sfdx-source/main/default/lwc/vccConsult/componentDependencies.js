/**
 * @author Booz Allen
 * @description: This file contains the dependencies for the vccConsult component
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
    title: 'Consults',
    icon: 'standard:individual'
};

const columns = [
    {
        label: 'Request Date',
        fieldName: 'requested',
        type: 'button',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: { fieldName: 'requestedString' },
            title: 'Click to View Consult Details',
            name: 'consultDetailClick',
            variant: 'base',
            type: 'date-local'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Consult Number', fieldName: 'id', type: 'text', sortable: true },
    { label: 'To Service', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'From Clinic', fieldName: 'facilityName', type: 'text', sortable: true },
    { label: 'Requestor', fieldName: 'provDxName', type: 'text', sortable: true },
    { label: 'Urgency', fieldName: 'urgency', type: 'text', sortable: true }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Result_Comments__c', //! VCV default      PHARM uses VCC_Labs__c
            preTextHeader: 'Request Date - Consult Number - To Service - Status - From Clinic - Requestor - Urgency \n'
        }
    ],
    initialSort: { field: 'requested', stringField: 'requested', direction: 'asc' },
    singleFilterField: {} //? empty so it won't show the filter option // {label: 'Name', apiName: 'name'}
};

const addToNoteDefaultColumns = [
    { label: 'Request Date', fieldName: 'requested', type: 'button', sortable: true },
    { label: 'Consult Number', fieldName: 'id', type: 'text', sortable: true },
    { label: 'To Service', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'From Clinic', fieldName: 'facilityName', type: 'text', sortable: true },
    { label: 'Requestor', fieldName: 'provDxName', type: 'text', sortable: true },
    { label: 'Urgency', fieldName: 'urgency', type: 'text', sortable: true }
];

export const errMessageTitle = 'There was an error retrieving records.';
export const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;

export const componentDependencies = {
    ...healthDataService,
    addToNoteDefaultColumns,
    addToNoteDefaultOptions,
    columns,
    settings,
    actionsComponent
};
