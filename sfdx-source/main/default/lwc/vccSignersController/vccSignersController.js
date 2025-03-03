import apex_searchProviders from "@salesforce/apex/VCC_SignersController.searchProviders";
import apex_getSignersForRecord from "@salesforce/apex/VCC_SignersController.getSignersForRecord";
import apex_addSignersToRecord from "@salesforce/apex/VCC_SignersController.addSignersToRecord";
import apex_deleteSigners from "@salesforce/apex/VCC_SignersController.deleteSigners";

export async function searchProviders({ searchString, site }) {
    return await apex_searchProviders({ searchString: searchString, site: site });
}

export async function getSignersForRecord({ recordId }) {
    return await apex_getSignersForRecord({ recordId: recordId });
}

export async function addSignersToRecord({ vistaUserList, recordId }) {
    return await apex_addSignersToRecord({ vistaUserList: vistaUserList, recordId: recordId });
}

export async function deleteSigners({ signers }) {
    return await apex_deleteSigners({ signers: signers });
}
