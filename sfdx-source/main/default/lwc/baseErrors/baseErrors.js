export class BridgMedsError extends Error {
    constructor(message) {
        super(message);
        this.name = "vccBridgMeds";
    }
}

export class BridgLabsError extends Error {
    constructor(message) {
        super(message);
        this.name = "vccBridgLabs";
    }
}
