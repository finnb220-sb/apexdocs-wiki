@IsTest
public class VCC_HttpCalloutMockFactory implements HttpCalloutMock {
    /**
     * @description This is a list of responses that will be returned in order
     */
    protected List<HttpResponse> orderedResponses = new List<HttpResponse>();

    /**
     * @description This constructor builds the response that will be returned
     * @param code HTTP status code (200, 201, 301, 302, 400, 404, 503, etc)
     * @param status HTTP text status. ie: "ok" for 200
     * @param bodyAsString This is the string that will be returned as the body
     * @param headers a map of headers applied to the response object
     **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_HttpCalloutMockFactory(Integer code, String status, String bodyAsString, Map<String, String> headers) {
        this.orderedResponses.add(VCC_HttpCalloutMockFactory.generateHttpResponse(code, status, bodyAsString, headers));
    }

    /**
     * @description This constructor accepts a list of responses to be returned.
     * @param orderedResponses HTTP status code (200, 201, 301, 302, 400, 404, 503, etc)
     **/
    public VCC_HttpCalloutMockFactory(List<HttpResponse> orderedResponses) {
        this.orderedResponses = orderedResponses;
    }

    /**
     * @description setMock can only be called once per test so to enable mocking
     * multiple callouts, this response method removes the first item on the list of
     * callouts, and returns that. additional callouts will respond with the next items
     * from the list.
     * @param req dependency injected by the system
     * @return HttpResponse
     **/
    public static Integer counter = 0;
    public HttpResponse respond(HttpRequest req) {
        counter += 1;
        System.debug(
            'VCC_HttpCalloutMockFactory.respond() counter: ' +
                counter +
                ' orderedResponses.size(): ' +
                this.orderedResponses.size()
        );
        return this.orderedResponses.remove(0);
    }

    /**
     * @description        Required method for the HttpCalloutMock interface
     * @param code         Integer to return as the status code - 200, 301, 404 etc.
     * @param status       String to return for the status: 'OK' or 'Server Error'
     * @param bodyAsString String to return as the body
     * @param headers      Map<String,String> of headers to return
     * @return            `HttpResponse`
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static HttpResponse generateHttpResponse(
        Integer code,
        String status,
        String bodyAsString,
        Map<String, String> headers
    ) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(code);
        res.setStatus(status);
        res.setBody(bodyAsString);
        for (String headerKey : headers.keySet()) {
            res.setHeader(headerKey, headers.get(headerKey));
        }
        return res;
    }
}
