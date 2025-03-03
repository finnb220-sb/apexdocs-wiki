@isTest
public with sharing class VCC_VdifQueueable_EsigTest {
    @IsTest
    static void executeQueueableTestHappy() {
        Object fakeQueueableContext;
        System.QueueableContext queueableContext = (System.QueueableContext) fakeQueueableContext;

        VCC_VdifQueueStratTest stratTest = new VCC_VdifQueueStratTest();

        VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
        (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
        VCC_VdifQueueableCallback vdifCallback = new VCC_VdifQueueableCallback(vdifParameters, stratTest);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody(JSON.serialize(new VCC_VdifIsValidEsigRS()));
        VCC_HttpOverride_Mock.mockNext(mockResponse);
        Test.startTest();
        new VCC_VdifQueueable_Esig(vdifCallback).execute(vdifCallback, queueableContext);
        Test.stopTest();

        System.assert(stratTest.onQueueableStartCalled, 'Method not called as expected.');
        System.assert(stratTest.onCalloutResponseCalled, 'Method not called as expected.');
        System.assert(!stratTest.onExceptionCalled, 'Method called unexpectedly.');
        System.assert(stratTest.onQueueableEndCalled, 'Method not called as expected.');
    }

    @IsTest
    static void executeQueueableTestSad() {
        Object fakeQueueableContext;
        System.QueueableContext queueableContext = (System.QueueableContext) fakeQueueableContext;

        VCC_VdifQueueStratTest stratTest = new VCC_VdifQueueStratTest();
        stratTest.throwMockException = true;
        VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
        (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
        VCC_VdifQueueableCallback vdifCallback = new VCC_VdifQueueableCallback(vdifParameters, stratTest);
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody(JSON.serialize(new VCC_VdifIsValidEsigRS()));
        VCC_HttpOverride_Mock.mockNext(mockResponse);
        Test.startTest();
        new VCC_VdifQueueable_Esig(vdifCallback).execute(vdifCallback, queueableContext);
        Test.stopTest();

        System.assert(stratTest.onQueueableStartCalled, 'Method not called as expected.');
        System.assert(!stratTest.onCalloutResponseCalled, 'Method called unexpectedly.');
        System.assert(stratTest.onExceptionCalled, 'Method not called as expected.');
        System.assert(!stratTest.onQueueableEndCalled, 'Method called unexpectedly.');
    }
}
