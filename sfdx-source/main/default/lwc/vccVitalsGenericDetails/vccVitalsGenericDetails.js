import { LightningElement, api } from 'lwc';

export default class VccVitalsGenericDetails extends LightningElement {
    @api
    measurementsToDisplay;

    @api
    label;
}
