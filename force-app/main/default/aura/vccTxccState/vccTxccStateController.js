({
    doInit: function (component, event, helper) {
        let vccMessageChannel = helper.getMessageChannel();
        helper.setClient(
            component,
            vccMessageChannel.createClient(
                "txccState",
                (msg) => {
                    let actionName = msg.payload.action;
                    if (actionName == "triageStarted") {
                        component.set("v.activeTxccClient", msg.payload.clientName);
                        component.set("v.activeRecordId", msg.payload.recordId);
                        window.addEventListener("beforeunload", helper.onBeforeUnload);
                        msg.reply(true);
                    }
                    if (actionName == "triageComplete") {
                        helper.resetState(component);
                        msg.reply(true);
                    }
                    if (actionName == "isTxccActive") {
                        let activeClient = component.get("v.activeTxccClient");
                        let activeRecordId = component.get("v.activeRecordId");
                        if (activeClient != null || activeClient != undefined) {
                            msg.reply(true);
                        } else {
                            msg.reply(false);
                        }
                    }
                    if (actionName == "destroy") {
                        helper
                            .getClient(component)
                            .sendRequestTo(component.get("v.activeTxccClient"), {
                                action: "destroy"
                            })
                            .catch((e) => console.warn(e))
                            .finally(() => {
                                helper.resetState(component);
                            });
                    }
                },
                true
            )
        );
    },
    handleLocationChange: function (component, event, helper) {
        //console.log(JSON.parse(JSON.stringify(event.getParams())));
        let activeClient = component.get("v.activeTxccClient");
        let activeRecordId = component.get("v.activeRecordId");
        if (typeof activeClient != "string" || activeClient.length == 0) {
            return;
        }
        if (typeof activeRecordId != "string" || activeRecordId.length == 0) {
            return;
        }
        if (helper.getHref().includes(activeRecordId)) {
            window.removeEventListener("beforeunload", helper.onBeforeUnload);
            window.addEventListener("beforeunload", helper.onBeforeUnload);
            component.set("v.alertShown", false);
            return;
        }
        if (helper.getHref().includes("VCC_Progress_Note__c") && helper.getHref().search("VCC_Progress_Note__c/[a-zA-Z0-9]{18}") != -1) {
            helper
                .getClient(component)
                .sendRequestTo(component.get("v.activeTxccClient"), {
                    action: "destroy"
                })
                .catch((e) => console.warn(e))
                .finally(() => {
                    component.set("v.activeTxccClient", null);
                    component.set("v.activeRecordId", null);
                    component.set("v.alertShown", false);
                });
        } else {
            helper.openAlert(component);
            window.removeEventListener("beforeunload", helper.onBeforeUnload);
        }
    }
});
