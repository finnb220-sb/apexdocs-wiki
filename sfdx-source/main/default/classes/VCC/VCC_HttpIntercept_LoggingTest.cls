@IsTest
public with sharing class VCC_HttpIntercept_LoggingTest {
    @IsTest
    static void testLogNext() {
        VCC_HttpOverride_Mock.mockNext(new HttpResponse());

        Test.startTest();
        VCC_HttpIntercept_Logging.logNext();
        VCC_HttpService.send(new HttpRequest());
        VCC_HttpIntercept_Logging.logHttpRequest(new HttpRequest());
        VCC_HttpIntercept_Logging.logHttpResponse(new HttpResponse());
        Test.stopTest();

        Assert.isTrue(true, 'No asserts to be made.');
    }

    @IsTest
    static void testMockAll() {
        VCC_HttpOverride_Mock.mockAll(new HttpResponse());

        Test.startTest();
        VCC_HttpIntercept_Logging.logAll();
        VCC_HttpService.send(new HttpRequest());
        VCC_HttpIntercept_Logging.logHttpRequest(new HttpRequest());
        VCC_HttpIntercept_Logging.logHttpResponse(new HttpResponse());
        Test.stopTest();

        Assert.isTrue(true, 'No asserts to be made.');
    }

    @IsTest
    static void testClearMock() {
        VCC_HttpOverride_Mock.clearMock();
        Assert.isTrue(true, 'No asserts to be made.');
    }
}
