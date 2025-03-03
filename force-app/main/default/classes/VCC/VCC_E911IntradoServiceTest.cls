/**
 * @author Booz Allen
 * @date 04/2024
 * @description This is the test class for the VCC_E911IntradoService class
 *
 */

@IsTest
public class VCC_E911IntradoServiceTest {
    /**
     * @description unit test for building the request body for an Intrado call
     */
    @IsTest
    public static void unitBuildReqBodyFromMetricPositive() {
        String expectedResp = buildTestCivicAddress();
        VCC_e911_Metrics__c testMetric = new VCC_e911_Metrics__c();
        testMetric.VCC_Call_Back_Number__c = '000-000-0000';
        testMetric.VCC_State__c = 'AL';
        testMetric.VCC_City__c = 'City';
        testMetric.VCC_Street__c = '123 Test St';
        testMetric.VCC_Zip_Code__c = '00000';
        testMetric.VCC_Country__c = 'US';

        String requestBody;
        Test.startTest();
        requestBody = VCC_E911IntradoService.buildReqBodyFromMetric(testMetric);
        Test.stopTest();

        Assert.areEqual(requestBody, expectedResp, 'request body generated was not expected');
    }

    /**
     * @description unit test for a positive mock callout response from Intrado
     */
    @IsTest
    public static void unitHandleCalloutPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_IntradoRespBody');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String resp = VCC_E911IntradoService.handleCallout('', 'vccGetTransferNumber');
        Test.stopTest();
        VCC_E911IntradoService.E911Response testResp = (VCC_E911IntradoService.E911Response) JSON.deserialize(
            resp,
            VCC_E911IntradoService.E911Response.class
        );
        Assert.areEqual(testResp.success, 'true', 'mocked resp body success field failed');
        Assert.areEqual(
            testResp.response.transferNumber,
            '0000000000',
            'mocked resp body transfer number field failed'
        );
    }

    /**
     * @description unit test for a positive mock callout response from Intrado
     */
    @IsTest
    public static void unitHandleCallout400Negative() {
        Test.setMock(HttpCalloutMock.class, new BadStatusCodeCalloutMock(400));

        Test.startTest();
        String resp = VCC_E911IntradoService.handleCallout('', 'vccGetTransferNumber');
        Test.stopTest();

        Assert.areEqual(null, resp, 'expected response to be null');
    }

    /**
     * @description unit test for a positive mock callout response from Intrado
     */
    @IsTest
    public static void unitHandleCallout500Negative() {
        Test.setMock(HttpCalloutMock.class, new BadStatusCodeCalloutMock(500));

        Test.startTest();
        String resp = VCC_E911IntradoService.handleCallout('', 'vccGetTransferNumber');
        Test.stopTest();

        Assert.areEqual(null, resp, 'expected response to be null');
    }

    /**
     * @description callout mocking
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    private class BadStatusCodeCalloutMock implements HttpCalloutMock {
        private Integer statusCode;

        /**
         * @description - mocking http response call in tests
         *
         * @param req - incoming http request
         * @return HttpResponse - mocked response
         */
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);
            return res;
        }

        /**
         * @description - constructor for setting response code
         *
         * @param code - response code
         */
        public BadStatusCodeCalloutMock(Integer code) {
            statusCode = code;
        }
    }

    /**
     * @description builds a sample request body
     *
     * @return String - serialized sample request body
     */
    private static String buildTestCivicAddress() {
        VCC_E911IntradoService.CivicAddress addr = new VCC_E911IntradoService.CivicAddress();
        addr.houseNumber = '123';
        addr.road = 'Test St';
        addr.city = 'City';
        addr.state = 'AL';
        addr.postalCode = '00000';
        addr.country = 'US';

        VCC_E911IntradoService.E911RequestBody body = new VCC_E911IntradoService.E911RequestBody();
        body.civicAddress = addr;
        body.callbackNumber = '0000000000';

        return JSON.serialize(body);
    }
}
