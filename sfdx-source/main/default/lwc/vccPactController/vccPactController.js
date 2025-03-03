import * as NonVaPact from "./NonVaPact";
import * as VaPact from "./VaPact";

export class PactData {
    vaPact;

    nonVaPact;

    cprsView;
}

/**
 *
 * @param {string} rawJson The json string response from the PCMM endpoint.
 * @returns {PactData}
 */
export function parsePactJson(rawJson, Logger) {
    let parsedJson = {};

    try {
        parsedJson = JSON.parse(rawJson);
    } catch (e) {
        Logger.debug("pact json parse failed");
        Logger.debug(String(e));
        return parsedJson;
    }

    let pactData = new PactData();

    pactData.vaPact = VaPact.parseVaPactMembers(parsedJson?.PatientSummary?.patientAssignmentsAtStations, Logger);
    pactData.nonVaPact = NonVaPact.parseNonVaPact(parsedJson?.PatientSummary?.nonVAPCProviders, Logger);
    pactData.cprsView = parsedJson?.PatientSummary?.PatientSummaryText;

    Logger.saveLog();

    return pactData;
}

export * from "./VaPact";
export * from "./NonVaPact";
export * from "./PactBase";
