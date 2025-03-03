@isTest
/**
 * @description
 * @author Matthew Katona
 * @since 5/18/2021
 * @group HTTP
 */
global class VCC_MedsMockHttpResponse implements HttpCalloutMock {
    // configurable response code
    public Integer resCode;

    // mock response
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"testResult":"OK"}');

        // set status code
        res.setStatusCode(resCode);

        // if status code isn't 200, set error message in status
        if (resCode != 200) {
            res.setStatus(resCode + ' error');
        }

        return res;
    }
}
