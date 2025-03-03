/**
 * @description       : Assists in frozen column datatable
 * @author            : Booz Allen Hamilton
 **/
import { LightningElement, api } from 'lwc';

export default class childCustomDatatableCellTemplate extends LightningElement {
    @api value;
    @api minimumHeight;
}
