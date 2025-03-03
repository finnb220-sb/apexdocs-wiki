import { LightningElement, track, api, wire } from 'lwc';
import getProviders from '@salesforce/apex/VCC_SignersController.getProvidersBySite';
//import checkProviderCallout from '@salesforce/apex/VCC_SignersController.checkCustomSettingVisn';
import vccAddSignersTitleLabel from '@salesforce/label/c.vccAddSignersTitleLabel';
import vccAddSignersSelectLabel from '@salesforce/label/c.vccAddSignersSelectLabel';
import vccAddSignerNoResultsLabel from '@salesforce/label/c.vccAddSignerNoResultsLabel';
import vccProviderSearchHelptext from '@salesforce/label/c.VCC_Add_Signers_Provider_Search_Helptext';
import VCC_Add_SIgner_Component_Generic_Error from '@salesforce/label/c.VCC_Add_SIgner_Component_Generic_Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { proxyTool } from 'c/helpersLWC';
import vccProgressNoteAddSigner from '@salesforce/messageChannel/vccProgressNoteAddSigner__c';
import vccProgressNoteAddSignerBroadcast from '@salesforce/messageChannel/vccProgressNoteAddSignerBroadcast__c';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';

// const columns = [
//     { label: 'Name', fieldName: 'providername', type:'string'},
//     { label: 'DUZ', fieldName: 'duz', type:'string', initialWidth:90},
//     //{ label: 'NPI', fieldName: 'npinumber', type:'string'}
// ];
// const addSignersColumns = [
//     { label: '', type:'button-icon',
//         typeAttributes:{
//             iconName:'utility:add',
//             name:'addSigner',
//             variant:'brand'
//         },
//         initialWidth: 50
//     },
//     columns[0],
//     { label: 'Title', fieldName: 'providertitle', type:'string', initialWidth:150 },
//     columns[1],
//     //columns[2],
// ]
// const removeSignersColumns = [
//     { label: '', type:'button-icon',
//         typeAttributes:{
//             iconName:'utility:dash',
//             name:'removeSigner',
//             variant:'brand-inverse'
//         },
//         initialWidth: 50
//     },
//     ...columns
// ]
export default class VccProgressNoteAddSigner extends LightningElement {
    constructor() {
        super();
        this.addSignerByNameBestEffort = this.addSignerByNameBestEffort.bind(this);
    }

    @track columns = [
        { label: 'Name', fieldName: 'providername', type: 'string' },
        { label: 'DUZ', fieldName: 'duz', type: 'string', initialWidth: 90 }
        //{ label: 'NPI', fieldName: 'npinumber', type:'string'}
    ];

    @track addSignersColumns = [
        {
            label: '',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:add',
                name: 'addSigner',
                variant: 'brand',
                disabled: { fieldName: 'disable' }
            },
            initialWidth: 50
        },
        this.columns[0],
        { label: 'Title', fieldName: 'providertitle', type: 'string', initialWidth: 150 },
        this.columns[1]
        //columns[2],
    ];

    @track removeSignersColumns = [
        {
            label: '',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:dash',
                name: 'removeSigner',
                variant: 'brand-inverse'
            },
            initialWidth: 50
        },
        ...this.columns
    ];
    /** Properites */

    @api recordId; //adding public property back to ancestory error in unlocked package deployment
    @wire(MessageContext)
    messageContext;

    subscription;

    //render conditionals
    isSigned = false;
    isLoading = false;
    displayError = false;

    @track isNewApi = false;

    //datatable data
    additionalSignersSet = {};
    additionalSignersData = [];
    searchResults = [];

    //datatable columns
    //this.addSignersColumns = this.addSignersColumns;
    //this.removeSignersColumns = this.removeSignersColumns;

    //labels
    labels = {
        vccAddSignerNoResultsLabel,
        vccAddSignersSelectLabel,
        vccProviderSearchHelptext,
        vccAddSignersTitleLabel,
        VCC_Add_SIgner_Component_Generic_Error
    };

    //modal stuff
    displayModal = false;
    providersToSearch = [];

    @api clinicName;

    /** Properties with Getters/Setters */
    @api
    set testprop1(val) {
        this._testprop1 = val;
    }

    get testprop1() {
        return this.isNewApi;
    }

    @api
    set signerApiBoolean(val) {
        this._SignerApiBoolean = val;
    }

    get signerApiBoolean() {
        return this.isNewApi;
    }

    @api
    set signers(val) {
        if (val && typeof val === 'string') {
            /* eslint no-empty: ["error", { "allowEmptyCatch": true }] */
            try {
                val = JSON.parse(val);
            } catch (e) {}

            if (Array.isArray(val)) {
                for (let i = 0; i < val.length; i++) {
                    this.addSigner(val[i], true);
                }
            }
        }
    }
    get signers() {
        return JSON.stringify(this.additionalSignersData);
    }

    @api
    set providerUserId(val) {
        if (val && typeof val === 'string' && val.length && !Number(val)) {
            this._providerUserId = val;
        }
    }
    get providerUserId() {
        return this._providerUserId;
    }

    @api
    set siteCode(val) {
        if (val && typeof val === 'string' && val.length && val.length < 5 && !!Number(val)) {
            this._siteCode = val;
        }
    }
    get siteCode() {
        return this._siteCode;
    }

    /** Life-cycle hooks */

    connectedCallback() {
        this.searchResults = [...this.searchResults];
        this.refreshSearchResults(this.searchResults);
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                vccProgressNoteAddSigner,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
            this.handleGet(); //publishing list of signers when loaded
        }

        // checkProviderCallout({
        //     clinicName:this.clinicName

        // }).then(response => {
        //
        //     if(response == 'true'){
        //         this.isNewApi = true;
        //         this.addSignersColumns = [
        //             { label: '', type:'button-icon',
        //                 typeAttributes:{
        //                     iconName:'utility:add',
        //                     name:'addSigner',
        //                     variant:'brand'
        //                 },
        //                 initialWidth: 50
        //             },
        //             this.columns[0],
        //             { label: 'Title', fieldName: 'providertitle', type:'string', initialWidth:150 },
        //             this.columns[1],
        //             { label: 'NPI', fieldName: 'npinumber', type:'string'},
        //         ];

        //         this.columns = [
        //             { label: 'Name', fieldName: 'providername', type:'string'},
        //             { label: 'DUZ', fieldName: 'duz', type:'string', initialWidth:90},
        //             { label: 'NPI', fieldName: 'npinumber', type:'string'}
        //         ];

        //         this.removeSignersColumns = [
        //             { label: '', type:'button-icon',
        //                 typeAttributes:{
        //                     iconName:'utility:dash',
        //                     name:'removeSigner',
        //                     variant:'brand-inverse'
        //                 },
        //                 initialWidth: 50
        //             },
        //             ...this.columns
        //         ]

        //     }

        // })
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    /** Methods */

    //refreshes properties on the search results table records
    refreshSearchResults(results) {
        //apply disabled property if the signer has already been selected
        if (results && Array.isArray(results) && results.length > 0) {
            this.searchResults = results.map((item) => ({
                ...item,
                disable:
                    this.additionalSignersSet[item.duz] !== null && this.additionalSignersSet[item.duz] !== undefined
                        ? true
                        : false
            }));
        } else {
            this.searchResults = results;
        }
    }

    pub(message) {
        message = { ...message };
        publish(this.messageContext, vccProgressNoteAddSignerBroadcast, message);
    }

    addSigner(providerTO, suppressPublish) {
        let added = false;

        if (providerTO && providerTO.duz) {
            if (
                this.additionalSignersSet[providerTO.duz] === null ||
                this.additionalSignersSet[providerTO.duz] === undefined
            ) {
                providerTO.loginSiteCode = this.siteCode;
                this.additionalSignersSet[providerTO.duz] = providerTO;
                this.additionalSignersData = [...Object.values(this.additionalSignersSet)];

                if (!suppressPublish) {
                    this.pub({ result: 'added', providers: [providerTO] });
                }
                added = true;
            }
        }

        this.refreshSearchResults(this.searchResults);

        return added;
    }

    removeSigner(providerTO) {
        let removed = false;
        if (this.additionalSignersSet[providerTO.duz]) {
            delete this.additionalSignersSet[providerTO.duz];
            this.additionalSignersData = [...Object.values(this.additionalSignersSet)];
            removed = true;
            this.pub({ result: 'removed', providers: [providerTO] });
        }

        this.refreshSearchResults(this.searchResults);

        return removed;
    }

    addSignerByNameBestEffort(providerTO, callback) {
        if (
            providerTO?.providername &&
            typeof providerTO.providername == 'string' &&
            this.providerUserId &&
            this.siteCode
        ) {
            getProviders({
                providerUserId: this.providerUserId,
                providerSearchString: providerTO.providername,
                siteId: this.siteCode,
                recordId: this.recordId
            })
                .then((response) => {
                    let providers = JSON.parse(response);

                    for (let i = 0; i < providers.length; i++) {
                        providers[i].alphabeticalKey = i + 1;
                    }

                    //if first provider name is exact match
                    if (providers[0].providername.toLowerCase() === providerTO.providername.toLowerCase()) {
                        //if there are not multiple matches
                        if (providers[0].providername.toLowerCase() !== providers[1].providername.toLowerCase()) {
                            if (callback) {
                                callback({ status: 'success', data: providers, error: null });
                            } else {
                                if (this.addSigner(providers[0])) {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Signer Added!',
                                            variant: 'success'
                                        })
                                    );
                                }
                                this.isLoading = false;
                            }
                        } else {
                            if (callback) {
                                callback({ status: 'multiple', data: providers, error: null });
                            } else {
                                //multiple providers with the same name, present search results to user
                                this.searchResults = [...providers];
                                this.refreshSearchResults(this.searchResults);

                                // display notification to user indicating multiple matches
                                this.isLoading = false;
                                this.pub({ result: 'error', providers: [providerTO] });
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Multiple Matches Found',
                                        variant: 'warning'
                                    })
                                );
                            }
                        }
                    } else {
                        if (callback) {
                            callback({ status: 'none', data: providers, error: null });
                        } else {
                            //no exact match
                            this.searchResults = [...providers];
                            this.refreshSearchResults(this.searchResults);

                            // display notification to user indicating no match
                            this.pub({ result: 'error', providers: [providerTO] });
                            this.isLoading = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'No Matches Found',
                                    variant: 'info'
                                })
                            );
                        }
                    }
                })
                .catch((e) => {
                    let message;
                    if (e?.body?.message) {
                        message = e.body.message;
                    }
                    if (callback && message) {
                        callback({ status: 'error', data: null, error: message });
                    } else {
                        // display notification to user indicating no match
                        this.pub({ result: 'error', providers: [providerTO] });
                        this.isLoading = false;
                        if (message) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: message,
                                    variant: 'error'
                                })
                            );
                        }
                    }
                });
        } else {
            if (callback) {
                // eslint-disable-next-line no-undef
                callback({ status: 'error', data: null, error: labels.VCC_Add_SIgner_Component_Generic_Error });
            } else {
                // display notification to user indicating no match
                this.pub({ result: 'error', providers: [providerTO] });
                this.isLoading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Provider name not found.',
                        variant: 'error'
                    })
                );
            }
        }
    }

    doProvidersCallout(searchString) {
        if (this.providerUserId && this.siteCode && searchString && typeof searchString === 'string') {
            getProviders({
                providerUserId: this.providerUserId,
                providerSearchString: searchString,
                siteId: this.siteCode,
                recordId: this.recordId
                //clinicName: this.clinicName
            })
                .then((response) => {
                    this.isLoading = false;
                    let results = JSON.parse(response);

                    this.searchResults = Array.isArray(results) ? Object.values(results) : [];
                    this.refreshSearchResults(this.searchResults);
                })
                .catch((e) => {
                    this.isLoading = false;

                    if (e?.body?.message) {
                        this.displayError = true;
                        this.error = `An unexpected error has occurred: "${e.body.message}" Please contact your administrator.`;
                    } else {
                        this.displayError = true;
                        this.error = 'An unexpected error has occurred, please contact your administrator.';
                    }
                });
        } else {
            this.error = 'An unexpected error has occurred, please contact your administrator.';
            this.displayError = true;
            this.isLoading = false;
        }
    }

    addMany(providers) {
        this.providersToSearch = providers;
        this.displayModal = true;
        // let providersToSearch = [];
        // let providersAdded = [];
        // for(let i = 0; i < providers.length; i++){

        //     let success = this.addSigner(providers[i]);

        //     if(success === false){
        //         providersToSearch.push(providers[i]);
        //     } else {
        //         providersAdded.push(providers[i]);
        //     }

        // }

        // if (providersAdded.length > 0){
        //     this.pub({result:'added', providers:providersAdded});
        // }
        // if (providersToSearch.length > 0){//open modal and search for signers
        //     this.providersToSearch = providersToSearch;
        //     this.displayModal = true;
        // }
    }

    /** Event Handlers */

    handleRowAction(event) {
        let row = event?.detail?.row;
        let action = event?.detail?.action;

        switch (action.name) {
            case 'addSigner':
                this.addSigner(row);
                break;

            case 'removeSigner':
                this.removeSigner(row);
                break;

            default:
                break;
        }
    }

    handleCloseModalDone(event) {
        let signers = event?.detail?.signers;

        for (let i = 0; i < signers.length; i++) {
            this.addSigner(signers[i], true);
        }

        this.pub({ result: 'added', providers: signers });

        this.displayModal = false;
    }

    handleCloseModalCancel() {
        this.displayModal = false;
    }

    handleSearch(event) {
        if (event.detail.state === 'done') {
            if (typeof event.detail.value === 'string' && event.detail.value !== '') {
                this.doProvidersCallout(event.detail.value);
            } else {
                this.searchResults = [];
                this.isLoading = false;
            }
        } else if (event.detail.state === 'typing') {
            this.isLoading = true;
        }
    }

    handleMessage(message) {
        // eslint-disable-next-line default-case
        switch (message.action.toLowerCase()) {
            case 'add':
                this.handleAdd(message.providers);
                break;
            case 'remove':
                this.handleRemove(message.providers);
                break;
            case 'get':
                this.handleGet();
                break;
        }
    }

    handleAdd(providers) {
        if (providers && typeof providers == 'object' && Array.isArray(providers)) {
            if (providers.length === 1) {
                // only adding one
                this.isLoading = true;
                if (!this.addSigner(providers[0])) {
                    this.addSignerByNameBestEffort(providers[0]);
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Signer Added!',
                            variant: 'success'
                        })
                    );
                }
            } else if (providers.length > 1) {
                //adding multiple

                this.addMany(providers);
            }
        }
    }

    handleRemove(providers) {
        let removedSigners = [];
        for (let i = 0; i < providers.length; i++) {
            if (this.removeSigner(providers[i])) {
                removedSigners.push(providers[i]);
            }
        }
        this.pub({ result: 'removed', providers: removedSigners });
    }

    handleGet() {
        this.pub({ result: 'added', providers: [...Object.values(this.additionalSignersSet)] });
    }

    @api
    validate() {
        if (this.displayModal) {
            let signers = this.template.querySelector('c-vcc-progress-note-add-signers-modal').getChosenSigners();
            for (let i = 0; i < signers.length; i++) {
                this.addSigner(signers[i]);
            }
        }

        return {
            isValid: true
        };
    }
}
