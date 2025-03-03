import apex_getSiteIntegrationType from '@salesforce/apex/VCC_DASController.getSiteIntegrationType';
import apex_selectPatient from '@salesforce/apex/VCC_DASController.selectPatient';

export const IntegrationType = {
    VDIF: 'VDIF',
    DAS: 'DAS'
};

export async function getSiteIntegrationType(siteId) {
    if (typeof siteId != 'string' || siteId == '') {
        throw Error('vccDasController.getSiteIntegrationType Error: expected non-empty String for siteId');
    }

    // siteId needs to be an Integer, as such it cannot contain a decimal point, which would make it a Float/Double/Decimal
    if (Number(siteId) == NaN || siteId.indexOf('.') != -1) {
        throw Error('vccDasController.getSiteIntegrationType Error: could not convert siteId to Integer');
    }

    let integrationType = await apex_getSiteIntegrationType({ siteId: Number(siteId) });

    if (IntegrationType[integrationType] == undefined) {
        throw Error('vccDasController.getSiteIntegrationType Error: unexpected return value from VCC_DASController');
    }

    return integrationType;
}

export async function selectPatient({
    providerLoginSiteCode,
    providerName,
    providerUserId,
    patientLocalPid,
    patientLocalSiteId,
    recordId
}) {
    if (
        providerLoginSiteCode == null ||
        providerName == null ||
        providerUserId == null ||
        patientLocalPid == null ||
        patientLocalSiteId == null ||
        recordId == null
    ) {
        throw Error('vccDasController.selectPatient received a null input value.');
    }
    return await apex_selectPatient({
        providerLoginSiteCode: providerLoginSiteCode,
        providerName: providerName,
        providerUserId: providerUserId,
        patientLocalPid: patientLocalPid,
        patientLocalSiteId: patientLocalSiteId,
        recordId: recordId
    });
}
