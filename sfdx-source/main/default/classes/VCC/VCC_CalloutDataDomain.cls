public with sharing class VCC_CalloutDataDomain {
    public VCC_Callout_Data__c convertHttpDataToCalloutData(VCC_HttpIntercept_Observer.HttpData httpData) {
        if (httpData == null) {
            return new VCC_Callout_Data__c();
        }
        VCC_Callout_Data__c calloutData = new VCC_Callout_Data__c(
            VCC_Request_Time__c = httpData.timeSent,
            VCC_Request_Body__c = VCC_String_Utilities.truncateStringForField(httpData.requestBody, VCC_Callout_Data__c.VCC_Request_Body__c),
            VCC_Endpoint__c = (!String.isBlank(httpData.requestEndpoint)) ? VCC_EndpointUtility.getUrlForNamedCredential(httpData.requestEndpoint) : null,
            VCC_Response_Time__c = httpData.timeReceived,
            VCC_Response_Body__c = VCC_String_Utilities.truncateStringForField(httpData.responseBody, VCC_Callout_Data__c.VCC_Response_Body__c),
            VCC_Status_Code__c = httpData.responseStatusCode
        );
        return calloutData;
    }
}
