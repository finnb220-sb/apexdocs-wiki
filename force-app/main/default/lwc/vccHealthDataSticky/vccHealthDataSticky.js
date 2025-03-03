import { LightningElement, api, wire, track } from 'lwc';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import vccUIUpdate from '@salesforce/messageChannel/vccUIUpdate__c';
import hasMSAPermission from '@salesforce/customPermission/VCC_MSA';
import hasRN_Permission from '@salesforce/customPermission/VCC_Registered_Nurse';
import hasMP_Permission from '@salesforce/customPermission/VCC_Medical_Provider';
import hasPharmI_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_I';
import hasPharmII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_II';
import hasPharmIII_Permission from '@salesforce/customPermission/VCC_Pharmacy_Tier_III';

/**
 * @description LWC for patient Health Data that sticks to the top of the screen as users scroll
 */
export default class VccHealthDataSticky extends LightningElement {
    @track hdr = {
        meds: {
            order: 1,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:medication',
            label: 'Meds Rx'
        },
        appointments: {
            order: 2,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'custom:custom94',
            label: 'Appointments'
        },
        allergies: {
            order: 3,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:campaign',
            label: 'Allergies'
        },
        labs: {
            order: 4,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:metrics',
            label: 'Labs'
        },
        consults: {
            order: 5,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:individual',
            label: 'Consults'
        },
        problems: {
            order: 6,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:document_reference',
            label: 'Problems'
        },
        vitals: {
            order: 7,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:feed',
            label: 'Vitals'
        },
        immunizations: {
            order: 8,
            show: false,
            access: false,
            variant: 'base',
            btnClass: 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium',
            icon: 'standard:immunization',
            label: 'Immunizations'
        }
    };

    get hdrList() {
        return Object.keys(this.hdr)
            .map((e) => ({ key: e, ...this.hdr[e] }))
            .sort((a, b) => a.order - b.order);
    }

    isSticky;

    userName;
    showLabs = false;
    showAllergies = false;
    showConsults = false;
    showMeds = false;
    showVitals = false;
    showImmunizations = false;
    showProblems = false;
    showAppointments = false;
    healthData = false;
    yScroll;
    anyAccess;

    currentAction;
    @api recordId;
    @api objectApiName;
    @api addToNoteOptions;
    @api columnsForAddToNote;
    objAddToNoteOptions = {};
    objColumnsForAddToNote = {};

    /**
     * @description This is how the subscription and publisher message context works
     */

    subscription = null;
    @wire(MessageContext)
    messageContext;

    /**
     * @description this assigns health data views based on permissions
     */

    assignViews() {
        if (hasMSAPermission) {
            this.hdr.meds.access = true;
        }
        if (hasRN_Permission) {
            this.hdr.meds.access = true;
            this.hdr.problems.access = true;
        }
        if (hasMP_Permission) {
            this.hdr.allergies.access = true;
            this.hdr.labs.access = true;
            this.hdr.meds.access = true;
            this.hdr.immunizations.access = true;
            this.hdr.consults.access = true;
            this.hdr.vitals.access = true;
            this.hdr.problems.access = true;
        }
        if (hasPharmIII_Permission) {
            this.hdr.allergies.access = true;
            this.hdr.labs.access = true;
            this.hdr.meds.access = true;
            this.hdr.appointments.access = true;
            this.hdr.consults.access = true;
            this.hdr.vitals.access = true;
            this.hdr.problems.access = true;
        }
        if (hasPharmII_Permission) {
            this.hdr.allergies.access = true;
            this.hdr.labs.access = true;
            this.hdr.meds.access = true;
            this.hdr.appointments.access = true;
            this.hdr.consults.access = true;
        }
        if (hasPharmI_Permission) {
            this.hdr.meds.access = true;
            this.hdr.consults.access = true;
            this.hdr.appointments.access = true;
        }

        this.defaultViews();
    }

    /**
     * @description sets meds component open for pharmacy users
     */
    defaultViews() {
        if (hasPharmI_Permission || hasPharmII_Permission || hasPharmIII_Permission) {
            this.showButtons('meds', false);
        }
    }

    /**
     * @description Code that should run once the component renders- we need relevant height information from the anchor
     */
    connectedCallback() {
        this.assignViews();
        this.anyAccess = Object.values(this.hdr).reduce(function (collect, elem) {
            if (elem.access) {
                return collect + 1;
            }
            return collect + 0;
        }, 0);
        if (this.anyAccess) {
            window.addEventListener('resize', this.resize);
            window.addEventListener('scroll', this.resize);
            if (!this.subscription) {
                this.subscription = subscribe(
                    this.messageContext,
                    vccUIUpdate,
                    (message) => {
                        if (
                            message.componentName === 'vccHealthDataSticky' &&
                            this.recordId === message.recordId &&
                            message.values > 0
                        ) {
                            this.yScroll = message.values;
                            this.setHeight();
                        }
                    },
                    { scope: APPLICATION_SCOPE }
                );
            }
        }
        if (this.addToNoteOptions) {
            this.objAddToNoteOptions = JSON.parse(this.addToNoteOptions);
        }
        if (this.columnsForAddToNote) {
            this.objColumnsForAddToNote = JSON.parse(this.columnsForAddToNote);
        }
    }

    /**
     * @description removed everything we've added a listener to
     */

    disconnectedCallback() {
        window.removeEventListener('resize', this.resize);
        window.removeEventListener('scroll', this.resize);
    }

    /**
     * @description Passes relevant height details after a component finishes rendering
     */
    renderedCallback() {
        if (this.anyAccess) {
            let outerSection = this.template.querySelector('.outer');
            let stickysection = this.template.querySelector('.sticky');
            outerSection?.style?.setProperty('--spacer-height', stickysection.getBoundingClientRect().height + 'px');
        }
    }

    /**
     * @description sets the initial height of the top value
     */
    setHeight() {
        let outerSection = this.template.querySelector('.outer');
        let linksSection = this.template.querySelector('.border');
        let linksHeight = linksSection.getBoundingClientRect().height;
        outerSection.style.setProperty(
            '--conditional-height',
            window.innerHeight - (this.yScroll + linksHeight + 20) + 'px'
        );
    }

    /**
     * @description provides size info as component changes
     */
    resize = () => {
        try {
            let outerSection = this.template.querySelector('.outer');
            let stickysection = this.template.querySelector('.sticky');
            let parentDiv = outerSection.getBoundingClientRect();
            let parentTop = outerSection.offsetTop + 12;

            stickysection.style.left = `${parentDiv.left}px`;
            stickysection.style.width = `${parentDiv.width}px`;

            if (window.scrollY > parentTop) {
                stickysection.style.position = 'fixed';
                stickysection.style.top = `${this.yScroll}px`;

                outerSection.style.setProperty('--sticky-index', 2000);
                outerSection.style.setProperty('--spacer-height', stickysection.getBoundingClientRect().height + 'px');
                this.isSticky = true;
            } else {
                stickysection.style.position = 'relative';
                stickysection.style.top = 'auto';
                stickysection.style.left = 'auto';

                outerSection.style.setProperty('--sticky-index', 'auto');
                this.isSticky = false;
            }
        } catch (error) {
            const logger = this.template.querySelector('c-logger');
            logger.error(error);
            logger.saveLog();
        }
    };

    /**
     * @description Action that happens when a component is clicked
     */
    handleClick(event) {
        event.stopPropagation();
        let clickId;
        if (event.target.dataset.id) {
            // Button was clicked
            clickId = event.target.dataset.id;
        } else {
            // Wrapping div was clicked
            clickId = event.currentTarget.dataset.id;
        }
        let curShow = this.hdr[clickId].show;

        Object.keys(this.hdr).forEach((e) => {
            if (this.hdr[e].access) {
                if (e !== clickId) {
                    this.btnReset(e);
                } else {
                    this.showButtons(e, curShow);
                }
            }
        });
    }

    /**
     * @description shows needed buttons
     * @param key meds data that was clicked on
     * @param buttonClicked button that was clicked on
     */

    showButtons(key, buttonClicked) {
        if (this.hdr[key]) {
            this.hdr[key].variant = buttonClicked ? 'base' : 'neutral';
            this.hdr[key].show = !buttonClicked;
            this.hdr[key].btnClass = buttonClicked
                ? 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium'
                : 'slds-m-left_xxx-small slds-m-right_medium';
            this['show' + key?.charAt(0)?.toUpperCase() + key?.substring(1)] = !buttonClicked;
            this.healthData = !buttonClicked;
        }
    }

    /**
     * @description Reset button values
     */
    btnReset(element) {
        if (this.hdr[element]) {
            this.hdr[element].variant = 'base';
            this.hdr[element].show = false;
            this.hdr[element].btnClass = 'slds-m-left_xxx-small slds-m-right_medium slds-p-horizontal_medium';
            this['show' + element?.charAt(0)?.toUpperCase() + element?.substring(1)] = false;
        }
    }

    /**
     * @description closes health data
     */
    closeHealthData() {
        this.healthData = false;
        Object.keys(this.hdr).forEach((e) => {
            if (this.hdr[e].access) {
                this.btnReset(e);
            }
        });
    }
}
