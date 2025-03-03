import { LightningElement, api } from "lwc";
//Custom Permission to make warnings visibile
import canSeeAddress from "@salesforce/customPermission/VAHC_Bad_Address_Indicator";
import canSeeMail from "@salesforce/customPermission/VAHC_Mail_Indicator";

export default class VccMedicationWarning extends LightningElement {
    warningTitle = `Warning`;
    hasWarnings = false;
    canSeeBadAddress = canSeeAddress;
    canSeeMail = canSeeMail;
    @api meds;
    @api medErrors;
    warnings = [];

    connectedCallback() {
        this.warnings.push(...this.medErrors);
        this.processSiteData(this.meds);
        this.hasWarnings = this.warnings.length > 0;
        this.warningTitle += `${this.warnings.length > 1 ? "s" : ""} (` + `${this.warnings.length}` + `)`;
        if (this.warnings.length > 0) this.logWarnings(this.warnings);
    }

    processSiteData(data) {
        if (data?.sites?.length == 0) {
            return; //TODO will need to toggle whether or not hasWarnings
        }

        let siteWarningObj = {};
        let siteSupplementalList = [];
        siteWarningObj.siteDataList = [];
        //? run through all of the incoming data for each site
        data.sites.forEach((site) => {
            let siteSummaryObject = {};
            siteSupplementalList.push(site.siteSupplemental);
            siteSummaryObject.name = site?.siteSupplemental?.facility;
            siteSummaryObject.badAddress = site?.siteSupplemental?.badAddressIndicator; //"Bad Address: Address Not Found"; // won't show if blank //if "" insert null into object
            siteSummaryObject.mailStatus = site?.siteSupplemental?.mailStatus;
            siteSummaryObject.mailStatusExpDate = site?.siteSupplemental?.mailStatusExpDate ? site?.siteSupplemental?.mailStatusExpDate : null;

            let expDateString = "";
            if (siteSummaryObject.mailStatusExpDate != null) {
                siteSummaryObject.mailStatusExpDate = this.convertDate(siteSummaryObject.mailStatusExpDate);
                expDateString = ` (EXP:  ${siteSummaryObject.mailStatusExpDate})`;
            }

            if (siteSummaryObject.mailStatus != null) {
                switch (siteSummaryObject.mailStatus) {
                    case "0":
                        siteSummaryObject.mailStatus = "Regular Mail";
                        break;
                    case "1":
                        siteSummaryObject.mailStatus = "Certified Mail";
                        break;
                    case "2":
                        siteSummaryObject.mailStatus = "Do Not Mail";
                        break;
                    case "3":
                        siteSummaryObject.mailStatus = "For Local - Regular Mail";
                        break;
                    case "4":
                        siteSummaryObject.mailStatus = "For Local - Certified Mail";
                        break;
                }
                siteSummaryObject.mailStatus += expDateString;
            }
            //TODO check on what is sent with data, are the fields null or "". Working on null assumption
            if (siteSummaryObject.badAddress != null || siteSummaryObject.mailStatus != null) {
                siteWarningObj.siteDataList.push(siteSummaryObject);
            }
        });
        //? log all siteSupplemental info
        this.logWarnings(siteSupplementalList);

        if (siteWarningObj.siteDataList.length > 0) {
            siteWarningObj.message = "This patient has a Bad Address or Mail Status Indicator in the following facilities.";
            siteWarningObj.hasSiteData = true;
            this.warnings.push(siteWarningObj);
        }
    }

    logWarnings(warnings) {
        this.dispatchEvent(new CustomEvent("logwarnings", { detail: { value: warnings } }));
    }

    convertDate(date) {
        // Parse the date
        var year = parseInt(date.substring(0, 4));
        var month = parseInt(date.substring(4, 6));
        var day = parseInt(date.substring(6, 8));

        // Format the date
        var formattedDate = new Date(year, month - 1, day).toLocaleDateString("en-US", { month: "long", day: "numeric", year: "numeric" });

        return formattedDate;
    }
}

/*


warnings = [
	{
		message: "Important! The patient has 13 medication(s) that have missing values and have not been retrieved.
The medication list may be incomplete, please review the patient's medical records in EHR."
	},
	{
		message: "This patient has a Bad Address or Mail Status Indicator in the following facilities.",
		hasSiteData: true,
		siteDataList: [
			{
				"name": "541",
				"badAddress": "UNDELIVERABLE"
			},
			{
				"name": "982",
				"mailStatus": "Regular Mail"
			}
		]
	}
]


*/
