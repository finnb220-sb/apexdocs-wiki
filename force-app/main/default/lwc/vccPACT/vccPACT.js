/**
 * DEPRECATED 09 02 2022
 * PLEASE USE vccPactV2
 */

import { api, LightningElement } from "lwc";

export default class VccPACT extends LightningElement {
    @api responseJSON;
    @api enableAddSigners;
    @api siteCode;
    @api columnsTemplate = "";
}
