import { searchHelper } from 'c/utils';
import { datatableHelper } from 'c/utils';

export const format = searchHelper.formatStringForSearch;
export const sortList = datatableHelper.sortFlatList;

export const columns = [
    {
        label: 'Date',
        fieldName: 'dateCreatedFormatted',
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'dateCreatedFormatted' },
            variant: 'base',
            name: 'date'
        },
        sortable: true
    },
    { label: 'Local Title', fieldName: 'localTitle', sortable: true },
    { label: 'Type', fieldName: 'typeName', sortable: true },
    { label: 'Encounter Name', fieldName: 'encounterName', sortable: true },
    { label: 'Facility', fieldName: 'facilityName', sortable: true }
];

export const collectSearchTargets = (progressNote) => {
    let nestedData = [];
    // grab nested data to search against
    if (progressNote?.text?.length) {
        for (const i of progressNote.text) {
            for (const [key, value] of Object.entries(i)) {
                if (key === 'clinicians') {
                    value.forEach((e) => Object.values(e).forEach((nestedvalue) => nestedData.push(nestedvalue)));
                } else {
                    nestedData.push(value);
                }
            }
        }
    }

    return Object.values(progressNote)
        .concat(nestedData)
        .filter((value) => typeof value != 'object')
        .map((e) => format(e));
};
