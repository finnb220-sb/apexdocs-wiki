export const columns = [
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
        fieldName: 'onsetDate',
        type: 'text',
        sortable: true,
        typeAttributes: {
            month: '2-digit',
            day: '2-digit'
        }
    },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    {
        label: 'Last Updated',
        fieldName: 'lastUpdated',
        type: 'date',
        sortable: true,
        typeAttributes: {
            weekday: 'short',
            year: 'numeric',
            month: 'short',
            day: '2-digit',
            timeZone: 'UTC'
        }
    },
    { label: 'ICD Code', fieldName: 'ICGCode', type: 'text', sortable: true },
    { label: 'Description', fieldName: 'description', type: 'text', sortable: true, initialWidth: 300 }
];
