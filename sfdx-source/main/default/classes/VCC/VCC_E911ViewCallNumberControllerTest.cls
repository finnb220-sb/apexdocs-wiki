/**
 * @author Booz Allen
 * @date 04/2024
 * @description Test class for VCC_E911ViewCallNumberController
 */
@IsTest
public class VCC_E911ViewCallNumberControllerTest {
    /**
     * @description unit test that attempts to get a mock e911 Metric record, retrieve temporary e911 number, set the number on the e911 record, and do a database update
     */
    @IsTest
    private static void unitGetTransferNumberPositive() {
        Id fakeE911MetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.sObjectType);
        //mock response
        VCC_e911_Metrics__c testMetricResp = new VCC_e911_Metrics__c();
        testMetricResp.VCC_Call_Back_Number__c = '0000000000';
        testMetricResp.VCC_State__c = 'AL';
        testMetricResp.VCC_City__c = 'City';
        testMetricResp.VCC_Street__c = '123 Test St';
        testMetricResp.VCC_Zip_Code__c = '00000';
        testMetricResp.VCC_Country__c = 'US';
        //mock update input for mock repo
        SobjectType objType = VCC_e911_Metrics__c.sObjectType;
        sObject sampleMetric = objType.newSObject();
        sampleMetric.put('VCC_Call_Back_Number__c', '0000000000');
        sampleMetric.put('VCC_State__c', 'AL');
        sampleMetric.put('VCC_City__c', 'City');
        sampleMetric.put('VCC_Street__c', '123 Test St');
        sampleMetric.put('VCC_Zip_Code__c', '00000');
        sampleMetric.put('VCC_Country__c', 'US');
        sampleMetric.put('VCC_Temporary_e911_Number__c', '0000000000');
        //mocked repo
        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(fakeE911MetricId)
            .returning(testMetricResp)
            .mockingMethodCall('doUpdate', SObject.class)
            .withParameterValues(sampleMetric)
            .returning((Database.SaveResult) JSON.deserialize('{"success":true}', Database.SaveResult.class))
            .defineStub();
        //static resource houses the sample response data
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_IntradoRespBody');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, mock);
        VCC_E911ViewCallNumberController.memoizedE911MetricsRepo = stubE911MetricsRepo;
        List<VCC_E911IntradoService.E911Response> testResults;
        Test.startTest();
        testResults = VCC_E911ViewCallNumberController.getTransferNumberCallout(new List<String>{ fakeE911MetricId });
        Test.stopTest();

        Assert.areEqual(testResults.get(0).success, 'true', 'mocked response did not return true');
    }

    /**
     * @description unit test for retrieving an e911 record when given an id positive
     */
    @IsTest
    private static void unitGetE911MetricRecordPositive() {
        Id fakeE911MetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.sObjectType);

        //mocked repo
        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(fakeE911MetricId)
            .returning(new VCC_e911_Metrics__c(VCC_Call_Back_Number__c = '0000000000'))
            .defineStub();

        VCC_E911ViewCallNumberController.memoizedE911MetricsRepo = stubE911MetricsRepo;
        VCC_e911_Metrics__c result;
        Test.startTest();
        result = VCC_E911ViewCallNumberController.getE911MetricRecord(fakeE911MetricId);
        Test.stopTest();

        Assert.areEqual(result.VCC_Call_Back_Number__c, '0000000000', 'mocked response did not return data');
    }

    /**
     * @description unit test for retrieving an e911 record when given an id negative
     */
    @IsTest
    private static void unitGetE911MetricRecordNegative() {
        Id fakeE911MetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.sObjectType);

        //mocked repo
        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(fakeE911MetricId)
            .returning(null)
            .defineStub();

        VCC_E911ViewCallNumberController.memoizedE911MetricsRepo = stubE911MetricsRepo;
        VCC_e911_Metrics__c result;
        Test.startTest();
        result = VCC_E911ViewCallNumberController.getE911MetricRecord(fakeE911MetricId);
        Test.stopTest();

        Assert.isNull(result, 'mocked repo was supposed to respond with no result');
    }
}
