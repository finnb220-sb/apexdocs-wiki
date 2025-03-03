@isTest
public with sharing class VCC_HttpIntercept_ObserverTest {
    @IsTest
    static void methodName() {
        VCC_HttpOverride_Mock.mockAll(new HttpResponse());
        Test.startTest();
        VCC_HttpIntercept_Observer.observeNext();
        VCC_HttpIntercept_Observer.observeAll();
        VCC_HttpService.send(new HttpRequest());
        Test.stopTest();

        System.assert(VCC_HttpIntercept_Observer.getData() != null, 'Expected non null.');
        System.assert(VCC_HttpIntercept_Observer.getData().timeReceived != null, 'Expected non null.');
    }
}
