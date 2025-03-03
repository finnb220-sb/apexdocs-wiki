import { LightningElement, track, api } from "lwc";

export default class VccVitalsDetailsTable extends LightningElement {
    isInit = true;
    @track isShowSpinner = false;
    @track totalRecords = 0;
    @track pageSize = 5;
    @track currentPage = 1;
    @api rowInfo;
    @api focusedVital = {};
    _focusedVital = {};

    _sortItems = "vital";
    _oldSortItems = "vital";
    _sortVital = "dwsc";

    columns = [
        { label: "Vital", fieldName: "vital", type: "text", sortable: true },
        { label: "Reading", fieldName: "reading", type: "text", sortable: true },
        { label: "Unit", fieldName: "unit", type: "text", sortable: true },
        { label: "Reference Range", fieldName: "referenceRange", type: "text", sortable: true },
        { label: "Interpretation", fieldName: "interpretation", type: "text", sortable: true }
    ];
    defaultSortDirection = "asc";
    sortDirection = "asc";
    sortedBy;
    secondSortedBy;

    _vitalList = [];
    vitalList = [];
    /* eslint-disable */
    connectedCallback() {
        if (!this.isInit) {
            return;
        }
        this.isInit = false;
        debugger;
        this.processResult(this.focusedVital);
    }

    @api
    processResult(focusedVital) {
        debugger;
        let vitalListRaw = focusedVital.measurements.measurement;
        let counter = 0;
        let vitalListTemp = [];
        for (let i = 0; i < vitalListRaw.length; i++) {
            let vitalEle = JSON.parse(JSON.stringify(vitalListRaw[i]));
            vitalEle["vital"] = vitalEle.name;
            vitalEle["interpretation"] = !vitalEle.isBp ? vitalEle.reading : "-";
            vitalEle["reading"] = vitalEle.value;
            vitalEle["unit"] = vitalEle.units;
            vitalEle["referenceRange"] = vitalEle.low + " - " + vitalEle.high;
            vitalEle["key"] = "Key" + i;
            vitalListTemp.push(vitalEle);
            if (vitalEle["name"] === "WEIGHT" && vitalEle.bmi) {
                /*
                 Clause to add BMI to focused vitals
                */
                let vitalEleBMI = {
                    name: " ",
                    id: " ",
                    value: " ",
                    vuid: " ",
                    vital: " ",
                    interpretation: " ",
                    reading: " ",
                    unit: " ",
                    referenceRange: " ",
                    key: " "
                };
                let xSum = vitalListRaw.length;
                vitalEleBMI["name"] = "BMI";
                vitalEleBMI["id"] = vitalEle.id + 1;
                vitalEleBMI["value"] = vitalEle.bmi;
                vitalEleBMI["vuid"] = vitalEle.vuid + 1;
                vitalEleBMI["vital"] = "BMI";
                vitalEleBMI["interpretation"] = vitalEle.bmi < 25 ? "Normal" : "Overweight";
                vitalEleBMI["reading"] = vitalEle.bmi;
                vitalEleBMI["unit"] = "kg/m²";
                vitalEleBMI["referenceRange"] = vitalEle.low + " - " + vitalEle.high;
                vitalEleBMI["key"] = "Key" + (i + 1);
                vitalListTemp.push(vitalEleBMI);
            }
        }
        this.sortData("vital", "asc");
        let vitalListRefined = vitalListTemp;
        this._vitalList = vitalListRefined;
        this.vitalList = vitalListRefined;
        this.totalRecords = vitalListRefined.length;
        this.setRecords();
    }

    handlePageChange(event) {
        debugger;
        this.currentPage = event.detail;
        this.setRecords();
    }

    setRecords() {
        debugger;

        let vitalList = this._vitalList;
        let startPageIndex;
        let currentPage = this.currentPage - 1;
        if (currentPage == 0) {
            startPageIndex = currentPage;
        } else {
            startPageIndex = currentPage * this.pageSize;
        }
        let endPageIndex = startPageIndex + this.pageSize;
        vitalList = vitalList.slice(startPageIndex, endPageIndex);
        this.vitalList = vitalList;
    }

    onHandleSort(event) {
        const { fieldName, sortDirection } = event.detail;
        this.sortData(fieldName, sortDirection);
        this.sortDirection = sortDirection;
        this.sortedBy = fieldName;
    }

    sortData(fieldName, sortDirection) {
        debugger;
        let sortResult = [...this._vitalList];
        let parser = (v) => v;
        let column = this.columns.find((c) => c.fieldName === fieldName);
        if (column.type === "date" || column.type === "datetime") {
            parser = (v) => v && new Date(v);
        }
        let sortMult = sortDirection === "asc" ? 1 : -1;
        this._vitalList = sortResult.sort((a, b) => {
            let a1 = parser(a[fieldName]),
                b1 = parser(b[fieldName]);
            let r1 = a1 < b1,
                r2 = a1 === b1;
            return r2 ? 0 : r1 ? -sortMult : sortMult;
        });
        this.setRecords();
    }

    /* eslint-enable */

    get isSmall() {
        return this.flexipageRegionWidth == "SMALL";
    }
    get isMedium() {
        return this.flexipageRegionWidth == "MEDIUM";
    }
}
