import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import vclLabel from '@salesforce/label/c.VCC_Veteran_Crisis_Line';
import getLinks from '@salesforce/apex/VCC_ExternalVaLinksController.getLinks';
import createUserUIe911Record from '@salesforce/apex/VCC_ExternalVaLinksController.createUserUIe911Record';
import createTaske911 from '@salesforce/apex/VCC_ExternalVaLinksController.createTaske911';

//? check for TUC User permissions
import hasTUCRN_Permission from '@salesforce/customPermission/TED_RN';
import hasTUCMP_Permission from '@salesforce/customPermission/TED_Medical_Provider';
//? check for CRM User permissions
import hasCT_Permission from '@salesforce/customPermission/VCC_Registered_Nurse';
import hasMSA_Permission from '@salesforce/customPermission/VCC_MSA';
import hasVCV_Permission from '@salesforce/customPermission/VCC_Medical_Provider';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';
//? check for e911 permissions
import hasE911_Permission from '@salesforce/customPermission/VCC_VAHC_E911_User';
import getE911ActiveCustomSetting from '@salesforce/apex/VCC_ExternalVaLinksController.getE911ActiveCustomSetting';

/**
 * @description Array of booleans. A true from any indicates user has Tele-EC custom permission(s)
 * @type {boolean[]}
 */
const TUC_PERMISSIONS = [hasTUCRN_Permission, hasTUCMP_Permission];

/**
 * @description Array of booleans. A true from any indicates user has CRM custom permission(s)
 * @type {boolean[]}
 */
const CRM_PERMISSIONS = [
    hasCT_Permission,
    hasMSA_Permission,
    hasVCV_Permission,
    hasPharmI_Permission,
    hasPharmII_Permission,
    hasPharmIII_Permission
];

const SNIPPET_E911 = 'e911';
const FLOW_STATUS_FINISHED = 'FINISHED';

export default class VccExternalVaLinks extends NavigationMixin(LightningElement) {
    /**
     * @description Indicates if the getLinks wired method has returned a data or error, yet. Informs spinner in UI.
     * @return {boolean}
     */
    get isLoading() {
        return this.wiredLinks?.data === undefined && this.wiredLinks?.error === undefined;
    }

    /**
     * @description Controls visibility of dialog showing e911 flow.
     * @type {boolean}
     */
    showE911FlowModal = false;

    /**
     * @description (deprecated) Originally intended to inform query for links based on audience; that query (in VCC_ExternalVaLinksController.getLinks) is now controlled through different logic.
     * - Left this public property in place because it is called out in the meta.xml file and may be referenced on different screens using this LWC.
     * @type {string}
     */
    @api targetAudience = 'All';
    @api recordId;
    @api objectApiName;

    /**
     * @description indicates if current user has any of the CRM-oriented custom permissions
     * @return {boolean}
     */
    get isCRMUser() {
        return CRM_PERMISSIONS.includes(true);
    }
    /**
     * @description indicates if current user has any of the Tele-EC-oriented custom permissions
     * @return {boolean}
     */
    get isTUCUser() {
        return TUC_PERMISSIONS.includes(true);
    }
    /**
     * @description indicates if current user has the e911 custom permission
     * @return {boolean}
     */
    get isE911User() {
        return hasE911_Permission === true;
    }

    labels = {
        noResultsMessage: 'No External Links found.',
        vclLabel: vclLabel
    };

    /**
     * @description Retrieves a boolean value from the e911 custom setting
     */
    @wire(getE911ActiveCustomSetting) wiredE911Setting;

    /**
     * @description Indicates if e911 functionality is enabled, per custom settings
     * @return {boolean}
     */
    get isE911Enabled() {
        return this.wiredE911Setting?.data === true;
    }

    /**
     * @description Evaluates if UI should display the e911 button, based on feature enablement and user permissions.
     * @return {boolean}
     */
    get showE911Button() {
        return this.isE911Enabled && this.isE911User;
    }

    /**
     * @description Retrieves the va links according to records in the External_VA_Link__mdt custom metadata type
     */
    @wire(getLinks, { isCRMUser: '$isCRMUser' }) wiredLinks;

    /**
     * @description Reads data value from getLinks response
     * @return {External_VA_Link__mdt[]|*[]}
     */
    get links() {
        return this.wiredLinks?.data ?? [];
    }

    /**
     * @description Indicates if UI should display empty state due to retrieving an empty list of links
     * @return {boolean}
     */
    get showEmptyState() {
        return !this.isLoading && this.links.length === 0;
    }

    /**
     * @description Opens the link selected whenever the user clicks on one of the available options
     * - this is also the onclick handler for e911 button
     * @param {*} event - click event from the UI
     */
    navigateToLink(event) {
        event.preventDefault();
        const url = event?.target?.dataset?.url;
        const title = event?.target?.title; //check for a title (present on buttons)
        if (url) {
            //enter this if statement if a link is clicked
            if (url.includes(SNIPPET_E911) && this.recordId) {
                // Call the 911 function
                this.logE911LinkClick();
            }
            // Handle Navigation
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            });
        } else if (title && title.includes(SNIPPET_E911)) {
            //if button having title containing 'e911'
            this.showE911FlowModal = true;
        } else {
            this.nebulaLogger('URL is undefined');
        }
    }

    /**
     * @description Wrapper function for Nebula logger component
     * @param {*} incomingError - error object
     * @return null when logger does not exist, otherwise void
     * - treat this as a void function
     */
    nebulaLogger(incomingError) {
        if (incomingError) {
            const logger = this.template.querySelector('c-logger');
            if (!logger) {
                return;
            }
            logger.error(JSON.stringify(incomingError));
            logger.saveLog();
        }
    }

    /**
     * @description Handles the creation of e911 metric record when a user clicks on the e911 button
     */
    logE911LinkClick() {
        createUserUIe911Record({ objectAPI: this.objectApiName, recordClickedOn: this.recordId }).catch(() => {
            this.nebulaLogger('Error attempted to create a UserUIe911 record');
        });
        if (this.isTUCUser) {
            createTaske911({ objectAPI: this.objectApiName, recordClickedOn: this.recordId }).catch(() => {
                this.nebulaLogger('Error attempted to create a Task record');
            });
        }
    }

    /**
     * @description Returns a map of data to pass to the e911 flow
     * @return [Object]
     */
    get flowInputVars() {
        return [
            { name: 'recordId', type: 'String', value: this.recordId },
            { name: 'sObjectType', type: 'String', value: this.objectApiName }
        ];
    }

    /**
     * @description Hides e911 flow when flow status changes to FINISHED
     * @param event An event from the embedded e911 flow
     */
    handleFlowStatusChange(event) {
        if (event?.detail?.status === FLOW_STATUS_FINISHED) {
            this.showE911FlowModal = false;
        }
    }
}
