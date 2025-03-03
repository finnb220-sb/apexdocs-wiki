/* eslint-disable no-undef */ //justification - Base Aura calls are flagged as undef ($A)
/* eslint-disable no-unused-expressions */ //justification - Helper methods are called in Controller class
/**
 * @description       : Class used as a Helper for Kanban Board Cards
 * @author            : Booz Allen Hamilton
 **/
({
    modalHelper: function (component, modal, backdrop, tf) {
        let mdl = component.find(modal).getElement();
        let bkdrp = component.find(backdrop).getElement();
        if (tf) {
            $A.util.addClass(mdl, 'slds-fade-in-open');
            $A.util.addClass(bkdrp, 'slds-backdrop_open');
            mdl.focus();
        } else {
            $A.util.removeClass(mdl, 'slds-fade-in-open');
            $A.util.removeClass(bkdrp, 'slds-backdrop_open');
        }
    },
    resetAttributes: function (component) {
        component.set('v.modalButtonDisable', true);
        component.set('v.targetStatus', false);
        component.set('v.showModal', false);
    }
});
