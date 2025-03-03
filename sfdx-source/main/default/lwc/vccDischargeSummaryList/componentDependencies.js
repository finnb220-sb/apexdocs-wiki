import { healthDataService } from 'c/services';

const actionsComponent = {
    name: 'c/vccHdrDatatableActions',
    props: {
        showAddToNote: false,
        options: []
    }
};
const settings = {
    title: 'Discharge Summary',
    icon: 'standard:outcome'
};
const columns = [
    {
        label: 'Date of Discharge',
        fieldName: 'dateCreated',
        type: 'button',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: { fieldName: 'dateCreatedWithSlashes' },
            title: 'Click to View Discharge Summary Details',
            name: 'dischargeSummaryDetailClick',
            variant: 'base',
            type: 'date'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Title', fieldName: 'localTitle', type: 'text', sortable: true },
    {
        label: 'Status',
        fieldName: 'status',
        type: 'text',
        sortable: true
    },
    {
        label: 'Facility',
        fieldName: 'facilityName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Clinician',
        fieldName: 'clinicians',
        type: 'text',
        sortable: true
    },
    {
        label: 'Content',
        fieldName: 'content',
        type: 'text',
        sortable: true,
        initialWidth: 250
    }
];

const errMessageTitle = 'There was an error retrieving records.';
const errSubMessage =
    "Note: Please visit the Electronic Health Record (EHR) to review this patient's " + settings.title;
export const componentDependencies = {
    ...healthDataService,
    columns,
    actionsComponent,
    settings,
    errMessageTitle,
    errSubMessage
};
