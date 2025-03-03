@IsTest
public with sharing class VCC_HttpOverride_MockTest {
    @IsTest
    static void httpOverrideMockTest() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('test test test');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('www.fakewebsitedontgohere.com');
        request.setMethod('GET');
        HttpResponse response;
        Exception expectedException;

        Test.startTest();
        VCC_HttpOverride_Mock.mockNext(mockResponse);
        response = VCC_HttpService.send(request);
        VCC_HttpOverride_Mock.clearMock();
        try {
            VCC_HttpService.send(request);
        } catch (Exception e) {
            expectedException = e;
        }
        Test.stopTest();

        System.assert(response.getBody() == 'test test test', 'HttpResponse did not mock properly.');
        System.assert(expectedException.getMessage() == 'Methods defined as TestMethod do not support Web service callouts', 'Expected exception not caught.');
    }
}
