import { LightningElement } from "lwc";
import getActiveAnnouncements from "@salesforce/apex/VCC_AnnouncementController.getActiveAnnouncements";

export default class VccAnnouncement extends LightningElement {
    announcementList;

    connectedCallback() {
        this.getActiveAnnouncementsJS();
    }

    getActiveAnnouncementsJS() {
        getActiveAnnouncements().then((response) => {
            if (response.length) {
                this.announcementList = response;
            }
        });
    }
}
