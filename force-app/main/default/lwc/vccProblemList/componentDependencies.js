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
    title: 'Problem List',
    icon: 'standard:document_reference'
};

const columns = [
    {
        label: 'Name',
        fieldName: 'name',
        type: 'button',
        sortable: true,
        initialWidth: 550,
        typeAttributes: {
            label: { fieldName: 'name' },
            title: 'Click to View Problem Details',
            name: 'problemDetailClick',
            variant: 'base',
            type: 'text'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    {
        label: 'Onset Date',
        fieldName: 'onsetdate',
        type: 'date',
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },
    { label: 'Status', fieldName: 'statusName', type: 'text', sortable: true },
    {
        label: 'Last Updated',
        fieldName: 'updatedDate',
        type: 'date',
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },
    { label: 'ICD Code', fieldName: 'icd', type: 'text', sortable: true },
    { label: 'Description', fieldName: 'icdd', type: 'text', sortable: true, initialWidth: 300 }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Problems__c',
            preTextHeader: 'Name - Description \n'
        }
    ],
    initialSort: { field: 'name', stringField: 'name', direction: 'asc' },
    singleFilterField: {} //? empty so it won't show the filter option // {label: 'Name', apiName: 'name'},
};

const addToNoteDefaultColumns = [
    {
        label: 'Name',
        fieldName: 'name',
        type: 'text',
        sortable: true,
        initialWidth: 550,
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Description', fieldName: 'icdd', type: 'text', sortable: true }
];

const detailComponentColumns = [
    {
        label: 'Date',
        fieldName: 'enteredDate',
        type: 'date',
        hideDefaultActions: true,
        initialWidth: 125,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },
    { label: 'Author Name', fieldName: 'enteredBy', type: 'text', hideDefaultActions: true, initialWidth: 200 },
    { label: 'Comment', fieldName: 'body', type: 'text', wrapText: true, hideLabel: true }
];

export const componentDependencies = {
    ...healthDataService,
    addToNoteDefaultColumns,
    addToNoteDefaultOptions,
    columns,
    detailComponentColumns,
    actionsComponent,
    settings
};

export const errMessageTitle = 'There was an error retrieving records.';
export const errSubMessage = "Note: Please visit the Electronic Health Record (EHR) to review this patient's Orders ";
