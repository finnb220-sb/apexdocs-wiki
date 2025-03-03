/**
 * @description this is the wrapper component that will be seen on the Account flexipage. It will separate the appointments from the
vccAppointment component into "upcoming" and "historical" events. It accomplishes this by separating once the data event is activated.
 */
import { LightningElement, track, api } from 'lwc';
import { componentDependencies as service } from './componentDependencies.js';

export default class VccAppointmentMain extends LightningElement {
    @api flexipageRegionWidth;
    @api recordId;

    @track isShowSpinner = false;
    @track columns = [];
    @track upcoming = [];
    @track historical = [];
    @track actionsComponent = {};

    settings = service.settings;

    connectedCallback() {
        this.isShowSpinner = true;
    }

    /**
     * @description initiate the processing of the data once the child component has completed the fetch
     * @param {Object} event which will contain the full HDR response
     */
    handleFetchComplete(event) {
        this.columns = event.detail.columns;
        this.actionsComponent = event.detail.actionsComponent;

        let { upcoming, historical } = this.processData(event.detail.data);
        if (upcoming) {
            this.upcoming = upcoming;
        }
        if (historical) {
            this.historical = historical;
        }
        this.isShowSpinner = false;
    }

    /**
     * @description separate out the full HDR response into "upcoming" & "historical" arrays
     * @param {Array} incomingData the full HDR response
     * @returns {Object}
     * @returns {Array} upcoming - the upcoming appointments
     * @returns {Array} historical - the historical appointments
     */
    processData(incomingData) {
        let upcoming = [];
        let historical = [];

        let currentDate = new Date();
        currentDate.setHours(0, 0, 0, 0);

        //? sort by date descending
        incomingData.sort((a, b) => new Date(b.appointmentDateTime) - new Date(a.appointmentDateTime));

        incomingData.forEach((appointment) => {
            const date = new Date(appointment.appointmentDateTime.appointmentDateTime);
            const userTimezoneOffset = Math.abs(date.getTimezoneOffset() * 60000);
            let aptDateTime = new Date(date.getTime() - userTimezoneOffset);

            aptDateTime.setHours(0, 0, 0, 0);

            if (aptDateTime >= currentDate) {
                upcoming.push(appointment);
            } else {
                historical.push(appointment);
            }
        });
        return { upcoming, historical };
    }

    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccAppointmentDetails');
    }
}
