import { getFieldValue } from "lightning/uiRecordApi";

import CONTROLLED_NON_VA_MEDICATION from "@salesforce/schema/VCC_Progress_Note__c.VCC_Controlled_Non_VA_Medication__c";
import CONTROLLED_VA_MEDICATION from "@salesforce/schema/VCC_Progress_Note__c.VCC_Controlled_medication__c";
import MEDICATION_RENEWAL from "@salesforce/schema/VCC_Progress_Note__c.VCC_Medication_Fill_Renewal__c";
import RECENT_SUD_LABS from "@salesforce/schema/VCC_Progress_Note__c.VCC_Recent_SUD_Labs__c";

import { Interval, Seconds, Minutes } from "c/vccTime";

export const fields = [CONTROLLED_NON_VA_MEDICATION, CONTROLLED_VA_MEDICATION, MEDICATION_RENEWAL, RECENT_SUD_LABS];

let controlledNonVaMedication;
let controlledVaMedication;
let medicationRenewal;
let recentSudLabs;

function getCurrentFieldValues(record) {
    return {
        controlledNonVaMedication: getFieldValue(record, CONTROLLED_NON_VA_MEDICATION),
        controlledVaMedication: getFieldValue(record, CONTROLLED_VA_MEDICATION),
        medicationRenewal: getFieldValue(record, MEDICATION_RENEWAL),
        recentSudLabs: getFieldValue(record, RECENT_SUD_LABS)
    };
}

function getPriorFieldValues() {
    return {
        controlledNonVaMedication,
        controlledVaMedication,
        medicationRenewal,
        recentSudLabs
    };
}

function updatePriorFieldValues(fields) {
    controlledNonVaMedication = fields.controlledNonVaMedication;
    controlledVaMedication = fields.controlledVaMedication;
    medicationRenewal = fields.medicationRenewal;
    recentSudLabs = fields.recentSudLabs;
}

function needsInitialFieldValues() {
    if (controlledNonVaMedication == null && controlledVaMedication == null && medicationRenewal == null && recentSudLabs == null) {
        return true;
    }
    return false;
}

function conditionsAreMet(fields) {
    if (fields.medicationRenewal == false) {
        return false;
    }
    if (fields.controlledVaMedication == false && fields.controlledNonVaMedication == false) {
        return false;
    }
    return true;
}

function conditionsAreNotMet(fields) {
    return !conditionsAreMet(fields);
}

function recentSudLabsIsBlank(record) {
    let recentSudLabs = getFieldValue(record, RECENT_SUD_LABS);
    if (recentSudLabs == null || recentSudLabs == "") {
        return true;
    }
    return false;
}

let refreshInterval = Interval.for(Minutes(2)).every(Seconds(1));
export function onRecordUpdate(record, refreshRecord) {
    let current = getCurrentFieldValues(record);
    let prior = getPriorFieldValues();

    if (needsInitialFieldValues()) {
        updatePriorFieldValues(current);
        return;
    }

    // stop refreshing if conditions ARE met and SUD lab field is NOT blank
    if (conditionsAreMet(current) && !recentSudLabsIsBlank(record) && refreshInterval.isRunning()) {
        refreshInterval.stop();
        return;
    }

    // CCCM-29620 remove logic that waits for field to be cleared, the field is now cleared by a fast field update flow

    // getting SUD labs
    if (conditionsAreMet(current) && conditionsAreNotMet(prior) && recentSudLabsIsBlank(record)) {
        refreshInterval
            .do(() => {
                refreshRecord();
            })
            .start();
    }

    // CCCM-29620 remove logic that waits for field to be cleared, the field is now cleared by a fast field update flow

    updatePriorFieldValues(current);
}
