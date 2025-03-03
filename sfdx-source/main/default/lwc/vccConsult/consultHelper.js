/**
 * @description Helper file for the Consults component
 * @author Booz Allen
 */
export const columns = [
    {
        label: 'Request Date',
        fieldName: 'requested',
        type: 'button',
        sortable: true,
        initialWidth: 150,
        typeAttributes: {
            label: { fieldName: 'formattedDateNoTime' },
            title: 'Click to View Consult Details',
            name: 'consultDetailClick',
            variant: 'base',
            type: 'string'
        },
        wrapText: false,
        cellAttributes: {
            style: 'padding: 0 !important; flex-wrap: nowrap !important',
            class: 'slds-has-flexi-truncate'
        }
    },
    { label: 'Consult Number', fieldName: 'id', type: 'text', sortable: true },
    { label: 'To Service', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Status', fieldName: 'status', type: 'text', sortable: true },
    { label: 'From Clinic', fieldName: 'facilityName', type: 'text', sortable: true },
    { label: 'Requestor', fieldName: 'provDxName', type: 'text', sortable: true },
    { label: 'Urgency', fieldName: 'urgency', type: 'text', sortable: true }
];

export const settings = {
    title: 'Consults',
    icon: 'standard:individual'
};
