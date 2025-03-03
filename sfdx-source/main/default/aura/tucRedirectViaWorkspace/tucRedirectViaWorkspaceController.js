({
    invoke: function (component) {
        var recordId = component.get("v.recordId");
        var objectName = component.get("v.recordObject");
        var workspaceAPI = component.find("workspace");
        workspaceAPI
            .getFocusedTabInfo()
            .then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.openSubtab({
                    parentTabId: focusedTabId,
                    url: "/lightning/r/" + objectName + "/" + recordId + "/view",
                    focus: true
                });
            })
            .catch(function (error) {
                console.log(error);
            });
    }
});
