/**
 * @description
 * @author David Bingham
 * @since 4/28/2021
 * @group HTTP
 */
global class VCC_HttpRequestAction {
    @InvocableMethod(label='Generate HttpRequest' description='Constructs an HTTP Request')
    global static List<ActionResult> processRequests(List<ActionRequest> requests) {
        // Todo: Training Mode look here to inject training mode service
        List<ActionResult> results = new List<ActionResult>();
        for (ActionRequest request : requests) {
            results.add(processRequest(request));
        }
        return results;
    }

    public static ActionResult processRequest(ActionRequest request) {
        if (Test.isRunningTest()) {
            // To Do: mock stub
            System.debug(LoggingLevel.INFO, 'Test mode.');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + request.endpoint + '/' + request.path);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-Type', 'application/json; charset=UTF-8');
        req.setMethod('POST');
        req.setHeader('clientId', '{!$Credential.Username}');
        req.setHeader('clientSecret', '{!$Credential.Password}');

        if (request.origin != null && request.origin != '') {
            req.setHeader('Origin', request.origin);
        } else {
            req.setHeader('Origin', System.URL.getSalesforceBaseURL().toExternalForm());
        }

        req.setBody(request.requestJSON);
        req.setTimeout(120000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(LoggingLevel.INFO, 'Response: ' + res.getBody());

        ActionResult result = new ActionResult();
        result.responseJSON = res.getBody();
        return result;
    }

    global class ActionRequest {
        @InvocableVariable(required=true)
        global String endPoint;

        @InvocableVariable(required=true)
        global String path;

        @InvocableVariable(required=false)
        global String requestJSON;

        @InvocableVariable(required=false)
        global String origin;

        @InvocableVariable(required=false)
        global String clientIdKey;

        @InvocableVariable(required=false)
        global String clientSecretKey;
    }

    global class ActionResult {
        @InvocableVariable
        global String responseJSON;
    }

    class ActionException extends Exception {
    }
}
