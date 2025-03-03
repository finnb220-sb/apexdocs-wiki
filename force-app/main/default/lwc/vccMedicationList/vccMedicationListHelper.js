/* eslint-disable no-unused-vars, no-use-before-define, eqeqeq, consistent-return */
import * as lwcHelper from 'c/helpersLWC';

export const NON_BREAKING_HYPHEN = '\u2011';
export const NON_BREAKING_SPACE = '\u00A0';
const ACTIVE_MED_STATUS = 'ACTIVE';
const PENDING_MED_STATUS = 'PENDING';
const SUSPENDED_MED_STATUS = 'SUSPENDED';

// Constants representing the patient's mail status, which would prevent the user from refilling a medication
const MAIL_STATUS = {
    CERTIFIED_MAIL: 'Certified Mail',
    DO_NOT_MAIL: 'Do Not Mail',
    FOR_LOCAL_CERTIFIED_MAIL: 'For Local - Certified Mail',
    DEFAULT: ''
};

/**
 * @description Groups facilities in a medication list.
 * @param {Array} formattedMeds - List of formatted medications.
 * @returns {Object} Grouped facilities in the medication list.
 */
export const facilitesInMedslist = (formattedMeds) => {
    return identifyAllFacilitiesInMedList(formattedMeds);
};

export const help = lwcHelper;

/**
 * @description Determines if a medication has bad or missing data.
 * @param {Object} med - The medication object.
 * @returns {Boolean} True if medication has bad data, false otherwise.
 */
const medHasBadData = (med) => {
    //? VA Med === "O" - should check both drugName and prescriptionValue (number)
    let isVaMed = med?.fullData?.vaType?.value === 'O';
    let vaMedCriteriaCheck =
        med?.drugName === '' ||
        med?.drugName === null ||
        med?.prescriptionValue === '' ||
        med?.prescriptionValue === null;

    //? non VA Med === "N" - should only check drugName
    let isNonVaMed = med?.fullData?.vaType?.value === 'N';
    let nonVaMedCriteriaCheck = med?.drugName === '' || med?.drugName === null;

    //? VA Med return
    // if (isVaMed) return true;							//! throw VA error
    if (isVaMed && vaMedCriteriaCheck) return true;

    //? NonVA Med return
    // if (isNonVaMed) return true; 						//! throw nonVA error
    return isNonVaMed && nonVaMedCriteriaCheck;
};

/**
 * @description Sorts an array in descending order based on a property.
 * @param {Array} arr - The array to sort.
 * @param {String} property - The property to sort by.
 */
const sortArrayDesc = (arr, property) => {
    arr.sort((a, b) => {
        return a[property] < b[property] ? 1 : -1;
    });
};

/**
 * @description Checks if the parsed response is invalid.
 * @param {Array} parsedResponse - The parsed response to validate.
 * @returns {Boolean} True if invalid, false otherwise.
 */
const isResponseInvalid = (parsedResponse) => {
    return !parsedResponse?.length;
};

/**
 * @description Handles medications with bad data by pushing them into the appropriate error array.
 * @param {Object} med - The medication object.
 * @param {Object} preparedMeds - The prepared medications object.
 */
const handleMedWithErrors = (med, preparedMeds) => {
    let propertyForErrors = med?.fullData?.vaType?.value === 'O' ? 'dataHasErrors' : 'nonVADataHasErrors';
    if (medHasBadData(med)) {
        preparedMeds[propertyForErrors]?.push(med);
    }
};

/**
 * @description Surfaces key medication properties to the top level for display.
 * @param {Object} med - The medication object.
 */
const surfaceMedProperties = (med) => {
    med.drugName = med?.drugName.replaceAll(' ', NON_BREAKING_SPACE);
    med.drugName = med?.drugName.replaceAll('-', NON_BREAKING_HYPHEN);
    med.uuid = lwcHelper.uniqueId();

    //? Surfacing properties to top level for use in data table
    med.facilityName = `${med?.fullData?.facility?.name} - ${med?.fullData?.facility?.code}`;
    med.facilityId = med?.fullData?.facility?.code?.substring(0, 3);
    med.daysOfSupply = med?.fullData?.daysSupply?.value;
    med.schedule = med?.fullData?.doses?.dose ? med?.fullData?.doses?.dose[0]?.schedule : '';
    med.remarks = med?.fullData?.supplemental?.outpatientRxFields?.remarks || '';
    med.rxPatientStatus = med?.fullData?.supplemental?.outpatientRxFields?.rxPatientStatus?.name || '';
    med.parked = med?.fullData?.supplemental?.outpatientRxFields?.parkedInd === '1' ? 'Yes' : 'No';
    med.indication = med?.fullData?.supplemental?.outpatientRxFields?.indicationForUse || '';
    med.deactivateDuplicateButton = true;
};

/**
 * @description Sets the controlled substance schedule and medication supply values.
 * @param {Object} med - The medication object.
 */
const setCsSchedule = (med) => {
    // Initial set of DEA Schedule values
    // med.csSchedule = med?.fullData?.supplemental?.outpatientRxFields?.drug?.deaSpeclHandling;
    let filteredCSchedule = [];

    if (med?.fullData?.supplemental?.outpatientRxFields?.drug?.deaSpeclHandling?.length) {
        filteredCSchedule = med?.fullData?.supplemental?.outpatientRxFields?.drug?.deaSpeclHandling[0];
    }
    med.csSchedule = ['1', '2', '3', '4', '5']?.includes(filteredCSchedule) ? filteredCSchedule : '';

    med.medicationSupply =
        med?.fullData?.supplemental?.outpatientRxFields?.drug?.deaSpeclHandling === 'S' ? 'Supply' : 'Medication';
};

/**
 * @description Sets provider and non-VA comments.
 * @param {Object} med - The medication object.
 */
const setProviderComments = (med) => {
    med.providerComments = med?.fullData?.supplemental?.outpatientRxFields?.providerComments?.text || '';
    med.providerComments = med.providerComments + ''; //? convert to string so it can be searched
    med.nonVaComments = med?.fullData?.supplemental?.nonVaMedFields?.comments[0]?.comment;
    // .map((m) => m + "").join(" ");
};

/**
 * @description Builds the non-VA documented-by field.
 * @param {Object} med - The medication object.
 */
const setNonVaDocumentedBy = (med) => {
    //? build the non VA documented by field
    let family = med?.fullData?.supplemental?.nonVaMedFields?.documentedBy?.practitioner?.name?.family || '';
    let given = med?.fullData?.supplemental?.nonVaMedFields?.documentedBy?.practitioner?.name?.given || '';
    let middle = med?.fullData?.supplemental?.nonVaMedFields?.documentedBy?.practitioner?.name?.middle || '';
    med.nonVaDocumentedBy = family && given && middle ? `${family}, ${given} ${middle}` : '';
};

/**
 * @description Sets the documented date for the medication.
 * @param {Object} med - The medication object.
 */
const setDocumentedDate = (med) => {
    //? surface documentedDate
    med.documentedDate =
        med?.fullData?.supplemental?.nonVaMedFields?.documentedBy?.documentedDate?.formattedDocumentedDate || '';
};

/**
 * @description Builds the indicators string for table display.
 * @param {Object} med - The medication object.
 */
const buildIndicatorString = (med) => {
    //? Build the Indicators String for table display
    let indicatorsArray = [];
    if (med?.fullData?.supplemental?.outpatientRxFields?.drug?.cmopId) indicatorsArray.push('(>)');
    if (med?.fullData?.supplemental?.outpatientRxFields?.copayTransactionType?.id) indicatorsArray.push('($)');
    if (med?.fullData?.supplemental?.outpatientRxFields?.ecme?.ecmeNumber) indicatorsArray.push('(e)');
    if (med?.fullData?.supplemental?.outpatientRxFields?.titrationInd) indicatorsArray.push('(t)');
    if (med?.fullData?.supplemental?.outpatientRxFields?.returnedToStock) indicatorsArray.push('(R)');
    if (med?.fullData?.supplemental?.outpatientRxFields?.lastCmopEvent?.status === 'TRANSMITTED')
        indicatorsArray.push('(AT)');
    const outpatientRxFields = med?.fullData?.supplemental?.outpatientRxFields;
    if (outpatientRxFields?.placerNumber && outpatientRxFields?.erxHubId) {
        indicatorsArray.push('(&)');
    }

    med.indicatorString = indicatorsArray.map((m) => m).join(' ');
};

/**
 * @description Sets the bad address indicator.
 * @param {Object} med - The medication object.
 * @param {Object} sitesData - The sites data object.
 */
const setBadAddressIndicator = (med, sitesData) => {
    let facilityId = med?.fullData?.facility?.code.substring(0, 3);
    let siteIndex = sitesData?.findIndex((site) => facilityId === site?.siteSupplemental?.facility);
    if (siteIndex >= 0 && sitesData[siteIndex]) {
        let siteSupplemental = sitesData[siteIndex]?.siteSupplemental;
        formatBadAddress(med, siteSupplemental);
    }
};

/**
 * @description Convert the site siteSupplemental Bad Address and Mail Status fields to a formatted string.
 * @param {Object} med - The medication object.
 * @param {Object} siteSupplemental Site siteSupplemental object from the meds call
 * @return an array of formatted strings holding Bad Address and Mail Status
 */
const formatBadAddress = (med, siteSupplemental) => {
    if (!siteSupplemental) {
        return;
    }
    if (siteSupplemental.badAddressIndicator) {
        med.badAddressIndicator = 'Bad Address: ' + siteSupplemental.badAddressIndicator;
    }
    if (siteSupplemental.mailStatus) {
        const today = new Date().toISOString().slice(0, 10).replace(/-/g, '');
        const expirationDate = siteSupplemental.mailStatusExpDate;
        if (!expirationDate || expirationDate > today) {
            med.mailStatusIndicator = 'Mail Status: ';
            switch (siteSupplemental.mailStatus) {
                case '1':
                    med.mailStatusIndicator += MAIL_STATUS.CERTIFIED_MAIL;
                    break;
                case '2':
                    med.mailStatusIndicator += MAIL_STATUS.DO_NOT_MAIL;
                    break;
                case '4':
                    med.mailStatusIndicator += MAIL_STATUS.FOR_LOCAL_CERTIFIED_MAIL;
                    break;
                default:
                    med.mailStatusIndicator = MAIL_STATUS.DEFAULT;
                    break;
            }
        }
    }
};

/**
 * @description Prepares a medication object by surfacing properties and building display values.
 * @param {Object} med - The medication object.
 * @returns {Object} Prepared medication object.
 */
const prepareMed = (med, sitesData) => {
    surfaceMedProperties(med);
    setCsSchedule(med);
    setProviderComments(med);
    setNonVaDocumentedBy(med);
    setDocumentedDate(med);
    buildIndicatorString(med);
    setBadAddressIndicator(med, sitesData);

    // ? Build the criteria string of what qualifies as a duplicate
    med.drugNameFacilityString = med?.drugName + med?.fullData?.facility?.name;

    return med;
};

/**
 * @description Sorts and organizes medications into various statuses, identifies duplicates,
 * and prepares them for display.
 * @param {Object} preparedMeds - The object containing categorized medications.
 * @property {Array<Object>} preparedMeds.nonVaMeds - Array of non-VA medications to be sorted.
 * @property {Array<Object>} preparedMeds.active - Array of active VA medications to be organized.
 * @property {Array<Object>} preparedMeds.uniqueMedsListForDisplay - Array to hold unique medications for display.
 * @property {Object} preparedMeds.groupedDuplicateMeds - Object to store grouped duplicate medications.
 * @returns {void} Updates the `preparedMeds` object by sorting, organizing, and identifying duplicates.
 */
const sortAndOrganizeMeds = (preparedMeds) => {
    //? Sort Non-VA Meds
    preparedMeds.nonVaMeds.sort((a, b) => (a?.drugName > b?.drugName ? 1 : -1));

    //? Sort VA Meds
    let statusObject = {
        active: [],
        suspended: [],
        pending: [],
        nonVerified: [],
        expired: [],
        discontinued: [],
        discontinuedEdit: [],
        unAccountedFor: []
    };

    //? (1) Group by status into arrays
    preparedMeds?.active?.forEach((med) => {
        if (med?.vaStatusValue === 'NON-VERIFIED') {
            statusObject?.nonVerified?.push(med);
        } else if (med?.vaStatusValue === 'DISCONTINUED (EDIT)') {
            statusObject?.discontinuedEdit?.push(med);
        } else if (Object.keys(statusObject).includes(med?.vaStatusValue?.toLowerCase())) {
            statusObject[med?.vaStatusValue?.toLowerCase()]?.push(med);
        } else {
            statusObject?.unAccountedFor?.push(med);
        }
    });

    //? (2) Sort each group array
    Object.values(statusObject).forEach((value) => {
        sortArrayDesc(value);
    });

    //? (3) Unify arrays
    let displayArray = [];
    Object.values(statusObject).forEach((value) => {
        displayArray?.push(...value);
    });
    preparedMeds.active = displayArray;

    //? (4) Make set of unique names to display on Table
    preparedMeds.uniqueMedsListForDisplay = lwcHelper.uniqueVals(preparedMeds?.active, 'drugNameFacilityString');

    //? (5) Group all the duplicates together
    const duplicates = lwcHelper.groupBy(preparedMeds?.active, 'drugNameFacilityString');

    //? (6) Loop through uniqueMedsListForDisplay and the associated duplicates for final touches
    for (let i = 0; i < preparedMeds?.uniqueMedsListForDisplay?.length; i++) {
        let med = preparedMeds.uniqueMedsListForDisplay[i];
        let duplicateMeds = duplicates[med?.drugNameFacilityString];
        if (!Array.isArray(duplicateMeds) || duplicateMeds.length <= 1) {
            continue;
        }
        med.deactivateDuplicateButton = false;

        // if no duplicate meds in "Active", "Pending", or "Suspended" status are present, display the med with the latest expiration date
        let hasActivePendingOrSuspended = false;
        let medWithLatestExpiration = null;
        duplicateMeds.forEach((dupeMed) => {
            let status = dupeMed.vaStatusValue;
            if (hasActivePendingOrSuspended === true) {
                return;
            }
            if (
                typeof status === 'string' &&
                (status === ACTIVE_MED_STATUS || status === PENDING_MED_STATUS || status === SUSPENDED_MED_STATUS)
            ) {
                hasActivePendingOrSuspended = true;
                return;
            }
            let thisMedsExpiration = dupeMed?.fullData?.expires?.formattedValue;
            let currentLatestExpiringMedsExpiration = medWithLatestExpiration?.fullData?.expires?.formattedValue;
            if (medWithLatestExpiration === null || currentLatestExpiringMedsExpiration < thisMedsExpiration) {
                medWithLatestExpiration = dupeMed;
            }
        });
        if (hasActivePendingOrSuspended === true) {
            continue;
        }

        // set new med as display med
        preparedMeds.uniqueMedsListForDisplay[i] = medWithLatestExpiration;
        // if duplicate meds truly exist, make the button in the table selectable
        med.deactivateDuplicateButton = true;
        medWithLatestExpiration.deactivateDuplicateButton = false;
    }
    //? (7) Store duplicates
    preparedMeds.groupedDuplicateMeds = duplicates;
};

/**
 * @description Iterates through each med in list, processing it for display
 * @param {`object`} parsedResponse
 * @return `object` JS Object with medslist sorted and categorized
 */
export const processCallout = (medsData) => {
    let parsedResponse = JSON.parse(medsData.medsResponse);
    let sitesData = medsData?.v1?.sites;
    if (isResponseInvalid(parsedResponse)) {
        return null;
    }

    let preparedMeds = {
        outpatientMeds: [],
        nonVaMeds: [],
        nonActiveVaMeds: [],
        active: [],
        uniqueMedsListForDisplay: [],
        groupedDuplicateMeds: [],
        dataHasErrors: [],
        nonVADataHasErrors: [],
        all: parsedResponse
    };

    for (let i = 0; i < parsedResponse?.length; i++) {
        let med = parsedResponse[i];

        if (medHasBadData(med)) {
            handleMedWithErrors(med, preparedMeds);
            continue;
        }

        try {
            med = prepareMed(med, sitesData);

            //? Separating out meds by type async

            if (med?.fullData?.vaType?.value === 'O') {
                preparedMeds?.outpatientMeds?.push(med);
                preparedMeds?.active?.push(med);
            } else if (med?.fullData?.vaType?.value === 'N') {
                preparedMeds?.nonVaMeds?.push(med);
            }
        } catch (error) {
            console.error(`VCC Medications could not parse this med: ${error} `, med);
            continue;
        }
    }

    sortAndOrganizeMeds(preparedMeds);

    preparedMeds?.uniqueMedsListForDisplay?.forEach((med, index) => (med.index = index));
    return preparedMeds;
};

/**
 * @description Organizes med metadata such as facility of a med
 * @returns metadata of a list of meds
 */
export const identifyAllFacilitiesInMedList = (meds) => {
    try {
        return lwcHelper.groupBy(
            lwcHelper.uniqueVals(
                meds.map((med) => {
                    return {
                        id: med?.fullData?.facility?.code,
                        name: med?.fullData?.facility?.name,
                        concat: `${med?.fullData?.facility?.code}-${med?.fullData?.facility?.name}`
                    };
                }),
                'concat'
            ),
            'id'
        );
    } catch (error) {
        console.error(error); // eslint-disable-line no-console
    }
};

/**
 * @description Processes error messages to extract facility codes that have encountered errors.
 * @param {Array<string>} errors - An array of error messages containing facility information.
 * @returns {Array<string>} A list of facility codes extracted from the error messages.
 */
export const processVistaLimitErrors = (errors) => {
    let facilitiesWithErrors = [];
    for (let i = 0; i < errors?.length; i++) {
        let words = errors[i].split(' ');
        let numberIndex = words.findIndex((word) => word === 'Facility');
        let facilityCode = words[numberIndex + 2];
        facilitiesWithErrors.push(facilityCode.slice(0, -1));
    }
    return facilitiesWithErrors;
};
