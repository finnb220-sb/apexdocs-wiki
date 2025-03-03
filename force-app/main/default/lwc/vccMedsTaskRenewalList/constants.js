export const fullColumns = [
    {
        label: 'Medication Name',
        fieldName: 'drugName',
        type: 'text',
        wrapText: false,
        initialWidth: 250,
        sortable: true
    },
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
];

export const fakeData =
    '[{"vaStatusValue":"ACTIVE","sig":"TAKE ONE TABLET BY MOUTH EVERY DAY (WITH FOOD)","quantityValue":30,"prescriptionValue":"17026186","lastFilledValue":"2023-07-05","fillsRemainingValue":11,"expiresValue":"2024-07-05","drugName":"ASPIRIN 325MG BUFFERED TAB","facilityName":"CLEVELAND VAMC - 541","indication":"BLOOD THINNER","providerComments":""},{"vaStatusValue":"ACTIVE","sig":"TAKE 1 TAB BY MOUTH ONE TIME TESTING TESTING","quantityValue":1,"prescriptionValue":"10952041","lastFilledValue":"2023-05-25","fillsRemainingValue":4,"expiresValue":"2024-05-22","drugName":"A-HEFT STUDY DRUG","facilityName":"CLEVELAND VAMC - 541","indication":"TESTING","providerComments":"testing"},{"vaStatusValue":"ACTIVE","sig":"TAKE ONE TABLET BY MOUTH TWICE A DAY HEADACHES CS SCHEDULE 6 DRUG","quantityValue":60,"prescriptionValue":"10952028","lastFilledValue":"","fillsRemainingValue":11,"expiresValue":"2024-05-22","drugName":"ZAFIRLUKAST 2OMG TAB","facilityName":"CLEVELAND VAMC - 541","indication":"HEADACHES","providerComments":"testing"},{"vaStatusValue":"ACTIVE","sig":"TAKE 1 TABLET BY MOUTH TWICE A DAY WITH MEALS TESTING CS SCHEDULE 5 DRUG","quantityValue":60,"prescriptionValue":"10952043","lastFilledValue":"2023-05-26","fillsRemainingValue":5,"expiresValue":"2023-11-25","drugName":"ATROPINE 0.025MG/DIPHENOXYLATE 2.5MG TAB","facilityName":"CLEVELAND VAMC - 541","indication":"TESTING","providerComments":"CS SCHEDULE 5 DRUG"}]';

export const columns = [{ label: 'Medication', fieldName: 'medication', type: 'text' }];

export const preTextHeader =
    'Medication Name - Rx # - Dosage - Fill Qty - Last Fill Date - Refills Remaining - Expiration Date - SIG - Provider Comments - Facility - Status - Indication \n';

export const radioValues = [
    { label: 'Tier I Progress Note', value: 'VCC_Tier_I_Progress_Note' },
    { label: 'Tier II Progress Note', value: 'VCC_Tier_II_Progress_Note' }
];
