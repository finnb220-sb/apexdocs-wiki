import { LightningElement, api } from 'lwc';
import { tXengine } from 'c/dshiCode';

/**
 * txccMixin is defined below.
 * This class contains the modifications to the dshi code as well as a few other fixes to get things working
 *
 * IMPORTANT:
 * Disabling eslint for the entire class because it is a copy/paste of the original dshi code.
 */
/* eslint-disable */
export default class DshiTxcc extends txccMixin(LightningElement) {
    initialized = false;

    constructor() {
        try {
            super();
        } catch (e) {
            console.warn(e);
        }
    }

    dispatchEvent(event) {
        this.template.dispatchEvent(new CustomEvent(event.type, { detail: event.detail, composed: true }));
    }

    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = true;
        try {
            this.setupWidget();
            this.postSetupFixes();
            this.handleTxlLoaded();
        } catch (e) {
            console.warn(e);
        }
    }

    postSetupFixes = () => {
        //since salesforce changes the html id attribute, here is code fixing the input -> datalist connection
        let qaNumericList = this.template.querySelector('[data-id="qaNumericList"]');
        let qaDateList = this.template.querySelector('[data-id="qaDateList"]');
        let qaListList = this.template.querySelector('[data-id="qaListList"]');
        qaNumericList.previousElementSibling.setAttribute('list', qaNumericList.getAttribute('id'));
        qaDateList.previousElementSibling.setAttribute('list', qaDateList.getAttribute('id'));
        qaListList.previousElementSibling.setAttribute('list', qaListList.getAttribute('id'));

        //another instance of the onclick property not working
        this.ec.tctLibraryBack.addEventListener('click', this.doLibraryBack.bind(this));
    };

    loadedCt = 0;
    handleTxlLoaded = (e) => {
        this.loadedCt++;
        if (this.loadedCt === 3) {
            this.dispatchEvent(new CustomEvent('txccloaded', { composed: true }));
        }
    };

    /**
     * Below are modifications to original dshi code.
     * Any modifications will have their old values commented out.
     * Everything else is direct copy/paste.
     */

    //setting url to correct value, otherwise it will point to salesforce
    //The Test URL is used in the lower environments for testing against the TXCC test environment. There are situations where this would need to be manually flipped, so keeping the URL commented out in the code for those situations.
    // url = 'https://test.triagexpert.com/'; // lower environment link
    url = 'https://va.triagexpert.com/'; // production link
    // url = 'https://txcc-aws.dshisystems.net';

    autosizeregister = () => {};
    autosizeupdate = () => {};

    //replacing references to this.shadowRoot.x to this.template.x
    shadowRoot = {
        getElementById: (id) => this.template.querySelector(`[data-id="${id}"]`),
        querySelectorAll: (selector) => this.template.querySelectorAll(selector),
        querySelector: (selector) => this.template.querySelector(selector)
    };

    handleOpenTab(e) {
        this.openTab.bind(this)(event, /** e.target.id */ e.target.dataset.id);
    }
    tXeAtDataPoint(rsp) {
        var input;
        var dl;
        var option;
        var i;
        rsp.isDataPoint = true;
        this.tXeAtQuestion(rsp);
        if (this.ec.qanextbtn.inputControl) {
            this.ec.qanextbtn.inputControl = undefined;
        }
        this.ec.qaUnits.style.display = 'none';
        if (rsp.dataPoint.unitsList && rsp.dataPoint.unitsList.length > 1) {
            if (this.ec?.qaUnitSelection?.options?.length > 0) {
                this.ec.qaUnitSelection.options.length = 0;
            }
            for (var uIdx = 0; uIdx < rsp.dataPoint.unitsList.length; uIdx++) {
                var opt = document.createElement('option');
                opt.label = rsp.dataPoint.unitsList[uIdx];
                opt.value = rsp.dataPoint.unitsList[uIdx];
                opt.innerText = rsp.dataPoint.unitsList[uIdx];
                if (rsp.dataPoint.units == rsp.dataPoint.unitsList[uIdx]) {
                    opt.selected = true;
                }
                this.ec.qaUnitSelection.appendChild(opt);
            }
            this.ec.qaUnitSelection.style.display = 'inherit';
            this.ec.qaUnitText.style.display = 'none';
            this.ec.qaUnits.style.display = 'inline-block';
        } else {
            this.ec.qaUnitSelection.style.display = 'none';
            if (rsp.dataPoint.units) {
                this.ec.qaUnitText.style.display = 'inherit';
                this.ec.qaUnitText.innerText = rsp.dataPoint.units;
                if (rsp.dataPoint.units != 'na') this.ec.qaUnits.style.display = 'inline-block';
            } else {
                this.ec.qaUnitText.style.display = 'none';
            }
        }
        if (rsp.dataPoint[rsp.dataPoint.units].type == 'Number') {
            input = this.ec.qaNumber;
            var isIntegral = false;
            input.dataPoint = rsp.dataPoint;
            input.min = input.dataPoint[input.dataPoint.units].min;
            input.max = input.dataPoint[input.dataPoint.units].max;
            input.step = input.dataPoint[input.dataPoint.units].step;
            if (input.dataPoint.value) input.value = input.dataPoint.value;
            else input.value = '';
            input.unit = rsp.dataPoint.units;
            if (input.dataPoint[input.dataPoint.units].integral) {
                isIntegral = true;
            }
            dl = this.ec.qaNumericList;
            dl.innerHTML = '';
            var precision = 0;
            if (input.step == 0.1) {
                precision = 1;
            }
            var n = parseFloat(input.min);
            var x = parseFloat(input.max);
            var s = parseFloat(input.step);
            for (i = n; i <= x; i += s) {
                option = document.createElement('option');
                option.value = this.round(i, precision);
                dl.appendChild(option);
                if (!isIntegral) {
                    if (option.value.indexOf('.') < 0) {
                        option = document.createElement('option');
                        option.value = this.round(i, precision) + '.0';
                        dl.appendChild(option);
                    }
                }
            }
            this.ec.qadatapoint.style.display = 'block';
            this.ec.qaNumeric.style.display = 'inline-block';
            this.ec.qaList.style.display = 'none';
            this.ec.qaDate.style.display = 'none';
            this.ec.qanextbtn.inputControl = input;
        } else {
            if (rsp.dataPoint[rsp.dataPoint.units].type == 'Date') {
                input = this.ec.qaDateInput;
                input.dataPoint = rsp.dataPoint;
                input.minDate = new Date(rsp.dataPoint[rsp.dataPoint.units].min);
                input.maxDate = new Date(rsp.dataPoint[rsp.dataPoint.units].max);
                if (rsp.dataPoint.value) {
                    input.value = rsp.dataPoint.value;
                }
                dl = this.ec.qaDateList;
                dl.innerHTML = '';
                var currentDate = input.minDate;
                while (currentDate.getTime() < input.maxDate.getTime()) {
                    var y = currentDate.getFullYear();
                    var m = currentDate.getMonth() + 1;
                    var d = currentDate.getDate();
                    var ms = m < 10 ? '0' + m : '' + m;
                    var ds = d < 10 ? '0' + d : '' + d;
                    var dStr2 = ms + '/' + ds + '/' + y;
                    option = document.createElement('option');
                    option.value = dStr2;
                    option.text = dStr2;
                    dl.appendChild(option);

                    currentDate = currentDate.addDays(1);
                }
                this.ec.qadatapoint.style.display = 'block';
                this.ec.qaNumeric.style.display = 'none';
                this.ec.qaList.style.display = 'none';
                this.ec.qaDate.style.display = 'inline-block';
                this.ec.qaUnits.style.display = 'none';
                this.ec.qanextbtn.inputControl = input;
            } else {
                if (rsp.dataPoint[rsp.dataPoint.units].type == 'List') {
                    input = this.ec.qaListInput;
                    input.dataPoint = rsp.dataPoint;
                    if (rsp.dataPoint.value) {
                        input.value = rsp.dataPoint.value;
                    }
                    input.unit = rsp.dataPoint.units;
                    dl = this.ec.qaListList;
                    dl.innerHTML = '';
                    var vList = input.dataPoint[input.dataPoint.units].list;
                    for (i = 0; i < vList.length; i++) {
                        option = document.createElement('option');
                        option.value = vList[i];
                        option.text = vList[i];
                        dl.appendChild(option);
                    }
                    this.ec.qadatapoint.style.display = 'block';
                    this.ec.qaNumeric.style.display = 'none';
                    this.ec.qaList.style.display = 'inline-block';
                    this.ec.qaDate.style.display = 'none';
                    this.ec.qaUnits.style.display = 'none';
                    this.ec.qanextbtn.inputControl = input;
                    var properties = Object.keys(rsp.dataPoint);
                    if (properties.length > 3) {
                        var qaUnits = this.ec.qaUnitSelection;
                        qaUnits.innerHTML = '';
                        for (i = 0; i < properties.length; i++) {
                            var property = properties[i];
                            if (!this.skipProperties.includes(property)) {
                                option = document.createElement('option');
                                option.text = property;
                                if (property === input.dataPoint.units) {
                                    option.selected = true;
                                }
                                // qaUnits.add(option);
                                qaUnits.appendChild(option);
                                this.ec.qaUnits.style.display = 'inline-block';
                            }
                        }
                    } else {
                        this.ec.qaUnits.style.display = 'none';
                    }
                } else {
                    this.alert('Data Input is not implemented');
                }
            }
        }
    }
    demoClick(event) {
        var qasdl;

        //replace if/else condition to point to dataset.id instead of id
        if (/** event.target.id == 'demobtn' */ event.target.dataset.id == 'demobtn') {
            qasdl = 'qasessiondatalist';
            //replace if/else condition to point to dataset.id instead of id
        } else if (/** event.target.id == 'valuebtn' */ event.target.dataset.id == 'valuebtn') {
            qasdl = 'valuedatalist';
            //replace if/else condition to point to dataset.id instead of id
        } else if (/** event.target.id == 'findingsbtn' */ event.target.dataset.id == 'findingsbtn')
            qasdl = 'findingsdatalist';

        if (this.shadowRoot.getElementById(qasdl).style.display != 'block') {
            var ddt = this.shadowRoot.querySelectorAll('.ddtable');
            if (ddt) {
                for (var i = 0; i < ddt.length; i++) {
                    //replace if/else condition to point to dataset.id instead of id
                    if (/** ddt[i].id == qasdl */ ddt[i].dataset.id == qasdl) {
                        ddt[i].style.display = 'block';
                        var newLeft = event.target.offsetLeft - 5;
                        var newTop = event.target.offsetTop + event.target.offsetHeight + 5;
                        ddt[i].style.left = newLeft + 'px';
                        ddt[i].style.top = newTop + 'px';
                    } else {
                        ddt[i].style.display = 'none';
                    }
                }
            }
        } else {
            this.shadowRoot.getElementById(qasdl).style.display = 'none';
        }
        event.stopPropagation();
    }
    rdemoClick(event) {
        var qasdl;
        if (event.target.dataset.id /** event.target.id */ == 'rdemobtn') {
            qasdl = 'rsessiondatalist';
        } else if (event.target.dataset.id /** event.target.id */ == 'rvaluebtn') {
            qasdl = 'rvaluedatalist';
        } else if (event.target.dataset.id /** event.target.id */ == 'rfindingsbtn') qasdl = 'rfindingsdatalist';
        if (this.shadowRoot.getElementById(qasdl).style.display != 'block') {
            var ddt = this.shadowRoot.querySelectorAll('.ddtable');
            if (ddt) {
                for (var i = 0; i < ddt.length; i++) {
                    if (ddt[i].dataset.id /** ddt[i].id */ == qasdl) {
                        ddt[i].style.display = 'block';
                        var newLeft = event.target.offsetLeft - 5;
                        var newTop = event.target.offsetTop + event.target.offsetHeight + 5;
                        ddt[i].style.left = newLeft + 'px';
                        ddt[i].style.top = newTop + 'px';
                    } else {
                        ddt[i].style.display = 'none';
                    }
                }
            }
        } else {
            this.shadowRoot.getElementById(qasdl).style.display = 'none';
        }
        event.stopPropagation();
    }
    onNumberKeypress(e) {
        var input = e.target;

        var pressedKey = String.fromCharCode(e.which);
        if (pressedKey === '.' && input.step >= 1) {
            e.preventDefault();
            return;
        }
        if (pressedKey != '.') {
            var parsedVal = parseInt(pressedKey);
            var nan = isNaN(parsedVal);
            if (nan) {
                e.preventDefault();
                return;
            }
        }
        var iv;
        if (input.selectionStart == input.selectionEnd) {
            iv = input.value + pressedKey;
        } else {
            iv = input.value.substring(input.selectionEnd) + pressedKey;
        }
        // var listId = e.target.attributes.list.value;
        var listId = e.target.nextElementSibling.dataset.id;
        if (!this.isValidDataListPartialValue(listId, iv)) {
            e.preventDefault();
            return;
        }
        return;
    }
    isValidDataListPartialValue(listId, value) {
        var listElement = this.shadowRoot.getElementById(listId);
        for (var i = 0; i < /** listElement.options.length */ listElement.children.length; i++) {
            var oVal = /** listElement.options[i].value */ listElement.children[i].value;
            if (oVal.startsWith(value)) {
                return true;
            }
        }
        return false;
    }
    isValidDatalistValue(idDataList, inputValue) {
        var selector = `[data-id="${idDataList}"] option[value="${inputValue.replace('"', '\\"')}"]`;
        // var selector = "#" + idDataList + " option[value='" + inputValue.replace('\'', '\\\'') + "']";
        var option = this.shadowRoot.querySelector(selector);
        if (option != null) {
            return option.value.length > 0;
        }
        return false;
    }
    onTXLdisplayArticle(ev) {
        if (this.careLinks.hasOwnProperty(ev.detail.fullTitle)) {
            this.ec.libTXL.setVerbal(
                this.shadowRoot.getElementById('vi' + this.careLinks[ev.detail.fullTitle]).getAttribute('checked'),
                ev.detail.fullTitle
            );
            this.ec.libTXL.setWeb(
                this.shadowRoot.getElementById('wi' + this.careLinks[ev.detail.fullTitle]).getAttribute('checked'),
                ev.detail.fullTitle
            );
        }
        return null;
    }
    onTXLverbalChanged(ev) {
        let i = -1;
        let vci;
        if (ev.detail.checked) {
            this.ec.piclcontainer.style.display = 'inherit';
            if (!this.careLinks.hasOwnProperty(ev.detail.fullTitle)) {
                i = this.careLinksCount;
                this.careLinksCount++;
                this.careLinks[ev.detail.fullTitle] = i;
                var tr = document.createElement('DIV');
                tr.className = 'trow';
                var tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tcb';
                var wcv = document.createElement('input');
                wcv.type = 'checkbox';
                wcv.dataset.id = 'wi' + i; //wcv.id = 'wi' + i;
                wcv.checked = false;
                wcv.fullTitle = ev.detail.fullTitle;
                wcv.addEventListener('change', this.handleWebCheckChange.bind(this));
                var wcl = document.createElement('label');
                wcl.htmlFor = 'wi' + i; // id of wcv
                wcl.appendChild(document.createTextNode('Web'));
                tdcb.appendChild(wcv);
                tdcb.appendChild(wcl);
                tr.appendChild(tdcb);
                tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tcb';
                wcv = document.createElement('input');
                wcv.type = 'checkbox';
                wcv.dataset.id = 'vi' + i; //wcv.id = 'vi' + i;
                wcv.fullTitle = ev.detail.fullTitle;
                wcv.addEventListener('change', this.handleVerbalCheckChange.bind(this));
                wcl = document.createElement('label');
                wcl.appendChild(wcv);
                wcl.appendChild(document.createTextNode('Verbal'));
                tdcb.appendChild(wcl);
                tr.appendChild(tdcb);
                tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tlink';
                var tdvb = document.createElement('button');
                tdvb.innerHTML = ev.detail.fullTitle;
                tdvb.topic = ev.detail.fullPath;
                tdvb.className = 'pibtn';
                tdvb.dataset.id = 'll' + i; //tdvb.id = 'll' + i;
                tdvb.addEventListener('click', this.handleLibraryClick.bind(this));
                tdcb.appendChild(tdvb);
                tr.appendChild(tdcb);
                this.ec.picltable.appendChild(tr);
            } else {
                i = this.careLinks[ev.detail.fullTitle];
            }
            vci = this.shadowRoot.getElementById('vi' + i);
            vci.checked = true;
        } else {
            if (this.careLinks.hasOwnProperty(ev.detail.fullTitle)) {
                i = this.careLinks[ev.detail.fullTitle];
                vci = this.shadowRoot.getElementById('vi' + i);
                vci.checked = false;
            }
        }
    }
    onTXLwebChanged(ev) {
        let i = -1;
        let vci;
        if (ev.detail.checked) {
            this.ec.piclcontainer.style.display = 'inherit';
            var wcl;
            var wcv;
            var tr;
            var tdcb;
            var tdvb;
            if (!this.careLinks.hasOwnProperty(ev.detail.fullTitle)) {
                i = this.careLinksCount;
                this.careLinksCount++;
                this.careLinks[ev.detail.fullTitle] = i;
                tr = document.createElement('DIV');
                tr.className = 'trow';
                tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tcb';
                wcv = document.createElement('input');
                wcv.type = 'checkbox';
                wcv.dataset.id = 'wi' + i; // wcv.id = 'wi' + i;
                wcv.checked = false;
                wcv.fullTitle = ev.detail.fullTitle;
                wcv.addEventListener('change', this.handleWebCheckChange.bind(this));
                wcl = document.createElement('label');
                wcl.htmlFor = 'wi' + i; // id of wcv
                wcl.appendChild(document.createTextNode('Web'));
                tdcb.appendChild(wcv);
                tdcb.appendChild(wcl);
                tr.appendChild(tdcb);
                tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tcb';
                wcv = document.createElement('input');
                wcv.type = 'checkbox';
                wcv.dataset.id = 'vi' + i; // wcv.id = 'vi' + i;
                wcv.fullTitle = ev.detail.fullTitle;
                wcv.addEventListener('change', this.handleVerbalCheckChange.bind(this));
                wcl = document.createElement('label');
                wcl.appendChild(wcv);
                wcl.appendChild(document.createTextNode('Verbal'));
                tdcb.appendChild(wcl);
                tr.appendChild(tdcb);
                tdcb = document.createElement('DIV');
                tdcb.className = 'tcell tlink';
                tdvb = document.createElement('button');
                tdvb.innerHTML = ev.detail.fullTitle;
                tdvb.topic = ev.detail.fullPath;
                tdvb.className = 'pibtn';
                tdvb.dataset.id = 'll' + i; // tdvb.id = 'll' + i;
                tdvb.addEventListener('click', this.handleLibraryClick.bind(this));
                tdcb.appendChild(tdvb);
                tr.appendChild(tdcb);
                this.ec.picltable.appendChild(tr);
            } else {
                i = this.careLinks[ev.detail.fullTitle];
            }
            vci = this.shadowRoot.getElementById('wi' + i);
            vci.checked = true;
        } else {
            if (this.careLinks.hasOwnProperty(ev.detail.fullTitle)) {
                i = this.careLinks[ev.detail.fullTitle];
                vci = this.shadowRoot.getElementById('wi' + i);
                vci.checked = false;
            }
        }
    }
    generateInstructionList() {
        var title;
        var vtopics = [];
        var wtopics = [];
        var checkedList = this.ec.picltable.querySelectorAll('input:checked');
        for (var i = 0; i < checkedList.length; i++) {
            var wid = checkedList[i].dataset.id; // var wid = checkedList[i].id;
            if (wid.substr(0, 2) === 'wi') {
                title = checkedList[i].fullTitle;
                wtopics.push(title);
            } else if (wid.substr(0, 2) === 'vi') {
                title = checkedList[i].fullTitle;
                vtopics.push(title);
            }
        }
        var instructions = {};
        if (vtopics.length > 0) {
            instructions.verbaltopics = vtopics;
        }
        if (wtopics.length > 0) {
            instructions.webtopics = wtopics;
        }
        return instructions;
    }
    tXeAtReport(rsp) {
        var sysConcern;
        var piList;
        var valueDataList;
        var vm;
        var title;
        let i;
        var pf;
        var node;
        var textnode;
        var wcl;
        var wcv;
        let li;
        let s;
        let row;
        this.ec.notebtn.rsp = rsp;
        this.ec.qAndA.disabled = true;
        this.ec.qAndA.style.opacity = 0.25;
        this.ec.library.disabled = false;
        this.ec.library.style.opacity = 1.0;
        if (rsp.etreatable && rsp.etreatable === true) {
            this.ec.cvc.style.display = 'block';
        } else {
            this.ec.cvc.style.display = 'none';
        }
        if (rsp.systemConcern) {
            sysConcern = rsp.systemConcern.join(', ');
            this.ec.sysconcern.innerHTML = sysConcern;
            this.ec.sysconcerncontainer.style.display = 'block';
        } else {
            this.ec.sysconcerncontainer.style.display = 'none';
        }
        if (rsp.assessments) {
            for (i = 0; i < rsp.assessments.length; i++) {
                s = rsp.assessments[i].text;
                li = document.createElement('li');
                if (s.indexOf('video visit') > 0) {
                    li.classList.add('aliste');
                } else if (s.indexOf('text chat') > 0) {
                    li.classList.add('bliste');
                } else if (s.indexOf('telephone call') > 0) {
                    li.classList.add('cliste');
                }
                li.appendChild(document.createTextNode(s));
                this.ec.assessmentsList.appendChild(li);
            }
            this.ec.assessments.style.display = 'block';
        } else {
            this.ec.assessments.style.display = 'none';
        }
        if (rsp.alerts) {
            var aCnt = 0;
            for (i = 0; i < rsp.alerts.length; i++) {
                s = rsp.alerts[i].text;
                if (!s.startsWith('Advanced Triage: ')) {
                    aCnt++;
                    li = document.createElement('li');
                    li.appendChild(document.createTextNode(s));
                    this.ec.alertsList.appendChild(li);
                }
            }
            if (aCnt > 0) {
                this.ec.alerts.style.display = 'block';
            } else {
                this.ec.alerts.style.display = 'none';
            }
        } else {
            this.ec.alerts.style.display = 'none';
        }
        if (!this.standAlone) {
            this.ec.rsltwhere.innerHTML = rsp.where[0];
            this.ec.rsltwhen.innerHTML = rsp.when;
        } else {
            if (rsp.where) {
                var selector = '#rsltwhere option[value="' + rsp.where[0] + '"]';
                var whereOption = this.shadowRoot.querySelector(selector);
                whereOption.text = whereOption.text + ' (System)';
                whereOption.selected = true;
            }
            if (rsp.when) {
                var selector = '#rsltwhen option[value="' + rsp.when + '"]';
                var whenOption = this.shadowRoot.querySelector(selector);
                whenOption.text = whenOption.text + ' (System)';
                whenOption.selected = true;
            }
        }
        if (rsp.predictedResources) {
            piList = this.ec.piList;
            piList.innerHTML = '';
            for (i = 0; i < rsp.predictedResources.length; i++) {
                li = document.createElement('li');
                li.innerHTML = rsp.predictedResources[i];
                piList.appendChild(li);
            }
            this.ec.predicteresourcescontainer.style.display = 'block';
        } else {
            this.ec.predicteresourcescontainer.style.display = 'none';
        }
        if (rsp.demographics) {
            valueDataList = this.ec.qasessiondatalist;
            valueDataList.innerHTML = '';
            vm = '';
            for (i = 0; i < this.demographicsToShow.length; i++) {
                if (rsp.demographics.hasOwnProperty(this.demographicsToShow[i])) {
                    title = this.demographicsTitles[i];
                    vm = rsp.demographics[this.demographicsToShow[i]];
                    if (typeof rsp.demographics[this.demographicsToShow[i]].getMonth === 'function')
                        vm = this.dateToString(vm);
                    row = valueDataList.insertRow(-1);
                    row.insertCell(0).innerHTML = title;
                    row.insertCell(1).innerHTML = vm;
                }
            }
        }

        if (rsp.values) {
            valueDataList = this.ec.valuedatalist;
            valueDataList.innerHTML = '';
            vm = '';
            for (i = 0; i < this.valuesAndMeasuresToShow.length; i++) {
                if (rsp.values.hasOwnProperty(this.valuesAndMeasuresToShow[i])) {
                    title = this.valuesAndMeasuresTitles[i];

                    if (this.valuesAndMeasuresUnits.hasOwnProperty(this.valuesAndMeasuresToShow[i]))
                        vm = rsp.values[this.valuesAndMeasuresToShow[i]];
                    else vm = rsp.values[this.valuesAndMeasuresToShow[i]];
                    row = valueDataList.insertRow(-1);
                    row.insertCell(0).innerHTML = title;
                    row.insertCell(1).innerHTML = vm;
                }
            }
        }
        if (rsp.positiveFindings) {
            pf = this.ec.qaPositiveFindings;
            pf.innerHTML = '';
            for (i = 0; i < rsp.positiveFindings.length; i++) {
                node = document.createElement('LI');
                textnode = document.createTextNode(rsp.positiveFindings[i]);
                node.appendChild(textnode);
                pf.appendChild(node);
            }
            this.ec.qapositivehdr.style.display = 'block';
            pf.style.display = 'block';
        } else {
            this.ec.qapositivehdr.style.display = 'none';
            this.ec.qaPositiveFindings.style.display = 'none';
        }
        if (rsp.negativeFindings) {
            pf = this.ec.qaNegativeFindings;
            pf.innerHTML = '';
            for (i = 0; i < rsp.negativeFindings.length; i++) {
                node = document.createElement('LI');
                textnode = document.createTextNode(rsp.negativeFindings[i]);
                node.appendChild(textnode);
                pf.appendChild(node);
            }
            this.ec.qanegativehdr.style.display = 'block';
            pf.style.display = 'block';
        } else {
            this.ec.qanegativehdr.style.display = 'none';
            this.ec.qaNegativeFindings.style.display = 'none';
        }
        if (rsp.positiveFindings || rsp.negativeFindings) {
            this.ec.findingscontainer.style.visibility = 'visible';
        } else {
            this.ec.findingscontainer.style.visibility = 'hidden';
        }
        this.ec.picontainer.style.display = 'none';
        this.ec.piclcontainer.style.display = 'none';
        if ((rsp.when === 'Now, 911' || rsp.when === 'Now') && rsp.patientInstructions) {
            this.ec.piinformation.innerHTML = rsp.patientInstructions;
            this.ec.picontainer.style.display = 'block';
        } else {
            if (rsp.careLinks) {
                this.careLinks = {};
                this.careLinksCount = rsp.careLinks.length;
                for (i = 0; i < rsp.careLinks.length; i++) {
                    var clId = i;
                    var fullTitle = rsp.careLinks[i].title;
                    var fullTopic = rsp.careLinks[i].topic;
                    if (rsp.careLinks[i].title.endsWith(' Home Care')) {
                        this.careLinks[rsp.careLinks[i].title + ' Veteran'] = clId;
                    }
                    var tr = document.createElement('DIV');
                    tr.className = 'trow';
                    var tdcb = document.createElement('DIV');
                    tdcb.className = 'tcell tcb';
                    wcv = document.createElement('input');
                    wcv.type = 'checkbox';
                    wcv.dataset.id = 'wi' + clId; // wcv.id = 'wi' + clId;
                    wcv.checked = false;
                    wcv.fullTitle = fullTitle;
                    wcv.fullTopic = fullTopic;
                    wcv.addEventListener('change', this.handleWebCheckChange.bind(this));
                    wcl = document.createElement('label');
                    wcl.htmlFor = 'wi' + clId; // id of wcv
                    wcl.appendChild(document.createTextNode('Web'));
                    tdcb.appendChild(wcv);
                    tdcb.appendChild(wcl);
                    tr.appendChild(tdcb);
                    tdcb = document.createElement('DIV');
                    tdcb.className = 'tcell tcb';
                    wcv = document.createElement('input');
                    wcv.type = 'checkbox';
                    wcv.dataset.id = 'vi' + clId; // wcv.id = 'vi' + clId;
                    wcv.fullTitle = fullTitle;
                    wcv.addEventListener('change', this.handleVerbalCheckChange.bind(this));
                    wcl = document.createElement('label');
                    wcl.appendChild(wcv);
                    wcl.appendChild(document.createTextNode('Verbal'));
                    tdcb.appendChild(wcl);
                    tr.appendChild(tdcb);
                    tdcb = document.createElement('DIV');
                    tdcb.className = 'tcell tlink';
                    var tdvb = document.createElement('button');
                    tdvb.innerHTML = rsp.careLinks[i].title;
                    tdvb.topic = fullTopic;
                    tdvb.className = 'pibtn';
                    tdvb.dataset.id = 'll' + clId; // tdvb.id = 'll' + clId;
                    tdvb.addEventListener('click', this.handleLibraryClick.bind(this));
                    tdcb.appendChild(tdvb);
                    tr.appendChild(tdcb);
                    this.ec.picltable.appendChild(tr);
                }
                this.ec.piclcontainer.style.display = 'block';
            }
        }
        this.openTab.bind(this)(null, 'results');
    }
    handleLibraryClick(event) {
        this.ec.tctTXL.showArticle(event.currentTarget.topic);
        this.ec.tctLibraryPopup.style.display = 'block'; // this.ec.tctLibraryPopup.style.display = 'inherit'; // newlib
        this.ec.tab.style.display = 'none';
        this.ec.tabContent.style.display = 'none';
        event.preventDefault();
        return null;
    }
    onDateKeypress(e) {
        var input = e.target;
        var pressedKey = String.fromCharCode(e.which);
        var iv = input.value + pressedKey;
        var listId = e.target.nextElementSibling.dataset.id;
        if (!this.isValidDataListPartialValue(listId, iv)) {
            e.preventDefault();
            return;
        }
        return;
    }
    onHeightKeypress(e) {
        var input = e.target;
        var pressedKey = String.fromCharCode(e.which);
        var parsedVal = parseInt(pressedKey);
        var nan = isNaN(parsedVal);
        var iv = input.value;
        var il = input.value.length;
        var validValues = input.nextElementSibling.dataset.id;
        if (il == 0) {
            if (nan) {
                e.preventDefault();
                return;
            }
            if (!this.isValidDataListPartialValue(validValues, pressedKey)) {
                e.preventDefault();
                return;
            }
            return;
        } else if (il == 1) {
            if (pressedKey == "'" || pressedKey == ' ') {
                input.value = input.value + "'";
                e.preventDefault();
                return;
            }
            if (nan) {
                e.preventDefault();
                return;
            }
            iv = iv + "'" + pressedKey;
            if (!this.isValidDataListPartialValue(validValues, iv)) {
                e.preventDefault();
                return;
            }
            input.value = iv;
            e.preventDefault();
            return;
        } else if (il == 2 || il == 3) {
            if (nan) {
                e.preventDefault();
                return;
            }
            iv = iv + pressedKey;
            if (!this.isValidDataListPartialValue(validValues, iv)) {
                e.preventDefault();
                return;
            }
            input.value = iv;
            e.preventDefault();
            return;
        }
        e.preventDefault();
        return;
    }
}

function txccMixin(LightningElement) {
    return class TxccMixin extends LightningElement {
        constructor() {
            super();
            this.url = '/';
            this.uiVersion = '240503';

            if (typeof Date.prototype.addDays != 'function') {
                Date.prototype.addDays = function (days) {
                    var date = new Date(this.valueOf());
                    date.setDate(date.getDate() + days);
                    return date;
                };
            }

            if (!String.prototype.endsWith) {
                String.prototype.endsWith = function (search, this_len) {
                    if (this_len === undefined || this_len > this.length) {
                        this_len = this.length;
                    }
                    return this.substring(this_len - search.length, this_len) === search;
                };
            }
            if (typeof String.prototype.startsWith != 'function') {
                String.prototype.startsWith = function (str) {
                    return this.slice(0, str.length).toLowerCase() == str.toLowerCase();
                };
            }

            this.requiredProperties = ['dob', 'g'];
            this.mapStartProperties = {
                c: 'cc',
                h: 'height',
                w: 'weight',
                s: 'systolicbloodpressure',
                d: 'diastolicbloodpressure',
                t: 'temperature',
                gl: 'serumglucose',
                pb: 'pefrbaseline',
                pf: 'pefrcurrent',
                ln: 'lnmp',
                r: 'respiratoryrate',
                o: 'Ox',
                p: 'pulse'
            };
            this.valuesAndMeasuresToNote = [
                'height',
                'weight',
                'systolicBloodPressure',
                'diastolicBloodPressure',
                'temperature',
                'serumGlucose',
                'pefrBaseline',
                'pefrCurrent',
                'lnmp',
                'respiratoryRate',
                'pulse',
                'gestationalAge',
                'bmi',
                'peakFlowPctBest',
                'painscale',
                'durationOfComplaint',
                'o2',
                'meanArterialPressure',
                'pulsePressure',
                'modifiedShockIndex'
            ];
            this.valuesAndMeasuresToShow = [
                'height',
                'weight',
                'systolicbloodpressure',
                'diastolicbloodpressure',
                'temperature',
                'serumglucose',
                'pefrbaseline',
                'pefrcurrent',
                'lnmp',
                'respiratoryrate',
                'pulse',
                'gestationalage',
                'bmi',
                'peakflowpctbest',
                'painscale',
                'durationofcomplaint',
                'Ox',
                'meanarterialpressure',
                'pulsepressure',
                'modifiedshockindex'
            ];
            this.valuesAndMeasuresTitles = [
                'Height',
                'Weight',
                'SBP',
                'DBP',
                'Temperature',
                'FSBG',
                'PEFR Best',
                'PEFR Current',
                'LNMP',
                'Respiratory Rate',
                'Pulse',
                'Gestational age',
                'BMI',
                'PEFR Percent Best',
                'Painscale',
                'Duration of CC',
                'O2 Sat',
                'MAP',
                'PP',
                'MSI'
            ];
            this.valuesAndMeasuresTitlesNote = [
                'Height',
                'Weight',
                'SBP',
                'DBP',
                'Temperature',
                'FSBG',
                'PEFR Best',
                'PEFR Current',
                'LNMP',
                'Respiratory Rate',
                'Pulse',
                'Gestational age',
                'BMI',
                'PEFR Percent Best',
                'Painscale',
                'Duration of CC',
                'O2 Sat',
                'Mean Arterial Pressure',
                'Pulse Pressure',
                'Modified Shock Index'
            ];
            this.valuesAndMeasuresUnits = {
                Ox: '%'
            };
            this.valuesAndMeasuresToNoteSupplmental = {};
            this.demographicsToShow = ['cc', 'gender', 'age'];
            this.demographicsTitles = ['CC', 'Genotype', 'Age'];
            this.skipProperties = ['value', 'units', 'type'];
            var dobMin = new Date();
            var dobMax = new Date(dobMin);
            dobMin.setFullYear(dobMin.getFullYear() - 120);
            dobMax.setFullYear(dobMax.getFullYear() - 16);
            var lnmpMin = new Date();
            var lnmpMax = new Date(lnmpMin);
            lnmpMin.setFullYear(lnmpMin.getFullYear() - 1);
            this.startProperties = {
                gender: {
                    type: 'string',
                    name: 'g',
                    values: ['M', 'F']
                },
                dob: {
                    type: 'date',
                    name: 'dob',
                    min: dobMin,
                    max: dobMax
                },
                cc: {
                    type: 'string',
                    name: 'c'
                },
                height: {
                    type: 'string',
                    name: 'h',
                    min: '1\'0"',
                    max: '9\'0"',
                    units: 'Feet/Inches'
                },
                weight: {
                    type: 'number',
                    name: 'w',
                    min: 0,
                    max: 999,
                    units: 'Lbs'
                },
                systolicBloodPressure: {
                    type: 'number',
                    name: 's',
                    min: 0,
                    max: 999
                },
                diastolicBloodPressure: {
                    type: 'number',
                    name: 'd',
                    min: 0,
                    max: 999
                },
                temperature: {
                    type: 'number',
                    name: 't',
                    min: 0.0,
                    max: 999.9,
                    units: 'F'
                },
                serumGlucose: {
                    type: 'number',
                    name: 'gl',
                    min: 0,
                    max: 999
                },
                pefrBaseline: {
                    type: 'number',
                    name: 'pb',
                    min: 50,
                    max: 600
                },
                pefrCurrent: {
                    type: 'number',
                    name: 'pf',
                    min: 50,
                    max: 600
                },
                lnmp: {
                    type: 'date',
                    name: 'ln',
                    min: lnmpMin,
                    max: lnmpMax
                },
                respiratoryRate: {
                    type: 'number',
                    name: 'r',
                    min: 0,
                    max: 999
                },
                o2: {
                    type: 'number',
                    name: 'o',
                    min: 0,
                    max: 100
                },
                pulse: {
                    type: 'number',
                    name: 'p',
                    min: 0,
                    max: 999
                },
                visn: {
                    type: 'string',
                    name: 'z1'
                },
                facility: {
                    type: 'string',
                    name: 'z2'
                },
                residenceState: {
                    type: 'string',
                    name: 'z3'
                }
            };
            this.careLinks = {};
            this.careLinksCount = 0;
        }
        @api
        start(startData) {
            return this.doStart.bind(this)(startData);
        }
        abort() {
            return this.doAbort();
        }
        parseValue(value, unitsArray, defaultUnits) {
            var firstChar = value.charAt(0);
            var results = {};
            if (firstChar >= '0' && firstChar <= '9') {
                var regexGroups = value.match(/(\d*\.?\d+)\s+(.*)/);
                if (regexGroups.length < 1) {
                    return null;
                }
                if (regexGroups.length > 2) {
                    return null;
                }
                if (!regexGroups[1] && defaultUnits) {
                    results.value = regexGroups[0];
                    results.units = defaultUnits;
                    return results;
                } else {
                    if (!unitsArray.contains(regexGroups[1])) {
                        return null;
                    }
                }
                results.value = regexGroups[0];
                results.units = regexGroups[1];
            }
        }
        @api
        doAbort(event) {
            event.cancelBubble = true;
            var cAbort = this.confirm(
                'Pressing OK will abort (cancel) the session; any collected information or results will be lost.\n\n Do you wish to abort?'
            );
            if (cAbort) {
                this.doResetComponent();
                var e = new CustomEvent('abort', {
                    detail: 'Aborted'
                });
                this.dispatchEvent(e);
                event.preventDefault();
                return;
            }
            event.preventDefault();
        }
        doStart(values) {
            var e;
            var i;
            var startObject = {};
            var propertyName;
            var z = ['', '', ''];

            this.ec.sessionResults.style.display = 'block';
            this.ec.sessionNote.style.display = 'none';
            for (propertyName in values) {
                if (values.hasOwnProperty(propertyName) && this.startProperties.hasOwnProperty(propertyName)) {
                    var val = values[propertyName];
                    var sI = this.startProperties[propertyName];
                    if (sI.type === 'number') {
                        if (typeof val != sI.type) {
                            e = new CustomEvent('error', {
                                detail: 'Expected ' + sI.type + ' found ' + typeof val + ': ' + propertyName
                            });
                            this.dispatchEvent(e);
                            return;
                        }
                        if (sI.min && sI.max) {
                            if (val < sI.min || val > sI.max) {
                                e = new CustomEvent('error', {
                                    detail: propertyName + ' must be from ' + sI.min + ' to ' + sI.max + ': ' + val
                                });
                                this.dispatchEvent(e);
                                return;
                            }
                        }
                    } else if (sI.type == 'string') {
                        if (typeof val != sI.type) {
                            e = new CustomEvent('error', {
                                detail: 'Expected ' + sI.type + ' found ' + typeof val + ': ' + propertyName
                            });
                            this.dispatchEvent(e);
                            return;
                        }
                        if (sI.values && sI.values.indexOf(val) < 0) {
                            e = new CustomEvent('error', {
                                detail:
                                    propertyName +
                                    ' value is invalid should be one of [' +
                                    sI.values.join(',') +
                                    ']: ' +
                                    val
                            });
                            this.dispatchEvent(e);
                            return;
                        }
                    } else if (sI.type == 'date') {
                        if (typeof val.getMonth != 'function') {
                            e = new CustomEvent('error', {
                                detail: 'Expected ' + sI.type + ' found ' + typeof val + ': ' + propertyName
                            });
                            this.dispatchEvent(e);
                            return;
                        }
                        if (sI.min && sI.max) {
                            if (val < sI.min || val > sI.max) {
                                e = new CustomEvent('error', {
                                    detail: propertyName + ' must be from ' + sI.min + ' to ' + sI.max + ': ' + val
                                });
                                this.dispatchEvent(e);
                                return;
                            }
                        }
                    }
                    if (sI.units) {
                        startObject[sI.name] = val + ' ' + sI.units;
                    } else {
                        startObject[sI.name] = val;
                    }
                }
            }
            for (i = 0; i < this.requiredProperties.length; i++) {
                propertyName = this.requiredProperties[i];
                if (!startObject[propertyName]) {
                    e = new CustomEvent('error', {
                        detail: 'Missing required start property: ' + propertyName
                    });
                    this.dispatchEvent(e);
                    return;
                }
            }
            var haveZ = false;
            if (startObject.hasOwnProperty('z1')) {
                z[0] = startObject.z1.replace(/ /g, '_');
                delete startObject.z1;
                haveZ = true;
            }
            if (startObject.hasOwnProperty('z2')) {
                z[1] = startObject.z2.replace(/ /g, '_');
                delete startObject.z2;
                haveZ = true;
            }
            if (startObject.hasOwnProperty('z3')) {
                z[2] = startObject.z3.replace(/ /g, '_');
                delete startObject.z3;
                haveZ = true;
            }
            if (haveZ) {
                startObject.z = z.join('~');
            }
            if (startObject.hasOwnProperty('ln') && startObject.g != 'F') {
                e = new CustomEvent('error', {
                    detail: 'LNMP is only valid for Females'
                });
                this.dispatchEvent(e);
                return;
            }

            this.values = startObject;
            this.dob = this.values.dob;
            this.gender = this.values.g;
            this.age = this.calculateAgeYM(this.dob);
            this.ageRange = this.getAgeRange(this.age);
            this.startTime = new Date();
            if (this.values.c) {
                this.ec.mmContent.style.display = 'none';
                this.cc = this.values.c;
                delete this.values.g;
                delete this.values.dob;
                delete this.values.c;
                delete this.values.startTime;
                this.tXe.start(this.cc, this.dob, this.gender, this.values);
                this.ec.qAndA.disabled = false;
                this.ec.qAndA.style.opacity = 1;
                this.ec.library.disabled = true;
                this.ec.library.style.opacity = 0.25;
                this.ec.results.disabled = false;
                this.ec.results.style.opacity = 1;
                return;
            }
            this.ec.mmInput.style.display = 'inherit';
            this.ec.qAndA.disabled = false;
            this.ec.qAndA.style.opacity = 1;
            this.ec.library.disabled = false;
            this.ec.library.style.opacity = 1.0;
            this.ec.results.disabled = false;
            this.ec.results.style.opacity = 1.0;
        }
        calculateAgeYM(dob) {
            var date;
            if (typeof dob === 'string') date = new Date(dob);
            else if (typeof dob.getMonth === 'function') date = dob;
            else throw new Error('Invalid type for date variable passed to calculateAge');
            var today = new Date();
            var months;
            months = (today.getFullYear() - date.getFullYear()) * 12;
            months += today.getMonth();
            months -= date.getMonth();
            months = months > 0 ? months : 1;
            if (months < 36) {
                return months + ' Months';
            }
            var years = Math.floor(months / 12);
            return years + ' Years';
        }
        startWithMatch(text, searchString) {
            return text.toLowerCase().startsWith(searchString.toLowerCase());
        }
        handleOpenTab(e) {
            //this function is modified in the extending class
        }
        lAlert(msg) {
            alert(msg);
        }
        lConfirm(msg) {
            return confirm(msg);
        }
        setupWidget() {
            if (!this.alert) {
                this.alert = this.lAlert;
            }
            if (!this.confirm) {
                this.confirm = this.lConfirm;
            }
            if (!this.autosizeregister) {
                this.autosizeregister = autosize;
            }
            if (!this.autosizeupdate) {
                this.autosizeupdate = autosize.update;
            }
            this.ec = {};
            this.ec.rsltwhere = this.shadowRoot.getElementById('rsltwhere');
            this.ec.rsltwhen = this.shadowRoot.getElementById('rsltwhen');
            if (this.standAlone) {
                var saWhere =
                    '             <select class="rsltlist" id="rsltwhere">' +
                    '               <option value="Emergency department">Emergency department</option>' +
                    '               <option value="Urgent care center">Urgent care center</option>' +
                    '               <option value="Clinic | Office">Clinic</option>' +
                    '               <option value="Dentist Office">Dentist office</option>' +
                    '               <option value="Virtual Care">Virtual care</option>' +
                    '               <option value="Home">Home</option>' +
                    '             </select>';
                var saWhen =
                    '              <select class="rsltlist" id="rsltwhen">' +
                    '               <option value="Now, 911">Now, 911</option>' +
                    '               <option value="Now">Now</option>' +
                    '               <option value="Within 8 Hours">Within 8 Hours</option>' +
                    '               <option value="Within 24 Hours">Within 24 Hours</option>' +
                    '               <option value="Within 3 Days">Within 3 Days</option>' +
                    '               <option value="Within 2 Weeks">Within 2 Weeks</option>' +
                    '               <option value="Self-care">Self-care</option>' +
                    '             </select>';
                this.ec.rsltwhere.outerHTML = saWhere;
                this.ec.rsltwhen.outerHTML = saWhen;
            }
            this.shadowRoot.getElementById('cyear').innerHTML = new Date().getFullYear();
            this.ec.controlContainer = this.shadowRoot.getElementById('controlContainer');
            this.ec.controlContainer.addEventListener('click', this.onCtlCtrClick.bind(this));
            this.ec.mmInput = this.shadowRoot.getElementById('mmInput');
            this.ec.mmInput.addEventListener('input', this.mmChange.bind(this));
            this.ec.mmList = this.shadowRoot.getElementById('mmList');
            this.ec.warningContent = this.shadowRoot.getElementById('warningContent');
            this.ec.closenotebtn = this.shadowRoot.getElementById('closenotebtn');
            this.ec.closenotebtn.addEventListener('click', this.doViewResults.bind(this));
            this.ec.notedonebtn = this.shadowRoot.getElementById('notedonebtn');
            this.ec.notedonebtn.addEventListener('click', this.doNoteDone.bind(this));
            this.ec.resultsabortbtn = this.shadowRoot.getElementById('resultsabortbtn');
            this.ec.resultsabortbtn.addEventListener('click', this.doAbort.bind(this));
            this.ec.noteabortbtn = this.shadowRoot.getElementById('noteabortbtn');
            this.ec.noteabortbtn.addEventListener('click', this.doAbort.bind(this));
            if (this.url === '/' || this.url === '') {
                if (!window.location.origin) {
                    this.url = window.location.protocol + '//' + window.location.host;
                } else {
                    this.url = window.location.origin;
                }
            }
            if (!this.url.endsWith('/')) this.url += '/';
            this.tXe = new tXengine(
                {
                    appId: 'cmgplus',
                    url: this.url
                },
                this
            );
            this.tXe.addListener('atQuestion', this.tXeAtQuestion.bind(this));
            this.tXe.addListener('atDataPoint', this.tXeAtDataPoint.bind(this));
            this.tXe.addListener('atReport', this.tXeAtReport.bind(this));
            this.tXe.addListener('onError', this.tXeOnError.bind(this));
            this.ec.qanextbtn = this.shadowRoot.getElementById('qanextbtn');
            this.ec.qanextbtn.addEventListener('click', this.doNext.bind(this));
            this.ec.qayesbtn = this.shadowRoot.getElementById('qayesbtn');
            this.ec.qayesbtn.addEventListener('click', this.doYes.bind(this));
            this.ec.qanobtn = this.shadowRoot.getElementById('qanobtn');
            this.ec.qanobtn.addEventListener('click', this.doNo.bind(this));
            this.ec.qabackbtn = this.shadowRoot.getElementById('qabackbtn');
            this.ec.qabackbtn.addEventListener('click', this.doBack.bind(this));
            this.ec.demobtn = this.shadowRoot.getElementById('demobtn');
            this.ec.demobtn.addEventListener('click', this.demoClick.bind(this));
            this.ec.valuebtn = this.shadowRoot.getElementById('valuebtn');
            this.ec.valuebtn.addEventListener('click', this.demoClick.bind(this));
            this.ec.findingsbtn = this.shadowRoot.getElementById('findingsbtn');
            this.ec.findingsbtn.addEventListener('click', this.demoClick.bind(this));
            this.ec.rdemobtn = this.shadowRoot.getElementById('rdemobtn');
            this.ec.rdemobtn.addEventListener('click', this.rdemoClick.bind(this));
            this.ec.rvaluebtn = this.shadowRoot.getElementById('rvaluebtn');
            this.ec.rvaluebtn.addEventListener('click', this.rdemoClick.bind(this));
            this.ec.rfindingsbtn = this.shadowRoot.getElementById('rfindingsbtn');
            this.ec.rfindingsbtn.addEventListener('click', this.rdemoClick.bind(this));
            this.ec.notebtn = this.shadowRoot.getElementById('notebtn');
            this.ec.notebtn.addEventListener('click', this.doNote.bind(this));
            this.ec.qAndA = this.shadowRoot.getElementById('qAndA');
            this.ec.qAndA.addEventListener('click', this.handleOpenTab.bind(this));
            this.ec.library = this.shadowRoot.getElementById('library');
            this.ec.library.addEventListener('click', this.handleOpenTab.bind(this));
            this.ec.results = this.shadowRoot.getElementById('results');
            this.ec.results.addEventListener('click', this.handleOpenTab.bind(this));
            this.ec.vno = this.shadowRoot.getElementById('vno');
            this.ec.vno.innerText = '(v' + this.uiVersion + ')';
            this.ec.vno.onclick = this.doVnoClick.bind(this);
            this.shadowRoot.onclick = function () {
                var ddt = this.shadowRoot.querySelector('.ddtable');
                if (ddt) {
                    for (var i = 0; i < ddt.length; i++) {
                        ddt[i].style.display = 'none';
                    }
                }
            };
            this.ec.notebody = this.shadowRoot.getElementById('notebody');
            this.notebodyregistered = false;
            this.educationlogregistered = false;
            this.ec.educationlog = this.shadowRoot.getElementById('educationlog');
            this.ec.qaControlPanel = this.shadowRoot.getElementById('qaContentPanel');
            this.ec.rsltContent = this.shadowRoot.getElementById('rsltContent');
            this.ec.libContentPanel = this.shadowRoot.getElementById('libContentPanel');
            this.ec.libTXL = this.shadowRoot.getElementById('libTXL');
            this.ec.libTXL.addEventListener('verbalChanged', this.onTXLverbalChanged.bind(this));
            this.ec.libTXL.addEventListener('webChanged', this.onTXLwebChanged.bind(this));
            this.ec.libTXL.addEventListener('displayArticle', this.onTXLdisplayArticle.bind(this));
            this.ec.rsessiondatalist = this.shadowRoot.getElementById('rsessiondatalist');
            this.ec.rfindingsdatalist = this.shadowRoot.getElementById('rfindingsdatalist');
            this.ec.rvaluedatalist = this.shadowRoot.getElementById('rvaluedatalist');
            this.ec.rdemocontainer = this.shadowRoot.getElementById('rdemocontainer');
            this.ec.rfindingscontainer = this.shadowRoot.getElementById('rfindingscontainer');
            this.ec.rvaluecontainer = this.shadowRoot.getElementById('rvaluecontainer');
            this.ec.qasessiondatalist = this.shadowRoot.getElementById('qasessiondatalist');
            this.ec.findingsdatalist = this.shadowRoot.getElementById('findingsdatalist');
            this.ec.valuedatalist = this.shadowRoot.getElementById('valuedatalist');
            this.ec.democontainer = this.shadowRoot.getElementById('democontainer');
            this.ec.findingscontainer = this.shadowRoot.getElementById('findingscontainer');
            this.ec.valuecontainer = this.shadowRoot.getElementById('valuecontainer');
            this.ec.mmContent = this.shadowRoot.getElementById('mmContent');
            this.ec.recommendationscontainer = this.shadowRoot.getElementById('recommendationscontainer');
            this.ec.library = this.shadowRoot.getElementById('library');
            this.ec.rsltwhere = this.shadowRoot.getElementById('rsltwhere');
            this.ec.rsltwhen = this.shadowRoot.getElementById('rsltwhen');
            this.ec.piinclude = this.shadowRoot.getElementById('piinclude');
            this.ec.sessionResults = this.shadowRoot.getElementById('sessionResults');
            this.ec.sessionNote = this.shadowRoot.getElementById('sessionNote');
            this.ec.piinformation = this.shadowRoot.getElementById('piinformation');
            this.ec.sysconcern = this.shadowRoot.getElementById('sysconcern');
            this.ec.sysconcerncontainer = this.shadowRoot.getElementById('sysconcerncontainer');
            this.ec.predicteresourcescontainer = this.shadowRoot.getElementById('predicteresourcescontainer');
            this.ec.piList = this.shadowRoot.getElementById('piList');
            this.ec.picontainer = this.shadowRoot.getElementById('picontainer');
            this.ec.qAndA = this.shadowRoot.getElementById('qAndA');
            this.ec.qaContent = this.shadowRoot.getElementById('qaContent');
            this.ec.notebtn = this.shadowRoot.getElementById('notebtn');
            this.ec.cvc = this.shadowRoot.getElementById('cvc');
            this.ec.piclcontainer = this.shadowRoot.getElementById('piclcontainer');
            this.ec.picltable = this.shadowRoot.getElementById('picltable');
            this.ec.qadatapoint = this.shadowRoot.getElementById('qadatapoint');
            this.ec.qaNumeric = this.shadowRoot.getElementById('qaNumeric');
            this.ec.qaNumber = this.shadowRoot.getElementById('qaNumber');
            this.ec.qaNumericList = this.shadowRoot.getElementById(this.ec.qaNumber.getAttribute('list'));
            this.ec.qaNumber.addEventListener('keypress', this.onNumberKeypress.bind(this));
            this.ec.qaList = this.shadowRoot.getElementById('qaList');
            this.ec.qaListInput = this.shadowRoot.getElementById('qaListInput');
            this.ec.qaListList = this.shadowRoot.getElementById(this.ec.qaListInput.getAttribute('list'));
            this.ec.qaListInput.addEventListener('keypress', this.onHeightKeypress.bind(this));
            this.ec.qaDate = this.shadowRoot.getElementById('qaDate');
            this.ec.qaDateInput = this.shadowRoot.getElementById('qaDateInput');
            this.ec.qaDateInput.addEventListener('keypress', this.onDateKeypress.bind(this));
            this.ec.qaDateList = this.shadowRoot.getElementById(this.ec.qaDateInput.getAttribute('list'));
            this.ec.qaUnitSelection = this.shadowRoot.getElementById('qaUnitSelection');
            this.ec.qaUnitSelection.addEventListener('change', this.onUnitSelectionChange.bind(this));
            this.ec.qaUnits = this.shadowRoot.getElementById('qaUnits');
            this.ec.qaUnitText = this.shadowRoot.getElementById('qaUnitText');
            this.ec.qareasoning = this.shadowRoot.getElementById('qareasoning');
            this.ec.qaprompt = this.shadowRoot.getElementById('qaprompt');
            this.ec.qaassisttext = this.shadowRoot.getElementById('qaassisttext');
            this.ec.qapositivehdr = this.shadowRoot.getElementById('qapositivehdr');
            this.ec.qaPositiveFindings = this.shadowRoot.getElementById('qaPositiveFindings');
            this.ec.qanegativehdr = this.shadowRoot.getElementById('qanegativehdr');
            this.ec.qaNegativeFindings = this.shadowRoot.getElementById('qaNegativeFindings');
            this.ec.qaContentPanel = this.shadowRoot.getElementById('qaContentPanel');
            this.ec.library.disabled = true;
            this.ec.library.style.opacity = 0.25;
            this.ec.qAndA.disabled = true;
            this.ec.qAndA.style.opacity = 0.25;
            this.ec.results.disabled = true;
            this.ec.results.style.opacity = 0.25;
            this.ec.mmInput.style.display = 'none';
            this.ec.tab = this.shadowRoot.getElementById('tab');
            this.ec.tabContent = this.shadowRoot.getElementById('tabContent');
            this.ec.tctLibraryBack = this.shadowRoot.getElementById('tctLibraryBack');
            this.ec.tctLibraryBack.onclick = this.doLibraryBack.bind(this);
            this.ec.tctTXL = this.shadowRoot.getElementById('tctTXL');
            this.ec.tctLibraryPopup = this.shadowRoot.getElementById('tctLibraryPopup');
            this.ec.assessments = this.shadowRoot.getElementById('assessments');
            this.ec.assessmentsList = this.shadowRoot.getElementById('assessmentsList');
            this.ec.alerts = this.shadowRoot.getElementById('alerts');
            this.ec.alertsList = this.shadowRoot.getElementById('alertsList');
            var mmEntries = this.shadowRoot.querySelectorAll('.ui-ccbtn');
            for (var i = 0; i < mmEntries.length; i++) {
                mmEntries[i].onclick = this.ccSelect.bind(this);
                mmEntries[i].onkeydown = this.ccKeydown.bind(this);
            }
            this.ec.libTXL.addEventListener('loaded', this.onTXLloaded.bind(this));
            this.ec.tctTXL.addEventListener('loaded', this.onTctTXLloaded.bind(this));
            this.ec.licenseWarning = this.shadowRoot.getElementById('licenseWarning');
        }
        async doVnoClick() {
            if (!this.Versions) {
                var v = await fetch(this.url + '/txnet20wse/?m=ver').then((response) => response.json());
                this.Versions = v.ver;
            }
            if (this.Versions) {
                var vDisplay =
                    'URL: ' +
                    this.url +
                    '\nUI: ' +
                    this.uiVersion +
                    '\nE: ' +
                    this.Versions.TXE +
                    '\nL: ' +
                    this.Versions.TXL +
                    '\nS: ' +
                    this.Versions.TXS;
                alert(vDisplay);
            }
        }
        onTXLloaded(ev) {
            var e = new CustomEvent('loaded', {
                detail: {
                    widget: 'TXC'
                }
            });
            this.dispatchEvent(e);
        }
        onTctTXLloaded(ev) {}
        onTXLdisplayArticle(ev) {
            //this function is modified in the extending class
        }
        onTXLverbalChanged(ev) {
            //this function is modified in the extending class
        }
        handleWebCheckChange(ev) {
            this.ec.libTXL.setWeb(ev.currentTarget.checked, ev.currentTarget.fullTitle);
        }
        handleVerbalCheckChange(ev) {
            this.ec.libTXL.setVerbal(ev.currentTarget.checked, ev.currentTarget.fullTitle);
        }
        onTXLwebChanged(ev) {
            //this function is modified in the extending class
        }
        onUnitSelectionChange(ev) {
            var newOption = ev.target.value;
            var inputControl = this.ec.qanextbtn.inputControl;
            inputControl.unit = newOption;
            inputControl.value = this.ec.qaNumber.value;
            var dataPoint = inputControl.dataPoint;
            this.setupDataPoint(dataPoint, newOption);
        }
        onCtlCtrClick() {
            var ddTable = this.ec.controlContainer.getElementsByClassName('ddtable');
            for (var i = 0; i < ddTable.length; i++) {
                ddTable[i].style.display = 'none';
            }
        }
        demoClick(event) {
            //this function is modified in the extending class
        }
        rdemoClick(event) {
            //this function is modified in the extending class
        }
        isHidden(el) {
            var style = window.getComputedStyle(el);
            return style.visibility === 'hidden';
        }
        openTab(event, tab) {
            var clickedTab = this.shadowRoot.getElementById(tab);
            if (clickedTab.classList.contains('active')) {
                return;
            }
            if (clickedTab.classList.contains('disabled')) {
                return;
            }
            var activeTab = this.shadowRoot.querySelectorAll('.active')[0];
            activeTab.classList.remove('active');
            this.shadowRoot.getElementById(tab).classList.add('active');
            if (tab == 'qAndA') {
                this.ec.qaContentPanel.style.display = 'block';
                this.ec.rsltContent.style.display = 'none';
                this.ec.libContentPanel.style.display = 'none';
            } else if (tab == 'library') {
                this.ec.libContentPanel.style.display = 'block';
                this.ec.qaContentPanel.style.display = 'none';
                this.ec.rsltContent.style.display = 'none';
            } else if (tab == 'results') {
                if (!this.fixed) {
                    if (!this.educationlogregistered) {
                        this.educationlogregistered = true;
                        this.autosizeregister(this.ec.educationlog);
                    }
                } else {
                    if (this.fixed) {
                        this.ec.educationlog.style.height = '250px';
                    }
                }
                this.ec.qaContentPanel.style.display = 'none';
                this.ec.libContentPanel.style.display = 'none';
                this.ec.rsltContent.style.display = 'block';
                this.ec.rsessiondatalist.innerHTML = this.ec.qasessiondatalist.innerHTML;
                this.ec.rfindingsdatalist.innerHTML = this.ec.findingsdatalist.innerHTML;
                this.ec.rvaluedatalist.innerHTML = this.ec.valuedatalist.innerHTML;
                this.ec.rdemocontainer.style.visibility = !this.isHidden(this.ec.democontainer) ? 'visible' : 'hidden';
                this.ec.rfindingscontainer.style.visibility = !this.isHidden(this.ec.findingscontainer)
                    ? 'visible'
                    : 'hidden';
                this.ec.rvaluecontainer.style.visibility = !this.isHidden(this.ec.valuecontainer)
                    ? 'visible'
                    : 'hidden';
            }
        }
        getAgeRange(age) {
            var ia = parseInt(age);
            if (isNaN(ia)) {
                return 'A';
            }
            if (age.toLowerCase().indexOf(' months') <= 0) {
                ia *= 12;
            }
            if (ia < 30) {
                return 'I';
            }
            if (ia < 204) {
                return 'C';
            }
            return 'A';
        }
        mmChange(event) {
            if (this.ec.licenseWarning.style.display != 'none') {
                this.ec.licenseWarning.style.display = 'none';
            }
            var value = event.target.value;
            var html = '';
            this.ec.mmList.innerHTML = html;
            var bspStart = 0;
            if (value && value.length >= 1) {
                var ageGender = this.ageRange + this.gender;
                var nGender = this.gender == 'M' ? 1 : 2;
                var matchCount = 0;
                var i = 0;
                for (i = 0; i < this.sym[ageGender].length && matchCount < 10; i++) {
                    if (this.startWithMatch(this.sym[ageGender][i], value)) {
                        var vcaIndicator = '';
                        var bspEntries = 0;
                        let bspHTML = '';
                        if (this.bsp) {
                            while (
                                this.bsp[bspStart][0].toLowerCase() < this.sym[ageGender][i].toLowerCase() &&
                                bspStart < this.bsp.length
                            ) {
                                bspStart++;
                            }
                            if (bspStart < this.bsp.length) {
                                if (
                                    this.bsp[bspStart].length > 5 &&
                                    this.bsp[bspStart][3] == 1 &&
                                    (this.bsp[bspStart][3] && nGender) != 0
                                ) {
                                    vcaIndicator =
                                        '<span class="icon2"><button class="opnBtn" alt="Better Start Point" title="Better Start Point">Better Option</button><button class="clsBtn" alt="Close" title="Close" style="display: none;">Better option</button></span>';
                                    bspEntries = this.bsp[bspStart][5].length;

                                    for (var bspI = 0; bspI < bspEntries; bspI++) {
                                        if ((this.bsp[this.bsp[bspStart][5][bspI]][4] & nGender) != 0) {
                                            bspHTML +=
                                                '<li class="ui-btn ui-ccbtn bspEntry" tabindex="0" style="display: none;">' +
                                                'Switch to:&nbsp;&nbsp;' +
                                                this.bsp[this.bsp[bspStart][5][bspI]][0] +
                                                '</li>';
                                        }
                                    }
                                }
                            }
                        }
                        html +=
                            '<li class="ui-btn ui-ccbtn" tabindex="0"><div style="float:left;">' +
                            this.sym[ageGender][i] +
                            '</div>' +
                            vcaIndicator +
                            '<div style="clear:both;"></div></li>' +
                            bspHTML;
                        matchCount++;
                        if (matchCount >= 10) {
                            matchCount = 0;
                            while (
                                i < this.sym[ageGender].length &&
                                this.startWithMatch(this.sym[ageGender][i], value)
                            ) {
                                i++;
                                matchCount++;
                            }
                            if (matchCount >= 10) {
                                html +=
                                    '<li tabindex="0"><div style="float:left; color: red;">' +
                                    matchCount +
                                    ' additional matches, continue typing to refine list.<div style="clear:both;"></div></li>';
                            }
                        }
                    }
                }
            }
            if (html.length > 0) {
                this.ec.mmList.innerHTML = html;
                var mmEntries = this.shadowRoot.querySelectorAll('.ui-ccbtn');
                for (let i = 0; i < mmEntries.length; i++) {
                    mmEntries[i].onclick = this.ccSelect.bind(this);
                    mmEntries[i].onkeydown = this.ccKeydown.bind(this);
                }
                this.ec.mmList.style.display = 'inline-block';
                this.ec.warningContent.style.display = 'none';
                let bspE = this.shadowRoot.querySelectorAll('.opnBtn');
                for (let i = 0; i < bspE.length; i++) {
                    bspE[i].onclick = this.bspClick.bind(this);
                    bspE[i].onkeydown = this.btnKeydown.bind(this);
                }
                bspE = this.shadowRoot.querySelectorAll('.clsBtn');
                for (let i = 0; i < bspE.length; i++) {
                    bspE[i].onclick = this.bspClick.bind(this);
                    bspE[i].onkeydown = this.btnKeydown.bind(this);
                }
            } else {
                if (value.length < 1) {
                    this.ec.mmList.style.display = 'none';
                } else {
                    this.ec.mmList.innerHTML =
                        '<li tabindex="0"><div style="float:left; color: red;">No matches, try alternative spelling or wording.  Consider searching Library.<div style="clear:both;"></div></li>';
                    this.ec.mmList.style.display = 'inline-block';
                    this.ec.warningContent.style.display = 'none';
                }
            }
        }
        btnKeydown(e) {
            if (
                e.keyCode === 13 ||
                e.keyCode === 32 ||
                (e.keyCode == 40 && e.currentTarget.className == 'opnBtn') ||
                (e.keyCode == 38 && e.currentTarget.className == 'clsBtn')
            ) {
                e.preventDefault();
                e.stopImmediatePropagation();
                this.bspClick(e);
            }
        }
        ccKeydown(e) {
            let ns;
            if (e.keyCode === 13 || e.keyCode === 32) {
                e.preventDefault();
                e.stopImmediatePropagation();
                this.ccSelect(e);
            }
            if (e.target.parentElement.className == 'qpList') {
                return;
            }
            if (e.keyCode == 37 || e.keyCode == 39) {
                e.preventDefault();
                e.stopImmediatePropagation();
                return;
            }
            if (e.keyCode == 40) {
                ns = e.currentTarget.nextSibling;
                while (ns) {
                    if (ns.style.display != 'none') {
                        ns.focus();
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        return;
                    }
                    ns = ns.nextSibling;
                }
                return;
            }
            if (e.keyCode == 38) {
                ns = e.currentTarget.previousSibling;
                while (ns) {
                    if (ns.style.display != 'none') {
                        ns.focus();
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        return;
                    }
                    ns = ns.previousSibling;
                }
                return;
            }
        }
        bspClick(event) {
            let bspE = this.shadowRoot.querySelectorAll('.bspEntry');
            for (let i = 0; i < bspE.length; i++) {
                bspE[i].style.display = 'none';
            }
            bspE = this.shadowRoot.querySelectorAll('.clsBtn');
            for (let i = 0; i < bspE.length; i++) {
                bspE[i].style.display = 'none';
            }
            bspE = this.shadowRoot.querySelectorAll('.opnBtn');
            for (let i = 0; i < bspE.length; i++) {
                bspE[i].style.display = '';
            }
            if (event.currentTarget.classList[0] == 'opnBtn') {
                let currentTarget = event.target.parentElement.parentElement.nextSibling;
                while (currentTarget) {
                    if (currentTarget.localName != 'li') {
                        currentTarget = currentTarget.nextSibling;
                        continue;
                    }
                    if (
                        currentTarget.classList &&
                        currentTarget.classList.length > 2 &&
                        currentTarget.classList[1] == 'ui-ccbtn' &&
                        currentTarget.classList[2] == 'bspEntry'
                    ) {
                        currentTarget.style.display = '';
                    } else {
                        if (
                            currentTarget.classList &&
                            currentTarget.classList.length < 3 &&
                            currentTarget.classList[1] == 'ui-ccbtn'
                        ) {
                            break;
                        }
                    }
                    currentTarget = currentTarget.nextSibling;
                }
                event.currentTarget.style.display = 'none';
                event.currentTarget.nextSibling.style.display = '';
                event.currentTarget.nextSibling.focus();
            } else {
                event.currentTarget.style.display = 'none';
                event.currentTarget.previousSibling.style.display = '';
                event.currentTarget.previousSibling.focus();
            }
            event.stopPropagation();
        }

        ccSelectPreDOC(event) {
            this.ec.sessionResults.style.display = 'block';
            this.ec.sessionNote.style.display = 'none';
            if (!this.gender || !this.dob) {
                this.alert('Genotype and DOB are required');
                return;
            }
            this.ec.mmContent.style.display = 'none';
            this.cc = event.currentTarget.childNodes[0].innerText;
            this.dob = this.values.dob;
            this.gender = this.values.g;
            delete this.values.g;
            delete this.values.dob;
            this.tXe.start(this.cc, this.dob, this.gender, this.values);
            this.ec.library.disabled = true;
            this.ec.library.style.opacity = 0.25;
            this.ec.qAndA.disabled = false;
            this.ec.qAndA.style.opacity = 1.0;
            this.ec.results.disabled = false;
            this.ec.results.style.opacity = 1.0;
        }

        ccSelect(event) {
            this.ec.sessionResults.style.display = 'block';
            this.ec.sessionNote.style.display = 'none';
            if (!this.gender || !this.dob) {
                this.alert('Genotype and DOB are required');
                return;
            }
            this.ec.mmContent.style.display = 'none';
            if (event.currentTarget.childNodes[0].innerText) this.cc = event.currentTarget.childNodes[0].innerText;
            else this.cc = event.currentTarget.childNodes[0].textContent;
            if (this.cc.startsWith('Switch to:')) {
                this.cc = this.cc.substr(12);
            }
            this.dob = this.values.dob;
            this.gender = this.values.g;
            delete this.values.g;
            delete this.values.dob;
            let lValues = Object.assign({}, this.values);
            if (Object.keys(lValues).length > 0) {
                for (const vp in lValues) {
                    if (lValues.hasOwnProperty(vp)) {
                        if (this.mapStartProperties.hasOwnProperty(vp)) {
                            lValues[this.mapStartProperties[vp]] = lValues[vp];
                            delete lValues[vp];
                        }
                    }
                }
            }
            this.ec.recommendationscontainer.style.display = 'block';
            this.ec.library.disabled = true;
            this.ec.library.style.opacity = 0.25;
            this.ec.qAndA.disabled = false;
            this.ec.qAndA.style.opacity = 1.0;
            this.ec.results.disabled = false;
            this.ec.results.style.opacity = 1.0;
            var rsp = {
                dataPoint: {
                    Minutes: {
                        type: 'Number',
                        min: 1,
                        max: 59,
                        step: 1.0,
                        integral: true
                    },
                    Hours: {
                        type: 'Number',
                        min: 1,
                        max: 23,
                        step: 1.0,
                        integral: true
                    },
                    Days: {
                        type: 'Number',
                        min: 1,
                        max: 31,
                        step: 1.0,
                        integral: true
                    },
                    Weeks: {
                        type: 'Number',
                        min: 1,
                        max: 19,
                        step: 1.0,
                        integral: true
                    },
                    Months: {
                        type: 'Number',
                        min: 1,
                        max: 18,
                        step: 1.0,
                        integral: true
                    },
                    Years: {
                        type: 'Number',
                        min: 1,
                        max: 5,
                        step: 1.0,
                        integral: true
                    },
                    name: 'durationofchiefcomplaint',
                    descriptor: 103,
                    units: 'Hours',
                    unitsList: ['Minutes', 'Hours', 'Days', 'Weeks', 'Months', 'Years']
                },
                locationType: 'Data Point',
                navigationMethods: ['Next'],
                session: 'sess',
                prompt: 'Select duration of ' + this.cc + ':',
                demographics: {
                    dob: this.dob,
                    age: this.age,
                    gender: this.gender
                },
                hint: ''
            };
            if (Object.keys(lValues).length > 0) {
                rsp.values = Object.assign(lValues);
            }
            this.nextState = 'Start';
            this.tXeAtDataPoint(rsp);
        }
        isValidDatalistValue(idDataList, inputValue) {
            //this function is modified in the extending class
        }
        doNext(event) {
            var value;
            var unit;
            if (event.target.inputControl) {
                var icType = event.target.inputControl.dataPoint[event.target.inputControl.dataPoint.units].type;
                if (icType == 'Number') {
                    value = event.target.inputControl.value;
                    if (!this.isValidDatalistValue('qaNumericList', value)) {
                        this.alert(
                            'Number must be between ' +
                                event.target.inputControl.min +
                                ' and ' +
                                event.target.inputControl.max
                        );
                        return;
                    }
                    this.ec.qaNumericList.innerHTML = '';
                }
                if (icType == 'Date') {
                    value = event.target.inputControl.value;
                    if (!this.isValidDatalistValue('qaDateList', value)) {
                        this.alert(
                            'Date must be between ' +
                                event.target.inputControl.minDate +
                                ' and ' +
                                event.target.inputControl.maxDate
                        );
                        return;
                    }
                }
                if (icType == 'List') {
                    value = event.target.inputControl.value;
                    if (!this.isValidDatalistValue('qaListList', value)) {
                        this.alert(
                            'Height must be between ' +
                                event.target.inputControl.minList +
                                ' and ' +
                                event.target.inputControl.maxList
                        );
                        return;
                    }
                }
                if (event.target.inputControl.unit != 'na') {
                    unit = event.target.inputControl.unit;
                }
            }
            if (this.nextState == 'Start') {
                this.nextState = '';
                this.values.durationofchiefcomplaint = {
                    value: value + ' ' + unit
                };
                this.tXe.start(this.cc, this.dob, this.gender, this.values);
                return;
            } else {
                this.tXe.next(value, unit);
            }
        }
        doNo() {
            this.tXe.no();
        }
        doYes() {
            this.tXe.yes();
        }
        doBack() {
            this.tXe.previous();
        }
        generateInstructionList() {
            //this function is modified in the extending class
        }
        b64encode(number, length) {
            var _keyStr = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
            var s = '';
            var n = 0;
            for (n = number; n > 0; n >>>= 6) {
                s = _keyStr[n & 0x3f] + s;
            }
            s = 'A'.repeat(length - s.length) + s;
            return s;
        }
        hash(str) {
            var i,
                l,
                hval = 0x811c9dc5;
            for (i = 0, l = str.length; i < l; i++) {
                hval ^= str.charCodeAt(i);
                hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
            }
            return hval >>> 0;
        }
        generateCoachKey(nData) {
            var wtopics = [];
            if (nData.webtopics) {
                wtopics = nData.webtopics;
            }
            if (wtopics.length > 0) {
                var age = parseInt(nData.age);
                var gender = nData.demographics.gender.substr(0, 1);
                var ccid = -1;
                if (nData.ccid) ccid = parseInt(nData.ccid);
                var date = new Date().getTime() / 1000;
                var sDomain = window.location.hostname;
                var k = this.b64encode(date, 6);
                k += this.b64encode(ccid, 6);
                k += this.b64encode(this.hash(sDomain), 6);
                var ag = age + (gender.toLowerCase() === 'm' ? 128 : 0);
                k += this.b64encode(ag, 2);
                for (var i = 0; i < wtopics.length; i++) {
                    k += this.b64encode(this.hash(wtopics[i].toLowerCase().replace(' overview', '')), 6);
                }
                return 'https://vha-pip.dshisystems.net/pi.htm?k=TEA' + k;
            }
            return null;
        }
        doNote(event) {
            var cRsp = {};
            var rsp;
            if (!event.target.rsp) {
                rsp = {};
                if (this.values) {
                    rsp.values = {};
                    Object.assign(this.values, rsp.values);
                    if (!rsp.values.starttime) {
                        rsp.values.starttime = this.startTime;
                    }
                } else {
                    rsp.values.starttime = this.startTime;
                }
                if (this.demographics) {
                    rsp.demographics = this.demographics;
                } else {
                    rsp.demographics = {};
                    rsp.demographics.age = this.age;
                    rsp.demographics.gender = this.gender;
                    rsp.demographics.dob = this.dob;
                }
                if (this.positiveFindings) {
                    rsp.positiveFindings = this.positiveFindings;
                }
                if (this.negativeFindings) {
                    rsp.negativeFindings = this.negativeFindings;
                }
                rsp.earlyTerm = true;
            } else {
                rsp = event.target.rsp;
            }
            if (rsp.earlyTerm) {
                cRsp.earlyTerm = rsp.earlyTerm;
            }
            if (rsp.vcModality) {
                cRsp.vcModality = rsp.vcModality;
            }
            if (rsp.syndromics) {
                cRsp.syndromics = rsp.syndromics;
            }
            if (rsp.demographics.gender) {
                cRsp.gender = rsp.demographics.gender;
            }
            if (rsp.demographics.dob) {
                cRsp.dob = new Date(rsp.demographics.dob);
            }
            if (rsp.demographics.cc) {
                cRsp.cc = rsp.demographics.cc;
            }
            if (rsp.demographics.age) {
                cRsp.age = rsp.demographics.age;
            }
            if (rsp.values) {
                if (rsp.values.starttime) {
                    cRsp.startTime = rsp.values.starttime;
                }
                if (rsp.values.duration) {
                    cRsp.duration = parseInt(rsp.values.duration) * 1000;
                }
                if (rsp.values.height) {
                    cRsp.height = rsp.values.height;
                }
                if (rsp.values.weight) {
                    cRsp.weight = rsp.values.weight;
                }
                if (rsp.values.systolicbloodpressure) {
                    cRsp.systolicBloodPressure = rsp.values.systolicbloodpressure;
                }
                if (rsp.values.diastolicbloodpressure) {
                    cRsp.diastolicBloodPressure = rsp.values.diastolicbloodpressure;
                }
                if (rsp.values.temperature) {
                    cRsp.temperature = rsp.values.temperature;
                }
                if (rsp.values.serumglucose) {
                    cRsp.serumGlucose = rsp.values.serumglucose;
                }
                if (rsp.values.pefrbaseline) {
                    cRsp.pefrBaseline = rsp.values.pefrbaseline;
                }
                if (rsp.values.pefrcurrent) {
                    cRsp.pefrCurrent = rsp.values.pefrcurrent;
                }
                if (rsp.values.lnmp) {
                    cRsp.lnmp = this.stringToDate(rsp.values.lnmp);
                }
                if (rsp.values.respiratoryrate) {
                    cRsp.respiratoryRate = rsp.values.respiratoryrate;
                }
                if (rsp.values.ox) {
                    cRsp.o2 = rsp.values.ox;
                }
                if (rsp.values.pulse) {
                    cRsp.pulse = rsp.values.pulse;
                }
                if (rsp.values.durationofcomplaint) {
                    cRsp.durationOfComplaint = rsp.values.durationofcomplaint;
                }
                if (rsp.values.gestationalage) {
                    cRsp.gestationalAge = rsp.values.gestationalage;
                }
                if (rsp.values.bmi) {
                    cRsp.bmi = rsp.values.bmi;
                }
                if (rsp.values.peakflowpctbest) {
                    cRsp.peakFlowPctBest = rsp.values.peakflowpctbest;
                }
                if (rsp.values.meanarterialpressure) {
                    cRsp.meanArterialPressure = rsp.values.meanarterialpressure;
                }
                if (rsp.values.modifiedshockindex) {
                    cRsp.modifiedShockIndex = rsp.values.modifiedshockindex;
                }
                if (rsp.values.pulsepressure) {
                    cRsp.pulsePressure = rsp.values.pulsepressure;
                }
            }
            if (rsp.negativeFindings) {
                cRsp.negativeFindings = rsp.negativeFindings;
            }
            if (rsp.positiveFindings) {
                cRsp.positiveFindings = rsp.positiveFindings;
            }
            if (rsp.predictedResources) {
                cRsp.predictedResources = rsp.predictedResources;
            }
            if (rsp.systemConcern) {
                cRsp.systemConcern = rsp.systemConcern;
            }
            if (rsp.demographics.cc) {
                if (rsp.when) {
                    cRsp.systemRfi = rsp.when;
                }
                if (rsp.where) {
                    cRsp.systemRfl = rsp.where[0].replace(' | Office', '');
                }
                if (this.standAlone) {
                    var nurserfl = this.ec.rsltwhere.value;
                    if (nurserfl) {
                        cRsp.nurseRfl = nurserfl.replace(' | Office', '');
                    }
                    var nurserfi = this.ec.rsltwhen.value;
                    if (nurserfi) {
                        cRsp.nurseRfi = nurserfi;
                    }
                }
                if (rsp.etreatable && rsp.etreatable === true) {
                    cRsp.eTreatable = true;
                }
            }
            if (this.ec.piinclude.checked) {
                var pii = this.ec.piinformation.innerText;
                if (pii && pii.length > 0) {
                    cRsp.patientInstructionsText = this.getPatientInformationText.bind(this)();
                }
            }
            rsp.webtopics = undefined;
            rsp.verbaltopics = undefined;
            var instructions = this.generateInstructionList.bind(this)();
            if (instructions.webtopics) {
                rsp.webtopics = instructions.webtopics;
                var coachKey = this.generateCoachKey.bind(this)(rsp);
                if (coachKey) {
                    cRsp.webInstructions = coachKey;
                }
            }
            if (instructions.verbaltopics) {
                cRsp.verbalTopics = instructions.verbaltopics;
            }
            if (instructions.webtopics) {
                cRsp.webTopics = instructions.webtopics;
            }
            var educationLog = this.ec.educationlog.value;
            if (educationLog && educationLog.length > 0) {
                cRsp.educationLog = educationLog;
            }
            if (rsp.assessments) {
                cRsp.assessments = rsp.assessments;
            }
            if (rsp.alerts) {
                cRsp.alerts = rsp.alerts;
            }
            this.ec.sessionResults.style.display = 'none';
            var note = this.generateNote(cRsp) + '\n';
            var noteBody = this.ec.notebody;
            noteBody.value = note;
            noteBody.cRsp = cRsp;
            this.ec.sessionNote.style.display = 'block';
            if (this.fixed) {
                noteBody.style.height = '1px';
                var sh = noteBody.scrollHeight + 'px';
                noteBody.style.height = sh;
            } else {
                if (!this.notebodyregistered) {
                    this.notebodyregistered = true;
                    this.autosizeregister(this.ec.notebody);
                }
                this.autosizeupdate(noteBody);
            }
        }
        walkNodes(domEntry, text, indent) {
            var i;
            switch (domEntry.nodeName) {
                case '#text':
                    text += indent + domEntry.textContent;
                    break;
                case 'BR':
                    text += '\n';
                    break;
                case 'UL':
                    indent += '\t';
                    for (i = 0; i < domEntry.childNodes.length; i++)
                        text = this.walkNodes(domEntry.childNodes[i], text, indent);
                    indent = indent.substr(0, indent.length - 1);
                    break;
                case 'DIV':
                    for (i = 0; i < domEntry.childNodes.length; i++)
                        text = this.walkNodes(domEntry.childNodes[i], text, indent);
                    text += '\n';
                    break;
                case 'LI':
                    for (i = 0; i < domEntry.childNodes.length; i++)
                        text = this.walkNodes(domEntry.childNodes[i], text, indent);
                    text += '\n';
                    break;
                default:
                    for (i = 0; i < domEntry.childNodes.length; i++)
                        text = this.walkNodes(domEntry.childNodes[i], text, indent);
                    break;
            }
            return text;
        }
        getPatientInformationText() {
            var piiHTML = this.ec.piinformation;
            return this.walkNodes(piiHTML, '', '\t\t').replace(/\s+$/, '');
        }
        doViewResults() {
            this.ec.sessionNote.style.display = 'none';
            this.ec.sessionResults.style.display = 'block';
        }
        @api
        doResetComponent() {
            this.ec.cvc.style.display = 'none';
            this.ec.rdemobtn.style.display = 'none';
            this.ec.rfindingsbtn.style.display = 'none';
            this.ec.rvaluebtn.style.display = 'none';
            this.ec.library.disabled = true;
            this.ec.library.style.opacity = 0.25;
            this.ec.qAndA.disabled = true;
            this.ec.qAndA.style.opacity = 0.25;
            this.ec.results.disabled = true;
            this.ec.results.style.opacity = 0.25;
            this.ec.sessionResults.style.display = 'inline-block';
            this.ec.mmInput.style.display = 'none';
            this.ec.sysconcern.innerText = '';
            this.ec.sysconcerncontainer.style.display = 'none';
            this.ec.assessments.style.display = 'none';
            this.ec.assessmentsList.innerHTML = '';
            this.ec.alerts.style.display = 'none';
            this.ec.alertsList.innerHTML = '';
            if (!this.standAlone) {
                this.ec.rsltwhen.innerHTML = '';
            } else {
                var wSelect = this.ec.rsltwhen;
                for (i = 0; i < wSelect.options.length; i++) {
                    wSelect.options[i].innerText = wSelect.options[i].value;
                }
            }
            if (!this.standAlone) {
                this.ec.rsltwhere.innerHTML = '';
            } else {
                wSelect = this.ec.rsltwhere;
                for (i = 0; i < wSelect.options.length; i++) {
                    wSelect.options[i].innerText = wSelect.options[i].value;
                }
            }
            this.ec.predicteresourcescontainer.style.display = 'none';
            this.ec.piList.innerHTML = '';
            this.ec.picontainer.style.display = 'none';
            this.ec.piinclude.checked = false;
            this.ec.piinformation.innerHTML = '';
            this.ec.educationlog.value = '';
            this.openTab.bind(this)(null, 'qAndA');
            this.ec.library.disabled = true;
            this.ec.library.style.opacity = 0.25;
            this.ec.qAndA.disabled = true;
            this.ec.qAndA.style.opacity = 0.25;
            this.ec.qaContent.style.display = 'none';
            this.ec.mmContent.style.display = 'block';
            this.ec.mmList.innerHTML = '';
            this.ec.mmInput.value = '';
            this.ec.sessionNote.style.display = 'none';
            this.ec.notebody.value = '';
            this.careLinks = {};
            this.careLinksCount = 0;
            this.ec.picltable.innerHTML = '';
            this.ec.piclcontainer.style.display = 'none';
            this.ec.libTXL.reset();
            delete this.ec.notebtn.rsp;
            delete this.positiveFindings;
            delete this.negativeFindings;
            delete this.demographics;
            delete this.startTime;
            this.ec.recommendationscontainer.style.display = 'none';
        }
        doNoteDone() {
            var note = this.ec.notebody.value;
            var cRsp = this.ec.notebody.cRsp;
            cRsp.triageNote = note;
            if (this.standAlone) {
                if (!this.manualClipboardCopy) {
                    navigator.clipboard.writeText(note).then(
                        () => {
                            alert('Note has automatically been copied to clipboard');
                            this.doResetComponent.bind(this)();
                            var e = new CustomEvent('complete', {
                                detail: cRsp
                            });
                            this.dispatchEvent(e);
                        },
                        () => {
                            // cannot automatically copy to clipboard
                            this.manualClipboardCopy = true;
                            if (
                                !confirm(
                                    'Warning:  Make sure you have copied this note to your clipboard before pressing OK.  If you need to go back to copy to clipboard, press CANCEL to return to the triage note.'
                                )
                            ) {
                                return;
                            } else {
                                this.doResetComponent.bind(this)();
                                var e = new CustomEvent('complete', {
                                    detail: cRsp
                                });
                                this.dispatchEvent(e);
                            }
                        }
                    );
                } else {
                    if (
                        !confirm(
                            'Warning:  Make sure you have copied this note to your clipboard before pressing OK.  If you need to go back to copy to clipboard, press CANCEL to return to the triage note.'
                        )
                    ) {
                        return;
                    } else {
                        this.doResetComponent.bind(this)();
                        var e = new CustomEvent('complete', {
                            detail: cRsp
                        });
                        this.dispatchEvent(e);
                    }
                }
            } else {
                this.doResetComponent.bind(this)();
                var e = new CustomEvent('complete', {
                    detail: cRsp
                });
                this.dispatchEvent(e);
            }
        }
        generateNote(nData) {
            var i;
            var note = 'Phone Triage\n';
            if (nData.startTime) note += nData.startTime + '\n';
            note += '\nDemographics' + '\n';
            note += '\t' + nData.age.replace('Years', 'y/o').replace('Months', 'm/o') + ' ' + nData.gender + '\n';
            if (nData.lastname || nData.firstname) {
                note += '\t';
                if (nData.lastname) {
                    note += nData.lastname;
                    if (nData.firstname) {
                        note += ', ';
                    }
                }
                if (nData.firstname) {
                    note += nData.firstname;
                }
                note += '\n';
            }
            if (nData.cc) {
                note += '\nResults\n';
            }
            if (nData.cc) {
                note += '\tCC: ' + nData.cc + '\n';
            }
            if (nData.earlyTerm) {
                note +=
                    '\n\tNote:  TXCC was exited prior to triage history completion and triage urgency assignment.\n';
            }
            if (nData.durationofcc) {
                note += '\t' + nData.durationofcc + '\n';
            }
            if (nData.painlevel) {
                note += '\t' + nData.painlevel + '\n';
            }
            if (nData.nurseRfi) {
                note += '\tNurse selected: ' + nData.nurseRfi + '\n';
            }
            if (nData.nurseconsidervirtualcare === true) {
                note += 'Nurse selected: consider virtual care\n';
            }
            if (nData.nurseRfl) {
                note += '\tNurse selected follow-up location: ' + nData.nurseRfl;
                if (nData.nurseconsidervirtualcare && nData.nurseconsidervirtualcare === true) {
                    note += ', consider virtual care';
                }
                note += '\n';
            }
            if (nData.systemRfi) {
                note += '\tSoftware suggested: ' + nData.systemRfi + '\n';
            }
            if (nData.systemRfl) {
                note += '\tSoftware suggested follow-up location: ' + nData.systemRfl;
                if (nData.eTreatable && nData.eTreatable === true) {
                    note += ', consider virtual care';
                }
                note += '\n';
            }

            var vm = '';
            for (i = 0; i < this.valuesAndMeasuresToNote.length; i++) {
                var property = this.valuesAndMeasuresToNote[i];
                if (nData.hasOwnProperty(property)) {
                    if (property == 'lnmp')
                        vm += '\t' + this.valuesAndMeasuresTitlesNote[i] + ': ' + this.dateToString(nData[property]);
                    else if (this.valuesAndMeasuresUnits.hasOwnProperty(property))
                        vm +=
                            '\t' +
                            this.valuesAndMeasuresTitlesNote[i] +
                            ': ' +
                            nData[property] +
                            ' ' +
                            this.valuesAndMeasuresUnits[property];
                    else vm += '\t' + this.valuesAndMeasuresTitlesNote[i] + ': ' + nData[property];
                    if (this.valuesAndMeasuresToNoteSupplmental[property]) {
                        vm += ' ' + this.valuesAndMeasuresToNoteSupplmental[property];
                    }
                    vm += '\n';
                }
            }
            if (vm.length > 0) {
                note += '\nValues and Measures\n';
                note += vm;
            }
            if (nData.alerts) {
                var alerts = '';
                for (var aii = 0; aii < nData.alerts.length; aii++) {
                    alerts += '\t' + (aii + 1) + ')  ' + nData.alerts[aii].text + '\n\n';
                }
                if (alerts.length > 0) {
                    note += '\nAlerts\n\n';
                    note += alerts;
                }
            }
            if (nData.positiveFindings && nData.positiveFindings.length > 0) {
                note += '\nPositive Responses\n';
                note += '\t' + nData.positiveFindings.join('\n\t') + '\n';
            }
            if (nData.negativeFindings && nData.negativeFindings.length > 0) {
                note += '\nNegative Responses\n';
                note += '\tDenies: ' + nData.negativeFindings.join('\n\tDenies: ') + '\n';
            }
            if (nData.verbalTopics || nData.patientInstructionsText || nData.webInstructions) {
                note += '\nVeteran Education\n';
                if (nData.verbalTopics && nData.verbalTopics.length > 0) {
                    note += '\n\tVerbal Education Provided for:\n';
                    for (i = 0; i < nData.verbalTopics.length; i++) {
                        note += '\t\t' + nData.verbalTopics[i] + '\n';
                    }
                    note += '\n';
                }
                if (nData.patientInstructionsText) {
                    note += '\n\tVerbal Education Provided:\n';
                    note += nData.patientInstructionsText;
                }
                if (nData.webInstructions) {
                    note += '\tWeb Instructions:\n\t\t' + nData.webInstructions + '\n';
                }
            }
            if (nData.educationLog) {
                note += '\nEducation Log\n\t' + nData.educationLog.replace(/\n/g, '\n\t');
            }
            return note;
        }
        tXeAtReport(rsp) {
            //this function is modified in the extending class
        }
        round(value, precision) {
            var multiplier = Math.pow(10, precision || 0);
            return Math.round(value * multiplier) / multiplier;
        }
        tXeAtDataPoint(rsp) {
            //this function is modified in the extending class
        }
        setupDataPoint(dataPoint, units, newValue) {
            var i;
            var option;
            var input;
            var dl;

            if (dataPoint[units].type == 'Number') {
                input = this.ec.qaNumber;
                var isIntegral = false;
                input.dataPoint = dataPoint;
                input.min = input.dataPoint[units].min;
                input.max = input.dataPoint[units].max;
                input.step = input.dataPoint[units].step;
                input.unit = units;
                if (input.dataPoint[units].integral) {
                    isIntegral = true;
                }
                if (!input.value) {
                    if (input.dataPoint.value) input.value = input.dataPoint.value;
                    else input.value = '';
                }

                dl = this.ec.qaNumericList;
                dl.innerHTML = '';
                var precision = 0;
                if (input.step == 0.1) {
                    precision = 1;
                }
                var n = parseFloat(input.min);
                var x = parseFloat(input.max);
                var s = parseFloat(input.step);
                var valueMaps = false;
                for (i = n; i <= x; i += s) {
                    option = document.createElement('option');
                    option.value = this.round(i, precision);
                    if (option.value == input.value) valueMaps = true;
                    dl.appendChild(option);
                    if (!isIntegral) {
                        if (option.value.indexOf('.') < 0) {
                            option = document.createElement('option');
                            option.value = this.round(i, precision) + '.0';
                            if (option.value == input.value) valueMaps = true;
                            dl.appendChild(option);
                        }
                    }
                }
                if (!valueMaps) this.ec.qaNumber.value = '';
                this.ec.qanextbtn.inputControl = input;
                this.ec.qadatapoint.style.display = 'block';
                this.ec.qaNumeric.style.display = 'inline-block';
                this.ec.qaList.style.display = 'none';
                this.ec.qaDate.style.display = 'none';
            } else {
                if (dataPoint[dataPoint.units].type == 'Date') {
                    input = this.ec.qaDateInput;
                    input.dataPoint = dataPoint;
                    input.minDate = new Date(dataPoint[units].min);
                    input.maxDate = new Date(dataPoint[units].max);
                    if (dataPoint.value) {
                        input.value = dataPoint.value;
                    }
                    dl = this.ec.qaDateList;
                    dl.innerHTML = '';
                    var currentDate = input.minDate;
                    while (currentDate.getTime() < input.maxDate.getTime()) {
                        var y = currentDate.getFullYear();
                        var m = currentDate.getMonth() + 1;
                        var d = currentDate.getDate();
                        var ms = m < 10 ? '0' + m : '' + m;
                        var ds = d < 10 ? '0' + d : '' + d;
                        var dStr2 = ms + '/' + ds + '/' + y;
                        option = document.createElement('option');
                        option.value = dStr2;
                        option.text = dStr2;
                        dl.appendChild(option);
                        currentDate = currentDate.addDays(1);
                    }
                    this.ec.qadatapoint.style.display = 'block';
                    this.ec.qaNumeric.style.display = 'none';
                    this.ec.qaList.style.display = 'none';
                    this.ec.qaDate.style.display = 'inline-block';
                    this.ec.qaUnits.style.display = 'none';
                    this.ec.qanextbtn.inputControl = input;
                } else {
                    if (dataPoint[dataPoint.units].type == 'List') {
                        input = this.ec.qaListInput;
                        input.dataPoint = dataPoint;
                        if (dataPoint.value) {
                            input.value = dataPoint.value;
                        }
                        input.unit = dataPoint.units;
                        dl = this.ec.qaListList;
                        dl.innerHTML = '';
                        var vList = input.dataPoint[units].list;
                        for (i = 0; i < vList.length; i++) {
                            option = document.createElement('option');
                            option.value = vList[i];
                            option.text = vList[i];
                            dl.appendChild(option);
                        }
                        this.ec.qadatapoint.style.display = 'block';
                        this.ec.qaNumeric.style.display = 'none';
                        this.ec.qaList.style.display = 'inline-block';
                        this.ec.qaDate.style.display = 'none';
                        this.ec.qaUnits.style.display = 'none';
                        this.ec.qanextbtn.inputControl = input;
                    } else {
                        this.alert('Data Input is not implemented');
                    }
                }
            }
        }

        tXeAtQuestion(rsp) {
            var vm;
            var pf;
            var i;
            var node;
            var textnode;
            var valueDataList;
            var row;
            var vc;
            let title;

            this.ec.sessionNote.style.display = 'none';
            this.ec.sessionResults.style.display = '';

            if (this.ec.qanextbtn.inputControl) {
                this.ec.qanextbtn.inputControl = undefined;
            }
            this.ec.qadatapoint.style.display = 'none';
            this.ec.qaContent.style.display = 'inline-block';
            if (rsp.rationale) {
                this.ec.qareasoning.innerText = rsp.rationale;
            }
            if (rsp.prompt) {
                this.ec.qaprompt.innerText = rsp.prompt;
            } else {
                this.ec.qaprompt.innerText = '';
            }
            if (rsp.hint) {
                this.ec.qaassisttext.innerText = rsp.hint;
            } else {
                this.ec.qaassisttext.innerText = '';
            }
            if (rsp.navigationMethods.includes('Next')) {
                this.ec.qanextbtn.style.display = 'inline-block';
            } else {
                this.ec.qanextbtn.style.display = 'none';
            }
            if (rsp.navigationMethods.includes('Yes')) {
                this.ec.qayesbtn.style.display = 'inline-block';
            } else {
                this.ec.qayesbtn.style.display = 'none';
            }
            if (rsp.navigationMethods.includes('No')) {
                this.ec.qanobtn.style.display = 'inline-block';
            } else {
                this.ec.qanobtn.style.display = 'none';
            }
            if (rsp.navigationMethods.includes('Previous')) {
                this.ec.qabackbtn.style.display = 'inline-block';
            } else {
                this.ec.qabackbtn.style.display = 'none';
            }
            if (rsp.demographics) {
                this.demographics = rsp.demographics;
                valueDataList = this.ec.qasessiondatalist;
                valueDataList.innerHTML = '';
                vm = '';
                vc = 0;
                for (i = 0; i < this.demographicsToShow.length; i++) {
                    if (rsp.demographics.hasOwnProperty(this.demographicsToShow[i])) {
                        title = this.demographicsTitles[i];
                        vm = rsp.demographics[this.demographicsToShow[i]];
                        if (this.demographicsToShow[i] == 'dob') {
                            vm = this.dateToString(new Date(vm));
                        }
                        row = valueDataList.insertRow(-1);
                        row.insertCell(0).innerHTML = title;
                        row.insertCell(1).innerHTML = vm;
                        vc++;
                    }
                }
            }
            if (rsp.positiveFindings) {
                this.positiveFindings = rsp.positiveFindings;
                pf = this.ec.qaPositiveFindings;
                pf.innerHTML = '';
                for (i = 0; i < rsp.positiveFindings.length; i++) {
                    node = document.createElement('LI');
                    textnode = document.createTextNode(rsp.positiveFindings[i]);
                    node.appendChild(textnode);
                    pf.appendChild(node);
                }
                this.ec.qapositivehdr.style.display = 'block';
                pf.style.display = 'block';
            } else {
                this.ec.qapositivehdr.style.display = 'none';
                this.ec.qaPositiveFindings.style.display = 'none';
            }
            if (rsp.negativeFindings) {
                this.negativeFindings = rsp.negativeFindings;
                pf = this.ec.qaNegativeFindings;
                pf.innerHTML = '';
                for (i = 0; i < rsp.negativeFindings.length; i++) {
                    node = document.createElement('LI');
                    textnode = document.createTextNode(rsp.negativeFindings[i]);
                    node.appendChild(textnode);
                    pf.appendChild(node);
                }
                this.ec.qanegativehdr.style.display = 'block';
                pf.style.display = 'block';
            } else {
                this.ec.qanegativehdr.style.display = 'none';
                this.ec.qaNegativeFindings.style.display = 'none';
            }
            if (rsp.positiveFindings || rsp.negativeFindings) {
                this.ec.findingscontainer.style.visibility = 'visible';
            } else {
                this.ec.findingscontainer.style.visibility = 'hidden';
            }
            if (rsp.values) {
                if (this.nextState != 'Start') {
                    this.values = rsp.values;
                }
                valueDataList = this.ec.valuedatalist;
                valueDataList.innerHTML = '';
                vm = '';
                vc = 0;
                for (i = 0; i < this.valuesAndMeasuresToShow.length; i++) {
                    if (rsp.values.hasOwnProperty(this.valuesAndMeasuresToShow[i])) {
                        title = this.valuesAndMeasuresTitles[i];
                        if (this.valuesAndMeasuresUnits.hasOwnProperty(this.valuesAndMeasuresToShow[i]))
                            vm =
                                rsp.values[this.valuesAndMeasuresToShow[i]] +
                                ' ' +
                                this.valuesAndMeasuresUnits[this.valuesAndMeasuresToShow[i]];
                        else vm = rsp.values[this.valuesAndMeasuresToShow[i]];
                        if (typeof rsp.values[this.valuesAndMeasuresToShow[i]].getMonth === 'function')
                            vm = this.dateToString(vm);
                        row = valueDataList.insertRow(-1);
                        row.insertCell(0).innerHTML = title;
                        row.insertCell(1).innerHTML = vm;
                        vc++;
                    }
                }
                if (vc > 0) {
                    this.ec.valuecontainer.style.visibility = 'visible';
                } else {
                    this.ec.valuecontainer.style.visibility = 'hidden';
                }
            } else {
                this.ec.valuecontainer.style.visibility = 'hidden';
            }
        }
        doLibraryBack() {
            this.ec.tab.style.display = 'inline-block';
            this.ec.tabContent.style.display = 'inline-block';
            this.ec.tctLibraryPopup.style.display = 'none';
        }
        handleLibraryClick(event) {
            //this is modified in the extending class
        }
        tXeOnError(eData) {
            if (eData.rsp.status == 'Invalid Session') {
                alert('Lost Session');
            }
        }

        onDateKeypress(e) {
            //modified in extending class
        }
        onHeightKeypress(e) {
            //modified in extending class
        }
        onNumberKeypress(e) {
            //this function is modified in the extending class
        }
        isValidDataListPartialValue(listId, value) {
            //this function is modified in the extending class
        }
        stringToDate(s) {
            var m = s.substring(0, 2);
            var d = s.substring(3, 5);
            var y = s.substring(6, 10);
            return new Date(parseInt(y), parseInt(m) - 1, parseInt(d));
        }

        dateToString(d) {
            if (!(d instanceof Date)) return '';
            var m = (d.getMonth() + 1).toString();
            if (m.length < 2) m = '0' + m;
            var dy = d.getDate().toString();
            if (dy.length < 2) dy = '0' + dy;
            var y = (d.getYear() + 1900).toString();
            return m + '/' + dy + '/' + y;
        }
    };
}
/* eslint-enable */
