({
    getMessageChannel: function () {
        return this.MessageChannel;
    },
    setClient: function (component, client) {
        component.set("v.client", client);
    },
    getClient: function (component) {
        return component.get("v.client");
    },
    openAlert: function (component) {
        if (component.get("v.isAlertActive") == true) {
            return;
        }
        if (component.get("v.alertShown") == true) {
            return;
        }
        component.set("v.isAlertActive", true);
        component.set("v.alertShown", true);
        this.LightningAlert.open({
            message: "Triage is incomplete, if you leave the progress note screen, you will lose any information you previously entered and will be forced to start a new triage.",
            theme: "warning",
            label: "Warning: Triage Incomplete"
        }).then((result) => {
            if (result == false) {
                history.go(-1);
            } else if (result == true) {
                component
                    .get("v.client")
                    .sendRequestTo(component.get("v.activeTxccClient"), {
                        action: "destroy"
                    })
                    .catch((e) => console.warn(e))
                    .finally(() => {
                        component.set("v.activeTxccClient", null);
                        component.set("v.alertShown", false);
                    });
            }
            component.set("v.isAlertActive", false);
        });
    },
    onBeforeUnload: function (event) {
        event.returnValue = "TXCC Session Will Be Lost";
    },
    getHref: function () {
        return window.location.href;
    },
    resetState: function (component) {
        window.removeEventListener("beforeunload", this.onBeforeUnload);
        component.set("v.activeTxccClient", null);
        component.set("v.activeRecordId", null);
        component.set("v.alertShown", false);
    }
});
