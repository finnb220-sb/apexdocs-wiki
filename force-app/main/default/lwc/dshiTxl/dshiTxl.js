import { LightningElement, api } from "lwc";
import { txLibraryEngine } from "c/dshiCode";

export default class DshiTxl extends txlMixin(LightningElement) {
    initialized = false;

    constructor() {
        try {
            super();
        } catch (e) {
            console.warn(e);
        }
    }

    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        this.initialized = true;
        try {
            this.setupWidget();
        } catch (e) {
            console.warn(e);
        }
    }

    shadowRoot = {
        getElementById: (id) => {
            return this.template.querySelector('[data-id="' + id + '"]');
        }
    };

    getRootNode = () => {
        return {
            host: { url: "https://va.triagexpert.com/" }
        };
    };
    dispatchEvent = (e) => {
        this.template.dispatchEvent(new CustomEvent(e.type, { detail: e.detail, composed: true }));
    };
}

function txlMixin(LightningElement) {
    return class TxlMixin extends LightningElement {
        txLibMenuClickHandler(ev) {
            this.txLibEngine.load(ev.currentTarget.txLibReference);
            ev.preventDefault();
        }
        @api
        reset() {
            this.ec.txLibraryInput.value = "";
            this.ec.txLibraryList.style.display = "none";
            this.ec.txLibArticle.style.display = "none";
        }
        setupWidget() {
            this.sectionsToShow = ["Overview", "Symptoms", "Home Care", "References"];
            this.libOptions = {
                appId: "widget",
                timeout: "10000",
                onMenuLoaded: this.onMenuLoaded.bind(this),
                onArticleLoaded: this.displayArticle.bind(this),
                maxPrefetch: 256,
                maxMenuLength: 10
            };

            this.ec = {
                txLibrarySearchBtn: this.shadowRoot.getElementById("txLibrarySearchBtn"),
                txLibTitleText: this.shadowRoot.getElementById("txLibTitleText"),
                txLibArticleNavBtn: this.shadowRoot.getElementById("txLibArticleNavBtn"),
                txLibrarySectionList: this.shadowRoot.getElementById("txLibrarySectionList"),
                txLibraryInput: this.shadowRoot.getElementById("txLibraryInput"),
                txLibArticle: this.shadowRoot.getElementById("txLibArticle"),
                txLibArticleBody: this.shadowRoot.getElementById("txLibArticleBody"),
                txLibraryList: this.shadowRoot.getElementById("txLibraryList"),
                txLibPatientInformation: this.shadowRoot.getElementById("txLibPatientInformation"),
                txLibWebInstructions: this.shadowRoot.getElementById("txLibWebInstructions"),
                txLibVerbalInstructions: this.shadowRoot.getElementById("txLibVerbalInstructions"),
                txLibTitleSearch: this.shadowRoot.getElementById("txLibTitleSearch")
            };
            this.ec.txLibArticleNavBtn.addEventListener("click", this.onNavBtnClick.bind(this));
            this.ec.txLibrarySearchBtn.addEventListener("click", this.doShowLibSearchBar.bind(this));
            this.ec.txLibWebInstructions.addEventListener("change", this.onWebInstructionsChange.bind(this));
            this.ec.txLibVerbalInstructions.addEventListener("change", this.onVerbalInstructionsChange.bind(this));
            this.ec.txLibrarySectionList.style.display = "none";
            this.ec.txLibraryInput.style.disabled = true;
            this.ec.txLibraryInput.addEventListener("input", this.txLibraryInput.bind(this));
            if (this.libOptions.url) this.txLibEngine = new txLibraryEngine(this.libOptions);
            this.tlookup = {
                T: "TST",
                C: "CID",
                D: "DRG"
            };
            if (this.getAttribute("data-popup")) {
                this.isPopup = this.getAttribute("data-popup").toLowerCase() == "true";
                if (this.isPopup) {
                    this.ec.txLibraryList.style.display = "none";
                    this.ec.txLibPatientInformation.style.display = "none";
                    this.ec.txLibrarySearchBtn.style.display = "none";
                    this.ec.txLibArticleNavBtn.style.display = "none";
                } else {
                    this.ec.txLibraryList.style.display = "none";
                    this.ec.txLibPatientInformation.style.display = "inherit";
                    this.ec.txLibrarySearchBtn.style.display = "inherit";
                    this.ec.txLibArticleNavBtn.style.display = "inherit";
                }
            }
            this.setURL(this.getRootNode().host.url);
            var e = new CustomEvent("loaded", {
                detail: {
                    widget: "TXL"
                }
            });
            this.dispatchEvent(e);
        }
        setURL(url) {
            if (url) this.libOptions.url = url;
            if (this.libOptions.url) this.txLibEngine = new txLibraryEngine(this.libOptions);
        }
        @api
        setVerbal(checked, fullTitle) {
            if (this.ec.txLibVerbalInstructions.fullTitle == fullTitle) {
                this.ec.txLibVerbalInstructions.checked = checked;
            } else {
                if (this.ec.txLibVerbalInstructions.fullTitle == fullTitle + " Veteran") {
                    this.ec.txLibVerbalInstructions.checked = checked;
                }
            }
        }
        @api
        setWeb(checked, fullTitle) {
            if (this.ec.txLibWebInstructions.fullTitle == fullTitle) {
                this.ec.txLibWebInstructions.checked = checked;
            } else {
                if (this.ec.txLibWebInstructions.fullTitle == fullTitle + " Veteran") {
                    this.ec.txLibWebInstructions.checked = checked;
                }
            }
        }
        onVerbalInstructionsChange(ev) {
            var details = {
                checked: ev.target.checked,
                fullTitle: ev.target.fullTitle,
                title: ev.target.title,
                topic: ev.target.topic,
                fullPath: ev.target.articlePath
            };
            var e = new CustomEvent("verbalChanged", {
                detail: details
            });
            this.dispatchEvent(e);
        }
        onWebInstructionsChange(ev) {
            var details = {
                checked: ev.target.checked,
                fullTitle: ev.target.fullTitle,
                title: ev.target.title,
                topic: ev.target.topic,
                fullPath: ev.target.articlePath
            };
            var e = new CustomEvent("webChanged", {
                detail: details
            });
            this.dispatchEvent(e);
        }
        txLibraryInput(ev) {
            while (this.ec.txLibraryList.firstChild) {
                this.ec.txLibraryList.removeChild(this.ec.txLibraryList.firstChild);
            }
            var value = ev.target.value;
            if (value && value.length >= 1) {
                value = value.toLowerCase();
                if (this.txLibEngine.menuLib[value]) {
                    for (var i = 0; i < this.txLibEngine.menuLib[value].length; i++) {
                        var eName = this.txLibEngine.menuLib[value][i];

                        var aTitle = document.createElement("span");
                        aTitle.classList.add("txLibMenuText");
                        var aTitleText = document.createTextNode(eName);
                        aTitle.appendChild(aTitleText);

                        var aItem = document.createElement("li");
                        aItem.classList.add("txLibMenuEntry");
                        aItem.txLibReference = this.tlookup[this.txLibEngine.menuLibs[eName]] + "~" + eName;
                        aItem.appendChild(aTitle);
                        aItem.setAttribute("tabindex", 0);
                        aItem.addEventListener("click", this.txLibMenuClickHandler.bind(this));
                        aItem.addEventListener("keydown", this.txLibMenuKeyHandler.bind(this));
                        this.ec.txLibraryList.appendChild(aItem);
                    }
                }
            }
            this.ec.txLibraryList.style.display = this.ec.txLibraryList.firstChild ? "block" : "none";
        }
        txLibMenuKeyHandler(e) {
            let ns;
            if (e.keyCode == 37 || e.keyCode == 39) {
                e.preventDefault();
                e.stopImmediatePropagation();
                return;
            }
            if (e.keyCode === 13 || e.keyCode === 32) {
                e.preventDefault();
                e.stopImmediatePropagation();
                this.txLibMenuClickHandler(e);
            }
            if (e.keyCode == 40) {
                ns = e.currentTarget.nextSibling;
                while (ns) {
                    if (ns.style.display != "none") {
                        ns.focus();
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        return;
                    }
                    ns = ns.nextSibling;
                }
                e.preventDefault();
                e.stopImmediatePropagation();
                return;
            }
            if (e.keyCode == 38) {
                ns = e.currentTarget.previousSibling;
                while (ns) {
                    if (ns.style.display != "none") {
                        ns.focus();
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        return;
                    }
                    ns = ns.previousSibling;
                }
                e.preventDefault();
                e.stopImmediatePropagation();
                return;
            }
        }
        @api
        showArticle(article) {
            this.txLibEngine.load(article);
        }
        onNavBtnClick() {
            this.ec.txLibrarySectionList.style.display =
                this.ec.txLibrarySectionList.style.display == "none"
                    ? (this.ec.txLibrarySectionList.style.display = "inherit")
                    : (this.ec.txLibrarySectionList.style.display = "none");
        }

        doLibraryClick(ev) {
            var article = ev.target.hash.substring(1);
            this.txLibEngine.load(article);
            ev.preventDefault();
            return null;
        }

        onMenuLoaded() {
            this.ec.txLibraryInput.disabled = false;
            this.ec.txLibraryInput.style.cursor = "inherit";
        }

        doShowLibSearchBar() {
            if (this.ec.txLibTitleText.style.display === "none") {
                this.ec.txLibTitleText.style.display = "inline";
                this.ec.txLibTitleSearch.style.display = "none";
            } else {
                this.ec.txLibTitleSearch.style.display = "inline-block";
                this.ec.txLibTitleText.style.display = "none";
            }
        }
        txLibSectionClickHandler(ev) {
            this.txLibEngine.load(ev.currentTarget.txLibSectionRef);
            this.ec.txLibrarySectionList.style.display = "none";
            this.ec.txLibArticleNavBtn.textContent = ev.currentTarget.textContent;
            ev.preventDefault();
        }
        generateSectionMenu(sections, library, topic) {
            while (this.ec.txLibrarySectionList.firstChild) {
                this.ec.txLibrarySectionList.removeChild(this.ec.txLibrarySectionList.firstChild);
            }
            for (var idx = 0; idx < sections.directory.length; idx++) {
                var section = sections.directory[idx];
                var data = sections.entries[section];
                var title = data.title;
                var indentLevel = data.indentLevel;
                if (indentLevel <= 0 && this.sectionsToShow.indexOf(title) >= 0) {
                    var aTitle = document.createElement("span");
                    aTitle.classList.add("txLibSectionListEntry");
                    aTitle.classList.add("txLibOvl" + indentLevel);
                    var aText = document.createTextNode(title);
                    aTitle.appendChild(aText);
                    var aItem = document.createElement("li");
                    aItem.appendChild(aTitle);
                    aItem.classList.add("txLibSectionEntry");
                    aItem.txLibSectionRef = library + "~" + topic + "~" + section;
                    aItem.setAttribute("title", title);
                    aItem.setAttribute("library", data.library);
                    aItem.setAttribute("tabindex", 0);
                    aItem.addEventListener("click", this.txLibSectionClickHandler.bind(this));
                    this.ec.txLibrarySectionList.appendChild(aItem);
                }
            }
            return false;
        }
        displayArticle(article) {
            this.ec.txLibWebInstructions.fullTitle = article.topic + " " + article.fullTitle;
            this.ec.txLibVerbalInstructions.fullTitle = article.topic + " " + article.fullTitle;
            this.ec.txLibWebInstructions.title = article.title;
            this.ec.txLibVerbalInstructions.title = article.title;
            this.ec.txLibWebInstructions.topic = article.topic;
            this.ec.txLibVerbalInstructions.topic = article.topic;
            var aPath = article.library + "~" + article.topic + "~" + article.fullTitle;
            aPath = aPath.toLowerCase().replace(/ /g, "-");
            this.ec.txLibWebInstructions.articlePath = aPath;
            this.ec.txLibVerbalInstructions.articlePath = aPath;
            this.ec.txLibArticleBody.innerHTML = article.body;
            var articleLinks = this.ec.txLibArticleBody.querySelectorAll("a");
            for (var i = 0; i < articleLinks.length; i++) {
                if (this.isPopup) {
                    var span = document.createElement("span");
                    span.innerHTML = articleLinks[i].innerHTML;
                    articleLinks[i].parentNode.replaceChild(span, articleLinks[i]);
                } else {
                    articleLinks[i].addEventListener("click", this.doLibraryClick.bind(this));
                }
            }
            this.generateSectionMenu(article.sections, article.library, article.topic);
            if (article.title.toLowerCase() == "overview") {
                this.ec.txLibTitleText.innerHTML = article.topic;
            } else {
                this.ec.txLibTitleText.innerHTML = article.topic + " " + article.title;
            }
            this.ec.txLibArticle.style.display = "block";
            this.ec.txLibArticleNavBtn.textContent = article.title;
            this.ec.txLibWebInstructions.articleTitle = article.topic + " " + article.fullTitle;
            this.ec.txLibVerbalInstructions.articleTitle = article.topic + " " + article.fullTitle;
            this.ec.txLibWebInstructions.checked = false;
            this.ec.txLibVerbalInstructions.checked = false;
            this.ec.txLibTitleSearch.style.display = "none";
            this.ec.txLibArticle.style.display = "block";
            this.ec.txLibTitleText.style.display = "inline";
            var details = {
                fullTitle: this.ec.txLibWebInstructions.articleTitle
            };
            var e = new CustomEvent("displayArticle", {
                detail: details
            });
            this.dispatchEvent(e);
        }
    };
}
