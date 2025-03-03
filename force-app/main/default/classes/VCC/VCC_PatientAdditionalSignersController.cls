public with sharing class VCC_PatientAdditionalSignersController {
    @AuraEnabled
    public static String getPatientAdditionalSigners(Map<String, Object> addSignersParams) {
        return VCC_PatientService.getAdditionalSignersBridg(addSignersParams);
    }

    // TODO: refactor below to fit current pattern, doing this in the interest of time 07/19/2022
    @AuraEnabled
    public static string getAdditionalSigners(Map<String, Object> params) {
        try {
            HttpRequest request = new HttpRequest();
            HttpResponse resp;

            request.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', 'vccBridgAdditionalSigners'));
            // request.setEndpoint('callout:vccBridg_staging/additionalSigners');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiKey', '{!$Credential.Password}');
            request.setTimeout(120000);
            String json = JSON.serialize(new VCC_Bridg_AdditionalSignersRequest(params));
            system.debug('json' + json);
            request.setBody(json);
            resp = (new Http()).send(request);

            if (resp.getStatusCode() != 200) {
                Log.debug(resp.getBody());
            }

            System.debug(LoggingLevel.INFO, 'VAHC::response' + resp.getBody());

            return resp.getBody().replace('"null"', 'null').replace('"true"', 'true').replace('"false"', 'false');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
