export const renewalSettings = {
    title: 'Meds & Rx',
    icon: 'standard:medication'
};

export const allFutureRenewalOptions = {
    topButtons: [
        {
            variant: 'brand',
            label: 'Add Selected',
            field: 'VCC_Requested_Medication__c', //! CHANGE
            preTextHeader:
                'Rx # - Medication Name - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Facility - Status - Indication \n'
        }
    ],
    initialSort: {
        field: 'drugName',
        stringField: 'drugName',
        direction: 'asc'
    },
    medsFilterField: { label: 'Status', apiName: 'vaStatusValue' },
    frozenColumns: [
        {
            label: 'Medication Name',
            fieldName: 'drugName',
            type: 'text',
            wrapText: false,
            initialWidth: 250,
            sortable: true
        }
    ],
    dynamicColumns: [
        { label: 'Rx #', fieldName: 'prescriptionValue', type: 'text', sortable: true, initialWidth: 110 },
        { label: 'Dosage', fieldName: 'dosesDoseDosage', type: 'text' },
        {
            label: 'Fill Qty',
            fieldName: 'quantityValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            initialWidth: 90
        },
        { label: 'Last Fill Date', fieldName: 'lastFilledValue', type: 'date-local', sortable: true },
        {
            label: 'Refills Remaining',
            fieldName: 'fillsRemainingValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        { label: 'Expiration Date', fieldName: 'expiresValue', type: 'date-local', sortable: true },
        { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
        { label: 'Provider Comments', fieldName: 'providerComments', type: 'text', sortable: true },
        { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true, initialWidth: 110 },
        { label: 'Status', fieldName: 'vaStatusValue', type: 'text', initialWidth: 125, sortable: true },
        { label: 'Indication', fieldName: 'indication', type: 'text', sortable: true }
    ]
};
