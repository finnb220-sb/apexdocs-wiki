import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CreatedBy_FIELD from '@salesforce/schema/VCC_Progress_Note__c.CreatedById';
import Signed_FIELD from '@salesforce/schema/VCC_Progress_Note__c.VCC_Signed__c';
import { componentDependencies as service, errMessageTitle, errSubMessage } from './componentDependencies.js';
// wired methods
import getHealthDataConfig from '@salesforce/apex/VCC_AllergyController.fetchHealthDataConfig';
import getICN from '@salesforce/apex/VCC_lwc_utils.getICN';
import getAllergiesVTC from '@salesforce/apex/VCC_AllergyListController.fetchAllergies';
import { MessageContext } from 'lightning/messageService';
// modal imports
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

export default class VccAllergyList extends LightningElement {
    /**private props*/
    _addToNoteOptions = {};
    _columnsForAddToNote = [];
    /**api non-setaddToNoteDefaultOptionster props*/
    @api addToNoteOptions;
    @api columnsForAddToNote;
    @api labDisclaimer;
    @api flexipageRegionWidth;
    @api objectApiName;
    @api recordId;
    @api useMockData; // Deprecated
    /**tracked props*/
    @track isShowSpinner;
    @track selectedRecord;
    @track hdrData = [];
    @track dataSettings = {};
    /**props*/

    icn;
    startDate;
    stopDate;
    isEmpty = false;
    hasError = false;
    genericError = service.labels.genericError;
    hdrMessage;
    noResults = false;
    currentIndex = 0;
    state = {};
    totalRecordsDetails;
    maxRecordReached = false;
    maxErrorCheck = false;
    maxRecordMessage = service.labels.maxRecordMessage;
    maxRecordMessage2;
    customMessage;
    messageChannel = baseLightningModalComms;
    columns = service.columns;
    detailComponentColumns = service.detailComponentColumns;
    vtcArgs; // args for vtc call
    tempArgs; // object that is built up during wire calls used to build vtcArgs
    actionsComponent = service.actionsComponent; // grabs the actionsComponent object from the component dependencies
    patientBirthYear; // holds patient year to dynamically create the load more options until that year
    calloutsPerformed = []; // batches of data returned via wire calls
    errMessageTitle = errMessageTitle;
    errSubMessage = errSubMessage;

    vtcCalloutDateParameters = {
        // set on connectedCallback after getWorkstreamSettings is implicitly called
        startDate: null,
        stopDate: null
    };

    settings = service.settings;
    labels = { ...service.labels };

    async connectedCallback() {
        this.isShowSpinner = true;
        await service.setLabels.call(this, service.settings, 'allergies');
        service.settingAddToNoteValues.call(this, service.addToNoteDefaultOptions, service.addToNoteDefaultColumns);
        service.setCalloutDateParameters.call(this);
    }

    /** wires, these are defined by the ordered they're called*/
    @wire(MessageContext)
    messageContext;

    /**
     * @description Gets ICN number for patient from recordId
     * @param string recordId
     */
    @wire(getICN, { recordId: '$recordId' })
    wiredGetIcn({ data, error }) {
        if (data) {
            this.icn = data;
        }
        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Gets patient birth year, and workstream settings, the data required to perform calls to VTC
     * @param string icn to query DB against
     */
    @wire(getHealthDataConfig, { icn: '$icn' })
    wiredHDRConfig({ data, error }) {
        if (data) {
            this.patientBirthYear = data.patientBirthYear;
            service.setLoadMoreOptions.call(this, data);

            this.vtcArgs = {
                icn: this.icn,
                startDate: new Date(data.workstreamSettings.startDate).toISOString().split('T')[0], // ex: "2023-12-17"
                stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0] // ex: "2024-06-17"
            };
            this.dataSettings = data.workstreamSettings;
        }

        if (error) {
            this.logger(error);
        }
    }

    /**
     * @description Gets the default sorting field.
     * @returns {string|undefined} The field to sort by, if defined.
     */
    get defaultSortedBy() {
        return this.dataSettings?.sortBy;
    }
    /**
     * @description Gets the default sorting direction.
     * @returns {string|undefined} The sorting direction, if defined.
     */
    get defaultSortedDirection() {
        return this.dataSettings?.sortDirection;
    }

    /**
     * @description Get data for the patient via wire after icn and workstream settings are retrieved
     * @param args the essential criteria for a vtc call { icn: String, startDate: "2023-12-17", stopDate: "2024-06-17" }
     */
    @wire(getAllergiesVTC, { args: '$vtcArgs' })
    async wiredCallout(value) {
        const { data, error } = value;

        if (data) {
            await service.handleCalloutSuccess.call(this, data, this.vtcArgs);
            this.isShowSpinner = false;
        }
        if (error) {
            this.logger(error);
            if (error?.body?.message === 'NO_RETRY_CMD') {
                this.hasError = true;
            } else {
                await service.handleCalloutError.call(this, error, this.vtcArgs);
            }
            this.isShowSpinner = false;
        }
    }

    /**
     * @description Wire to getRecord to build the logic for use of Add to Note
     * @param error
     * @param data
     */
    @wire(getRecord, { recordId: '$recordId', fields: [CreatedBy_FIELD, Signed_FIELD] })
    progressNote({ error, data }) {
        // this will fail cleanly on an Account record or case record since the field data.fields.VCC_Signed__c.value is not present for that recordId

        if (error) {
            this.logger(error);
        } else if (data) {
            // this is required to be called as either true or false since this component is on the Progress Note page
            service.setShowAddToNoteOption.call(
                this,
                // If the user owns the record and the record is not signed, show the Add to Note button
                data.fields.CreatedById.value === service.currentUserId && !data.fields.VCC_Signed__c.value
            );
        }
    }

    /**
     * @description Invoke the save functionality in baseAddToNoteFrame
     * @param event
     */
    handleAddToNoteSubmit(event) {
        event.stopPropagation();
        service.handleAddToNoteSubmit.call(this);
    }
    /**
     * @description Activate the Add to Note button depending on criteria from baseAddToNoteFrame
     * @param event
     */
    handleAddToNoteActivation(event) {
        event.stopPropagation();
        service.handleAddToNoteActivation.call(this, event);
    }
    /**
     * @description Open the Add to Note modal
     */
    handleAddToNoteModalOpen() {
        service.handleAddToNoteModalOpen.call(this);
    }

    /**
     * @description Capture the record selected and render a modal with the details of the selected record in the body and the pagination in the footer
     * @param event Event from BaseHDRFrame when a row is selected
     */
    handleRowSelected(event) {
        service.handleRowSelected.call(this, event, 'c-base-h-d-r-frame', 'c/vccAllergyDetails');
    }

    /**
     * @description Invokes the close modal method on the health data service
     */
    closeModal() {
        service.closeModal.call(this);
    }

    /**
     * @description On a pagination button click, update the selected record and the pagination string
     * @param {`object`} event Expecting an event from baseModal
     *
     */
    nextValueChange(event) {
        service.nextValueChange.call(this, event, 'c-base-h-d-r-frame', 'c/vccAllergyDetails');
    }

    /**
     * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
     * @param {`object`} event Expecting a year e.g. '2004'
     */
    handleLoadMore(event) {
        service.handleLoadMore.call(this, event);
    }

    /**
     * @description invoke refreshApex on batches returned by wired callouts
     */
    async handleReloadHealthData() {
        this.isShowSpinner = true;
        await service.refreshDataInBatchesAsync.call(this);
        this.isShowSpinner = false;
    }

    /**
     * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
     */
    handleMaxLimitReached() {
        service.chunkBigCalloutAndRunAsync.call(this);
    }

    /**
     * @description invokes the setLoading method on the dynamically generated actions component
     * @param loading state of loading on actions component
     */
    setLoading(loading) {
        this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
    }

    /**
     * @description Fetches the dependent custom nebula logger LWC and that will be used for logging
     * @param {*} incomingError - object/string that represents the error that has occured
     */
    logger(incomingError) {
        const logger = this.template.querySelector('c-logger');
        if (!logger) {
            return;
        }
        logger.error(JSON.stringify(incomingError));
        logger.saveLog();
    }
}
