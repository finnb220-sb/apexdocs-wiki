import CNX_RESOURCE_LINK from '@salesforce/resourceUrl/cnx__CnxSfdcResources';
import { loadScript } from 'lightning/platformResourceLoader';
import { subscribe, publish, APPLICATION_SCOPE, createMessageContext } from 'lightning/messageService';
import cnxmc from '@salesforce/messageChannel/cnx__ConnectsIntegrationAPI__c';

export default function getIntegrationApi(lwc, cb) {
    // Load Integration API from static resource
    loadScript(lwc, CNX_RESOURCE_LINK + '/js/ConnectsIntegrationAPI.min.js')
        .then(() => {
            const messageContext = createMessageContext();
            const iAPIInstance = window.ConnectsIntegrationAPI.noConflict();
            iAPIInstance.setLMSEnvironment({
                mode: 'LWC',
                publishMethod: function (message) {
                    publish(messageContext, cnxmc, message);
                },
                subscribeMethod: function (handler) {
                    subscribe(messageContext, cnxmc, handler, { scope: APPLICATION_SCOPE });
                }
            });
            // Return the Integration API object when it is ready
            iAPIInstance.waitReady(() => {
                return cb(iAPIInstance);
            });
        })
        .catch((error) => {
            cb(null, error);
        });
}
