public with sharing class VCC_MockHttpResponseGenerator implements HttpCalloutMock {
    private HttpResponse mockResponse;

    public VCC_MockHttpResponseGenerator(HttpResponse mockResponse) {
        this.mockResponse = mockResponse;
    }

    public HttpResponse respond(HttpRequest req) {
        return mockResponse;
    }
}
