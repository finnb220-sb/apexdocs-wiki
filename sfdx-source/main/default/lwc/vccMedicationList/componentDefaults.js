export const NonVAMedsAddToNoteDefaults = {
    columnsForAll: [
        {
            label: 'Medication Name',
            fieldName: 'drugName',
            type: 'text',
            wrapText: false,
            initialWidth: 250,
            sortable: true
        },
        { label: 'Dosage', fieldName: 'dosesDoseDosage', type: 'text', initialWidth: 125, sortable: true },
        { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 300, sortable: true },
        {
            label: 'Documented Date',
            fieldName: 'documentedDate',
            type: 'date-local',
            initialWidth: 150,
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        { label: 'Documented By', fieldName: 'nonVaDocumentedBy', type: 'text', initialWidth: 150, sortable: true },
        { label: 'Comments', fieldName: 'nonVaComments', type: 'text', sortable: true }
    ],

    //? CT & RN
    clinicalTriage: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'VCC_NonVA_Medications_Renewal_Request__c',
                preTextHeader: 'Medication - Dosage - SIG - Documented Date - Documented By - Comments \n'
            }
        ]
    },
    pharmacy: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'VCC_Requested_Non_VA_Medication__c',
                preTextHeader: 'Medication - Dosage - SIG - Documented Date - Documented By - Comments \n'
            }
        ]
    },
    //? MSA & Admin
    scheduling: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: '',
                preTextHeader: 'Medication - Dosage - SIG - Documented Date - Documented By - Comments \n'
            }
        ]
    },
    //? MP & VCV
    virtualCareVisit: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'VCC_Non_VA_Medications__c',
                preTextHeader: 'Medication - Dosage - SIG - Documented Date - Documented By - Comments \n'
            }
        ]
    },
    teleUrgent: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'TUC_Active_Outpatient_Medications__c',
                preTextHeader: 'Medication - Dosage - SIG - Documented Date - Documented By - Comments \n' //this is the default header layout
            }
        ]
    }
};

export const AddToNoteDefaults = {
    //? RN
    //? MSA too
    clinicalTriage: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'VCC_Medications_Refill_Renewal_Request__c',
                preTextHeader: 'Rx # - Medication Name - Dosage - SIG - Number of Refills - Facility - Status \n',
                validateFacility: true
            }
        ],
        columns: [
            { label: 'Rx #', fieldName: 'prescriptionValue', type: 'text', sortable: true, initialWidth: 110 },
            {
                label: 'Medication Name',
                fieldName: 'drugName',
                type: 'text',
                wrapText: false,
                initialWidth: 250,
                sortable: true
            },
            {
                label: 'Med/ Supply',
                fieldName: 'medicationSupply',
                type: 'text',
                initialWidth: 150,
                sortable: true,
                exclude: true
            },
            {
                label: 'Dosage',
                fieldName: 'dosesDoseDosage',
                type: 'text',
                cellAttributes: { alignment: 'left' },
                initialWidth: 90,
                sortable: true
            },
            { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
            {
                label: 'Number of Refills',
                fieldName: 'fillsRemainingValue',
                type: 'number',
                initialWidth: 10,
                sortable: true
            },
            { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true, initialWidth: 110 },
            { label: 'Status', fieldName: 'vaStatusValue', type: 'text', initialWidth: 125, sortable: true }
        ]
    },

    pharmacy: {
        topButtons: [
            {
                variant: 'neutral',
                label: 'Add for Renewal',
                field: 'VCC_Requested_Medication__c',
                preTextHeader:
                    'Medication Name - Rx # - Dosage - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Facility - Status - Indication \n',
                validateFacility: true
            },
            {
                variant: 'brand',
                label: 'Add for Extension',
                field: 'VCC_Requested_Medication_extension__c',
                preTextHeader:
                    'Medication Name - Rx # - Dosage - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Facility - Status - Indication \n'
            }
        ],
        columns: [
            {
                label: 'Medication Name',
                fieldName: 'drugName',
                type: 'text',
                wrapText: false,
                initialWidth: 250,
                sortable: true
            },
            {
                label: 'Indicators',
                fieldName: 'indicatorString',
                initialWidth: 120,
                wrapText: false,
                type: 'text',
                sortable: true,
                exclude: true
            },
            { label: 'Rx #', fieldName: 'prescriptionValue', type: 'text', sortable: true, initialWidth: 110 },
            {
                label: 'Dosage',
                fieldName: 'dosesDoseDosage',
                type: 'text',
                cellAttributes: { alignment: 'left' },
                initialWidth: 90,
                sortable: true
            },
            {
                label: 'Med/ Supply',
                fieldName: 'medicationSupply',
                type: 'text',
                initialWidth: 150,
                sortable: true,
                exclude: true
            },
            {
                label: 'Fill Qty',
                fieldName: 'quantityValue',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'left' },
                initialWidth: 90
            },
            {
                label: 'Last Fill Date',
                fieldName: 'lastFilledValue',
                type: 'date-local',
                sortable: true,
                typeAttributes: {
                    year: 'numeric',
                    month: 'numeric',
                    day: 'numeric'
                }
            },
            {
                label: 'Refills Remaining',
                fieldName: 'fillsRemainingValue',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Expiration Date',
                fieldName: 'expiresValue',
                type: 'date-local',
                sortable: true,
                typeAttributes: {
                    year: 'numeric',
                    month: 'numeric',
                    day: 'numeric'
                }
            },
            { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
            { label: 'Provider Comments', fieldName: 'providerComments', type: 'text', sortable: true },
            { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true, initialWidth: 110 },
            { label: 'Status', fieldName: 'vaStatusValue', type: 'text', initialWidth: 125, sortable: true },
            { label: 'Indication', fieldName: 'indication', type: 'text', sortable: true }
        ]
    },

    teleUrgent: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'TUC_Active_Outpatient_Medications__c',
                preTextHeader: 'Medication Name - Dosage - Status \n'
            }
        ],
        columns: [
            {
                label: 'Medication Name',
                fieldName: 'drugName',
                type: 'text',
                wrapText: false,
                initialWidth: 250,
                sortable: true
            },
            { label: 'Med/ Supply', fieldName: 'medicationSupply', type: 'text', initialWidth: 150, sortable: true },
            {
                label: 'Dosage',
                fieldName: 'dosesDoseDosage',
                type: 'text',
                cellAttributes: { alignment: 'left' },
                initialWidth: 90,
                sortable: true
            },
            { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
            { label: 'Status', fieldName: 'vaStatusValue', type: 'text', initialWidth: 125, sortable: true }
        ]
    },

    //? MP
    virtualCareVisit: {
        topButtons: [
            {
                variant: 'brand',
                label: 'Add Selected',
                field: 'VCC_Medications__c',
                preTextHeader: 'Medication Name - Fill Qty - Dosage - SIG - Refills Remaining \n'
            }
        ],
        columns: [
            {
                label: 'Medication Name',
                fieldName: 'drugName',
                type: 'text',
                wrapText: false,
                initialWidth: 250,
                sortable: true
            },
            {
                label: 'Med/ Supply',
                fieldName: 'medicationSupply',
                type: 'text',
                initialWidth: 150,
                sortable: true,
                exclude: true
            },
            {
                label: 'Fill Qty',
                fieldName: 'quantityValue',
                type: 'number',
                sortable: true,
                cellAttributes: { alignment: 'left' }
            },
            {
                label: 'Dosage',
                fieldName: 'dosesDoseDosage',
                type: 'text',
                cellAttributes: { alignment: 'left' },
                initialWidth: 90,
                sortable: true
            },
            { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
            {
                label: 'Refills Remaining',
                fieldName: 'fillsRemainingValue',
                type: 'number',
                initialWidth: 10,
                sortable: true
            }
        ]
    }
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
    columns: [
        { label: 'Rx #', fieldName: 'prescriptionValue', type: 'text', sortable: true, initialWidth: 110 },
        {
            label: 'Medication Name',
            fieldName: 'drugName',
            type: 'text',
            wrapText: false,
            initialWidth: 250,
            sortable: true
        },
        { label: 'Med/ Supply', fieldName: 'medicationSupply', type: 'text', initialWidth: 150, sortable: true },
        {
            label: 'Fill Qty',
            fieldName: 'quantityValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            initialWidth: 90
        },
        {
            label: 'Last Fill Date',
            fieldName: 'lastFilledValue',
            type: 'date-local',
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Refills Remaining',
            fieldName: 'fillsRemainingValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Expiration Date',
            fieldName: 'expiresValue',
            type: 'date-local',
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        { label: 'SIG', fieldName: 'sig', type: 'text', initialWidth: 200, sortable: true },
        { label: 'Provider Comments', fieldName: 'providerComments', type: 'text', sortable: true },
        { label: 'Facility', fieldName: 'facilityName', type: 'text', sortable: true, initialWidth: 110 },
        { label: 'Status', fieldName: 'vaStatusValue', type: 'text', initialWidth: 125, sortable: true },
        { label: 'Indication', fieldName: 'indication', type: 'text', sortable: true }
    ]
};

/* 
Meds settings
	- VA meds 
		- columns
		- Entries per page
	- Non VA meds
		- columns
		- Entries per page





AddToNote Settings
	- Progress Note: Add to Note Options			includes top buttons, preTextHeader & field to write to
	- Add To Note: Columns (Array of Objects)


addToNoteOptions = {
		topButtons: [
			{
				variant: 'neutral',
				label: 'Add for Renewal',
				field: 'VCC_Requested_Medication__c',
				preTextHeader: 'Rx # - Medication Name - Dosage - SIG - Number of Refills - Status \n'
			},
			{
				variant: 'brand',
				label: 'Add for Extension',
				field: 'VCC_Requested_Medication_extension__c',
				preTextHeader: 'Rx # - Medication Name - Dosage - SIG - Number of Refills - Status \n'
			}
		],
		initialSort: {field: 'drugName', stringField: 'drugName', direction: 'asc' },
		singleFilterField: {label: 'Status', apiName: 'vaStatusValue'},
	};


columnsForAddToNote = [
		{ label: 'Rx #', fieldName: 'prescriptionValue', type: 'text', sortable: true, initialWidth:110 },
		{ label: "Medication Name", fieldName: "drugName", type: "text", wrapText: false, initialWidth: 250, sortable: true },
		{ label: "Dosage", fieldName: "dosesDoseDosage", type: "text", cellAttributes: { alignment: "left" }, initialWidth: 90, sortable: true },
		{ label: "SIG", fieldName: "sig", type: "text", initialWidth: 200, sortable: true },
		{ label: "Number of Refills", fieldName: "fillsRemainingValue", type: "number", initialWidth: 10, sortable: true },
		{ label: "Status", fieldName: "vaStatusValue", type: "text", initialWidth: 125, sortable: true }
	]
*/
