/* eslint-disable guard-for-in */
import { proxyTool } from 'c/helpersLWC';
import { dateFormatter } from 'c/utils';

export const processESR = (esrData) => {
    // destructuring date fields from esr to format

    const formattedDates = dynamicDestructure(esrData); //eslint-disable-line
    esrData = { ...proxyTool(esrData), formattedDates };
    return esrData;
};

export const dynamicDestructure = (esrData) => {
    let obj = {
        assignmentDate: '\u2014',
        secondaryAssignmentDate: '\u2014',
        secondaryUnassignmentDate: '\u2014',
        unassignmentDate: '\u2014',
        policyEffectiveDate: '\u2014',
        partAEffectiveDate: '\u2014',
        partBEffectiveDate: '\u2014',
        policyExpirationDate: '\u2014',
        effectiveDate: '\u2014',
        monetaryBenefitReportDate: '\u2014'
    };

    // monetary benefits

    if (esrData?.monetaryBenefits?.length) {
        const {
            monetaryBenefits: [{ monetaryBenefitReportDate }]
        } = esrData || {};

        obj.monetaryBenefitReportDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(monetaryBenefitReportDate);
    }
    // demographics
    if (esrData?.eeExtendedResponse) {
        if (esrData?.eeExtendedResponse?.demographics) {
            const {
                eeExtendedResponse: {
                    demographics: { assignmentDate, unassignmentDate }
                }
            } = esrData || {};

            obj.assignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(assignmentDate);
            obj.unassignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(unassignmentDate);
        }

        if (esrData?.eeExtendedResponse?.demographics?.preferredFacilities?.length) {
            const {
                eeExtendedResponse: {
                    demographics: {
                        preferredFacilities: [
                            { assignmentDate: secondaryAssignmentDate, unassignmentDate: secondaryUnassignmentDate }
                        ]
                    }
                }
            } = esrData || {};

            obj.secondaryAssignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(secondaryAssignmentDate);
            obj.secondaryUnassignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(secondaryUnassignmentDate);
        }
    }
    // insurance
    if (esrData?.eeExtendedResponse?.insuranceList?.length) {
        const {
            eeExtendedResponse: {
                insuranceList: [{ policyEffectiveDate, partAEffectiveDate, partBEffectiveDate, policyExpirationDate }]
            }
        } = esrData || {};

        obj.policyEffectiveDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(policyEffectiveDate);
        obj.partAEffectiveDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(partAEffectiveDate);
        obj.partBEffectiveDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(partBEffectiveDate);
        obj.policyExpirationDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(policyExpirationDate);
    }

    return obj;
};

export const mainArea = (esrData) => {
    if (!esrData && (!esrData?.length || !Object.keys(esrData).length)) {
        return null;
    }

    let obj = {
        assignmentDate: esrData?.eeExtendedResponse?.demographics?.assignmentDate || '\u2014',
        preferredFacilities: '\u2014',
        unassignmentDate: esrData?.eeExtendedResponse?.demographics?.unassignmentDate || '\u2014',
        preferredFacility: esrData?.eeExtendedResponse?.demographics?.preferredFacility || '\u2014',
        priorityGroup: esrData?.priorityGroup || '\u2014',
        serviceBranches: esrData?.serviceBranches?.length ? esrData?.serviceBranches : null,
        serviceConnectedPercentage: esrData?.serviceConnectedPercentage?.concat('%') || '\u2014',
        eligibleForMedicaid: esrData?.eligibleForMedicaid || '\u2014',
        enrollmentCategoryName:
            esrData?.eeExtendedResponse?.enrollmentDetermination?.enrollmentCategoryName || '\u2014',
        enrollmentStatus: esrData?.eeExtendedResponse?.enrollmentDetermination?.enrollmentStatus || '\u2014',
        effectiveDate: esrData?.eeExtendedResponse?.enrollmentDetermination?.effectiveDate || '\u2014',
        primaryEligibility: esrData?.eeExtendedResponse?.enrollmentDetermination?.primaryEligibility || '\u2014',
        otherEligibilities: '\u2014',
        secondaryEligibilities: '\u2014',
        ratedDisabilities: null
    };

    if (esrData?.eeExtendedResponse) {
        if (esrData?.eeExtendedResponse?.demographics) {
            const {
                eeExtendedResponse: {
                    demographics: { assignmentDate, unassignmentDate }
                }
            } = esrData || {};

            obj.assignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(assignmentDate);
            obj.unassignmentDate = dateFormatter.formatYYYYMMDDDateToMMDDYYYY(unassignmentDate);

            if (esrData?.eeExtendedResponse?.demographics?.preferredFacilities?.length) {
                const {
                    eeExtendedResponse: {
                        demographics: { preferredFacilities }
                    }
                } = esrData || {};

                obj.preferredFacilities = preferredFacilities
                    .map((facility) => {
                        return {
                            ...facility,
                            unassignmentDate: dateFormatter.formatYYYYMMDDDateToMMDDYYYY(facility.unassignmentDate),
                            assignmentDate: dateFormatter.formatYYYYMMDDDateToMMDDYYYY(facility.assignmentDate)
                        };
                    })
                    .filter((facility) => !facility.preferredFacility.includes(obj.preferredFacility));
            }
        }

        let {
            eeExtendedResponse: {
                enrollmentDetermination: {
                    primaryEligibility = null,
                    secondaryEligibilities = [],
                    otherEligibilities = []
                }
            }
        } = esrData;

        if (primaryEligibility && typeof primaryEligibility === 'object') {
            obj.primaryEligibility = {
                ...primaryEligibility,
                eligibilityReportDate: primaryEligibility?.eligibilityReportDate
                    ? dateFormatter.formatYYYYMMDDDateToMMDDYYYY(primaryEligibility.eligibilityReportDate)
                    : null
            };
        }
        if (Array.isArray(secondaryEligibilities) && secondaryEligibilities.length > 0) {
            obj.secondaryEligibilities = secondaryEligibilities.map((eligibility) => {
                let {} = eligibility; //eslint-disable-line
                return {
                    ...eligibility,
                    eligibilityReportDate: eligibility?.eligibilityReportDate
                        ? dateFormatter.formatYYYYMMDDDateToMMDDYYYY(eligibility.eligibilityReportDate)
                        : null
                };
            });
        }
        if (Array.isArray(otherEligibilities) && otherEligibilities.length > 0) {
            obj.otherEligibilities = otherEligibilities.map((eligibility) => {
                return {
                    ...eligibility,
                    eligibilityReportDate: eligibility?.eligibilityReportDate
                        ? dateFormatter.formatYYYYMMDDDateToMMDDYYYY(eligibility.eligibilityReportDate)
                        : null
                };
            });
        }
    }

    if (esrData?.serviceBranches?.length) {
        const { serviceBranches } = esrData || {};

        obj.serviceBranches = serviceBranches;
    }

    if (esrData?.ratedDisabilities?.length) {
        const { ratedDisabilities } = esrData || {};

        obj.ratedDisabilities = ratedDisabilities;
    }

    return obj;
};

export const insurance = (esrData) => {
    if (esrData && esrData.eeExtendedResponse?.insuranceList?.length) {
        let insuranceList = [];
        let obj = { ...esrData };
        for (let i in esrData.eeExtendedResponse.insuranceList) {
            let x = Object.assign(obj.eeExtendedResponse.insuranceList[i], {
                policyEffectiveDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(
                        esrData.eeExtendedResponse.insuranceList[i].policyEffectiveDate
                    ) || '\u2014',
                partAEffectiveDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(
                        esrData.eeExtendedResponse.insuranceList[i].partAEffectiveDate
                    ) || '\u2014',
                partBEffectiveDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(
                        esrData.eeExtendedResponse.insuranceList[i].partBEffectiveDate
                    ) || '\u2014',
                policyExpirationDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(
                        esrData.eeExtendedResponse.insuranceList[i].policyExpirationDate
                    ) || '\u2014',
                planType: esrData.eeExtendedResponse.insuranceList[i].planType || '\u2014',
                groupName: esrData.eeExtendedResponse.insuranceList[i].groupName || '\u2014',
                groupNumber: esrData.eeExtendedResponse.insuranceList[i].groupNumber || '\u2014',
                companyName: esrData.eeExtendedResponse.insuranceList[i].companyName || '\u2014',
                policyHolderName: esrData.eeExtendedResponse.insuranceList[i].policyHolderName || '\u2014',
                subscriber: esrData.eeExtendedResponse.insuranceList[i].subscriber || '\u2014',
                phoneNumber: esrData?.eeExtendedResponse?.insuranceList[i].insurancePhone || '\u2014',
                address: {
                    line1: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.line1 || null,
                    line2: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.line2 || null,
                    line3: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.line3 || null,
                    city: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.city || null,
                    zipCode: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.zipCode || null,
                    state: esrData?.eeExtendedResponse?.insuranceList[i]?.insuranceAddress?.state || null
                }
            });

            if (!x.insuranceAddress.line1) {
                x.address = null;
            }

            insuranceList.push(x);
        }
        return insuranceList;
    }

    return null;
};

export const healthBenefitPlans = (esrData) => {
    if (esrData?.eeExtendedResponse?.healthBenefitPlans?.length) {
        // eslint-disable-next-line no-shadow
        let healthBenefitPlans = [];
        for (let i in esrData.eeExtendedResponse.healthBenefitPlans) {
            let x = Object.assign(esrData.eeExtendedResponse.healthBenefitPlans[i], {
                effectiveDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(
                        esrData.eeExtendedResponse.healthBenefitPlans[i].effectiveDate
                    ) || '\u2014',
                planCode: esrData.eeExtendedResponse.healthBenefitPlans[i].planCode || '\u2014',
                planName: esrData.eeExtendedResponse.healthBenefitPlans[i].planName || '\u2014',
                coverageCode: esrData.eeExtendedResponse.healthBenefitPlans[i].coverageCode || '\u2014',
                description: esrData.eeExtendedResponse.healthBenefitPlans[i].description || '\u2014'
            });
            healthBenefitPlans.push(x);
        }
        return healthBenefitPlans;
    }

    return null;
};

export const benefits = (esrData) => {
    if (esrData?.monetaryBenefits?.length) {
        let benefits = []; //eslint-disable-line
        for (let i in esrData.monetaryBenefits) {
            let x = Object.assign(esrData.monetaryBenefits[i], {
                monetaryBenefitReportDate:
                    dateFormatter.formatYYYYMMDDDateToMMDDYYYY(esrData.monetaryBenefits[i].monetaryBenefitReportDate) ||
                    '\u2014',
                monetaryBenefitType: esrData.monetaryBenefits[i].monetaryBenefitType || '\u2014'
            });
            benefits.push(x);
        }

        return benefits;
    }

    return null;
};
