/*helper imports*/
import { api, LightningElement, track, wire } from "lwc";
import * as helper from "./labHelper";
import { mainRef, molRef, paxRef, apiNames } from "./labHelper";
import { labMockData } from "./mock.js";
import getLabs from "@salesforce/apex/VCC_LabController.getLabs";
import noResultsMessage from "@salesforce/label/c.VCC_Generic_message_for_null_search_results";
import noResultsSubMessage from "@salesforce/label/c.VCC_Generic_sub_message_for_null_search_results";
import genericError from "@salesforce/label/c.VCC_Generic_Error";
import genericSubError from "@salesforce/label/c.VCC_Generic_Sub_error";
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from "lightning/flowSupport";
import { APPLICATION_SCOPE, MessageContext, publish, subscribe, unsubscribe } from "lightning/messageService";
import allergiesMC from "@salesforce/messageChannel/vccAddToNoteAllergies__c";
import ALLERGIES_FIELD from "@salesforce/schema/VCC_Progress_Note__c.VCC_Allergies__c";
import MEDICATION_FIELD from "@salesforce/schema/VCC_Progress_Note__c.VCC_Medications__c";
import { flattenLabs } from "c/vccLab";

export default class VccAllergyTestToTreat extends LightningElement {
    @api recordId;
    progress = 0;

    componentTitle = "T2T Labs";
    @api useMockData;
    columns = helper.columns;
    @api flexipageRegionWidth;
    settings = {
        title: "T2T Labs",
        icon: "standard:metrics"
    };

    labLighntingReqWrp = {};
    @track labRes;
    @track labList;
    @track labSelected;
    @track isShowSpinner;
    @track totalRecords = 0;
    @track pageSize = 10;
    @track currentPage = 1;
    @track totalPageSize;
    @track isLastPage;
    @track isFirstPage;
    @track sortedField;
    @track sortDirection;
    @track previewArray;
    @track response = [];
    filterList = helper.labReference;

    _labList = [];
    _labListTemp = [];
    _labListTransfer = [];

    _sortItems = "Date";
    _oldSortItems = "Date";
    _sortOrder = "Desc";
    selectedrowindex;
    _startDateSelected;
    _endDateSelected;
    searchTerm = "";
    _searchResult = [];
    @track all = [];
    @track selectedLab;

    isEmpty = false;
    hasError = false;
    emptyMessage = "No Labs Returned In Search";
    genericError = genericError;

    displayAddToNoteButton = false;

    noResults = false;
    noConnection = false;
    labels = {
        noResultsMessage: noResultsMessage,
        noResultsSubMessage: noResultsSubMessage,
        noConnectionMessage: genericError,
        noConnectionSubMessage: genericSubError
    };

    subscription = null;
    Allergy;
    allergyPrev;
    Prescriptions;
    prescriptionPrev;
    Review;
    Preview;
    @track allergies = ALLERGIES_FIELD;
    @track prescriptions = MEDICATION_FIELD;
    @api flowStageTest2Treat;
    @api lwcOutput;
    @track receivedMessage = "";
    @track myMessage = "";
    @api objectApiName = "VCC_Progress_Note__c";
    data = [];
    @track _newString = [false, false, "", "", "", "test", 0];
    outputTextValue = "";

    @api progressNoteJson;
    @api mainKey = [];
    @api paxKey = [];
    @api molKey = [];
    @api allLabels = [];
    showExpandButton = false;
    isModalOpen = false;
    @track medArray = [];
    @track disArray = [];
    @track allArray = [];
    mainLabel = [];
    paxLabel = [];
    molLabel = [];
    handleExpandClick() {
        this.isModalOpen = true;
        this.fullPayload = JSON.stringify(this.progressNoteJson, null, 4);
    }

    handleCloseClick() {
        this.isModalOpen = false;
    }

    handleEscapeKey(event) {
        if (event.keyCode === 27) {
            this.isModalOpen = false;
        }
    }
    @api
    getLabsJS() {
        var date = new Date();
        date.setFullYear(date.getFullYear() - 2);
        let currentYear = date.getFullYear();
        this.showLoding();
        this.labLighntingReqWrp = {
            recordId: this.recordId,
            facility: "613",
            startDate: currentYear + "-01-01",
            endDate: "2050-01-01"
        };
        if (!this.useMockData) {
            getLabs({ labReqWrp: this.labLighntingReqWrp })
                .then((result) => {
                    this.processResult(result);
                })
                .catch((result) => {
                    console.error(result);
                    this.noConnection = true;
                    this.hideLoding();
                });
        } else {
            let result = labMockData;
            this.processResult(result);
        }
    }
    processResult(result) {
        this.labRes = result;
        let labList = result.labModal.sites
            .map((site) => {
                if (site?.results?.labs?.lab.length) {
                    return site.results.labs.lab;
                }
                return [];
            })
            .filter(Boolean)
            .flat();

        if (!labList?.length) {
            this.isEmpty = true;
            this.hideLoding();
            return;
        }

        labList.sort(function (a, b) {
            return new Date(b.collected.collectedDate) - new Date(a.collected.collectedDate);
        });

        for (let i = 0; i < labList.length; i++) {
            labList[i].key = "Key" + i;
        }

        this._labList = labList;
        this._labList = flattenLabs(labList);
        this.all = this._labList;
        this._labListTemp = this._labList;

        //this.noResults = false;
        this._labListTransfer = this._labListTemp.filter((test) => this.filterList.some((filterList) => filterList.test === test.test));
        this._labList = this._labListTransfer;
        this.totalRecords = this._labList.length;
        if (this._labList.length !== 0) {
            console.log(this.totalRecords);
            this.setRecords();
            this.hideLoding();
            const outputArray = this._labList.map(({ test, collectedDate, result, status, sample, provider }) => ({
                test,
                collectedDate,
                result,
                status,
                sample,
                provider
            }));
            const arrLabs = JSON.stringify(outputArray.map((obj) => Object.values(obj).join("---")));
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", arrLabs);
            this.dispatchEvent(attributeChangeEvent);
        } else {
            this.noResults = true;
            this.hideLoding();
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", "No results returned in this search");
            this.dispatchEvent(attributeChangeEvent);
        }
    }
    setRecords() {
        let labList = this._labList;
        let startPageIndex;
        let currentPage = this.currentPage - 1;
        if (currentPage == 0) {
            startPageIndex = currentPage;
        } else {
            startPageIndex = currentPage * this.pageSize;
        }
        let endPageIndex = startPageIndex + this.pageSize;
        labList = labList.slice(startPageIndex, endPageIndex);
        this.totalPageSize = Math.ceil(this.totalRecords / this.pageSize);
        this.labList = labList;
    }
    handleNextPage() {
        if (this.currentPage < this.totalPageSize) {
            this.currentPage = this.currentPage + 1;
        }
        this.handlePageChange();
    }
    handlePrevPage() {
        if (this.currentPage > 1) {
            this.currentPage = this.currentPage - 1;
        }
        this.handlePageChange();
    }
    handlePageChange() {
        this.setRecords();
        this.updatePageButtons();
    }
    updatePageButtons() {
        if (this.currentPage === 1) {
            this.isFirstPage = true;
        } else {
            this.isFirstPage = false;
        }
        if (this.currentPage >= this.totalPageSize) {
            this.isLastPage = true;
        } else {
            this.isLastPage = false;
        }
    }

    handleSort(event) {
        this.currentPage = 1;
        helper.sortFlatList(this._labList, event.detail.fieldName, event.detail.sortDirection);
        this.sortedField = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.handlePageChange();
    }

    showLoding() {
        this.isShowSpinner = true;
    }
    hideLoding() {
        this.isShowSpinner = false;
    }

    handleRowSelected(event) {
        this.selectedLab = event.detail;
        const modal = this.template.querySelector("c-base-modal");
        modal.open(this.template.host);
    }
    /*
    getters and setters persistent storage
     */
    initMethod() {
        this.newString[4] = this.recordId;
        this.newString[5] = this.recordId + "T2T";
        this.newString[6] = this.flowStageTest2Treat;
    }
    @api
    get newString() {
        return this._newString;
    }
    set newString(newString = []) {
        this._newString = [...newString];
    }
    handleNavigation() {
        if (this.newString[0] === "true" && this.flowStageTest2Treat === 1) {
            this.allergyPrev = true;
            this.outputTextValue = this._newString[2];
            let value = this.outputTextValue;
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
            this.dispatchEvent(attributeChangeEvent);
        } else if (this.newString[1] === "true" && this.flowStageTest2Treat === 2) {
            this.prescriptionPrev = true;
            this.outputTextValue = this._newString[3];
            let value = this.outputTextValue;
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
            this.dispatchEvent(attributeChangeEvent);
        } else {
            this.prescriptionPrev = false;
            this.allergyPrev = false;
        }
    }
    handleEvent(event) {
        if (event.target.dataset.name === "VCC_Allergies__c") {
            this.newString[2] = event.target.value;
            this.newString[0] = true;
        } else if (event.target.dataset.name === "VCC_Medications__c") {
            this.newString[3] = event.target.value;
            this.newString[1] = true;
        }
    }
    handleChange(evt) {
        if (evt.target.value) {
            let value = evt.target.value;
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
            this.dispatchEvent(attributeChangeEvent);
            this.myMessage = evt.target.value;
        } else if (evt.target.value === "") {
            let value = "delete";
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
            this.dispatchEvent(attributeChangeEvent);
            this.myMessage = evt.target.value;
        } else {
            let value = evt.target.value;
            const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
            this.dispatchEvent(attributeChangeEvent);
            this.myMessage = evt.target.value;
        }
        this.handleEvent(evt);
        const message = {
            messageToSend: this.myMessage,
            sourceSystem: "From Covid Test to Treat"
        };
        publish(this.messageContext, allergiesMC, message);
    }
    @api handleGoNext() {
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
    onHandleFlowScreen() {
        switch (this.flowStageTest2Treat) {
            case 1:
                this.clear();
                this.handleNavigation();
                this.Allergy = !this.allergyPrev;
                this.Prescriptions = false;
                this.Review = false;
                this.Preview;
                break;
            case 2:
                this.clear();
                this.handleNavigation();
                this.Allergy = false;
                this.Prescriptions = !this.prescriptionPrev;
                this.Review = false;
                this.Preview = false;
                break;
            case 3:
                this.clear();
                this.handleNavigation();
                this.Allergy = false;
                this.Prescriptions = false;
                this.Review = true;
                this.Preview = false;
                this.getLabsJS();
                this.labels.noResultsMessage = noResultsMessage.replace("{0}", this.componentTitle);
                this.labels.noConnectionMessage = genericError.replace("{0}", "Connection Error");
                break;
            case 4:
                this.clear();
                this.handleNavigation();
                this.Allergy = false;
                this.Prescriptions = false;
                this.Review = false;
                this.Preview = true;
                this.storeFlowInputs();
                this.handleProgress();
                break;
            default:
                this.clear();
                this.handleNavigation();
                this.Allergy = false;
                this.Prescriptions = false;
                this.Review = false;
                this.Preview = false;
                break;
        }
    }
    storeFlowInputs() {
        function generateUniqueId() {
            const timestamp = Date.now().toString(36);
            const randomString = Math.random().toString(36).substring(2, 8);
            return timestamp + randomString;
        }
        let _mainKey = [...this.mainKey].map((value) => (value === "" ? null : value));
        let _paxKey = [...this.paxKey].map((value) => (value === "" ? null : value));
        let _molKey = [...this.molKey].map((value) => (value === "" ? null : value));
        let _allLabels = [...this.allLabels];
        _allLabels.splice(0, 1); // Remove the value at index 0
        _allLabels = _allLabels.map((value) => {
            return value;
        });
        if (_molKey.length === 0) {
            this.mainLabel = _allLabels.slice(0, 4); // Array containing values from index 0 to 3 (inclusive)
            this.paxLabel = _allLabels.slice(4, 35); // Array containing values from index 4 to 34 (inclusive)
            this.molLabel = [];
        } else if (_paxKey.length === 0) {
            this.mainLabel = _allLabels.slice(0, 4); // Array containing values from index 0 to 3 (inclusive)
            this.molLabel = _allLabels.slice(4, 35); // Array containing values from index 4 to 34 (inclusive)
            this.paxLabel = [];
        } else {
            this.mainLabel = _allLabels.slice(0, 4); // Array containing values from index 0 to 3 (inclusive)
            this.paxLabel = _allLabels.slice(4, 35); // Array containing values from index 4 to 34 (inclusive)
            this.molLabel = _allLabels.slice(35, 66); // Array contatining values from index 35 to 65 (inclusive)
        }
        const finalmainKey = mainRef.map((obj, index) => {
            const { review } = obj;
            const response = _mainKey[index] !== undefined ? _mainKey[index] : null;
            const label = this.mainLabel[index] !== undefined ? this.mainLabel[index] : null;
            const id = generateUniqueId();
            /*Testing this feature for CCCM-10369*/
            const Index = index;
            const fieldName = apiNames[index].apiName;
            return { Index, fieldName, id, label, response, review };
        });

        const finalpaxKey = paxRef.map((obj, index) => {
            //offset index to access references
            let inTrack = index + 4;
            const { review } = obj;
            const response = _paxKey[index] !== undefined ? _paxKey[index] : null;
            const label = this.paxLabel[index] !== undefined ? this.paxLabel[index] : null;
            const id = generateUniqueId();
            /*Testing this feature for CCCM-10369*/
            const Index = inTrack;
            const fieldName = apiNames[inTrack].apiName;
            return { Index, fieldName, id, label, response, review };
        });

        const finalmolKey = molRef.map((obj, index) => {
            //offset index to access references
            let inTrack = index + 34;
            const { review } = obj;
            const response = _molKey[index] !== undefined ? _molKey[index] : null;
            const label = this.molLabel[index] !== undefined ? this.molLabel[index] : null;
            const id = generateUniqueId();
            /*Testing this feature for CCCM-10369*/
            const Index = inTrack;
            const fieldName = apiNames[inTrack].apiName;
            return { Index, fieldName, id, label, response, review };
        });

        const combinedArray = [...finalmainKey, ...finalpaxKey, ...finalmolKey].filter((obj) => obj.response !== null);
        const groupedArrays = combinedArray.reduce((acc, obj) => {
            const { id, review, label, response } = obj;
            if (review === "medical") {
                if (!acc.med) {
                    acc.med = [];
                }
                acc.med.push({ id, label, response });
            } else if (review === "disposition") {
                if (!acc.dis) {
                    acc.dis = [];
                }
                acc.dis.push({ id, label, response });
            }
            return acc;
        }, {});
        this.allArray = [...combinedArray];
        for (let i = 0; i < this.allArray.length; i++) {
            const item = this.allArray[i];
            item.response = item.response.replace(/(<([^>]+)>)/gi, ""); //remove formatting from responses
            item.label = item.label.replace(/(<([^>]+)>)/gi, ""); //remove formatting from labels
            //item.label = item.label.replace(/<\/?li>|<\/?ul>|<\/?strong>/gi, ''); //remove standard formatting
            //item.label = item.label.replace(/<strong style="font-size: 14px;">/gi, ''); //remove bad formatting from labels
            if (item.label === "" || item.response === "--" || item.response === "False") {
                //change here to drop additional items
                this.allArray.splice(i, 1);
                i--;
            }
        }
        this.processLabs(this.allArray);

        this.medArray = groupedArrays.med || [];
        this.disArray = groupedArrays.dis || [];
        const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", JSON.stringify(this.allArray));
        this.dispatchEvent(attributeChangeEvent);
    }
    processLabs(array) {
        function generateUniqueId() {
            const timestamp = Date.now().toString(36);
            const randomString = Math.random().toString(36).substring(2, 8);
            return timestamp + randomString;
        }
        const newArray = [];
        let labsIndex = -1;
        //check the index of the labs
        array.forEach((item, index) => {
            if (item.label === "Labs") {
                labsIndex = index;
            }
        });

        if (labsIndex !== -1) {
            array.forEach((item) => {
                if (item.response.startsWith("[") && item.response.endsWith("]") && item.label === "Labs") {
                    const labs = item.response.match(/"(.*?)"/g);
                    if (labs) {
                        labs.forEach((lab) => {
                            const trimmedLab = lab.replace(/"/g, "").trim();
                            if (trimmedLab !== "") {
                                newArray.push({ id: generateUniqueId(), label: " ", response: trimmedLab, review: "labs" });
                            }
                        });
                    } else {
                        newArray.push(item);
                    }
                }
            });
            if (newArray.length > 0) {
                newArray.splice(0, 0, { id: generateUniqueId(), label: " ", response: "TEST-------DATE-------RESULT-------STATUS-------SAMPLE-------PROVIDER", review: "labs" });
                newArray.splice(0, 0, { id: generateUniqueId(), label: "Recent Labs ", response: " ", review: "labs" });
            }
            array.splice(labsIndex, 1, ...newArray);
            console.log("ttd", array);
            return newArray;
        } else {
            return "No labs in this search";
        }
    }

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, allergiesMC, (message) => this.handleMessage(message), { scope: APPLICATION_SCOPE });
        }
    }
    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    handleMessage(message) {
        this.receivedMessage = message ? JSON.stringify(message, null, "\t") : "no message payload";
    }
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.initMethod();
        this.onHandleFlowScreen();
        document.addEventListener("keyup", this.handleEscapeKey.bind(this));
    }
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
        window.removeEventListener("keyup", this.handleEscapeKey);
    }
    clear() {
        let value = "";
        const attributeChangeEvent = new FlowAttributeChangeEvent("lwcOutput", value);
        this.dispatchEvent(attributeChangeEvent);
    }
    submit() {}
    handleProgress() {
        /*
        modify the duration of the loading bar here
         */
        const totalTime = 10000; // 10 seconds in milliseconds
        const steps = 100; // total steps from 0 to 100
        const intervalDuration = totalTime / steps;
        this._interval = setInterval(() => {
            this.progress = this.progress === 100 ? 0 : this.progress + 1;
        }, intervalDuration);
    }
}
