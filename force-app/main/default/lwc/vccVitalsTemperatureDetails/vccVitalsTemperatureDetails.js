import { LightningElement, api } from 'lwc';

export default class VccVitalsTemperatureDetails extends LightningElement {
    @api
    measurementsToDisplay;

    @api
    label;
    degreeSymbol = '°';
}
