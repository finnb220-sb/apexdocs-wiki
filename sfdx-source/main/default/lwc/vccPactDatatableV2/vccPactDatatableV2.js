import { LightningElement, api, wire, track } from "lwc";
import { subscribe, MessageContext, unsubscribe } from "lightning/messageService";
import VCC_PROGRESS_NOTE_PACT_CHANNEL from "@salesforce/messageChannel/vccProgressNoteFlowPact__c";
import { parsePactJson } from "c/vccPactController";
import { teamMemberColumns, teamMemberTrunc, nonVAColumns, COLUMN_TEMPLATE } from "./columns";
import LoggerMixin from "c/loggerMixin";
import vccNoPactMessage from "@salesforce/label/c.vccNoPactMessage";
export default class VccPactDatatableV2 extends LoggerMixin(LightningElement) {
    subscription = null;
    @wire(MessageContext)
    messageContext;
    selectedSigners = [];

    @api
    noVaPactMsg = vccNoPactMessage;

    @api responseJSON;
    @api columnsTemplate;
    @api siteCode;
    @api enableAddSigners;
    @api truncateColumns;

    @track tableData = [];
    columns = [];
    patientSummary;
    member;
    patientSummaryRaw = "";
    cprsView = false;
    noVaProviders = false;
    initialized = false;
    pactData = {};
    /** Lifecycle Hooks */
    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        if (this.responseJSON === null || typeof this.responseJSON != "string") {
            return;
        }
        if (COLUMN_TEMPLATE[this.columnsTemplate] === undefined) {
            throw new Error("Invalid Columns Template");
        }

        this.initialized = true;
        this.pactData = parsePactJson(this.responseJSON, this.Logger);

        if (this.columnsTemplate === COLUMN_TEMPLATE.teamMemberColumns) {
            this.columns = this.truncateColumns ? teamMemberTrunc : teamMemberColumns;
            if (Array.isArray(this.pactData?.vaPact?.vaPactMembers)) {
                if (this.pactData?.vaPact?.vaPactMembers.length === 0) {
                    this.noVaProviders = true;
                } else {
                    this.tableData = this.generateVaTableData(this.pactData.vaPact.vaPactMembers);
                    this.subscribeToPactChannel(this.tableData);
                }
            }
        } else if (this.columnsTemplate === COLUMN_TEMPLATE.nonVAColumns) {
            this.columns = nonVAColumns;
            this.isNonVaProvider = true;
            this.tableData = this.generateNonVaTableData(this.pactData.nonVaPact);
        } else if (this.columnsTemplate === COLUMN_TEMPLATE.cprs) {
            this.patientSummaryRaw = this.pactData.cprsView;
            this.cprsView = true;
        }

        if (this.enableAddSigners === true || this.enableAddSigners === "true") {
            this.columns = [
                {
                    type: "dynamicButton",
                    fieldName: "dynamicButtonHook",
                    initialWidth: 50,
                    hideDefaultActions: true
                },
                ...this.columns
            ];

            this.template.dispatchEvent(
                new CustomEvent("pactconnected", {
                    detail: {
                        messageHandler: this.handleMessage.bind(this),
                        tableData: this.tableData
                    },
                    composed: true,
                    bubbles: true
                })
            );

            this.pub({ action: "get", providers: [] }); //asking for the list of signers when loaded
        }
    }

    disconnectedCallback() {
        this.unsubscribeFromPactChannel();
    }

    /** Methods */
    generateVaTableData(vaPactMembers) {
        return vaPactMembers.flatMap((pactMember) => {
            if (typeof this.siteCode === "string" && this.siteCode !== "") {
                if (!pactMember.station.stationNumber.includes(this.siteCode)) {
                    return [];
                }
            }

            let tableRow = {
                name: pactMember?.name,
                primaryCare: pactMember?.primaryCare,
                supportStaff: pactMember?.supportStaff,
                teamName: pactMember?.assignment?.teamName,
                assignmentStatus: pactMember?.assignment?.assignmentStatus,
                assignmentCategory: pactMember?.assignment?.assignmentCategory,
                stationNumber: pactMember?.station?.stationNumber,
                stationNameAndNumber: pactMember?.station?.stationNameAndNumber,
                parentStationNameRaw: pactMember?.station?.parentStationNameRaw,
                careType: pactMember?.assignment?.careType,
                teamFocus: pactMember?.assignment?.teamFocus,
                roleName: pactMember?.roleName,
                roleDescription: pactMember?.roleDescription,
                assignmentDate: pactMember?.assignment?.assignmentDate,
                phone: pactMember?.phone,
                pager: pactMember?.pager
            };

            if (this.enableAddSigners === false || this.enableAddSigners === "false") {
                return tableRow;
            }

            let buttonClick = (cell) => {
                if (cell.value.isAdd === true) {
                    this.doSignerAction("add", tableRow);
                } else {
                    this.doSignerAction("remove", tableRow);
                }
            };

            let dynamicButtonHook = {
                isLoading: false,
                isAdd: true,
                isDisabled: tableRow?.name == null || tableRow?.name === "" ? true : false,
                handleClick: function () {
                    tableRow.dynamicButtonHook.isLoading = true;
                    this.value = tableRow.dynamicButtonHook;
                    buttonClick(this);
                }
            };

            tableRow = { ...tableRow, dynamicButtonHook };

            return tableRow;
        });
    }

    generateNonVaTableData(nonVaPact) {
        let tableData = [];
        try {
            let recordCount = 0;

            if (nonVaPact) {
                nonVaPact.forEach((nonVAPCPRovider) => {
                    let obj = {};
                    obj.specialtyName = nonVAPCPRovider.specialtyName;
                    obj.teamName = nonVAPCPRovider.teamName;
                    obj.careCoordinatorName = nonVAPCPRovider.careCoordinatorName;
                    obj.providerName = nonVAPCPRovider.providerName;
                    obj.phone = nonVAPCPRovider.phone;
                    obj.city = nonVAPCPRovider.city;
                    obj.state = nonVAPCPRovider.state;
                    obj.practiceCity = nonVAPCPRovider.practiceCity;
                    obj.practiceState = nonVAPCPRovider.practiceState;
                    obj.assignmentDate = nonVAPCPRovider.assignmentDate;
                    obj.Category = nonVAPCPRovider.Category;
                    recordCount++;
                    obj.id = recordCount;

                    tableData.push(obj);
                });
            }
        } catch (e) {
            return [];
        }
        return tableData;
    }

    subscribeToPactChannel(tableData) {
        if (!this.subscription) {
            this.subscription = subscribe(this.messageContext, VCC_PROGRESS_NOTE_PACT_CHANNEL, (message) => this.refreshPact(message, tableData));
        }
    }

    refreshPact(message, tableData) {
        this.selectedSigners = message.selectedSigners;
        // updates provider button based on already selected signers list
        for (let j = 0; j < tableData.length; j++) {
            if (tableData[j].name) {
                let i = this.selectedSigners.indexOf(tableData[j].name);
                if (i != -1) {
                    tableData[j].dynamicButtonHook.isAdd = false;
                } else {
                    tableData[j].dynamicButtonHook.isAdd = true;
                }
            }
        }
        this.render();
    }

    unsubscribeFromPactChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    sortedBy;
    defaultSortDirection = "asc";
    sortDirection = "asc";

    handleSort(event) {
        /*
            Function to handle sorting of the meds list
 
            @param event       Standard event object
        */

        // set up sort variables and sort the meds list
        const { fieldName: sortedBy, sortDirection } = event.detail;

        /**
         * if the sort direction is the only changing parameter,
         * reversing the array accomplishes the desired result
         */
        if (sortedBy === this.sortedBy && sortDirection !== this.sortDirection) {
            this.tableData = [...this.tableData.reverse()];
        } else {
            this.tableData = [
                ...this.tableData.sort((a, b) => {
                    let aVal = a[sortedBy];
                    let bVal = b[sortedBy];

                    return this.compare(aVal, bVal) * (sortDirection === "asc" ? 1 : -1);
                })
            ];
        }

        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    compare(a, b) {
        let aString = String(a).trim();
        let bString = String(b).trim();

        if (aString === "" || aString === "null" || aString === "undefined") {
            if (bString === "" || bString === "null" || bString === "undefined") {
                return 0;
            }
            return 1;
        }

        if ((aString === "true" || aString === "false") && (bString === "true" || bString === "false")) {
            if (aString === bString) {
                return 0;
            } else if (aString === "true" && bString === "false") {
                return -1;
            }
            return 1;
        }

        return a === b ? 0 : a > b ? 1 : -1;
    }

    doSignerAction(action, signer) {
        let providerTO = {};
        ({
            name: providerTO.providername = null,
            duz: providerTO.duz = null,
            stationNumber: providerTO.loginSiteCode = null,
            providerTitle: providerTO.providertitle = null
        } = signer);
        this.pub({ action: action, providers: [providerTO] });
    }

    pub(message) {
        this.template.dispatchEvent(
            new CustomEvent("message", {
                detail: {
                    message: message
                },
                composed: true,
                bubbles: true
            })
        );
    }

    /** Handlers */
    currentPatientData;

    handleRowAction(event) {
        /*
            Function to handle row actions defined in the columns variable. Performs logic based
            on the name of the action
 
            @param event     The event object
        */

        // get row action name
        var action = event.detail.action.name;
        // if row action = rxDetails, set currentRx to current row and displayCurrentRx to true
        // to display details in UI on current rx
        if (action === "displayStationDetails") {
            this.currentPatientData = event.detail.row;
            this.template.querySelector("c-vcc-pact-details").open(event.target);
        }
    }

    @api
    handleMessage(message) {
        switch (message.result) {
            case "added":
                this.handleAdded(message.providers);
                break;
            case "removed":
                this.handleRemoved(message.providers);
                break;
            case "error":
                this.handleError(message.providers);
                break;
            default:
            //console.warn("vccPactDatatableV2:handleMessage: unknown action");
        }
    }

    handleAdded(addedSigners) {
        for (let i = 0; i < addedSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name) {
                    // null checking
                    if (addedSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        this.tableData[j].dynamicButtonHook.isLoading = false;
                        this.tableData[j].dynamicButtonHook.isAdd = false;
                        this.tableData[j].duz = addedSigners[i].duz;
                        this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }

    handleRemoved(removedSigners) {
        for (let i = 0; i < removedSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name) {
                    // null checking
                    if (removedSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        this.tableData[j].dynamicButtonHook.isLoading = false;
                        this.tableData[j].duz = null;
                        this.tableData[j].dynamicButtonHook.isAdd = true;
                        this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }

    handleError(erroredSigners) {
        for (let i = 0; i < erroredSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name) {
                    if (erroredSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        this.tableData[j].dynamicButtonHook.isLoading = false;
                        this.tableData[j].dynamicButtonHook.isAdd = true;
                        this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }
}
