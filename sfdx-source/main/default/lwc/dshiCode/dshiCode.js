/* txEngine 1.0.0
 */

// disabling eslint for this file because it is a copy of third party code
/* eslint-disable */
export function tXengine(options, THIS) {
    this.scope = THIS;
    this.localDemographics = {};
    this.demographicList = ['cc', 'gender', 'age', 'dob'];
    this.valueList = [
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
        'starttime',
        'duration',
        'ox',
        'meanarterialpressure',
        'modifiedshockindex',
        'pulsepressure',
        'duration'
    ];
    this.whereMap = {
        'Emergency Room': 'Emergency department',
        'Doctor Office': 'Clinic | Office',
        'Doctor eVisit': 'Virtual Care',
        'Urgent Care': 'Urgent care center',
        'Dentist Office': 'Dentist Office',
        Home: 'Home'
    };
    this.whenMap = {
        '911 emergency': 'Now, 911',
        Immediate: 'Now',
        '1-2 weeks': 'Within 2 Weeks',
        'Self-care': 'Self-care',
        '2-3 days': 'Within 3 Days',
        '2-8 hours': 'Within 8 Hours',
        '12-24 hours': 'Within 24 Hours'
    };
    if (!options.appId || options.appId == '') {
        throw 'Required Application Id (appID) is not provided.';
    }
    this.appId = options.appId;
    if (options.url && options.url != '') {
        this.url = options.url + 'txnet20wse/';
    } else {
        if (!window.location.origin) {
            this.url = window.location.protocol + '//' + window.location.host + '/txnet20wse/';
        } else {
            this.url = window.location.origin + '/txnet20wse/';
        }
    }
    this.loadSymMenu = async function (req, THIS) {
        const symMenu = await fetch(req + 'symmenu.json').then((response) => response.json());
        const suggestMenu = await fetch(req + 'suggestmenu.json').then((response) => response.json());
        THIS.sym = symMenu;
        THIS.bsp = suggestMenu.menu;
    };
    this.loadSymMenu(options.url, THIS);
    if (options.timeout) {
        this.timeout = options.timeout;
    } else {
        this.timeout = 10000;
    }
    if (!_isSetup(this)) {
        throw 'Missing Required Options';
    }

    function _isSetup(THIS) {
        if (!THIS.url || THIS.url == '') {
            return false;
        }
        if (!THIS.appId || THIS.appId == '') {
            return false;
        }
        return true;
    }

    function _calculateAgeYM(dob) {
        var date;
        if (typeof dob === 'string') {
            date = new Date(dob);
        } else {
            if (typeof dob === 'object') {
                date = dob;
            } else {
                throw new Error('Invalid type for date variable passed to calculateAge');
            }
        }
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
    this.start = function (chiefComplaint, dob, gender, values) {
        if (values.startTime) {
            delete values.startTime;
        }
        var req =
            this.url +
            '?m=Start&appID=' +
            this.appId +
            '&d=1&v=' +
            gender +
            '&d=300&v=' +
            _calculateAgeYM(dob).replace(' ', '&u=') +
            '&d=200&v=' +
            chiefComplaint;
        if (values) {
            for (var property in values) {
                if (values[property].value) {
                    var pText = property;
                    if (pText.substr(0, 2) == 'D_') {
                        pText = pText.substr(2);
                    }
                    if (pText.toLowerCase() == 'durationofchiefcomplaint') {
                        pText = '103';
                    }
                    req += '&d=' + pText + '&v=' + values[property].value;
                    if (values[property].units) {
                        req += '&u=' + values[property].units;
                    }
                } else {
                    var vl = values[property];
                    var vu = null;
                    if (typeof vl === 'string') {
                        var sp = vl.indexOf(' ');
                        if (sp >= 0) {
                            vu = vl.substring(sp + 1);
                            vl = vl.substring(0, sp);
                        }
                        vl = vl.replace('%', '%25');
                    }
                    if (property == 'ln' || property == 'dob') {
                        vl = dateToString(vl).replace('/', '%2f');
                    }
                    req += '&d=' + property.toLowerCase() + '&v=' + vl;
                    if (vu) {
                        req += '&u=' + vu.replace('%', '%25');
                    }
                }
            }
        }
        this.localDemographics.dob = dob;
        _processRequest(req, this);
    };
    this.yes = function () {
        var req = this.url + '?m=Walk&session=' + this.sessionId + '&navigationMethod=yes';
        _processRequest(req, this);
    };
    this.no = function () {
        var req = this.url + '?m=Walk&session=' + this.sessionId + '&navigationMethod=no';
        _processRequest(req, this);
    };
    this.next = function (value, units) {
        var req = this.url + '?m=Walk&session=' + this.sessionId + '&navigationMethod=next';
        if (value) {
            req += '&value=' + value;
        }
        if (units) {
            req += '&units=' + units;
        }
        _processRequest(req, this);
    };
    this.previous = function () {
        var req = this.url + '?m=Walk&session=' + this.sessionId + '&navigationMethod=previous';
        _processRequest(req, this);
    };
    this.abort = function (reason) {
        var req;

        req = this.url + '?m=abort';
        if (reason) {
            req += '&reason=' + reason;
        }
        _processRequest(req, this);
    };

    function _setBtnDisabled(element, selector, state) {
        THIS.ec.qanobtn.disabled = state;
        THIS.ec.qayesbtn.disabled = state;
        THIS.ec.qanextbtn.disabled = state;
        THIS.ec.qabackbtn.disabled = state;
    }

    function _processRequest(req, THIS) {
        let i;
        var unitObject;
        var demographics;
        var entry;

        _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', true);
        THIS.scope.ec.controlContainer.classList.add('wait');
        fetch(req, {
            method: 'GET',
            credentials: 'include'
        })
            .then(
                function (response) {
                    if (!response.ok) {
                        THIS.scope.ec.controlContainer.classList.remove('wait');
                        _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                        if (this.listeners && this.listeners.onError) {
                            for (i = 0; i < this.listeners.onError.length; i++) {
                                this.listeners.onError[i](response);
                            }
                        }
                        return;
                    }
                    return response.json();
                }.bind(THIS)
            )
            .then(
                function (rspJSON) {
                    var careLink;
                    if (rspJSON.rsp.status && rspJSON.rsp.status != 'OK') {
                        THIS.scope.ec.controlContainer.classList.remove('wait');
                        _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                        if (this.listeners && this.listeners.onError) {
                            for (let i = 0; i < this.listeners.onError.length; i++) {
                                this.listeners.onError[i](rspJSON);
                            }
                        }
                        return;
                    }
                    this.sessionId = rspJSON.rsp.session;
                    var rspObject = {};
                    var entry;
                    if (rspJSON.rsp.locationType == 'Prompt' || rspJSON.rsp.locationType == 'Data Point') {
                        rspObject.prompt = _stripHTML(rspJSON.rsp.text);
                        if (rspJSON.rsp.helptext && rspJSON.rsp.helptext != '') {
                            rspObject.hint = rspJSON.rsp.helptext;
                        }
                        rspObject.navigationMethods = rspJSON.rsp.navigationMethods;
                        rspObject.rationale = rspJSON.rsp.rationale;

                        rspObject.mediaName = rspJSON.rsp.mediaName;

                        if (rspJSON.rsp.pertinentPositives) {
                            rspObject.positiveFindings = [];
                            for (entry = 0; entry < rspJSON.rsp.pertinentPositives.length; entry++) {
                                rspObject.positiveFindings.push(_stripHTML(rspJSON.rsp.pertinentPositives[entry]));
                            }
                            if (rspJSON.rsp.pertinentPositives.length != rspObject.positiveFindings.length) {
                                txcc_alert('findings mismatch!');
                            }
                        }
                        if (rspJSON.rsp.pertinentNegatives) {
                            rspObject.negativeFindings = [];
                            for (entry = 0; entry < rspJSON.rsp.pertinentNegatives.length; entry++) {
                                if (!rspJSON.rsp.pertinentNegatives[entry].startsWith('VS: '))
                                    rspObject.negativeFindings.push(_stripHTML(rspJSON.rsp.pertinentNegatives[entry]));
                            }
                        }
                        demographics = {};
                        let values = {};
                        Object.keys(this.localDemographics).forEach(
                            function (key, index) {
                                demographics[key] = this.localDemographics[key];
                            }.bind(this)
                        );
                        if (rspJSON.rsp.history) {
                            for (let i = 0; i < rspJSON.rsp.history.length; i++) {
                                entry = rspJSON.rsp.history[i];
                                let eName = entry[0];
                                let eValue = entry[1];
                                if (this.demographicList.indexOf(eName.toLowerCase()) >= 0) {
                                    demographics[eName] = eValue;
                                } else if (this.valueList.indexOf(eName.toLowerCase()) >= 0) {
                                    values[eName] = eValue;
                                }
                            }
                        }
                        if (Object.keys(demographics).length > 0) {
                            rspObject.demographics = demographics;
                        }
                        if (Object.keys(values).length > 0) {
                            rspObject.values = values;
                        }
                        if (rspJSON.rsp.locationType == 'Data Point') {
                            rspObject.dataPoint = {};
                            rspObject.dataPoint.value = rspJSON.rsp.dataPoint.value;
                            if (rspJSON.rsp.dataPoint.units) {
                                rspObject.dataPoint.units = rspJSON.rsp.dataPoint.units;
                            } else {
                                rspObject.dataPoint.units = 'na';
                            }
                            for (var i = 0; i < rspJSON.rsp.dataPoint.validationRules.length; i++) {
                                var ruleParts = rspJSON.rsp.dataPoint.validationRules[i].split(':');
                                var rangeParts = ruleParts[1].split(' ');
                                unitObject = {};
                                unitObject.type = rangeParts[0];
                                if (rangeParts[0] == 'Number') {
                                    unitObject.min = parseFloat(rangeParts[1]);
                                    unitObject.max = parseFloat(rangeParts[3]);
                                    if (rangeParts.length == 6) {
                                        unitObject.step = parseFloat(rangeParts[5]);
                                    }
                                } else if (rangeParts[0] == 'List') {
                                    unitObject.list = rangeParts[1].split('|');
                                } else if (rangeParts[0] == 'Date') {
                                    unitObject.min = parseDate(rangeParts[1]);
                                    unitObject.max = parseDate(rangeParts[3]);
                                } else {
                                    this.alert('invalid validation value type: ' + rangeParts[0]);
                                }
                                var units = ruleParts[0];
                                if (!units || units.length == 0) {
                                    units = 'na';
                                }
                                rspObject.dataPoint[units] = unitObject;
                            }
                            if (this.listeners && this.listeners.atDataPoint) {
                                THIS.scope.ec.controlContainer.classList.remove('wait');
                                _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                                for (i = 0; i < this.listeners.atDataPoint.length; i++) {
                                    this.listeners.atDataPoint[i](rspObject);
                                }
                            }
                        } else {
                            THIS.scope.ec.controlContainer.classList.remove('wait');
                            _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                            if (this.listeners && this.listeners.atQuestion) {
                                for (let i = 0; i < this.listeners.atQuestion.length; i++) {
                                    this.listeners.atQuestion[i].bind(this.scope)(rspObject);
                                }
                            }
                        }
                    } else if (rspJSON.rsp.locationType == 'Report') {
                        if (rspJSON.rsp.report.vcModality) {
                            rspObject.vcModality = rspJSON.rsp.report.vcModality;
                        }
                        if (rspJSON.rsp.report.syndromics) {
                            rspObject.report.syndromics = rspJSON.rsp.syndromics;
                        }
                        if (rspJSON.rsp.report.ccid) {
                            rspObject.ccid = rspJSON.rsp.report.ccid;
                        }
                        if (rspJSON.rsp.report.diffDx) {
                            rspObject.systemConcern = [];
                            for (let i = 0; i < rspJSON.rsp.report.diffDx.length; i++) {
                                rspObject.systemConcern.push(rspJSON.rsp.report.diffDx[i].text);
                            }
                        }
                        if (rspJSON.rsp.report.rfi) {
                            rspObject.when = this.whenMap[rspJSON.rsp.report.rfi];
                        }
                        if (rspJSON.rsp.report.pos) {
                            if (rspJSON.rsp.report.canVirtualCare) rspObject.etreatable = true;
                            rspObject.where = [];
                            for (let i = 0; i < rspJSON.rsp.report.pos.length; i++) {
                                if (!this.whereMap.hasOwnProperty(rspJSON.rsp.report.pos[i].text))
                                    this.alert('missing whereMap enrty: ' + rspJSON.rsp.report.pos[i].text);

                                rspObject.where.push(this.whereMap[rspJSON.rsp.report.pos[i].text]);
                            }
                        } else {
                            rspObject.where = [];
                            rspObject.where.push('Home');
                        }
                        if (rspJSON.rsp.report.tests) {
                            rspObject.predictedResources = [];
                            for (let i = 0; i < rspJSON.rsp.report.tests.length; i++) {
                                rspObject.predictedResources.push(rspJSON.rsp.report.tests[i].text);
                            }
                        }
                        if (rspJSON.rsp.report.assessments) {
                            rspObject.assessments = [];
                            for (let i = 0; i < rspJSON.rsp.report.assessments.length; i++) {
                                rspObject.assessments.push(rspJSON.rsp.report.assessments[i]);
                            }
                        }
                        if (rspJSON.rsp.report.alerts) {
                            rspObject.alerts = [];
                            for (let i = 0; i < rspJSON.rsp.report.alerts.length; i++) {
                                if (!rspJSON.rsp.report.alerts[i].text.startsWith('Debug')) {
                                    rspObject.alerts.push(rspJSON.rsp.report.alerts[i]);
                                }
                            }
                            if (rspObject.alerts.length < 1) {
                                delete rspObject.alerts;
                            }
                        }
                        if (rspJSON.rsp.report.termText) {
                            rspObject.patientInstructions = rspJSON.rsp.report.termText;
                        }
                        if (rspJSON.rsp.report.positiveList) {
                            rspObject.positiveFindings = [];
                            for (entry = 0; entry < rspJSON.rsp.report.positiveList.length; entry++) {
                                rspObject.positiveFindings.push(
                                    _stripHTML(rspJSON.rsp.report.positiveList[entry].reportSyntax)
                                );
                            }
                            if (rspJSON.rsp.report.positiveList.length != rspObject.positiveFindings.length) {
                                txcc_alert('findings mismatch!');
                            }
                        }
                        if (rspJSON.rsp.report.negativeList) {
                            rspObject.negativeFindings = [];
                            for (entry = 0; entry < rspJSON.rsp.report.negativeList.length; entry++) {
                                if (!rspJSON.rsp.report.negativeList[entry].reportSyntax.startsWith('VS: '))
                                    rspObject.negativeFindings.push(
                                        _stripHTML(rspJSON.rsp.report.negativeList[entry].reportSyntax)
                                    );
                            }
                        }
                        demographics = {};
                        var values = {};
                        Object.keys(this.localDemographics).forEach(
                            function (key, index) {
                                demographics[key] = this.localDemographics[key];
                            }.bind(this)
                        );
                        for (let i = 0; i < rspJSON.rsp.report.historyList.length; i++) {
                            let entry = rspJSON.rsp.report.historyList[i];
                            var eName = entry.name;
                            var eValue = entry.value;
                            var eUnits = '';
                            if (entry.units) {
                                eUnits = ' ' + entry.units;
                            }
                            if (this.demographicList.indexOf(eName.toLowerCase()) >= 0) {
                                demographics[eName.toLowerCase()] = eValue + eUnits;
                            } else if (this.valueList.indexOf(eName.toLowerCase()) >= 0) {
                                values[eName.toLowerCase()] = eValue + eUnits;
                            }
                        }
                        if (Object.keys(demographics).length > 0) {
                            rspObject.demographics = demographics;
                        }
                        if (Object.keys(values).length > 0) {
                            rspObject.values = values;
                        }
                        if (rspJSON.rsp.report.carelinks) {
                            rspObject.careLinks = [];
                            for (let i = 0; i < rspJSON.rsp.report.carelinks.length; i++) {
                                careLink = {};
                                careLink.title = rspJSON.rsp.report.carelinks[i].Title;
                                careLink.topic =
                                    'cid~' +
                                    rspJSON.rsp.report.carelinks[i].Topic +
                                    '~' +
                                    rspJSON.rsp.report.carelinks[i].Section;
                                rspObject.careLinks.push(careLink);
                            }
                        }

                        this.localDemographics = {};
                        delete this.sessionId;
                        THIS.scope.ec.controlContainer.classList.remove('wait');
                        _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                        if (this.listeners && this.listeners.atReport) {
                            for (let i = 0; i < this.listeners.atReport.length; i++) {
                                this.listeners.atReport[i](rspObject);
                            }
                        }
                    } else {
                        THIS.scope.ec.controlContainer.classList.remove('wait');
                        _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                        if (this.listeners && this.listeners.onError) {
                            for (let i = 0; i < this.listeners.onError.length; i++) {
                                this.listeners.onError[i](rspObject);
                            }
                        }
                    }
                    THIS.scope.ec.controlContainer.classList.remove('wait');
                    _setBtnDisabled(THIS.scope.shadowRoot, '.qabtn', false);
                }.bind(THIS)
            );
    }

    function dateToString(d) {
        if (!(d instanceof Date)) return '';
        var m = (d.getMonth() + 1).toString();
        if (m.length < 2) m = '0' + m;
        var dy = d.getDate().toString();
        if (dy.length < 2) dy = '0' + dy;
        var y = (d.getYear() + 1900).toString();
        return m + '/' + dy + '/' + y;
    }

    function parseDate(dateStr) {
        var month = parseInt(dateStr.substring(4, 6));
        var day = parseInt(dateStr.substring(6, 8));
        var year = parseInt(dateStr.substring(0, 4));
        return new Date(year, month - 1, day);
    }

    function _stripHTML(content) {
        var container = document.createElement('div');
        container.innerHTML = content;
        return container.textContent || container.innerText;
    }
    this.addListener = function (event, listener) {
        if (!this.listeners) {
            this.listeners = {};
        }
        if (!this.listeners.hasOwnProperty(event)) {
            this.listeners[event] = [listener];
        } else {
            if (this.listeners[event].indexOf(listener) < 0) {
                this.listeners[event].push(listener);
            }
        }
    };
}

/* txLibraryEngine 1.0.0
 */
export function txLibraryEngine(options) {
    if (options.onMenuLoaded) this.onMenuLoaded = options.onMenuLoaded;
    if (options.onArticleLoaded) this.onArticleLoaded = options.onArticleLoaded;
    if (options.maxPrefetch) this.maxprefetch = options.maxPrefetch;
    else this.maxprefetch = 256;
    if (options.maxMenuLength) this.maxmenulength = options.maxMenuLength;
    else this.maxmenulength = 8;
    this.appId = options.appId;
    if (options.url && options.url !== '') {
        this.url = options.url;
    } else {
        if (!window.location.origin) {
            this.url = window.location.protocol + '//' + window.location.host;
        } else {
            this.url = window.location.origin;
        }
    }
    if (options.timeout) {
        this.timeout = options.timeout;
    } else {
        this.timeout = 10000;
    }
    if (!_isSetup(this)) {
        throw 'Missing Required Options';
    }
    this.lib = loadLibraryMenu.bind(this)();

    function _isSetup(THIS) {
        if (!THIS.url || THIS.url === '') {
            return false;
        }
        if (!THIS.appId || THIS.appId === '') {
            return false;
        }
        return true;
    }

    function loadLibraryMenu() {
        var i;
        var req = this.url + '/library/?m=menu&id=' + this.appId + '&l=cid&g=all&f=bygroups';
        fetch(req)
            .then(
                function (response) {
                    if (!response.ok) {
                        if (this.listeners && this.listeners.onError) {
                            for (i = 0; i < this.listeners.onError.length; i++) {
                                this.listeners.onError[i](response);
                            }
                        }
                        return;
                    }
                    return response.json();
                }.bind(this)
            )
            .then(
                function (cidJson) {
                    if (!this.menuJson) {
                        this.menuJson = {};
                    }
                    this.menuJson.cid = cidJson.all;
                    processLibMenus.bind(this)();
                }.bind(this)
            );
    }

    function processLibMenus() {
        var libMenu = this.menuJson;
        var eName = '';
        var mLibEntry;
        var i;
        var sn;

        this.menuLib = {};
        this.menuLibs = {};
        this.menuCount = {};
        this.fullLibMenu = [];
        if (!this.libMap)
            this.libMap = {
                CC: 'C',
                CD: 'D',
                CT: 'T',
                DC: 'D',
                DD: 'D',
                DT: 'T',
                TC: 'T',
                TD: 'D',
                TT: 'T'
            };
        for (var pName in libMenu) {
            for (i = 0; i < libMenu[pName].length; i++) {
                eName = libMenu[pName][i];
                if (!this.menuLibs[eName]) {
                    this.menuLibs[eName] = pName.toUpperCase().charAt(0);
                    this.fullLibMenu.push(eName);
                } else {
                    mLibEntry = this.menuLibs[eName] + pName.toUpperCase().charAt(0);
                    this.menuLibs[eName] = this.libMap[mLibEntry];
                }
            }
        }
        this.fullLibMenu.sort();
        for (i = 0; i < this.fullLibMenu.length; i++) {
            eName = this.fullLibMenu[i];
            for (var j = 1; j <= eName.length && j < this.maxprefetch; j++) {
                sn = eName.substr(0, j).toLowerCase();
                if (!this.menuCount[sn]) this.menuCount[sn] = 0;
                if (!this.menuLib[sn]) this.menuLib[sn] = [];
                if (this.menuCount[sn] < this.maxmenulength) this.menuLib[sn].push(eName);
                this.menuCount[sn]++;
            }
        }
        for (var f in this.menuLib) {
            this.menuLib[f].sort(function (a, b) {
                if (a.toLowerCase() < b.toLowerCase()) return -1;
                if (a.toLowerCase() > b.toLowerCase()) return 1;
                return 0;
            });
        }
        if (this.onMenuLoaded) {
            this.onMenuLoaded(this);
        }
    }
    this.load = function (article) {
        if (typeof article === 'object') {
            if (article.library) this.library = article.library;
            else this.library = 'CID';
            if (article.section) this.section = article.section;
            else this.section = 'home-care-veteran';
            this.topic = article.topic;
        } else {
            var ap = article.split('~');
            this.library = ap[0];
            this.topic = ap[1];
            if (ap.length > 2 && ap[2].length > 0) this.section = ap[2];
            else {
                this.section = 'home-care-veteran';
            }
        }
        if (this.section == 'home-care-veteran') {
            this.section = 'home-care';
        }
        if (this.currenttopic !== this.topic) {
            loadTopic.bind(this)(this.topic);
        } else {
            this.currentsection = this.section;
            var eInfo = {};
            eInfo.topic = this.topic;
            eInfo.section = this.section;
            eInfo.library = this.library;
            if (!this.cidEntry.sections.entries.hasOwnProperty(this.section)) {
                if (this.section.substring(this.section.length - 8) == '-veteran') {
                    this.section = this.section.substring(0, this.section.length - 8);
                }
                if (this.section === 'definition') {
                    this.section = 'overview';
                }
            }
            this.title = this.cidEntry.sections.entries[this.section].title;
            eInfo.title = this.title;
            eInfo.fulltitle = getFullTitle.bind(this)();
            this.currenttopic = this.topic;
            this.eInfo = eInfo;
            if (this.onArticleLoaded) {
                var aInfo = {};
                if (!this.cidEntry.sections.entries.hasOwnProperty(this.section)) {
                    if (this.cidEntry.sections.entries.hasOwnProperty('home-care')) {
                        this.section = 'home-care';
                    } else {
                        this.section = 'overview';
                    }
                }
                var currentYear = new Date().getFullYear();
                aInfo.body =
                    this.cidEntry.sections.entries[this.section.toLowerCase()].body +
                    '<div class="txLibCopyright">&copy;&nbsp;1990-' +
                    currentYear +
                    ' DSHI Systems, Inc.</div>';
                aInfo.topic = this.cidEntry.topic;
                aInfo.title = this.cidEntry.sections.entries[this.section].title;
                aInfo.fullTitle = '';
                var curSection = this.section;
                while (curSection != '') {
                    aInfo.fullTitle = this.cidEntry.sections.entries[curSection].title + ' ' + aInfo.fullTitle;
                    curSection = this.cidEntry.sections.entries[curSection].parent;
                }
                aInfo.fullTitle = aInfo.fullTitle.trim();
                aInfo.sections = this.cidEntry.sections;
                aInfo.library = this.cidEntry.library;
                this.onArticleLoaded(aInfo);
            }
        }
    };

    function getFullTitle() {
        var sectionPath = '';
        var csection = this.section;
        var tSections = [];
        while (csection !== '') {
            tSections.push(this.cidEntry.sections.entries[csection].title);
            csection = this.cidEntry.sections.entries[csection].parent;
        }
        tSections.reverse();
        for (var i = 0; i < tSections.length; i++) sectionPath += ' ' + tSections[i];
        return this.cidEntry.topic + sectionPath;
    }

    function loadTopic(libraryEntryName) {
        var i;
        var lEN = libraryEntryName;
        var tLoc = libraryEntryName.indexOf('~');
        if (tLoc >= 0) lEN = libraryEntryName.substr(tLoc + 1);
        var req = this.url + '/library/?m=content&id=' + 'widget' + '&a=' + lEN;

        fetch(req)
            .then(
                function (response) {
                    if (!response.ok) {
                        if (this.listeners && this.listeners.onError) {
                            for (i = 0; i < this.listeners.onError.length; i++) {
                                this.listeners.onError[i](response);
                            }
                        }
                        return;
                    }
                    return response.json();
                }.bind(this)
            )
            .then(
                function (cidJson) {
                    this.cidEntry = cidJson.libEntry;
                    var aInfo = {};
                    if (!this.cidEntry.sections.entries.hasOwnProperty(this.section)) {
                        if (this.cidEntry.sections.entries.hasOwnProperty('home-care')) {
                            this.section = 'home-care';
                        } else {
                            this.section = 'overview';
                        }
                    }
                    if (this.section == 'home-care-veteran') {
                        this.section = 'home-care';
                    }
                    if (this.cidEntry.sections.entries.hasOwnProperty('home-care-veteran')) {
                        this.cidEntry.sections.entries['home-care'] =
                            this.cidEntry.sections.entries['home-care-veteran'];
                        delete this.cidEntry.sections.entries['home-care-veteran'];
                        var hcvIndex = this.cidEntry.sections.directory.indexOf('home-care-veteran');
                        if (hcvIndex >= 0) {
                            this.cidEntry.sections.directory.splice(hcvIndex, 1);
                        }
                        this.cidEntry.sections.entries['home-care'].title = 'Home Care';
                        this.cidEntry.sections.entries['home-care'].parent = '';
                        this.cidEntry.sections.entries['home-care'].indentLevel = 0;
                    }
                    var currentYear = new Date().getFullYear();
                    aInfo.body =
                        this.cidEntry.sections.entries[this.section.toLowerCase()].body +
                        '<div class="txLibCopyright">&copy;&nbsp;1990-' +
                        currentYear +
                        ' DSHI Systems, Inc.</div>';
                    aInfo.topic = this.cidEntry.topic;
                    aInfo.title = this.cidEntry.sections.entries[this.section].title;
                    aInfo.sections = this.cidEntry.sections;
                    aInfo.library = this.cidEntry.library;
                    aInfo.fullTitle = '';
                    var curSection = this.section;
                    while (curSection != '') {
                        aInfo.fullTitle = this.cidEntry.sections.entries[curSection].title + ' ' + aInfo.fullTitle;
                        curSection = this.cidEntry.sections.entries[curSection].parent;
                    }
                    aInfo.fullTitle = aInfo.fullTitle.trim();
                    this.currenttopic = this.topic;
                    if (this.onArticleLoaded) this.onArticleLoaded(aInfo);
                }.bind(this)
            );
    }
}
/* eslint-enable */

// Version: 240503
//  * UPD * Added standalone mode to the web component for use when not embedded
//  * UPD * Added logic to display message when no matching selection in chief complaint selection menu
//  * UPD * Added logic to indicate if there are more matches then displayed (including count) when too many matches in chief complaint selection menu
//  * UPD * Modified copyright date from 2022 to automatically set to current year
//  * CLN * Modified "Look For" in the expanded Chief Complaint selection menu to be "Better Option" to improve clinical clarity
//  * CLN * Modified Gender UI text to be Genotype for clarity that it is the genetic gender, not patient "preferred" gender
//  * CLN * Modified "Serum Glucose" UI text to be FSBG to correctly identify values origin
//  * CLN * Added code to supress "Advanced Triage" directives in alerts, which do not apply to TXCC
//  * CLN * Modified Note recommendations, changed text from "Where" to "Nurse should consider" for clinical clarity
//  * BUG * Added Support for 508 compliances in the "Quick Pick" Cheif complaint selection  by supporting tab, arrows, enter and space for navigation and selection.
//  *
// Version: 220825  Delivery: 8/29/2022 Reason: Hot Fix to 220506A  Urgency: Immediate
//	* BUG * Early Termination - Corrected issue where negatives were included in positives in note
//	* BUG * Early Termination - Fixed issue where returning to Questions tab and completing triage resulted in the Note being displayed with the partial report
//	* UPD * Early Termination - Inclusion of notice of incomplete triage in generated Note per DSHI Clinical/Legal
//
// Version: 220506A	Delivery: 7/20/2022	Reason: Bug Fix to 220506
//	* BUG * Updated Duration of Complaint drop down configuration to include Years
//
// Version: 220506	Delivery:	6/16/2022	Reason: Clinical Requests to UI, Internal improvements
//	* CLN * Completion of "VC Modality" which indicates the best virtual care option (Video/Telephone/Text).
//	* UPD * Update of License Notification
//	* UPD * Versioning updated to be consistent with DSHI internal versioning (no longer references sp or rc).
//	* UPD * Component Version (per DSHI) is displayed to the right of the copyright notice in parenthesis.
//	* CLN * Expansion of weeks in Duration of CC to 19 (per clinical request)
//	* CLN * Expansion of Months in Duration of CC to 18 (per clinical request)
//	* CLN * Addition of Years (1 to 5) in Duration of CC (per clinical request)
//	* UPD * Done Button spacing improved to further separate Done/Abort button on the Note display at Results (per clinical request)
//	* INT * Best Practice/coding updates (these updates do not affect functionality; they improve adherence to best practice standards)
//
// Version: SP2RC1	Delivery: 2/9/2022 	Reason: Clinical Requests, New Features
//	* CLN * Removal of the Nurse selected options on the results tab (nurseRfi/when; nurseRfl/where), and from the completion object as well.
//	* UPD * Support for 508 compliances in the Chief Complaint selection menu by supporting tab, arrows, enter and space for navigation and selection.
//	* CLN * The addition of the Better Starting Point (aka Look For) in the Chief Complaint selection menu
//	* CLN * Removal of Test/Drug library topics
//	* SVC * Addition of syndromics property to the completion object (as appropriate) for OPH; which will need to be included in the data sent to OPH when that occurs.  The property is an array of strings if it exists, if there are no syndromics to process then the property is not defined.
//
// Version: TXCCRC1	Delivery: 6/18/2021	Reason: Non-minimized Autosize for analysis of SF Environment issues with it
//	* INT * Changed Autosize function to be clear text rather than minimized
//	* INT * Added Loaded event fired when the TXCC component is fully loaded
//	* INT * Added Alert and Confirm w/ability to override so default Modal popups can be overridden in SF Environment
