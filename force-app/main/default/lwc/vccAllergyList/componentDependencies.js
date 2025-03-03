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
    title: 'Allergies / Adverse Reactions',
    icon: 'standard:campaign',
    sortedBylabel: 'Causative Agent'
};

const columns = [
    {
        label: 'Causative Agent',
        fieldName: 'agent',
        type: 'button',
        sortable: true,
        initialWidth: 300,
        typeAttributes: {
            label: { fieldName: 'agent' },
            title: 'Click to View Allergy Details',
            name: 'allergyDetailsClick',
            variant: 'base',
            type: 'text'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Signs and Symptoms', fieldName: 'signsAndSymptoms', type: 'text', sortable: true },
    { label: 'Drug Classes', fieldName: 'drugClass', type: 'text', sortable: true },
    {
        label: 'Date of Appearance',
        fieldName: 'dateOfAppearance',
        type: 'date',
        sortable: true,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
    },
    { label: 'Nature of Reaction', fieldName: 'natureOfReaction', type: 'text', sortable: true }
];

const addToNoteDefaultOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Allergies__c',
            preTextHeader: 'Causative Agent - Severity - Sign and Symptom - Date of Appearance \n'
        }
    ],
    initialSort: { field: 'agent', stringField: 'agent', direction: 'asc' },
    singleFilterField: { label: 'Severity', apiName: 'severity' }
};

const addToNoteDefaultColumns = [
    { label: 'Causative Agent', fieldName: 'agent', type: 'text', wrapText: false, sortable: true },
    { label: 'Severity', fieldName: 'severity', type: 'text', sortable: true },
    { label: 'Sign and Sympton', fieldName: 'signsAndSymptoms', type: 'text', sortable: true },
    {
        label: 'Date of Appearance',
        fieldName: 'dateOfAppearance',
        type: 'date',
        sortable: true,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
    }
];

const detailComponentColumns = [
    {
        label: 'Date/Time',
        fieldName: 'enteredDateTime',
        type: 'date',
        hideDefaultActions: true,
        initialWidth: 150,
        typeAttributes: dateFormatter.LIGHTNING_FORMATTED_DATE_TIME_OPTIONS
    },
    { label: 'Author Name', fieldName: 'enteredBy', type: 'text', hideDefaultActions: true, initialWidth: 150 },
    { label: 'Author Title', fieldName: 'enteredByTitle', type: 'text', hideDefaultActions: true, initialWidth: 150 },
    { label: 'Comment Type', fieldName: 'type', type: 'text', hideDefaultActions: true, initialWidth: 150 },
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
export const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;
