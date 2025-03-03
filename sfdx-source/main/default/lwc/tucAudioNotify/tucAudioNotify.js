import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, onError } from "lightning/empApi";
import getUserVISN from "@salesforce/apex/tucCommonUtils.getUserDivisionVISN";
import audios from "@salesforce/resourceUrl/tucAudios";
import isTeleECReadOnly from "@salesforce/customPermission/Tele_EC_Read_Only";

export default class TucAudioNotify extends LightningElement {
    @api soundEffect;
    @api eventType;
    @api toastType;
    channelName = "/event/TED_TeleECCase__e";
    userVisn;
    subscription = {};

    connectedCallback() {
        //Waits for the user VISN to come back from apex query
        //Basically forces this component to execute sychronously instead waiting on the promis of the SOQL to resolve
        (async () => {
            try {
                this.registerErrorListener();
                await getUserVISN().then((result) => {
                    this.userVisn = result;
                });
            } catch (error) {
                console.log(error);
            } finally {
                this.handleSubscribe();
            }
        })();
    }

/**
 * @description The if statement that checks to see if the user has the Tele_EC_Read_Only custom permission or not, as well as the userVISN and the event type, and, the subscription to channelName, need to be modified and reengineered if we want to generalize this LWC for broader purposes later.
 * 
 */
    handleSubscribe() {
        const self = this;
        const messageCallback = function (response) {
            var obj = JSON.parse(JSON.stringify(response));
            let objData = obj.data.payload;
            if (!isTeleECReadOnly && self.userVisn === objData.VISN__c && self.eventType === objData.eventType__c) {
                let toastEvent = new ShowToastEvent({
                    title: objData.message__c,
                    //message: objData.message__c,
                    variant: self.toastType,
                    mode: "sticky"
                });
                self.dispatchEvent(toastEvent);
                let audio = new Audio(audios + self.soundEffect);
                audio.load();
                audio.play();
            }
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            console.log("Subscription request sent to: ", JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

    //handle Error
    registerErrorListener() {
        onError((error) => {
            console.log("Received error from server: ", JSON.stringify(error));
        });
    }
}
