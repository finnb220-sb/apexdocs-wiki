({
    handleLocationChange: function (component, event, helper) {
        let clearTriageWrapper = component.find('clearTriageWrapper');
        clearTriageWrapper.locationChange(event);
    }
});
