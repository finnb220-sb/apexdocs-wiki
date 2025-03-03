({
    init: function (component, helper) {
        let flagForFocus = false;
        window.addEventListener("keydown", (event) => {
            console.log("ZN:: A key has been pressed!!");
            const isTabPressed = event.key === "Tab" || event.keyCode === 9;
            //? we only care about when the tab key is pressed
            if (!isTabPressed) return;

            //? once we have entered the modal, we should remain in the modal
            if (flagForFocus) {
                helper.trapFocus(event);
                return;
            }

            const theActiveElement = document.activeElement;
            const activeElementString = theActiveElement.toString();
            console.log("activeElementString: ", activeElementString);
            if (activeElementString === undefined) return;

            //? check for background elements with values that are not from the modal
            if (activeElementString.includes("https") || activeElementString.includes("javascript:void(0)") || activeElementString.includes("HTMLBodyElement")) {
                helper.assignFocus(event);
                flagForFocus = true;
            }
        });

        window.addEventListener(
            "message",
            (event) => {
                if (event.data == "showVerifyCaller") {
                    component.set("v.isShowPopup", true);
                    var flow = component.find("flowData");
                    var inputVariables = [
                        {
                            name: "recordId",
                            type: "String",
                            value: component.get("v.recordId")
                        }
                    ];
                    try {
                        if (flow != undefined && flow != null) {
                            flow.startFlow("VCC_Verify_Caller_2", inputVariables);
                        }
                    } catch (event) {}
                }
                if (window.location.href.indexOf("flexipageEditor/surface.app") != -1) {
                    component.set("v.isShowPopup", false);
                }
            },
            false
        );
        if (window.location.href.indexOf("flexipageEditor/surface.app") != -1) {
            component.set("v.isShowPopup", false);
        }
        // window.postMessage('showVerifyCaller','*');
        // component.set('v.isShowPopup', true);
    },
    statusChange: function (cmp, event) {
        console.log(event.getParam("status"));
        console.log(JSON.stringify(event.getParam("outputVariables")));
        if (event.getParam("status") === "FINISHED") {
            cmp.set("v.isShowPopup", false);
            window.postMessage("showDeceasedPatient", "*");
            window.postMessage("verifyPatientComplete", "*");
        }
    },
    closePopup: function (cmp) {
        cmp.set("v.isShowPopup", false);
    }
});
