/* eslint-disable no-undef */
({
    handleMessage: function (component, message) {
        if (message && message.getParam("recordId")) {
            if (component.get("v.recordId") == message.getParam("recordId") && component.get("v.componentName") == message.getParam("componentName")) {
                $A.get("e.force:refreshView").fire();
            }
        }
    }
});
