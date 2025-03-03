import { LightningElement, api } from 'lwc';

export default class VccVitalsBloodPressureDetails extends LightningElement {
    @api
    measurementsToDisplay;
}
