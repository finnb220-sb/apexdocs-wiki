import { LightningElement, api } from "lwc";

export default class VccPactV2 extends LightningElement {
    @api responseJSON;
    @api enableAddSigners;
    @api siteCode;
    @api columnsTemplate = "";
    @api truncateColumns;
}
