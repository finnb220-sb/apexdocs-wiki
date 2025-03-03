import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Id from "@salesforce/user/Id";
import { getRecord, getRecordNotifyChange } from "lightning/uiRecordApi";
import handleTeamsMeetingConversion from "@salesforce/apex/PC_ChatController.handleTeamsMeetingConversion";

export default class PcSpecialistChannelConvert extends LightningElement {
    @api recordId;
    messages = [];
    isDisabled = false;

    @wire(getRecord, { recordId: "$recordId", fields: ["PC_Case__c.Closed__c"] })
    record({ error, data }) {
        if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    message: error.body ? error.body.message : error.message,
                    title: "Cannot Retrieve record from Provider Connect Case",
                    variant: "error",
                    mode: "sticky"
                })
            );
        } else if (data) {
            this.isDisabled = data.fields.Closed__c.value;
        }
    }
    handleTeamsInitiate() {
        let emailSet = new Set();
        handleTeamsMeetingConversion({ caseId: this.recordId })
            .then((result) => {
                if (result.Id) {
                    this.session = { ...result };
                    let foundEmail = false;
                    if (this.session.Feeds) {
                        this.messages = this.messages.concat(this.session.Feeds);
                        this.messages.forEach((message) => {
                            if (Id !== message.InsertedById) {
                                emailSet.add(message.InsertedBy.Email);
                                foundEmail = true;
                            }
                        });
                    }
                    if (!foundEmail) {
                        emailSet.add(result.Provider_Connect_Case__r.CreatedBy.Email);
                    }
                }
                let badEmailAddress = [];
                emailSet.forEach(function (email) {
                    if (email.endsWith("invalid")) {
                        badEmailAddress.push(email);
                    }
                });
                if (badEmailAddress.length) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: "The Following email addresses are invalid: " + badEmailAddress.join(),
                            title: "Error occurred trying start a Teams Meeting",
                            variant: "error",
                            mode: "sticky"
                        })
                    );
                    badEmailAddress.forEach(function (email) {
                        emailSet.delete(email);
                    });
                }
                let emailAddresses = [...emailSet].join();
                if (emailAddresses.length) {
                    this.isDisabled = true;
                    window.open("https://teams.microsoft.com/l/call/0/0?users=" + emailAddresses, "_blank");
                }
                getRecordNotifyChange([{ recordId: this.recordId }]);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body ? error.body.message : error.message,
                        title: "Can not initiate a Teams Meeting on a closed case. Please make a new case.",
                        variant: "error",
                        mode: "sticky"
                    })
                );
            });
    }
}
