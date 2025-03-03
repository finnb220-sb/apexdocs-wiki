export function handlePhoneValueChange(valueObject, eventObject) {
    switch (eventObject?.target?.dataset.id) {
        case "area-code":
            valueObject.areaCode = eventObject?.target?.value;
            break;
        case "phone":
            valueObject.phoneNumber = eventObject?.target?.value;
            break;
        default:
            return;
    }
}

export function validatePhone(template) {
    let inputs = template.querySelectorAll("lightning-input");

    inputs.forEach((e) => {
        if (!e.checkValidity()) {
            throw {
                message: "One or more inputs are invalid. Please correct them and try again.",
                mode: "dismissible",
                title: "Invalid Input",
                variant: "warning"
            };
        }
    });
}

export class PhoneValue {
    areaCode = "";
    phoneNumber = "";

    constructor(phoneValue = "") {
        if (typeof phoneValue !== "string") {
            return;
        }

        let sanitizedPhoneValue = phoneValue.replaceAll(RegExp("[^0-9]", "g"), "");

        if (sanitizedPhoneValue.length === 0 || sanitizedPhoneValue.length > 10) {
            return;
        }

        if (sanitizedPhoneValue.length <= 7) {
            this.phoneNumber = sanitizedPhoneValue;
            return;
        }

        if (sanitizedPhoneValue.length <= 10) {
            this.areaCode = sanitizedPhoneValue.slice(0, 3);
            this.phoneNumber = sanitizedPhoneValue.slice(3);
            return;
        }
    }
}
