/**
 * DEPRECATED - 09 02 2022
 * PLEASE USE vccPactDatatableV2
 */
import { LightningElement, wire, api } from "lwc";

import vccProgressNoteAddSigner from "@salesforce/messageChannel/vccProgressNoteAddSigner__c";
import vccProgressNoteAddSignerBroadcast from "@salesforce/messageChannel/vccProgressNoteAddSignerBroadcast__c";
import { publish, MessageContext, subscribe, unsubscribe, APPLICATION_SCOPE } from "lightning/messageService";
import SystemModstamp from "@salesforce/schema/Account.SystemModstamp";

var actions = [{ label: "View Details", name: "displayStationDetails" }];

const teamMemberColumns = [
    { label: "Role", fieldName: "roleName" },
    {
        label: "Name",
        fieldName: "name",
        type: "button",
        scope: "col",
        typeAttributes: {
            label: { fieldName: "name" },
            title: "Click to view more",
            name: "displayStationDetails",
            variant: "base"
        }
    },
    { label: "Phone Number", fieldName: "phone" },
    { label: "Facility Name & Number", fieldName: "stationNameAndNumber" },
    { label: "Team Name", fieldName: "teamName" }
];

const nonVAColumns = [
    {
        label: "Name",
        fieldName: "providerName",
        type: "button",
        scope: "col",
        typeAttributes: {
            label: { fieldName: "providerName" },
            title: "Click to view more",
            name: "displayStationDetails",
            variant: "base"
        }
    },
    { label: "Speciality", fieldName: "specialtyName" },
    { label: "Phone Number", fieldName: "phone" },
    { label: "City/State", fieldName: "city" },
    { label: "Team Name", fieldName: "teamName" }
];

export default class VccPACTDataTable extends LightningElement {
    /** Properties */
    @api
    set responseJSON(val) {
        this._responseJSON = val;
        try {
            if (JSON.parse(val)?.PatientSummary?.PatientSummaryText) {
                this.patientSummaryRaw = JSON.parse(val).PatientSummary.PatientSummaryText;
            }
        } catch (e) {
            // eslint-disable-next-line no-console
            console.error("Error parsing PACT JSON.");
        }
    }
    get responseJSON() {
        return this._responseJSON;
    }

    @api columnsTemplate;
    @api siteCode;
    @api enableAddSigners;

    @wire(MessageContext)
    messageContext;
    subscription;

    tableData = [];
    columns = [];

    patientSummary;
    member;
    patientSummaryRaw = "";
    cprsView = false;

    /** Lifecycle Hooks */

    connectedCallback() {
        // To Do: Parameterize Parse Functions
        if (this.columnsTemplate === "teamMemberColumns") {
            this.columns = teamMemberColumns;
            this.parseTeamMemberData(this.responseJSON);
        } else if (this.columnsTemplate === "nonVAColumns") {
            this.columns = nonVAColumns;
            this.isNonVaProvider = true;
            this.parseNonVAData(this.responseJSON);
        } else if (this.columnsTemplate === "cprs") {
            this.cprsView = true;
        }
        if (!this.subscription && this.enableAddSigners) {
            this.columns = [{ type: "dynamicButton", fieldName: "dynamicButtonHook", initialWidth: 50, hideDefaultActions: true }, ...this.columns];
            this.subscription = subscribe(this.messageContext, vccProgressNoteAddSignerBroadcast, (message) => this.handleMessage(message), { scope: APPLICATION_SCOPE });
            this.pub({ action: "get", providers: [] }); //asking for the list of signers when loaded
        }
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /** Methods */

    parseTeamMemberData(responseJSON) {
        let parsedResponse;

        try {
            parsedResponse = JSON.parse(responseJSON);
        } catch (e) {
            //error
            // eslint-disable-next-line no-console
            console.error("Error parsing PACT JSON.");
        }

        if (parsedResponse?.PatientSummary?.patientAssignmentsAtStations == null) return;
        let {
            PatientSummary: { patientAssignmentsAtStations: stations = [] }
        } = parsedResponse;

        for (let station of stations) {
            let { assignments = [] } = station;

            for (let assignment of assignments) {
                let { teamMembers = [] } = assignment;

                for (let member of teamMembers) {
                    let { stationNameRaw, parentStationNameRaw, stationNumber, parentStationNameAndNumber, stationNameAndNumber } = station;
                    let { assignmentCategory, assignmentStatus, teamName, assignmentDate, careType, teamFocus } = assignment;
                    let { primaryCare, pager, phone, supportStaff, roleName, name, roleDescription, ien } = member;

                    let tableRow = {
                        name,
                        primaryCare,
                        supportStaff,
                        teamName,
                        assignmentStatus,
                        assignmentCategory,
                        stationNumber,
                        stationNameAndNumber,
                        parentStationNameRaw,
                        careType,
                        teamFocus,
                        roleName,
                        roleDescription,
                        assignmentDate,
                        phone,
                        pager,
                        duz: null
                    };

                    let buttonClick = (cell) => {
                        if (cell.value.isAdd === true) {
                            this.doSignerAction("add", tableRow);
                        } else {
                            this.doSignerAction("remove", tableRow);
                        }
                    };

                    tableRow.dynamicButtonHook = {
                        isLoading: false,
                        isAdd: true,
                        isDisabled: member.name == null || member.name == "" ? true : false,
                        handleClick: function (e) {
                            tableRow.dynamicButtonHook.isLoading = true;
                            this.value = tableRow.dynamicButtonHook;
                            buttonClick(this);
                        }
                    };

                    if (this.siteCode != null && this.siteCode != "") {
                        if (stationNumber != null && stationNumber != "") {
                            if (stationNumber.includes(this.siteCode)) {
                                this.tableData.push(tableRow);
                            }
                        }
                        continue;
                    }
                    this.tableData.push(tableRow);
                }
            }
        }
    }

    parseNonVAData(responseJSON) {
        try {
            this.patientSummary = JSON.parse(responseJSON).PatientSummary;
            let recordCount = 0;
            if (this.patientSummary.nonVAPCProviders) {
                this.tableData = [];
                this.patientSummary.nonVAPCProviders.forEach((nonVAPCPRovider) => {
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

                    let buttonClick = (cell) => {
                        if (cell.value.isAdd === true) {
                            this.doSignerAction("add", tableRow);
                        } else {
                            this.doSignerAction("remove", tableRow);
                        }
                    };

                    obj.dynamicButtonHook = {
                        isLoading: false,
                        isAdd: true,
                        isDisabled: obj.providerName == null || obj.providerName == "" ? true : false,
                        handleClick: function (e) {
                            tableRow.dynamicButtonHook.isLoading = true;
                            this.value = tableRow.dynamicButtonHook;
                            buttonClick(this);
                        }
                    };
                    this.tableData.push(obj);
                });
            }
        } catch (e) {
            this.tableData = [];
        }
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
         * assuming our first sort is correct, if the sort direction is the only
         * changing parameter, reversing the array accomplishes the desired result
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
            } else {
                return 1;
            }
        } else {
            if ((aString === "true" || aString === "false") && (bString === "true" || bString === "false")) {
                if (aString === bString) {
                    return 0;
                } else if (aString === "true" && bString === "false") {
                    return -1;
                } else {
                    return 1;
                }
            }
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
        publish(this.messageContext, vccProgressNoteAddSigner, message);
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
        if (action == "displayStationDetails") {
            this.currentPatientData = event.detail.row;
            this.template.querySelector("c-vcc-pact-details").open(event.target);
        }
    }

    // handleAddAll() {
    //     let providers = [];
    //     for (let i = 0; i < this.tableData.length; i++) {
    //         let providerTO = {};
    //         ({ name: providerTO.providername = null, duz: providerTO.duz = null, medicalCenter: providerTO.loginSiteCode = null, providerTitle: providerTO.providertitle = null } = this.tableData[i]);
    //         if (providerTO.providername != null || providerTO.providername != "") {
    //             providers.push(providerTO);
    //         }
    //     }
    //     if (providers.length > 0) {
    //         this.pub({ action: "add", providers: providers });
    //     }
    // }

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
        }
    }

    handleAdded(addedSigners) {
        for (let i = 0; i < addedSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name && this.tableData[j].stationNumber) {
                    // null checking

                    if (addedSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        if (addedSigners[i].loginSiteCode === this.tableData[j].stationNumber) {
                            this.tableData[j].dynamicButtonHook.isLoading = false;
                            this.tableData[j].dynamicButtonHook.isAdd = false;
                            this.tableData[j].duz = addedSigners[i].duz;
                            this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                        }
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }

    handleRemoved(removedSigners) {
        for (let i = 0; i < removedSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name && this.tableData[j].stationNumber) {
                    // null checking

                    if (removedSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        if (removedSigners[i].loginSiteCode === this.tableData[j].stationNumber) {
                            this.tableData[j].dynamicButtonHook.isLoading = false;
                            this.tableData[j].duz = null;
                            this.tableData[j].dynamicButtonHook.isAdd = true;
                            this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                        }
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }

    handleError(erroredSigners) {
        for (let i = 0; i < erroredSigners.length; i++) {
            for (let j = 0; j < this.tableData.length; j++) {
                if (this.tableData[j].name && this.tableData[j].stationNumber) {
                    // null checking

                    if (erroredSigners[i].providername.toLowerCase() === this.tableData[j].name.toLowerCase()) {
                        if (erroredSigners[i].loginSiteCode === this.tableData[j].stationNumber) {
                            this.tableData[j].dynamicButtonHook.isLoading = false;
                            this.tableData[j].dynamicButtonHook.isAdd = true;
                            this.tableData[j].dynamicButtonHook = { ...this.tableData[j].dynamicButtonHook };
                        }
                    }
                }
            }
        }
        this.tableData = [...this.tableData];
    }
}
