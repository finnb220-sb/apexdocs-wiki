/**
 * @description Provider Connect Specialist Omni Status Controller
 * This component allows the user to update and see their
 * login status.
 * @author Booz Allen
 */
({
    /**
     * @description This method utilizes omniToolkit to allow the specialist to set their status to online
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component Event
     * @param {*} hlp Ref to helper
     */
    /*@justification This is part of the aura function signature */
    /* eslint-disable-next-line */
    setOnlineStatus: function (cmp, evt, hlp) {
        const logger = cmp.find('logger');
        var omniAPI = cmp.find('omniToolkit');
        if (omniAPI === undefined) {
            logger.error('The OmniToolkit is unavailable');
        } else {
            let pcServicePresenceStatusId = cmp.get('v.servicePresenceStatusId');
            omniAPI
                .setServicePresenceStatus({ statusId: pcServicePresenceStatusId })
                .then(function () {
                    hlp.setUIStatusOnline(cmp);
                })
                .catch(function (error) {
                    logger.error(error);
                });
        }
        logger.saveLog();
    },
    /**
     * @description Using the omniToolkit, this function allows the Specialist to
     * logout of Omni-Channel
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component Event
     * @param {*} hlp Ref to helper
     */
    /*@justification This is part of the aura function signature */
    /* eslint-disable-next-line */
    logout: function (cmp, evt, hlp) {
        const logger = cmp.find('logger');
        var omniAPI = cmp.find('omniToolkit');
        if (omniAPI === undefined) {
            logger.error('The OmniToolkit is unavailable');
        } else {
            omniAPI
                .logout()
                /*@justification This is part of the aura function signature */
                /* eslint-disable-next-line */
                .then(function (result) {
                    hlp.setUIStatusOffline(cmp);
                })
                .catch(function (error) {
                    logger.error(error);
                });
        }
        logger.saveLog();
    },
    /**
     *@description This function checks the status on page load
     * so the proper button is updated to reflect it
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component Event
     * @param {*} hlp Ref to helper
     */
    doInit: function (cmp, evt, hlp) {
        hlp.initHelper(cmp, evt);
        hlp.fetchServicePresenceStatusId(cmp);
    },
    /**
     * @description This updates the status buttons
     * when a Specialist switches to Online from
     * the Omni-Channel widget
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component Event
     * @param {*} hlp Ref to helper
     */
    onStatusChanged: function (cmp, evt, hlp) {
        var statusApiName = evt.getParam('statusApiName');
        if (statusApiName === 'PC_Available_Provider_Connect') {
            hlp.setUIStatusOnline(cmp);
        }
    },
    /**
     * @description This updates the status buttons
     * when a Specialist switches to Offline from
     * the Omni-Channel widget
     * @param {*} cmp Ref to current aura component
     * @param {*} evt Component Event
     * @param {*} hlp Ref to helper
     */
    /*@justification This is part of the aura function signature */
    /* eslint-disable-next-line */
    onLogout: function (cmp, evt, hlp) {
        hlp.setUIStatusOffline(cmp);
    }
});
