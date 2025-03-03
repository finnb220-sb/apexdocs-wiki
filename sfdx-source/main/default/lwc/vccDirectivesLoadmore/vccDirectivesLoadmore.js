import { api, LightningElement } from "lwc";
import { fetchDirectives, convertResponse } from "c/vccDirectivesController";

const dateTimeFormat = {
    weekday: "short",
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "numeric",
    hour12: true
};

//i didn't feel the need to generalize this, as it's a very specific use case.
//Please replace if you find yourself looking to do this or something similar
export default class VccDirectivesLoadmore extends LightningElement {
    isLoading = false;

    siteDetailList = [];

    @api
    recordId;

    hasMoreNotes = false;

    @api
    setSiteDetailList(response) {
        if (response == null || !Array.isArray(response)) {
            return;
        }
        this.hasMoreNotes = false;
        console.log(response);

        //filtering site detail list down to sites that have more notes
        this.siteDetailList = response.flatMap((site) => {
            if (site.hasMore === false || site.hasMore == undefined || site.hasMore == null) {
                return [];
            }
            site.formattedDate = new Date(Date.parse(site.minDate)).toLocaleString("en-US", dateTimeFormat);
            site.sitesJoined = site.facilityNumberSet.join(", ");
            return site;
        });

        //if one or more sites remain, set hasMoreNotes flag to true
        if (this.siteDetailList.length > 0) {
            this.hasMoreNotes = true;
        }
    }

    async handleLoadMore(e) {
        this.isLoading = true;
        try {
            //for each site that has more notes, make an API call.
            //wait for all api calls to complete before moving on
            let results = await Promise.allSettled(
                this.siteDetailList.flatMap((siteDetails) => {
                    return fetchDirectives({
                        recordId: this.recordId,
                        systemId: siteDetails.systemId,
                        stopDate: siteDetails.minDate
                    });
                })
            );

            //set the new site detail list
            this.setSiteDetailList(
                results.flatMap((outcome) => {
                    return outcome.value;
                })
            );

            //dispatch custom event with new notes to parent component
            this.dispatchEvent(
                new CustomEvent("moreloaded", {
                    detail: {
                        notes: results.flatMap((outcome) => {
                            let sites = outcome.value;
                            return sites.flatMap((site) => {
                                return Object.values(site.facilityIdToDirectivesMap).flat();
                            });
                        })
                    }
                })
            );
        } catch (e) {
            console.error(e);
        } finally {
            this.isLoading = false;
        }
    }
}
