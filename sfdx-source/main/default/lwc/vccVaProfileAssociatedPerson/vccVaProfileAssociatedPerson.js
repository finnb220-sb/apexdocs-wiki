import { api, LightningElement } from "lwc";
import VaProfileModal from "c/vccVaProfileModal";
import { upsertAssociatedPersons } from "c/vccVaProfileController";
import { PhoneValue, AddressValue, RelationshipValue, relationshipOptions } from "c/vccVaProfileInput";
import LoggerMixin from "c/loggerMixin";

export const AssociatedPersonKind = {
    NextOfKin: "NextOfKin",
    EmergencyContact: "EmergencyContact",
    OtherNextOfKin: "OtherNextOfKin",
    OtherEmergencyContact: "OtherEmergencyContact"
};

export const AssociatedPersonKindToContactType = {
    NextOfKin: "Primary Next of Kin",
    EmergencyContact: "Emergency Contact",
    OtherNextOfKin: "Other Next of Kin",
    OtherEmergencyContact: "Other emergency contact"
};
// how apex and the API expect the AssociatedPerson
export class AssociatedPerson {
    updateDate;
    sourceDate;
    prefix;
    suffix;
    givenName;
    middleName;
    familyName;
    addressLine1;
    addressLine2;
    addressLine3;
    city;
    state;
    county;
    zipCode;
    zipPlus4;
    postalCode;
    provinceCode;
    country;
    primaryPhone;
    alternatePhone;
    contactType;
    relationship;

    constructor(associatedPerson = {}) {
        ({
            updateDate: this.updateDate = "",
            sourceDate: this.sourceDate = "",
            prefix: this.prefix = "",
            suffix: this.suffix = "",
            givenName: this.givenName = "",
            middleName: this.middleName = "",
            familyName: this.familyName = "",
            addressLine1: this.addressLine1 = "",
            addressLine2: this.addressLine2 = "",
            addressLine3: this.addressLine3 = "",
            city: this.city = "",
            state: this.state = "",
            county: this.county = "",
            zipCode: this.zipCode = "",
            zipPlus4: this.zipPlus4 = "",
            postalCode: this.postalCode = "",
            provinceCode: this.provinceCode = "",
            country: this.country = "",
            primaryPhone: this.primaryPhone = "",
            alternatePhone: this.alternatePhone = "",
            contactType: this.contactType = "",
            relationship: this.relationship = ""
        } = associatedPerson);
    }
}

//maps the json from apex response onto the properties accepted by lightning-formatted-address
class DisplayAddress {
    city = "";
    country = "";
    postalCode = "";
    province = "";
    street = "";

    constructor(associatedPerson = new AssociatedPerson()) {
        if (!(associatedPerson instanceof AssociatedPerson)) {
            //cant use nebula logger here so I'm not sure what to do
            return;
        }

        //city
        this.city = associatedPerson.city;

        //country
        this.country = associatedPerson.country;

        this.street =
            (typeof associatedPerson.addressLine1 === "string" && associatedPerson.addressLine1 !== "" ? associatedPerson.addressLine1 + "\n" : "") +
            (typeof associatedPerson.addressLine2 === "string" && associatedPerson.addressLine2 !== "" ? associatedPerson.addressLine2 + "\n" : "") +
            (typeof associatedPerson.addressLine3 === "string" && associatedPerson.addressLine3 !== "" ? associatedPerson.addressLine3 : "");

        if (associatedPerson.country !== "USA") {
            //if country is not USA, use postalCode and provinceCode from associatedPerson
            this.postalCode = associatedPerson.postalCode;
            this.province = associatedPerson.provinceCode;
        } else {
            //if country is USA, use zip and state from associatedPerson
            this.postalCode = associatedPerson.zipCode;
            this.province = associatedPerson.state;
        }
    }
}

/**
 * @author Patrick Skamarak
 * this class got bulky quite fast. I think it needs some re-thought...
 * maybe, splitting it into vccVaProfileAssociatedPerson* where * is
 * Address, Phone, Relationship, etc
 */
export default class VccVaProfileAssociatedPerson extends LoggerMixin(LightningElement) {
    @api recordId; // #region lwc properties
    @api kind;
    @api associatedPerson; //associated persona data passed in from parent component

    //associated person info pulled from associatedPersonData
    name = "";
    displayAddress = new DisplayAddress();

    //rendered callback and initializations
    initialized = false;

    renderedCallback() {
        if (this.kind === null) {
            return;
        }
        if (this.initialized === true) {
            return;
        }
        if (AssociatedPersonKind[this.kind] === undefined) {
            throw Error('Error: kind not specified. ex. <c-vcc-va-profile-associated-person kind="EmergencyContact">');
        }
        if (typeof this.associatedPerson !== "object" || this.associatedPerson === null) {
            return;
        }

        this.name = this.getName(this.associatedPerson).trim();
        this.displayAddress = new DisplayAddress(this.associatedPerson);

        this.initialized = true;
    }

    // #region "getters"

    getName(associatedPerson) {
        return (
            (typeof associatedPerson?.givenName == "string" ? associatedPerson?.givenName + " " : "") +
            (typeof associatedPerson?.familyName == "string" ? associatedPerson?.familyName : "")
        );
    }

    get showEdit() {
        return !!this.name && !!this.associatedPerson?.relationship;
    }

    // #endregion

    //#region event handlers
    handleEditPhone() {
        VaProfileModal.open({
            variant: "phone",
            headerLabel: "Edit Phone",
            size: "small",
            value: new PhoneValue(this.associatedPerson.primaryPhone),
            onsubmit: async (event) => {
                let phoneValue = event?.detail?.value;
                this.associatedPerson.primaryPhone = phoneValue?.areaCode + phoneValue?.phoneNumber?.replace("-", "");
                this.handleSubmit(event);
            }
        });
    }

    handleEditAddress() {
        VaProfileModal.open({
            variant: "address",
            headerLabel: "Edit Address",
            size: "small",
            value: new AddressValue(this.associatedPerson),
            onsubmit: async (event) => {
                try {
                    await Promise.resolve(event.detail.validationPromise);
                    if (typeof event?.detail?.value?.street == "string" && event?.detail?.value?.street.search("\n") !== -1) {
                        let addressLines = event?.detail?.value?.street.split("\n").flatMap((e) => {
                            if (e === "") {
                                return [];
                            }
                            return e;
                        });

                        if (addressLines.length >= 1) {
                            this.associatedPerson.addressLine1 = addressLines[0];
                        } else {
                            this.associatedPerson.addressLine1 = null;
                        }

                        if (addressLines.length >= 2) {
                            this.associatedPerson.addressLine2 = addressLines[1];
                        } else {
                            this.associatedPerson.addressLine2 = null;
                        }

                        if (addressLines.length >= 3) {
                            this.associatedPerson.addressLine3 = addressLines[2];
                        } else {
                            this.associatedPerson.addressLine3 = null;
                        }
                    } else {
                        this.associatedPerson.addressLine1 = event?.detail?.value?.street;
                        this.associatedPerson.addressLine2 = null;
                        this.associatedPerson.addressLine3 = null;
                    }

                    this.associatedPerson.country = event?.detail?.value?.country;
                    this.associatedPerson.street = event?.detail?.value?.street;
                    this.associatedPerson.city = event?.detail?.value?.city;

                    /**
                     * CCCM-18886 work start
                     * This work comes from QA testing with the VA Profile team
                     * Additional logic was needed based on if the address domestic/international
                     */

                    if (this.associatedPerson.country !== "USA") {
                        this.associatedPerson.postalCode = event?.detail?.value?.postalCode;
                        this.associatedPerson.provinceCode = event?.detail?.value?.province;

                        this.associatedPerson.state = null;
                        this.associatedPerson.zipCode = null;
                    } else {
                        this.associatedPerson.zipCode = event?.detail?.value?.postalCode;
                        this.associatedPerson.state = event?.detail?.value?.province;

                        this.associatedPerson.provinceCode = null;
                        this.associatedPerson.postalCode = null;
                    }

                    this.associatedPerson.county = null;
                    this.associatedPerson.zipPlus4 = null;

                    /**
                     * 18886 work end
                     */

                    this.handleSubmit(event);
                } catch (e) {
                    event.detail.submitPromise.reject(e);
                }
            }
        });
    }

    handleEditRelationship() {
        VaProfileModal.open({
            variant: "relationship",
            headerLabel: "Edit Relationship",
            size: "small",
            value: new RelationshipValue({
                relationshipOptions: relationshipOptions,
                relationshipValue: this.associatedPerson?.relationship
            }),
            onsubmit: async (event) => {
                this.associatedPerson.relationship = event?.detail?.value?.relationshipValue;
                this.handleSubmit(event);
            }
        });
    }

    /**
     * This function is a bit wacky. The event originates from vccVaProfileModalFooter, then moves
     * to vccVaProfileModal, and then to this components handleEdit* functions (which call this function).
     *
     * In vccVaProfileModal, the input is validated, and validationPromise is resolved or rejected.
     * This function waits for the validationPromise to resolve before attempting to make any callouts.
     * If the validation is rejected, this function will reject the submitPromise.
     *
     * tl;dr vccVaProfileModalFooter dispatches the event, vccVaProfileModal handles the validation and
     * validationPromise, this component handles the submission and submitPromise.
     */
    async handleSubmit(event) {
        try {
            await Promise.resolve(event.detail.validationPromise);

            if (AssociatedPersonKind[this.kind] === undefined || AssociatedPersonKindToContactType[this.kind] === undefined) {
                throw { message: "Invalid associated person kind or contact type mapping." };
            }

            this.associatedPerson.contactType = AssociatedPersonKindToContactType[this.kind];

            await upsertAssociatedPersons({
                recordId: this.recordId,
                associatedPersons: [this.associatedPerson]
            });

            setTimeout(() => {
                this.dispatchEvent(new CustomEvent("post", { composed: true, bubbles: true }));
                event.detail.submitPromise.resolve();
            }, 1000);
        } catch (e) {
            event.detail.submitPromise.reject(e);
        }
    }

    // #endregion
}
