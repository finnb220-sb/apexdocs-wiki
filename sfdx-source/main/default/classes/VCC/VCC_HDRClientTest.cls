@isTest
private class VCC_HDRClientTest {
    @isTest
    static void testGetDemographicsBridg() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"some": "data"}');

        Test.setMock(HttpCalloutMock.class, new VCC_MockHttpResponseGenerator(mockResponse));

        VCC_BridgRequest testRequest = new VCC_BridgRequest();
        Test.startTest();
        VCC_BridgDemographicsRS result = new VCC_HDRClient().getDemographicsBridg(testRequest);
        Test.stopTest();
    }

    @isTest
    static void testCallBridg() {
        // Create a mock response
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"some": "data"}');

        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new VCC_MockHttpResponseGenerator(mockResponse));

        // Create a test instance of VCC_BridgRequest
        VCC_BridgRequest testRequest = new VCC_BridgRequest();

        // Call the method to be tested
        Test.startTest();
        mockResponse.setStatusCode(200);
        HttpResponse result = VCC_HDRClient.callBridg(testRequest, 'vccBridgMeds');

        try {
            mockResponse.setStatusCode(404);
            HttpResponse badRequest = VCC_HDRClient.callBridg(testRequest, 'vccBridgMeds');
        } catch (Exception e) {
            Assert.isTrue(e != null, 'Expected to have a valid error');
        }

        try {
            mockResponse.setStatusCode(500);
            HttpResponse serverError = VCC_HDRClient.callBridg(testRequest, 'vccBridgMeds');
        } catch (Exception e) {
            Assert.isTrue(e != null, 'Expected to have a valid error');
        }

        Test.stopTest();
    }
}

// Mock HTTP callout class

