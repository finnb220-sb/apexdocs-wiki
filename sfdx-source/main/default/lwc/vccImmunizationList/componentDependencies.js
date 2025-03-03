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
        showLoadMore: false,
        showAddToNote: false,
        options: []
    }
};

const settings = {
    title: 'Immunizations',
    icon: 'standard:immunization'
};

const columns = [
    {
        label: 'Immunization Name',
        fieldName: 'immunizationName',
        type: 'button',
        sortable: true,
        initialWidth: 400,
        typeAttributes: {
            label: { fieldName: 'immunizationName' },
            title: 'Click to View Immunization Details',
            name: 'immunizationClicked',
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
        label: 'Administered Date',
        fieldName: 'administeredDate',
        type: 'date-local',
        sortable: true,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS
    },
    { label: 'Series', fieldName: 'series', type: 'text', sortable: true },
    { label: 'Ordering Provider', fieldName: 'orderingProvider', type: 'text', sortable: true },
    { label: 'Contraindication', fieldName: 'contraindication', type: 'text', sortable: true }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Immunizations__c',
            preTextHeader: 'IMMUNIZATION NAME -  ADMINISTERED DATE \n'
        }
    ],
    initialSort: { field: 'administeredDate', stringField: 'administeredDate', direction: 'desc' },
    singleFilterField: {}
};

const addToNoteDefaultColumns = [
    { label: 'Immunization Name', fieldName: 'immunizationName', type: 'text', wrapText: false, sortable: true },
    {
        label: 'Administered Date',
        fieldName: 'administeredDate',
        type: 'date',
        sortable: true,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_OPTIONS
    }
];

export const componentDependencies = {
    ...healthDataService,
    addToNoteDefaultColumns,
    addToNoteDefaultOptions,
    columns,
    actionsComponent,
    settings
};

export const errMessageTitle = 'There was an error retrieving records.';
export const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;
