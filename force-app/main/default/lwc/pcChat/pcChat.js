import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from "lightning/empApi";
import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getChatterMessages from "@salesforce/apex/PC_ChatController.getChatterMessages";
import getChatterMessagesCache from "@salesforce/apex/PC_ChatController.getChatterMessagesCache";
import saveChatterMessage from "@salesforce/apex/PC_ChatController.saveChatterMessage";
import closeChatSession from "@salesforce/apex/PC_ChatController.closeChatSession";
import getFullMessageBody from "@salesforce/apex/PC_ChatController.getFullMessageBody";

import Id from "@salesforce/user/Id";

import isSpecialist from "@salesforce/customPermission/PC_Specialist";
import isDebugEnabled from "@salesforce/customPermission/PC_Enable_Debug";

export default class PcChat extends LightningElement {
    @api sessionId;
    @api recordId;
    @api refreshSeconds = 5;
    @track showSpinner;

    systemMessages = ["Teams Video initiated please use Chat as needed."];
    _systemInsertedByName = "System message";

    @track messages = [];
    @track session = {};
    transcript = "";
    mostRecentMessage = "";
    @track newMessage = "";

    @track isClosed;
    @track isRecipientChatting = false;
    startedBy;
    closedBy;
    closedDate;
    userId = Id;

    pushEventId = "";

    errorCounter = 0;
    hasEnteredChatPublished = false;

    get disableSend() {
        return !this.newMessage;
    }

    get showCopy() {
        return this.isClosed;
    }

    get showRecipientChatAcknowledge() {
        return this.isRecipientChatting;
    }

    get charLength() {
        return this.newMessage?.length;
    }

    @track _initiationMsg;
    get initiationMsg() {
        return this._initiationMsg;
    }
    @api
    set initiationMsg(tempMessage) {
        this._initiationMsg = tempMessage;

        if (tempMessage) {
            saveChatterMessage({ sessionId: this.sessionId, message: tempMessage, chatPushEventId: this.pushEventId })
                .then((result) => {
                    this.pushEventId = result;
                })
                .catch(() => {
                    this.newMessage = tempMessage;
                });
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        this.getChatter();
        this.showSpinner = false;
        if (isDebugEnabled) {
            this.registerErrorListener();
            setDebugFlag(true);
            isEmpEnabled().then(function (result) {
                console.log("Is Emp Enabled? pcChat: " + result);
            });
        }
    }

    renderedCallback() {
        try {
            this.template.querySelector('[data-id="textarea"]').focus();
        } catch (err) {
            // fail silently
        }
    }

    @api
    getRecordId() {
        return this.recordId;
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }

    handleSubscribe(comp) {
        // Callback invoked whenever a new event message is received
        const messageCallback = function (response) {
            //the associated Push Topic is created in PC_Remind_specialists_to_close_case flow and its query dictates the fields returned on the response sobject
            let chatPushEvent = response?.data?.sobject;

            //replace response's chat push event sobject's Body__c field value with the full value from the
            //related chatter feed item's Body field value
            getFullMessageBody({ relatedFeedItemId: chatPushEvent?.PC_Related_Chatter_Id__c })
                .then((result) => {
                    //if not undef/null, successfully retrieved the full message body from the related chatter feed item
                    if (result) {
                        response.data.sobject.Body__c = result;
                    }
                })
                .catch((error) => {
                    //catch silently
                    console.log(error.body.message);
                })
                .finally(() => {
                    comp.handlePushTopicResponse(comp, response);
                    // Response contains the payload of the new message received
                });
        };

        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe("/topic/" + this.sessionId, -1, messageCallback).then((response) => {
            // Response contains the subscription information on subscribe call
            this.subscription = response;
            if (isDebugEnabled) {
                console.log("%cSubscribe pcChat: " + JSON.stringify(response), "color: blue");
            }
        });
    }

    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        try {
            unsubscribe(this.subscription, (response) => {
                if (isDebugEnabled) {
                    console.log("%cUnsubscribe pcChat: " + JSON.stringify(response), "color: blue");
                }
            });
        } catch (error) {
            if (isDebugEnabled) {
                console.log("%cUnsubscribe error pcChat: " + JSON.stringify(error), "color: red");
            }
        }
    }

    registerErrorListener() {
        // Invoke onError empApi method
        onError((error) => {
            console.log("%cerror from Server - pcChat: " + JSON.stringify(error), "color: red");
            // Error contains the server-side error
        });
    }

    handlePushTopicResponse(comp, ptResponse) {
        //console.log('entered handlePushTopicResponse');

        let result = ptResponse.data.sobject;
        comp.isClosed = result.isClosed__c;
        comp.closedBy = result.closedBy__c;
        comp.closedDate = result.closedDate__c;
        result.Body = result.Body__c;
        result.InsertedBy = {};
        result.InsertedBy.Name = result.ChatSentByFullName__c;
        if (result.hasSpecialistEnteredChat__c && result.ChatSentById__c != null && result.ChatSentById__c !== Id) {
            comp.recipientName = result.ChatSentByFullName__c;
            comp.isRecipientChatting = true;
        }
        if (result.Body && result.Body.length) {
            comp.messages.push(result);
            comp.mostRecentMessage = comp.messages[comp.messages.length - 1].LastModifiedDate;
            let shouldPlaySound = false;
            comp.messages.forEach((message) => {
                if (comp.isSystemMessage(message)) {
                    message.Body = message?.Body.startsWith("<b>") && message?.Body.endsWith("</b>") ? message.Body : "<b>" + message.Body + "</b>"; //make system messages bolded
                    message.InsertedBy.Name = this._systemInsertedByName;
                    message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                    message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound systemMessageColor";
                } else if (Id === message.CreatedById || Id === message.InsertedById) {
                    message.listClasses = "slds-chat-listitem slds-chat-listitem_outbound";
                    message.messageClasses = "slds-chat-message__text slds-chat-message__text_outbound";
                } else {
                    message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                    message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound blueContrast";

                    //play message received sound if message was not sent by current user and message was just created
                    if (message.Id === result.Id) {
                        shouldPlaySound = true;
                    }
                }
            });

            //play outside loop so that sound is only played once
            if (shouldPlaySound) {
                this.playMessageSound();
            }

            setTimeout(() => {
                let lastIndex = comp.messages.length - 1;
                comp.scrollToMessage(comp.messages[lastIndex].Random_Gen__c);
            }, 500);
        }

        if (comp.isClosed) {
            comp.transcript += "Chat started by " + comp.startedBy + " • " + comp.formatToLocale(comp.session.CreatedDate) + "\n\n\n";
            comp.messages.forEach((message) => {
                var insertedBy = "";
                if (comp.isSystemMessage(message)) {
                    insertedBy = this._systemInsertedByName;
                } else {
                    insertedBy = message.InsertedBy.Name;
                }
                comp.transcript += insertedBy + " • " + comp.formatToLocale(message.CreatedDate) + "\n" + message.Body + "\n\n";
            });
            comp.transcript += "\nChat ended by " + comp.closedBy + " • " + comp.formatToLocale(comp.closedDate);
            try {
                this.handleUnsubscribe();
            } catch (err) {
                // fail silently
            }
        }
    }

    getChatter() {
        getChatterMessages({ sessionId: this.sessionId, caseId: this.recordId, lastMessageTime: this.mostRecentMessage })
            .then((result) => {
                if (result.Id) {
                    this.session = { ...result };
                    this.sessionId = this.session.Id;
                    this.startedBy = this.session.CreatedBy.Name;

                    if (this.session.Feeds) {
                        this.messages = this.messages.concat(this.session.Feeds);
                        this.mostRecentMessage = this.messages[this.messages.length - 1].CreatedDate;
                        this.messages.forEach((message) => {
                            if (this.isSystemMessage(message)) {
                                message.Body = message?.Body.startsWith("<b>") && message?.Body.endsWith("</b>") ? message.Body : "<b>" + message.Body + "</b>"; //make system messages bolded
                                message.InsertedBy.Name = this._systemInsertedByName;
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound systemMessageColor";
                            } else if (Id === message.CreatedById || Id === message.InsertedById) {
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_outbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_outbound";
                            } else {
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound blueContrast";
                            }
                        });
                        setTimeout(() => {
                            let lastIndex = this.messages.length - 1;
                            this.scrollToMessage(this.messages[lastIndex].Random_Gen__c);
                        }, 500);
                    }

                    if (this.session.PC_Is_Closed__c) {
                        this.isClosed = true;
                        this.closedBy = this.session.PC_Closed_By__r.Name;
                        this.closedDate = this.session.PC_Closed_Date__c;
                        clearInterval(this.getMessageInterval);

                        this.transcript += "Chat started by " + this.startedBy + " • " + this.formatToLocale(this.session.CreatedDate) + "\n\n\n";
                        if (this.messages.length) {
                            this.messages.forEach((message) => {
                                var insertedBy = "";
                                if (this.isSystemMessage(message)) {
                                    insertedBy = this._systemInsertedByName;
                                } else {
                                    insertedBy = message.InsertedBy.Name;
                                }
                                this.transcript += insertedBy + " • " + this.formatToLocale(message.CreatedDate) + "\n" + message.Body + "\n\n";
                            });
                        }
                        this.transcript += "\nChat ended by " + this.closedBy + " • " + this.formatToLocale(this.closedDate);
                    } else {
                        this.handleSubscribe(this);
                    }
                }
            })
            .catch((error) => {
                if (this.errorCounter % 10 === 0) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            message: error.body ? error.body.message : error.message,
                            title: "Error occurred trying to retrieve chat",
                            variant: "error",
                            mode: "sticky"
                        })
                    );
                }
                this.errorCounter++;
            });
    }

    getChatterCache() {
        if (this.sessionId) {
            getChatterMessagesCache({ sessionId: this.sessionId, lastMessageTime: this.mostRecentMessage })
                .then((result) => {
                    this.isClosed = result.isClosed;
                    this.closedBy = result.closedBy;
                    this.closedDate = result.closedDate;
                    if (result.recipientId != null && result.recipientId !== Id) {
                        this.recipientName = result.recipientName;
                        this.isRecipientChatting = true;
                    }
                    let chatList = [...result.chatList];
                    if (chatList !== undefined && chatList.length) {
                        this.messages = this.messages.concat(chatList);
                        this.mostRecentMessage = this.messages[this.messages.length - 1].CreatedDate;
                        this.messages.forEach((message) => {
                            if (this.isSystemMessage(message.Body)) {
                                message.Body = message?.Body.startsWith("<b>") && message?.Body.endsWith("</b>") ? message.Body : "<b>" + message.Body + "</b>"; //make system messages bolded
                                message.InsertedBy.Name = this._systemInsertedByName;
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound systemMessageColor";
                            } else if (Id === message.CreatedById || Id === message.InsertedById) {
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_outbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_outbound";
                            } else {
                                message.listClasses = "slds-chat-listitem slds-chat-listitem_inbound";
                                message.messageClasses = "slds-chat-message__text slds-chat-message__text_inbound blueContrast";
                            }
                        });
                        setTimeout(() => {
                            let lastIndex = this.messages.length - 1;
                            this.scrollToMessage(this.messages[lastIndex].Random_Gen__c);
                        }, 500);
                    }

                    if (this.isClosed) {
                        this.transcript += "Chat started by " + this.startedBy + " • " + this.formatToLocale(this.session.CreatedDate) + "\n\n\n";
                        this.messages.forEach((message) => {
                            var insertedBy = "";
                            if (this.isSystemMessage(message.Body)) {
                                insertedBy = this._systemInsertedByName;
                            } else {
                                insertedBy = message.InsertedBy.Name;
                            }
                            this.transcript += insertedBy + " • " + this.formatToLocale(message.CreatedDate) + "\n" + message.Body + "\n\n";
                        });
                        this.transcript += "\nChat ended by " + this.closedBy + " • " + this.formatToLocale(this.closedDate);
                        try {
                            this.handleUnsubscribe();
                        } catch (err) {
                            // fail silently
                        }
                    }
                })
                .catch(() => {
                    //If there is error with cache, fetch chat list from database
                    this.getChatter();
                });
        }
    }

    handleCopy() {
        try {
            navigator.clipboard.writeText(this.transcript);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "",
                    message: "Copied",
                    variant: "success"
                })
            );
        } catch {
            let tempTextAreaField = document.createElement("textarea");
            tempTextAreaField.style = "position:fixed;top:-5rem;height:1px;width:10px;";
            tempTextAreaField.value = this.transcript;
            document.body.appendChild(tempTextAreaField);
            tempTextAreaField.select();
            document.execCommand("copy");
            tempTextAreaField.remove();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: "",
                    message: "Copied",
                    variant: "success"
                })
            );
        }
    }

    formatToLocale(dt) {
        var date = new Date(dt);
        return date.toString();
    }

    handleChange(event) {
        this.newMessage = event.target.value;
    }

    handleKeyDown() {
        // Notifies reciever that the Specialist has entered the chat.
        if (isSpecialist && !this.hasEnteredChatPublished) {
            this.hasEnteredChatPublished = true;
            let tempMessage = "";
            saveChatterMessage({ sessionId: this.sessionId, message: tempMessage, chatPushEventId: this.pushEventId })
                .then((result) => {
                    this.pushEventId = result;
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    this.newMessage = tempMessage;
                });
        }
    }

    handleSendMessage(event) {
        if (this.newMessage && (event.key === "Enter" || event.keyCode === 13 || event.target.dataset.id === "button")) {
            let tempMessage = this.newMessage;
            this.newMessage = "";
            saveChatterMessage({ sessionId: this.sessionId, message: tempMessage, chatPushEventId: this.pushEventId })
                .then((result) => {
                    this.pushEventId = result;
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                    this.newMessage = tempMessage;
                });
        }
    }

    handleEndChat() {
        this.showSpinner = true;
        closeChatSession({ sessionId: this.sessionId })
            .then(() => {
                this.isClosed = true;
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        message: error.body ? error.body.message : error.message,
                        title: "Error occurred trying to end the chat",
                        variant: "error",
                        mode: "sticky"
                    })
                );
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    scrollToMessage(messageId) {
        try {
            this.template.querySelector('[data-id="' + messageId + '"]').scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
        } catch (e) {}
    }

    isSystemMessage(message) {
        if (
            message.insertedBy === this._systemInsertedByName ||
            message.InsertedBy.Name === this._systemInsertedByName ||
            message.Body == this.systemMessages[0] ||
            (message.Body.startsWith("-*-") && message.Body.endsWith("-*-"))
        ) {
            return true;
        } else {
            return false;
        }
    }

    playMessageSound() {
        let cacheBuster = new Date().getTime();
        let audio = new Audio("/resource/" + cacheBuster + "/PC_ChatMessageSound");
        audio.load();
        audio.play();
    }
}
