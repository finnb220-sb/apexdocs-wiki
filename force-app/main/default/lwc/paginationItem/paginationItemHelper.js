import getPatientAdditionalSigners from '@salesforce/apex/VCC_PatientAdditionalSignersController.getPatientAdditionalSigners';
import { flattenObject } from 'c/helpersLWC';

export const arrErrors = [];

export const formatDate = (dateLiteral) => {
    try {
        const [year, month, day, hour, min, sec] = [
            dateLiteral.slice(0, 4),
            dateLiteral.slice(4, 6),
            dateLiteral.slice(6, 8),
            dateLiteral.slice(8, 10),
            dateLiteral.slice(10, 12),
            dateLiteral.slice(12, 14)
        ];

        return new Date(year, month - 1, day, hour, min, sec).toLocaleString('en-US', {
            hour12: false,
            year: 'numeric',
            month: 'numeric',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    } catch (err) {
        return '\u2014';
    }
};
/* eslint-disable consistent-return */
export const formatDataForDisplay = (response) => {
    const document =
        JSON.parse(response)?.additionalSignersStatus?.patient?.clinicalDocumentSigners?.clinicalDocumentSigner[0];
    const errors = JSON.parse(response)?.additionalSignersStatus?.errorSection?.fatalErrors?.fatalError[0];

    const additionalSigners = document?.additionalSigners?.additionalSigner;

    if (errors) {
        arrErrors.push(errors);
    }
    /* eslint-disable no-unused-expressions */
    if (additionalSigners?.length) {
        return additionalSigners.map((additionalSigner) => {
            let flat = { ...flattenObject(additionalSigner) };
            flat.literal ? (flat = { ...flat, date: formatDate(flat.literal) }) : (flat.date = 'Pending');
            return flat;
            // TODO: check
        });
    }
};
/* eslint-disable no-useless-catch */
export const fetchAddSigners = async ({
    assigningFacility,
    id,
    sObject,
    documents,
    assigningAuthority,
    nationalId
}) => {
    try {
        const callout = await getPatientAdditionalSigners({
            addSignersParams: {
                assigningFacility: assigningFacility,
                id: id,
                sObject: sObject,
                documents: documents, // document id, last entry in uid string
                assigningAuthority: assigningAuthority,
                nationalId: nationalId
            }
        });

        return formatDataForDisplay(callout);
    } catch (error) {
        // return {hasError: true, message: error};
        throw error;
    }
};
/* eslint-disable */
export const getAddendums = async (documents, { id, sObject, assigningFacility, assigningAuthority, nationalId }) => {
    documents = [...documents].slice(1);
    const addendums = [];

    if (documents?.length) {
        for (const i of documents) {
            if (i.clinicians?.length) {
                const clinicians = i?.clinicians?.map((clinician) => {
                    return {
                        ...clinician,
                        signature: clinician.signature || '\u2014',
                        signedDateTime: clinician.signedDateTime || 'Pending'
                    };
                });

                const document = i.id?.split(':')?.slice(-1)[0];
                // callout to get additional signers
                try {
                    const additionalSigners = await fetchAddSigners({
                        assigningFacility: assigningFacility,
                        id: id,
                        sObject: sObject,
                        documents: [document],
                        assigningAuthority: assigningAuthority,
                        nationalId: nationalId
                    });

                    addendums.push({
                        ...i,
                        date: i.timestamp,
                        document: document,
                        clinicians: clinicians,
                        additionalSigners: additionalSigners
                    });
                } catch (err) {
                    addendums.push({
                        ...i,
                        date: i.timestamp,
                        document: document,
                        clinicians: clinicians
                    });
                }
            }
        }
    }

    return addendums;
};
/* eslint-enable */
