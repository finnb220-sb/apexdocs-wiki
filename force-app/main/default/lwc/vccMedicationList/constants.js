// import all custom permissions here, then wrap them up and export later for use
import canSeeRefillLog from '@salesforce/customPermission/VAHC_View_Refill_Log';
import canSeePartialLog from '@salesforce/customPermission/VAHC_View_Partial_Refill_Log';
import canSeeActivityLog from '@salesforce/customPermission/VAHC_View_Activity_Log';
import canSeeLabelLog from '@salesforce/customPermission/VAHC_View_Label_Log';
import canSeeCopayLog from '@salesforce/customPermission/VAHC_View_Copay_Log';
import canSeeECMELog from '@salesforce/customPermission/VAHC_View_ECME_Log';
import canSeeERXLog from '@salesforce/customPermission/VAHC_View_ERX_Log';
import canSeeCMOPLog from '@salesforce/customPermission/VAHC_View_CMOP_Log';
import canSeeCMOPLotLog from '@salesforce/customPermission/VAHC_View_CMOPLot_Log';

// cutoff date for meds -> TODO: move this to the callout params and make it accessible via custom metadata
export const datesOlderThanLimit = 120;
// returns the cutoff date
export const medsExpiredCutOffDate = () =>
    new Date(new Date().setDate(new Date().getDate() - datesOlderThanLimit)).toISOString().split('T')[0];

export const defaultParams = {
    startDate: medsExpiredCutOffDate(),
    endDate: null
};

// bad meds statuses
export const badStatuses = ['DISCONTINUED', 'DISCONTINUED (EDIT)'];

// sorting order for status field
export const statusOrder = {
    top: ['ACTIVE', 'PENDING', 'SUSPENDED'],
    middle: [],
    bottom: ['EXPIRED', 'DISCONTINUED', 'DISCONTINUED (EDIT)']
};

// columns for lightning-datatable

export const importedFrozenColumns = [
    {
        label: 'Medication Name',
        fieldName: 'drugName',
        type: 'button',
        wrapText: false,
        initialWidth: 350,
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'drugName' },
            title: 'Click to View Duplicates',
            name: 'rxDuplicates',
            variant: 'base',
            disabled: { fieldName: 'deactivateDuplicateButton' },
            type: 'text'
        }
    }
];

export const importedDynamicColumns = [
    {
        label: 'Rx #',
        fieldName: 'prescriptionValue',
        type: 'button',
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'prescriptionValue' },
            title: 'Click to View More Info',
            name: 'rxDetails',
            variant: 'base',
            type: 'text'
        }
    },
    { label: 'Med/ Supply', fieldName: 'medicationSupply', type: 'text', sortable: true, hideDefaultActions: true },
    /*Remove order and add Provider in list view*/
    // { label: 'Order #', fieldName: 'rxNumber', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'vaStatusValue', type: 'text', sortable: true, hideDefaultActions: true },
    { label: 'Rx Patient Status', fieldName: 'rxPatientStatus', type: 'text', hideDefaultActions: true },
    {
        label: 'Refills Remaining',
        fieldName: 'fillsRemainingValue',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        hideDefaultActions: true
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
        label: 'Release Date',
        fieldName: 'fillsReleaseDate',
        type: 'date-local',
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        }
    },
    {
        label: 'Fill Qty',
        fieldName: 'quantityValue',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        hideDefaultActions: true
    },
    {
        label: 'Days of Supply',
        fieldName: 'daysOfSupply',
        type: 'number',
        sortable: true,
        cellAttributes: { alignment: 'left' },
        hideDefaultActions: true
    },
    {
        label: 'Date Prescribed',
        fieldName: 'startValue',
        type: 'date-local',
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'numeric',
            day: 'numeric'
        }
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
    { label: 'Facility Name', fieldName: 'facilityName', type: 'text', sortable: true, hideDefaultActions: true },
    { label: 'Provider', fieldName: 'orderingProviderName', type: 'text', sortable: true, hideDefaultActions: true }
];

// columns for duplicate meds table
export const duplicateMedsTable = {
    defaultSortDirection: 'desc',
    sortedDirection: 'desc',
    sortedBy: 'expiresValue',
    sortedByLabel: 'Expiration Date',
    data: [],
    columns: [
        {
            label: 'Rx #',
            fieldName: 'prescriptionValue',
            type: 'button',
            sortable: true,
            typeAttributes: {
                label: { fieldName: 'prescriptionValue' },
                title: 'Click to View More Info',
                name: 'rxDetails',
                variant: 'base',
                type: 'text'
            }
        },
        {
            label: 'Medication Name',
            fieldName: 'drugName',
            type: 'button',
            wrapText: false,
            initialWidth: 350,
            sortable: true,
            typeAttributes: {
                label: { fieldName: 'drugName' },
                title: 'Click to View Duplicates',
                name: 'rxDuplicates',
                variant: 'base',
                disabled: true, //? only difference between the VA Columns and Duplicate Columns
                type: 'text'
            }
        },
        { label: 'Status', fieldName: 'vaStatusValue', type: 'text', sortable: true },
        {
            label: 'Refills Remaining',
            fieldName: 'fillsRemainingValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' }
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
            label: 'Release Date',
            fieldName: 'fillsReleaseDate',
            type: 'date-local',
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Fill Qty',
            fieldName: 'quantityValue',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Days of Supply',
            fieldName: 'daysOfSupply',
            type: 'number',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Date Prescribed',
            fieldName: 'startValue',
            type: 'date-local',
            sortable: true,
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
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
        { label: 'Facility Name', fieldName: 'facilityName', type: 'text', sortable: true },
        { label: 'Provider', fieldName: 'orderingProviderName', type: 'text', sortable: true }
    ]
};

// columns for the non va meds table
export const nonVAcolumns = [
    {
        label: 'Medication Name',
        fieldName: 'drugName',
        type: 'button',
        wrapText: false,
        initialWidth: 400,
        sortable: true,
        typeAttributes: {
            label: { fieldName: 'drugName' },
            title: 'Click to View More Info',
            name: 'rxDetails',
            variant: 'base',
            type: 'text'
        }
    },
    { label: 'Dosage', fieldName: 'dosesDoseDosage', type: 'text', sortable: true },
    { label: 'Schedule', fieldName: 'schedule', type: 'text', sortable: true },
    { label: 'Facility Name', fieldName: 'facilityName', type: 'text', sortable: true }
];

export const activityLogColumns = {
    refillLogs: [
        {
            label: 'Log Date',
            fieldName: 'loginDate',
            type: 'date-local',
            sortable: true,
            initialWidth: 100,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Person Requesting Refill',
            fieldName: 'personRequestingRefill',
            type: 'text',
            sortable: true,
            initialWidth: 190,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Refill Date',
            fieldName: 'refillDate',
            type: 'date-local',
            sortable: true,
            initialWidth: 100,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'QTY',
            fieldName: 'quantity',
            type: 'number',
            sortable: true,
            initialWidth: 25,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Routing',
            fieldName: 'routing',
            type: 'text',
            sortable: true,
            initialWidth: 75,
            cellAttributes: { alignment: 'left' }
        },
        { label: 'Lot #', fieldName: 'lotNumber', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
        {
            label: 'Pharmacist',
            fieldName: 'pharmacistName',
            type: 'text',
            sortable: true,
            initialWidth: 190,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Division',
            fieldName: 'divisionName',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Division #',
            fieldName: 'divisionNumber',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Dispensed',
            fieldName: 'dispensedDate',
            type: 'date-local',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        {
            label: 'Released',
            fieldName: 'releasedDateTime',
            type: 'date-local',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric'
            }
        },
        { label: 'NDC', fieldName: 'ndc', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } }
    ],
    partialFillLogs: [
        {
            label: 'Log Date',
            fieldName: 'loginDateTime',
            type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Date',
            fieldName: 'partialDate',
            type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        { label: 'QTY', fieldName: 'quantity', type: 'number', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Routing', fieldName: 'routing', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Lot#', fieldName: 'lotNumber', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } },
        {
            label: 'Pharmacist',
            fieldName: 'pharmacistName',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Division',
            fieldName: 'divisionNumber',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Dispensed',
            fieldName: 'dispensedDate',
            type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Released',
            fieldName: 'releasedDateTime',
            type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        { label: 'NDC', fieldName: 'ndc', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } }
    ],
    activityLogs: [
        {
            label: 'Date/Time',
            fieldName: 'activityLogDate',
            type: 'date',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Reason',
            fieldName: 'reason',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Initiator Of Activity',
            fieldName: 'initiatorOfActivity',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Comments',
            fieldName: 'comment',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Other Comments',
            fieldName: 'otherCommentsString',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        }
    ],

    labelLogs: [
        {
            label: 'Date',
            fieldName: 'labelDateTime',
            type: 'date',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Printed By',
            fieldName: 'printedBy',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Comments',
            fieldName: 'labelComment',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'FDA Med Guide',
            fieldName: 'fdaMedGuide',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        }
    ],

    copayLogs: [
        {
            label: 'Date',
            fieldName: 'copayActivityLogDate',
            type: 'date-local',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'
            }
        },
        {
            label: 'Reason',
            fieldName: 'reason',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'number',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Initiator of Activity',
            fieldName: 'initiatorOfActivity',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        { label: 'Comment', fieldName: 'comment', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } }
    ],

    ecmeLogs: [
        {
            label: 'Date/Time',
            fieldName: 'ecmeLogDateTime',
            type: 'date',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Initiator of Activity',
            fieldName: 'initiatorOfActivity',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        { label: 'Comment', fieldName: 'comment', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } }
    ],

    erxLogs: [
        {
            label: 'Date',
            fieldName: 'erxLogDateTime',
            type: 'date',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Reason',
            fieldName: 'reason',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Initiator of Activity',
            fieldName: 'initiatorOfActivity',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        { label: 'Comments', fieldName: 'comment', type: 'text', sortable: true, cellAttributes: { alignment: 'left' } }
    ],

    cmopLogs: [
        {
            label: 'Date/Time',
            fieldName: 'dateTimeShipped',
            type: 'date',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric',
                timeZone: 'UTC'
            }
        },
        {
            label: 'Rx Ref',
            fieldName: 'rxReference',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'TRN-Order',
            fieldName: 'transmissionNumberUrl',
            type: 'url',
            typeAttributes: { label: { fieldName: 'transmissionNumber' } },
            initialWidth: 150,
            sortable: false,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Comments',
            fieldName: 'ndcReceived',
            type: 'text',
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'FDA Med Guide',
            fieldName: 'fdaMedGuide',
            type: 'text',
            initialWidth: 200,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        }
    ],

    cmopLotLogs: [
        //{ label: "#", fieldName: "itemNumber", type: "text", sortable: true, cellAttributes: { alignment: "left" } },
        {
            label: 'Rx Ref',
            fieldName: 'rxIndicator',
            type: 'text',
            initialWidth: 120,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Lot #',
            fieldName: 'lotExp',
            type: 'text',
            initialWidth: 150,
            sortable: true,
            cellAttributes: { alignment: 'left' }
        },
        {
            label: 'Expiration Date',
            fieldName: 'expirationDate',
            type: 'date-local',
            sortable: true,
            cellAttributes: { alignment: 'left' },
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: 'numeric',
                minute: 'numeric'
            }
        }
    ]
};

export const activityPermissions = {
    refillLog: canSeeRefillLog,
    partialLog: canSeePartialLog,
    activityLog: canSeeActivityLog,
    labelLog: canSeeLabelLog,
    copayLog: canSeeCopayLog,
    ecmeLog: canSeeECMELog,
    erxLog: canSeeERXLog,
    cmopLog: canSeeCMOPLog,
    cmopLotLog: canSeeCMOPLotLog
};

// TODO: Move this to custom labels for screen reader 11/22/2022

export const emptyStateLabels = {
    refillLog: 'There are no Refill Log entries available for this prescription',
    partialLog: 'There are no Partial Fills entries available for this prescription',
    activityLog: 'There are no Activity Log entries available for this prescription',
    labelLog: 'There are no Label Log entries available for this prescription',
    copayLog: 'There are no Copay Log entries available for this prescription',
    ecmeLog: 'There are no ECME Log entries available for this prescription',
    erxLog: 'There are no eRx Log entries available for this prescription',
    cmopLog: 'There are no CMOP Events Log entries available for this prescription',
    cmopLotLog: 'There are no CMOP LOT #/ Expiration Log entries available for this prescription'
};
