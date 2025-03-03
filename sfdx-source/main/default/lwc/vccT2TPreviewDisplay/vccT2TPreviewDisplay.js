/**
 * Created by abaddon on 8/9/23.
 */

import { LightningElement, api, track, wire } from "lwc";
import getStringList from "@salesforce/apex/VCC_T2T_Adapter_JSON2Object.getStringList";
/*
Declarations
 */
const SECTION_HEADERS = {
    main: "Evaluation \n",
    legal: "Limitations \n",
    medications: "Active Outpatient VA and Non-VA Medications \n",
    contraindications: "Contraindications \n",
    labs: "Recent Labs",
    criteria: "Criteria \n",
    childbearing: "All potential childbearing individuals \n",
    pregnant: "Pregnant Patients \n",
    dosage: "Dosage",
    disposition: "Disposition \n"
};
const REVIEW_TYPES_ORDER = ["main", "legal", "medications", "contraindications", "labs", "criteria", "childbearing", "pregnant", "dosage", "disposition"];

export default class vccT2TPreviewDisplay extends LightningElement {
    /*
    Declare display preferences
     */
    defaultMessage = "Notice";
    defaultSubMessage = "No T2T Assessment was completed for this patient";
    labels = {
        noResultsMessage: this.defaultMessage,
        noResultsSubMessage: this.defaultSubMessage
    };
    indentedDisplay = true;
    MAX_CHAR_LENGTH = 66;
    @api recordId;
    @track apexResponse = [];
    @track customObjectArray = [];
    @track sectionsArray = [];

    @wire(getStringList, { recordId: "$recordId" })
    apexWire({ data, error }) {
        if (data) {
            let sections = [];

            REVIEW_TYPES_ORDER.forEach((type) => {
                let sectionItems = data
                    .filter((item) => {
                        const parsedItem = JSON.parse(item);
                        return parsedItem.review === type;
                    })
                    .map((item) => {
                        const parsedItem = JSON.parse(item);
                        const itemLabel =
                            parsedItem.review === "dosage" || parsedItem.review === "labs" ? "" : parsedItem.label.endsWith(":") ? parsedItem.label : parsedItem.label + ":";

                        return {
                            ...parsedItem,
                            label: itemLabel,
                            processedLabel: this.processedText(itemLabel),
                            processedResponse: this.processedText(parsedItem.response)
                        };
                    });

                if (sectionItems.length > 0) {
                    sections.push({
                        title: SECTION_HEADERS[type],
                        items: sectionItems
                    });
                }
            });

            this.sectionsArray = sections;
            this.apexResponse = data;
        } else if (error) {
            this.logger.error(error);
            this.logger.saveLog();
        }
    }
    get hasData() {
        return this.sectionsArray && this.sectionsArray.length > 0;
    }
    processedText(text) {
        let result = "";
        while (text.length > 0) {
            result += text.substring(0, this.MAX_CHAR_LENGTH) + "\n";
            text = text.substring(this.MAX_CHAR_LENGTH);
        }
        return result.trim();
    }

    connectedCallback() {}
    disconnectedCallback() {}
}
