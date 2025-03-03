import { api, LightningElement } from "lwc";

//label
import phoneNumberLabel from "@salesforce/label/c.Phone_Number";

//address
import addressTemplate from "./address.html";
import { handleAddressValueChange, validateAddress } from "./address";
export { AddressValue, countryOptions } from "./address";

//relationship
import relationshipTemplate from "./relationship.html";
import { handleRelationshipValueChange } from "./relationship";
export { RelationshipValue, relationshipOptions } from "./relationship";

//phone
import phoneTemplate from "./phone.html";
import { handlePhoneValueChange, validatePhone } from "./phone";
export { PhoneValue } from "./phone";

const VARIANTS = {
    phone: "phone",
    relationship: "relationship",
    address: "address"
};

/**
 * @author Patrick Skamarak
 * tbh this lwc might get a bit bloated and could probably use a bit of separation
 * ymmv
 */

function validateAll({ template = null, componentVariant = "", value = {} } = {}) {
    if (componentVariant == VARIANTS.phone) {
        return validatePhone(template);
    }
    // if (componentVariant == VARIANTS.relationship){ validateRelationship(template); }
    if (componentVariant == VARIANTS.address) {
        validateAddress(value);
    }
}

function handleAllChanges({ valueObject = {}, componentVariant = "", eventObject = {} } = {}) {
    if (componentVariant == VARIANTS.phone) {
        handlePhoneValueChange(valueObject, eventObject);
    }
    if (componentVariant == VARIANTS.relationship) {
        handleRelationshipValueChange(valueObject, eventObject);
    }
    if (componentVariant == VARIANTS.address) {
        handleAddressValueChange(valueObject, eventObject);
    }
}
export default class VccVaProfileInput extends LightningElement {
    @api
    variant;

    @api
    value;

    phNumLbl = phoneNumberLabel; // Expose the imported label to the template

    render() {
        if (VARIANTS[this.variant] == undefined) {
            throw "Invalid variant for vccVaProfileInput.";
        }

        switch (this.variant) {
            case "address":
                return addressTemplate;
            case "relationship":
                return relationshipTemplate;
            case "phone":
                return phoneTemplate;
            default:
                break;
        }
    }

    handleChange(e) {
        handleAllChanges({
            eventObject: e,
            valueObject: this.value,
            componentVariant: this.variant
        });
    }

    @api
    validate() {
        validateAll({
            template: this.template,
            componentVariant: this.variant,
            value: this.value
        });
    }
}
