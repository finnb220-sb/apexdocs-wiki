/**
 * @description       : Main LWC for frozen column datatable
 * @author            : Booz Allen Hamiltion
 **/

import LightningDatatable from 'lightning/datatable';
import CustomCell from './CustomCell.html';

export default class FixedColumnDatatable extends LightningDatatable {
    static customTypes = {
        childDatatableCustomCellTemplate: {
            template: CustomCell,
            typeAttributes: ['value']
        }
    };

    /**
     * @description supports salesforce native lightning-datatable row selection functionality.
     */
    handleRowSelection() {}
}
