/**
 * These methods were 'cannibalized' from vccInpatientInfo during refactors included in 18433.
 * No changes were made except to adapt them to this helper js file.
 */

function getJsDateFromFileManDateTime(fileManDateTime) {
    let fileManDateTimeString = fileManDateTime + "";
    let year = parseInt(fileManDateTimeString.substring(0, 4));
    let month = parseInt(fileManDateTimeString.substring(4, 6)) - 1;
    let day = fileManDateTimeString.substring(6, 8);
    let hours = fileManDateTimeString.substring(8, 10);
    let minutes = fileManDateTimeString.substring(10, 12);
    return new Date(year, month, day, hours, minutes);
}

export function parseInpatientData(retrieveInpatientInfoResponse) {
    let inpatientData = JSON.parse(JSON.parse(retrieveInpatientInfoResponse).resBody);
    let patients = inpatientData?.clinicalData?.patientMovement?.patients?.patient;
    //inpatientList = the list of inpatient records that will be displayed to the user
    let inpatientList = [];

    for (let i = 0; i < patients.length; i++) {
        //Get the latest movement record. Each element in the patients array will have a different movement array that is based on facility
        let movementList = patients[i].movement;
        movementList = movementList.sort(function (a, b) {
            return b.dateTime - a.dateTime;
        });
        let latestMovement = movementList[0];
        //Check if movment qualifies as inpatient
        if (latestMovement.transactionTypeName !== "DISCHARGE" && latestMovement.transactionTypeName !== "CHECK-OUT LODGER") {
            //Add facility name
            latestMovement.facilityName = patients[i].facility;
            //Add formatted date/time
            let dateTimeVal = getJsDateFromFileManDateTime(latestMovement.dateTime);
            latestMovement.dateTimeLocaleString = new Date(dateTimeVal).toLocaleString();
            inpatientList.push(latestMovement);
        }
    }
    return inpatientList;
}

export function isInPatient(inpatientRecord) {
    if (typeof inpatientRecord === "object" && inpatientRecord !== null) {
        return {
            facilityName: inpatientRecord?.facilityName,
            mASMovementTransaction: inpatientRecord?.transactionTypeName,
            mASMovementType: inpatientRecord?.masMovementTypeName,
            facilityMovementType: "",
            roomBed: inpatientRecord?.roomBed
        };
    }
    return false;
}
