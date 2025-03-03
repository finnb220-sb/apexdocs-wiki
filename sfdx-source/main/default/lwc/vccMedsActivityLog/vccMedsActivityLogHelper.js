import getActivityLog from "@salesforce/apex/VCC_MedsListController.fetchPharmacyLog";
import { datatableHelper } from "c/utils";
import { uniqueId } from "c/helpersLWC";

// global datatable helpers
export const getColumn = datatableHelper.getColumn;
export const sortFlatList = datatableHelper.sortFlatList;

/**
 * @description Log callout
 * @param logType type of log
 * @param logRequest request for DIVA
 * @returns Refill log for current medication
 */

export const fetchLogs = async (logtype, logRequest) => {
    try {
        return await getActivityLog({ logType: logtype, jsObject: logRequest });
    } catch (error) {
        console.error(error); // eslint-disable-line
    }
};

/**
 * @description Iterates through each refill log, creating a unique id. Then sorts list by log date ascending
 * @param {*} list Refill log records to process
 * @param {*} sortProperty Date for default sorting
 * @returns Processed refill log records
 */
export const processData = (list, sortProperty = "loginDate") => {
    try {
        list.forEach((log) => {
            log.uuid = uniqueId();
            // log.ActivityLog = new Date(log.ActivityLog); // converting @hh:mm:ss to iso
        });
        return sortFlatList(list, { propertyName: sortProperty, type: "date" }, "asc");
    } catch (error) {
        console.error(error);
    }
    return null;
};
