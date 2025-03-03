import LightningDatatable from "lightning/datatable";
import dynamicButton from "./vccDynamicDatatableButton.html";
import clickableText from "./clickableText.html";

export default class VccDatatableCustomTypes extends LightningDatatable {
    static customTypes = {
        dynamicButton: {
            template: dynamicButton,
            standardCellLayout: true
        },
        clickableText: {
            template: clickableText,
            standardCellLayout: true,
            typeAttributes: ["onclick", "thisContext"]
        }
    };
}
