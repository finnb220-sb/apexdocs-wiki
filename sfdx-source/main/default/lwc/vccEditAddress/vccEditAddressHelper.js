import retrieveHDR from "@salesforce/apex/VCC_lwc_utils.retrieveHDR";
import { BridgMedsError } from "c/baseErrors";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export const hasPendingMedications = async (recordId) => {
    try {
        const meds = await retrieveHDR({
            recordId: recordId,
            bridgService: "vccBridgMeds",
            clientObject: "Account",
            initialCallout: false
        });

        let allMeds = [];
        let sites = JSON.parse(meds)?.sites || null;

        if (sites && sites?.length) {
            sites.forEach((site) => {
                if (site.results?.meds.med) {
                    for (let i = 0; i < site.results.meds.med.length; i++) {
                        allMeds.push(site.results.meds.med[i]);
                    }
                }
            });
        }
        //console.log('stats', allMeds[0].vaStatus.value);
        // const hasPendingMedications = allMeds.filter(med => badStatuses.includes(med.vaStatus?.value)).length;

        //console.log(allMeds.forEach(med => console.log(med.vaStatus.value)));

        for (let i = 0; i < allMeds.length; i++) {
            if (allMeds[i].vaStatus.value === "PENDING") {
                return true;
            }
        }

        return false;
    } catch (err) {
        throw new BridgMedsError("Health Data Repository Unavailable; this Veteran may have pending meds");
    }
};

export const dispatchToast = (template, { title, message, variant, mode = "dismissible" }) => {
    const event = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: mode
    });
    template.dispatchEvent(event);
};
