import vccVaProfileAccociatedPersonsRelationshipValues from "@salesforce/label/c.vccVaProfileAccociatedPersonsRelationshipValues";

export const relationshipOptions = vccVaProfileAccociatedPersonsRelationshipValues.split(",").flatMap((e) => {
    return {
        label: e.trim(),
        value: e.trim()
    };
});

export function handleRelationshipValueChange(valueObject, eventObject) {
    valueObject.relationshipValue = eventObject?.detail?.value;
}

export class RelationshipValue {
    relationshipOptions;
    relationshipValue;

    constructor({ relationshipOptions = [], relationshipValue = "UNRELATED FRIEND" } = {}) {
        this.relationshipOptions = relationshipOptions;
        this.relationshipValue = relationshipValue;
    }
}
