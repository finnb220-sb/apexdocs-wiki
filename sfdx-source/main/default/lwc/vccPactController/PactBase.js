export const PactBaseKind = {
    VA: "VA",
    NonVA: "NonVA"
};

export class PactBase {
    kind;

    constructor(kind) {
        if (typeof kind !== "string" || PactBaseKind[kind] === undefined) {
            throw new Error("Invalid Pact Member Kind.");
        }
        this.kind = kind;
    }
}
