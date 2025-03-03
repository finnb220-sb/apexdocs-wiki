import { LightningElement, api, track } from "lwc";
import * as h from "./vccMedsActivityLogHelper";
import emptyStateMarkup from "./emptyState.html";
import loadingMarkup from "./loading.html";
import errorMarkup from "./error.html";
import pharmLogMarkup from "./data.html";

const templates = { loading: "loading", error: "error", empty: "empty", data: "default" };
//const labels = { noResultsMessage: null };

export default class VccMedsActivityLog extends LightningElement {
    _logRequst;

    @api columns;
    @api emptyMessage;
    @api sortProperty;
    @track labels = { noResultsMessage: null };
    //  @track labels = labels;

    // sort properties
    sortDirection = "asc";
    sortedBy; // sorting property

    logs; // display data
    templateToRender = templates.loading;

    connectedCallback() {
        this.labels.noResultsMessage = this.emptyMessage;
    }

    async fetchDiva(logType, request) {
        this.templateToRender = templates.loading;
        // set the label for pharmacy log
        this.labels.noResultsMessage = this.emptyMessage;

        // callout, if the call fails this returns null
        let pharmLogResponse = await h.fetchLogs(logType, request);
        this.handleResponse(pharmLogResponse);
    }

    handleResponse(pharmLogResponse) {
        // set the loading template
        this.templateToRender = templates.loading;

        // if the call is falsy or an empty object render the error template
        if (!pharmLogResponse || pharmLogResponse?.message?.toLowerCase()?.includes("code = -2")) {
            this.labels.errorMsg = pharmLogResponse?.message;
            this.templateToRender = templates.error;
            return;
        }

        // empty state criteria, success attribute in payload is false and message leads with 'No Data', render empty state template
        const emptyState = !pharmLogResponse?.success && pharmLogResponse?.message?.toLowerCase()?.includes("no data");

        if (emptyState) {
            this.templateToRender = templates.empty;
            return;
        }

        // assign data and render success template
        this.logs = pharmLogResponse.log;
        this.sortedBy = this.sortProperty;
        this.logs = h.processData(this.logs, this.sortProperty);
        this.templateToRender = templates.data;
    }

    handleSort(event) {
        let { fieldName, sortDirection } = event.detail;
        const column = h.getColumn(this.columns, fieldName);

        // if column is a button or "clickable link" use the typeAttributes.type property to sort else use regular type on the root object
        if (column.type === "button") {
            this.logs = h.sortFlatList([...this.logs], { propertyName: fieldName, type: column.typeAttributes.type }, sortDirection);
        } else {
            this.logs = h.sortFlatList([...this.logs], { propertyName: fieldName, type: column.type }, sortDirection);
        }

        // change sort direction when done
        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
    }

    render() {
        return this.templateToRender === "loading"
            ? loadingMarkup
            : this.templateToRender === "error"
              ? errorMarkup
              : this.templateToRender === "empty"
                ? emptyStateMarkup
                : pharmLogMarkup; // default
    }

    @api
    set logRequest(value) {
        if (typeof value === "object") {
            this.fetchDiva(value.logType, { facilityId: value.facilityId.length > 3 ? value.facilityId.substring(0, 3) : value.facilityId, prescriptionId: value.prescriptionId });
        }
    }

    get logRequest() {
        return this._logRequst;
    }
}
