@isTest
public with sharing class VCC_HttpServiceTest {
    @isTest
    public static void responseInterceptTest() {
        InterceptTestClass responseInterceptTestClass = new InterceptTestClass();
        VCC_HttpService.setIntercept(responseInterceptTestClass);

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('vCC_badResponse');
        mock.setHeader('test', 'test');
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.google.com');
        VCC_HttpService.send(request);
        Test.stopTest();

        System.assert(responseInterceptTestClass.interceptedResponse != null, 'Expected an intercepted response.');
        System.assert(responseInterceptTestClass.interceptedResponse.getHeader('test') == 'test', 'Expected a header key/value of "test"=>"test".');
    }

    @isTest
    public static void sendOverrideTest() {
        SendOverrideTestClass sendOverrideTest = new SendOverrideTestClass();
        VCC_HttpService.setOverride(sendOverrideTest);

        Test.startTest();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://www.google.com');
        VCC_HttpService.send(request);
        Test.stopTest();

        System.assert(sendOverrideTest.overriden == true, 'Expected overriden to be true.');
    }

    private class InterceptTestClass implements VCC_HttpService.Intercept {
        public HttpResponse interceptedResponse;

        public HttpRequest interceptedRequest;

        public HttpRequest interceptHttpRequest(HttpRequest request) {
            this.interceptedRequest = request;
            return request;
        }

        public HttpResponse interceptHttpResponse(HttpResponse response) {
            this.interceptedResponse = response;
            return response;
        }
    }

    private class SendOverrideTestClass implements VCC_HttpService.SendOverride {
        public Boolean overriden = false;

        public HttpResponse sendHttpRequest(HttpRequest request) {
            this.overriden = true;
            return null;
        }
    }
}
