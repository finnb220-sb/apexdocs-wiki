/**
 * @author Booz Allen
 * @description: This file contains the dependencies for the Appointment component
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
    title: 'Appointments',
    icon: 'custom:custom94'
};

const columns = [
    {
        label: 'Date/Time',
        fieldName: 'dateTimeStrVal',
        type: 'button',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: { fieldName: 'dateTimeStrVal' },
            title: 'Click to View Appointment Details',
            name: 'appointmentDateClick',
            variant: 'base',
            type: 'text'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Clinic Name', fieldName: 'clinicNameVal', type: 'text', sortable: true },
    { label: 'Location', fieldName: 'locationVal', type: 'text', sortable: true },
    { label: 'Medical Center', fieldName: 'medicalCenterVal', type: 'text', sortable: true },
    // { label: 'Provider', fieldName: 'providerVal', type: 'text', sortable: true},
    { label: 'Status', fieldName: 'statusVal', type: 'text', sortable: true }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Appointments__c',
            preTextHeader: 'Date/Time - Clinic Name - Location - Medical Center - Provider - Status \n'
        }
    ],
    initialSort: { field: 'dateTimeVal', stringField: 'dateTimeStrVal', direction: 'desc' },
    singleFilterField: {}
};

const addToNoteDefaultColumns = [
    { label: 'Date/Time', fieldName: 'dateTimeStrVal', type: 'text', sortable: true, initialWidth: 150 },
    { label: 'Clinic Name', fieldName: 'clinicNameVal', type: 'text', sortable: true },
    { label: 'Location', fieldName: 'locationVal', type: 'text', sortable: true },
    { label: 'Medical Center', fieldName: 'medicalCenterVal', type: 'text', sortable: true },
    { label: 'Provider', fieldName: 'providerVal', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'statusVal', type: 'text', sortable: true }
];

export const componentDependencies = {
    ...healthDataService,
    addToNoteDefaultOptions,
    addToNoteDefaultColumns,
    columns,
    actionsComponent,
    settings
};
