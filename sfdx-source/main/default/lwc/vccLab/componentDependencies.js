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
import { dateFormatter } from 'c/utils';

const actionsComponent = {
    name: 'c/vccHdrDatatableActions',
    props: {
        showAddToNote: false,
        options: []
    }
};

const settings = {
    title: 'Labs',
    icon: 'standard:metrics'
};

const columns = [
    {
        label: 'Test Name',
        fieldName: 'testName',
        type: 'button',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: { fieldName: 'testName' },
            title: 'Click to View Lab Details',
            name: 'testClicked',
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
        label: 'Date of Test',
        fieldName: 'collectedDateString',
        type: 'date',
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            timeZone: 'UTC'
        }
    },

    { label: 'Lab Type', fieldName: 'labType', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'Result', fieldName: 'result', type: 'text', sortable: true },
    { label: 'Interpretation', fieldName: 'interpretation', type: 'text', sortable: true },
    { label: 'High Range Value', fieldName: 'high', type: 'number', sortable: true },
    { label: 'Low Range Value', fieldName: 'low', type: 'number', sortable: true },
    { label: 'Sample', fieldName: 'sample', type: 'text', sortable: true },
    { label: 'Providers', fieldName: 'providerName', type: 'text', sortable: true }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Result_Comments__c', //! VCV default      PHARM uses VCC_Labs__c
            preTextHeader:
                'Date of Test - Test Name - Lab Type - Status - Result - Interpretation - High Range - Low Range - Sample - Providers \n'
        }
    ],
    initialSort: { field: 'collected', stringField: 'collected', direction: 'asc' },
    singleFilterField: {} //? empty so it won't show the filter option // {label: 'Name', apiName: 'name'}
};

const addToNoteDefaultColumns = [
    {
        label: 'Date of Test',
        fieldName: 'collected',
        type: 'date',
        wrapText: false,
        sortable: true,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
    },
    { label: 'Test Name', fieldName: 'testName', type: 'text', sortable: true },
    { label: 'Lab Type', fieldName: 'labType', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'Result', fieldName: 'result', type: 'text', sortable: true },
    { label: 'Interpretation', fieldName: 'interpretation', type: 'text', sortable: true },
    { label: 'High Range', fieldName: 'high', type: 'number', sortable: true },
    { label: 'Low Range', fieldName: 'low', type: 'number', sortable: true },
    { label: 'Sample', fieldName: 'sample', type: 'text', sortable: true },
    { label: 'Provider', fieldName: 'providerName', type: 'text', sortable: true }
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
