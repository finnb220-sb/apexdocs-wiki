/**
 * @description Provider Connect Specialist Omni Status
 * This file providers helper methods to the
 * primary functions on the controller class
 * @author Booz Allen
 */
({
    /**
     * @description This function provides the framework to check the
     * status when the page is loaded
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component event
     */
    initHelper: function (cmp, evt) {
        this.checkStatus(cmp, evt);
    },
    /**
     * @description This function checks the status of the
     * Specialist when the page is loaded and updates
     * the proper button based on the results.
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component event
     * @param {*} retryCounter Holds the number to retry
     */
    checkStatus: function (cmp, evt, retryCounter) {
        const HELPER = this;
        const logger = cmp.find('logger');
        let loggerIsDefined = logger !== undefined;
        var omniAPI = cmp.find('omniToolkit');
        if (omniAPI === undefined && loggerIsDefined) {
            logger.error('The OmniToolkit is unavailable');
        } else {
            if (retryCounter === undefined) {
                retryCounter = 1;
            }
            omniAPI
                .getServicePresenceStatusId()
                .then(function (result) {
                    if (result.statusApiName === 'PC_Available_Provider_Connect') {
                        cmp.set('v.buttonsDisabled', false);
                        cmp.set('v.loaded', !cmp.get('v.loaded'));
                        HELPER.setUIStatusOnline(cmp);
                    }
                })
                .catch(function (error) {
                    if (retryCounter <= 5) {
                        /*@justification Unable to detect omni-channel until it comes online
                         so implemented setTimeout to give it a buffer to check status */
                        /* eslint-disable-next-line */
                        setTimeout(() => {
                            HELPER.checkStatus(cmp, evt, retryCounter + 1);
                        }, 3000);
                    } else {
                        cmp.set('v.buttonsDisabled', false);
                        cmp.set('v.loaded', !cmp.get('v.loaded'));
                        HELPER.setUIStatusOffline(cmp);
                        if (loggerIsDefined) {
                            logger.error(error);
                        }
                    }
                });
        }
        if (loggerIsDefined) {
            logger.saveLog();
        }
    },
    /**
     * @description This sets the css of the button to green when
     * the Specialist is online and defaults
     * the offline button
     * @param {*} cmp ref to current aura component
     */
    setUIStatusOnline: function (cmp) {
        cmp.set('v.onlineButtonCss', 'Online');
        cmp.set('v.offlineButtonCss', '');
    },
    /**
     * @description This sets the css of the button to red when
     * the Specialist is offline and defaults
     * the online button
     * @param {*} cmp ref to current aura component
     */
    setUIStatusOffline: function (cmp) {
        cmp.set('v.offlineButtonCss', 'Offline');
        cmp.set('v.onlineButtonCss', '');
    },
    /**
     * @description gets the Id of the PC Service Presence Status for a specialist to appear Available
     * @param {*} cmp ref to the aura component
     */
    fetchServicePresenceStatusId: function (cmp) {
        const logger = cmp.find('logger');
        const action = cmp.get('c.getPcServicePresenceStatusId');

        // Set callback function
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === 'SUCCESS') {
                // Set the response data to the component's attribute
                cmp.set('v.servicePresenceStatusId', response.getReturnValue());
            } else {
                let errors = response.getError();
                let errorMessage =
                    'While fetching the PC Available Service Presence Status Id for the pcSpecialistOmniStatus component, an error occurred. ';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        // log the error passed in to AuraHandledException
                        errorMessage += 'Error message: ' + errors[0].message;
                    }
                }
                logger.error(errorMessage);
                logger.saveLog();

                cmp.set('v.servicePresenceStatusId', null);
            }
        });

        // Enqueue the action
        $A.enqueueAction(action);
    }
});
