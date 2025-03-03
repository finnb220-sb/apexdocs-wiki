import { api, LightningElement } from "lwc";

const EMPHASIZED_CLASS = "emphasized";
export default class VccProgressNoteOutputSection extends LightningElement {
    renderedCallback() {
        if (this.section && this.section.emphasizeSection) {
            try {
                let section = this.template.querySelector("section");
                section.classList.add(EMPHASIZED_CLASS);
                if (!section.classList.contains(EMPHASIZED_CLASS)) {
                    // console.warn(`Emphasis not added to section ${this.section.sectionName}.`);
                }
            } catch (e) {
                // console.warn(`Error when rendering progress note output section, ${this.section.sectionName}.`);
            }
        }
    }

    @api
    set section(val) {
        if (typeof val === "object" && val.fields !== undefined && Array.isArray(val.fields)) {
            let hasValidField = false;
            for (let field of val.fields) {
                if (field.displayField) {
                    hasValidField = true;
                    break;
                }
            }
            this._section = val;
            this.displaySection = hasValidField;
        }
    }
    get section() {
        return this._section;
    }

    displaySection = false;
}
