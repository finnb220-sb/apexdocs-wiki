import { LightningElement, track, api } from "lwc";
import getTemplateInfo from "@salesforce/apex/VCC_HeartbeatTemplateController.getTemplateInfo";
import saveTemplateInfo from "@salesforce/apex/VCC_HeartbeatTemplateController.saveTemplateInfo";
import runTest from "@salesforce/apex/VCC_HeartbeatTemplateController.runTest";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import search from "@salesforce/apex/VCC_HeartbeatTemplateController.search";

export default class VccHeartbeatTemplate extends NavigationMixin(LightningElement) {
    @api templateId;
    @track info;
    @track isBusy = false;
    @track selectedTab = "info";
    @track paramList = [];
    @track canTest = false;
    @track canSave = false;
    @track endpoint = "";
    @track result = new Object();
    @track hasResult = false;

    isMultiEntry = false;
    maxSelectionSize = 5;
    errors = [];
    results = [];
    selection = [];

    connectedCallback() {
        this.setBusy(true);
        this.credential = new Object();
        this.info = new Object();
        this.canTest = false;
        if (!this.canTest) this.templateId = "";

        getTemplateInfo({ recordId: this.templateId })
            .then((response) => {
                this.processResponse(response);
            })
            .catch((error) => {
                //this.notifyUser('Persona Error', 'An error occured while retrieving the personas.', 'error');
                this.setBusy(false);
            });
    }

    processResponse(response) {
        this.info = JSON.parse(response);
        this.templateId = this.info.id;
        this.canTest = this.info.endpoint && this.info.endpoint.length > 0;

        var items = [];
        for (var i = 0; i < this.info.params.length; i++) {
            let param = new Object();
            param.row = "PARAM-" + i;
            param.name = this.info.params[i].name;
            param.dataType = this.info.params[i].dataType;
            param.isRequired = this.info.params[i].isRequired;
            param.format = this.info.params[i].format;
            param.description = this.info.params[i].description;

            items.push(param);
        }

        this.paramList = items;
        this.resetTypes();
        this.setBusy(false);
    }

    addNewParam(event) {
        let param = new Object();
        param.row = "PARAM-" + this.paramList.length;
        param.name = "";
        param.dataType = "String";
        param.isRequired = false;
        param.format = "";
        param.description = "";
        this.paramList.push(param);
        this.resetTypes();
        this.canSave = false;
    }

    handleLookupSearch(event) {
        const lookupElement = event.target;
        search(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.canSave = false;
                this.canTest = false;
                this.notifyUser("Lookup Error", "An error occured while searching named credentials.", "error");
                // eslint-disable-next-line no-console
                console.error("Lookup error", JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleLookupSelectionChange(event) {
        this.canTest = false;
        this.canSave = false;
        this.info.endpoint = "";
        this.endpoint = "";
        this.selection = this.template.querySelector("c-vcc-lookup").getSelection();
        if (this.selection.length > 0) {
            this.info.endpoint = this.selection[0].id;
            this.endpoint = this.selection[0].id;
        }
    }

    handleLookupTypeChange(event) {
        this.errors = [];
    }

    handleClear() {
        this.template.querySelector("c-vcc-lookup").clearSelection();
        this.errors = [];
    }

    onRemoveClick(event) {
        this.paramList.splice(event.target.dataset.id, 1);
        this.resetTypes();
        this.canSave = false;
    }

    onTextChange(event) {
        if (!event.target.dataset.name) return;

        if (event.target.dataset.name == "templateName") {
            this.info.name = event.target.value;
        }

        if (event.target.dataset.name == "templatePath") {
            this.info.path = event.target.value;
        }

        if (event.target.dataset.name == "templateMethod") {
            this.info.method = event.target.value;
        }

        if (event.target.dataset.name == "templateResponse") {
            this.info.expectedResponse = event.target.value;
        }

        if (event.target.dataset.name == "templateSchedule") {
            this.info.schedule = event.target.value;
        }

        let index = event.target.dataset.index;
        if (event.target.dataset.name == "name") {
            this.paramList[index].name = event.target.value;
        }

        if (event.target.dataset.name == "desc") {
            this.paramList[index].description = event.target.value;
        }

        if (event.target.dataset.name == "format") {
            this.paramList[index].format = event.target.value;
        }

        if (event.target.dataset.name == "value") {
            this.paramList[index].value = event.target.value;
        }

        if (event.target.dataset.name == "type") {
            this.paramList[index].dataType = event.target.value;
            this.resetTypes();
        }
    }

    resetTypes() {
        for (var i = 0; i < this.paramList.length; i++) {
            this.setParamType(i, this.paramList[i].dataType);
        }
    }

    setParamType(i, value) {
        this.paramList[i].isString = false;
        this.paramList[i].isNumber = false;
        this.paramList[i].isDate = false;
        this.paramList[i].isDateTime = false;
        this.paramList[i].isBoolean = false;
        this.paramList[i].isArray = false;

        if (value === "String") this.paramList[i].isString = true;
        if (value === "Date") this.paramList[i].isDate = true;
        if (value === "Date/Time") this.paramList[i].isDateTime = true;
        if (value === "Number") this.paramList[i].isNumber = true;
        if (value === "Boolean") this.paramList[i].isBoolean = true;
        if (value === "Array") this.paramList[i].isArray = true;
    }

    onRequiredClick(event) {
        let index = event.target.dataset.index;
        this.paramList[index].isRequired = event.target.checked;
    }

    onNextClick(event) {
        this.canTest = false;
        if (event.target.dataset.id == "infoNext") {
            if (this.templateDetailsAreGood(true)) {
                this.selectedTab = "params";
            }
        }

        if (event.target.dataset.id == "paramsNext") {
            if (this.parametersAreGood(true)) {
                this.canTest = true;
                setTimeout(() => {
                    this.selectedTab = "test";
                });
            }
        }
    }

    onPreviousClick(event) {
        this.setBusy(true);

        if (event.target.dataset.id == "paramsPrevious") {
            this.selectedTab = "info";
        }

        this.setBusy(false);
    }

    onCancel(event) {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: "VCC_Heartbeat_Template__c",
                actionName: "list"
            },
            state: {
                filterName: "Recent"
            }
        });
    }

    onSave(event) {
        this.setBusy(true);

        if (!this.templateDetailsAreGood(true)) {
            this.selectedTab = "info";
            this.notifyUser("Required Fields Missing", "Please provide all required fields in the template details.", "error");
            this.setBusy(false);
            this.canSave = false;
        }

        if (!this.parametersAreGood(true)) {
            this.selectedTab = "params";
            this.notifyUser("Required Fields Missing", "Please provide all required fields in the parameter list.", "error");
            this.setBusy(false);
            this.canSave = false;

            return;
        }

        this.info.params = this.paramList;
        saveTemplateInfo({ data: JSON.stringify(this.info) })
            .then((response) => {
                this.processResponse(response);
            })
            .catch((error) => {
                this.notifyUser("Save Template Error", "An error occured while saving the template.", "error");
                this.setBusy(false);
            });
    }

    runSampleTest(event) {
        this.setBusy(true);
        this.result = new Object();
        this.hasResult = false;

        let testInfo = new Object();
        testInfo.id = this.info.id;
        testInfo.endpoint = this.info.endpoint;
        testInfo.method = this.info.method;
        testInfo.params = [];
        testInfo.path = this.info.path;
        testInfo.expectedResponse = this.info.expectedResponse;

        for (var i = 0; i < this.paramList.length; i++) {
            let param = new Object();
            param.name = this.paramList[i].name;
            param.type = this.paramList[i].dataType;
            param.format = this.paramList[i].format;

            let inputName = "[data-name=" + this.paramList[i].name + "]";
            param.value = this.template.querySelector(inputName).value;
            testInfo.params.push(param);
        }

        console.log("***TEST:" + JSON.stringify(testInfo));

        runTest({ testData: JSON.stringify(testInfo) })
            .then((response) => {
                this.result = JSON.parse(response);
                this.hasResult = true;
                this.canSave = this.result.success;
                this.setBusy(false);
            })
            .catch((error) => {
                this.setBusy(false);
                this.notifyUser("API Error", "An error occured while attempting to run the template.", "error");
            });
    }

    templateDetailsAreGood(highlight) {
        if (!this.info.name || this.info.name.length === 0) {
            if (highlight) {
                this.selectedTab = "info";
                setTimeout(() => {
                    this.template.querySelector('[data-id="templateName"]').focus();
                    this.template.querySelector('[data-id="templateDesc"]').focus();
                    this.template.querySelector('[data-id="templateName"]').focus();
                });
            }

            return false;
        }

        if (!this.info.endpoint || this.info.endpoint.length == 0) {
            if (highlight) {
                this.selectedTab = "info";
                setTimeout(() => {
                    this.template.querySelector("c-vcc-lookup")?.focus();
                    this.template.querySelector('[data-id="templateName"]').focus();
                    this.template.querySelector("c-vcc-lookup").focus();
                });
            }
            return false;
        }

        return true;
    }

    parametersAreGood(highlight) {
        if (this.paramList.length == 0) return true;

        var item;
        for (var i = 0; i < this.paramList.length; i++) {
            item = this.paramList[i];

            if (!item?.name || item.name.length == 0) {
                if (highlight) {
                    setTimeout(() => {
                        this.template.querySelector('[data-id="' + item.row + '"]').focus();
                        this.template.querySelector('[data-check="' + item.row + '"]').focus();
                        this.template.querySelector('[data-id="' + item.row + '"]').focus();
                    });
                }
                return false;
            }
        }

        return true;
    }

    setBusy(busy) {
        this.isBusy = busy;
    }

    notifyUser(title, message, variant) {
        const toastEvent = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(toastEvent);
    }
}
