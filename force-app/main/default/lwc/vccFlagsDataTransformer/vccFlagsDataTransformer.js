/**
 * @author Booz Allen Hamilton
 * @description exports function 'transformFlagsData' that preps the response from VCC_FlagsController.getFlags for use in LWC's
 * these functions originally belonged to, and were extracted from, vccFlags for sharing with vccFlagsModalLauncher
 * @see vccFlags
 * @see vccFlagsModalLauncher
 */

/**
 * This new public property serves as a feature flag for checking women's health flags.
 * - The previous approach to disabling women's health flags was to comment out unused code. This resulted in sev 1 CodeScan "code smell" blockers.
 * - This implementation disables the women's health flags without code smell, and allows for easy reactivation, later.
 * @type {boolean}
 */
const CHECK_WOMENS_HEALTH_FLAGS = false;
const NOT_PREGNANT = 'NOT PREGNANT';
const PREGNANT_DO_NOT_KNOW = 'PREGNANT - DO NOT KNOW';
const NOT_LACTATING = 'NOT LACTATING';
const LACTATING_DO_NOT_KNOW = 'LACTATING - DO NOT KNOW';
const ACTIVE = 'Active';
const EMPTY_FLAG_SHAPE = {
    approvedBy: { code: '', name: '' },
    assigned: { assignedDate: '', assignedDateStr: '', value: '' },
    category: { value: '' },
    content: { content: '' },
    origSite: { code: '', name: '' },
    ownSite: { code: '', name: '' }
};

/**
 * Transforms Flags data into format for display
 * @param {Object} data Flags json data from Apex class VCC_FlagsController.getFlags
 */
export function transformFlagsData(data) {
    return preProcessRecords(flatten(data).concat(parseWomensHealthFlagsFromResult(data)));
}

/**
 * @description Evaluates the flags payload's "sites" list and flattens their "flags.flag" lists into a flat array containing all flags for patient across all sites.
 * @param data Flags payload from getFlags Apex method
 * @return {*[]}
 */
function flatten(data) {
    if (!Array.isArray(data?.flagModal?.sites) || data.flagModal.sites.length === 0) {
        return [];
    }
    return data.flagModal.sites.flatMap((site) => {
        if (!Array.isArray(site?.results?.flags?.flag)) {
            return [];
        }
        return site.results.flags.flag;
    });
}

/**
 * @description Parses result from getFlags Apex method to extract a list of women's health flags
 * - Pregnancy flags from `parsePregnancyFlags()`
 * - Lactation flags from `parseLactationFlags()`
 * @param result
 * @return {*[]}
 */
function parseWomensHealthFlagsFromResult(result = {}) {
    let flags = [];
    if (CHECK_WOMENS_HEALTH_FLAGS && result?.womenHealthResponseBody) {
        const womenHealthDetails = JSON.parse(result.womenHealthResponseBody);
        flags = parseWomensHealthFlagsForPatients(
            womenHealthDetails?.clinicalData?.womensHealth?.patients?.patients ?? []
        );
    }
    return flags;
}

/**
 * @description Parses women's health flags for a list of patients.
 * - Each member in the "list" of patients is assumed to represent the current patient.
 * @param patients Array of objects holding the patients womens health data
 * @return {{name: {value: string}, type: {value: string}, reviewDue: {reviewDate: Date}, approvedBy: {code: string, name: string}, assigned: {assignedDate: string, assignedDateStr: string, value: string}, category: {value: string}, content: {content: string}, origSite: {code: string, name: string}, ownSite: {code: string, name: string}}[]}
 */
function parseWomensHealthFlagsForPatients(patients = []) {
    return patients.flatMap((patient) => {
        return parseWomensHealthFlagsForPatient(patient);
    });
}

/**
 * @description Transforms a single patient into a list of flags, from the patient's pregnancy and lactation statuses.
 * @param patient an object holding the patients womens health data
 * @return {{name: {value: string}, type: {value: string}, reviewDue: {reviewDate: Date}, approvedBy: {code: string, name: string}, assigned: {assignedDate: string, assignedDateStr: string, value: string}, category: {value: string}, content: {content: string}, origSite: {code: string, name: string}, ownSite: {code: string, name: string}}[]}
 */
function parseWomensHealthFlagsForPatient(patient = {}) {
    const pregnancyStatuses = patient?.patient?.pregnancyStatus ?? [];
    const lactationStatuses = patient?.patient?.lactationStatus ?? [];
    return pregnancyStatuses
        .map((status) => {
            return parsePregnancyStatusIntoFlag(status);
        })
        .concat(
            lactationStatuses.map((status) => {
                return parseLactationStatusIntoFlag(status);
            })
        );
}

/**
 * @description Transforms a pregnancy status into a flag
 * - If the status's `state` property is not a string, is an empty string, or equals 'NOT PREGNANT', the `state` property is set to 'PREGNANT - DO NOT KNOW'
 * @param pregnancyStatus object holding the patients pregnancy status information
 * @return {{name: {value: string}, type: {value: string}, reviewDue: {reviewDate: Date}, approvedBy: {code: string, name: string}, assigned: {assignedDate: string, assignedDateStr: string, value: string}, category: {value: string}, content: {content: string}, origSite: {code: string, name: string}, ownSite: {code: string, name: string}}}
 */
function parsePregnancyStatusIntoFlag(pregnancyStatus = {}) {
    const dateEntered = this.getJsDateFromDateTime(pregnancyStatus?.dateEntered);
    const stateIsInvalid =
        typeof pregnancyStatus?.state !== 'string' ||
        pregnancyStatus?.state === '' ||
        pregnancyStatus?.state === NOT_PREGNANT;
    pregnancyStatus.state = stateIsInvalid ? PREGNANT_DO_NOT_KNOW : pregnancyStatus.state;

    return {
        name: { value: pregnancyStatus.state },
        type: { value: pregnancyStatus.state },
        reviewDue: {
            reviewDate: dateEntered
        },
        ...EMPTY_FLAG_SHAPE
    };
}

/**
 * @description Transforms a lactation status into a flag
 * - If the status's `state` property is not a string, is an empty string, or equals 'NOT LACTATING', the `state` property is set to 'LACTATING - DO NOT KNOW'
 * @param lactationStatus object holding the patients lactation status info
 * @return {{name: {value: string}, type: {value: string}, reviewDue: {reviewDate: Date}, approvedBy: {code: string, name: string}, assigned: {assignedDate: string, assignedDateStr: string, value: string}, category: {value: string}, content: {content: string}, origSite: {code: string, name: string}, ownSite: {code: string, name: string}}}
 */
function parseLactationStatusIntoFlag(lactationStatus = {}) {
    const dateEntered = this.getJsDateFromDateTime(lactationStatus.dateEntered);
    const stateIsInvalid =
        typeof lactationStatus?.state !== 'string' ||
        lactationStatus?.state === '' ||
        lactationStatus?.state === NOT_LACTATING;
    lactationStatus.state = stateIsInvalid ? LACTATING_DO_NOT_KNOW : lactationStatus.state;

    return {
        name: { value: lactationStatus.state },
        type: { value: lactationStatus.state },
        reviewDue: { reviewDate: dateEntered },
        ...EMPTY_FLAG_SHAPE
    };
}

/**
 * @description Does some initial data scrubbing before passing the payload to `healthDataService.processRecordsBaseline`.
 * - We're doing this here (pre-baseline), to ensure any Date-typed fields we may want to get formatted are already present at the root of each record.
 * @param records The flag records
 * @return {{reviewDate: *}[]} The list of records, each with a new property
 */
function preProcessRecords(records = []) {
    return records.map((record, i) => {
        return preProcessRecord(record, 'Key' + i);
    });
}

/**
 * @description Adds additional properties to given flag record
 * - Copies `name.value` to `flagName`
 * - Copies `type.value` to `flagType`
 * - Sets `status` to 'Active'
 * - Copies `reviewDue.reviewDate` to `reviewDate`
 * @param record A single flag record
 * @return {{reviewDate: (string|string|*)}} The record with properties added
 */
function preProcessRecord(record = {}, key = 'Key0') {
    let reviewDateValue = record.reviewDue?.reviewDate;
    reviewDateValue =
        reviewDateValue && typeof reviewDateValue.getMonth === 'function'
            ? reviewDateValue.toISOString()
            : reviewDateValue;
    return {
        ...record,
        key: key,
        flagName: record.name?.value,
        flagType: record.type?.value,
        status: ACTIVE,
        reviewDate: reviewDateValue
    };
}
