import apex_getRecordTypeId from "@salesforce/apex/VCC_VatPageController.getRecordTypeId";
import apex_getUserSites from "@salesforce/apex/VCC_VatPageController.getUserSites";
import apex_runTestForSite from "@salesforce/apex/VCC_VatPageController.runTestForSite";
import apex_getToken from "@salesforce/apex/VCC_VatPageController.getToken";

export async function getRecordTypeId() {
    return await apex_getRecordTypeId();
}

export async function getUserSites() {
    return await apex_getUserSites();
}

export async function runTestForSite({ serviceApiName, siteCode, esig, token, duz }) {
    return await apex_runTestForSite({
        parametersObject: {
            serviceApiName: serviceApiName,
            siteCode: siteCode,
            esig: esig,
            token: token,
            duz: duz
        }
    });
}

export async function getToken() {
    return await apex_getToken();
}
