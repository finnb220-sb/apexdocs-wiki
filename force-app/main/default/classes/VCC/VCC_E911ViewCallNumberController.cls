/**
 * @description e911 View Call Number controller for acquiring the active e911 metric data as well as the temporary e911 number
 * @author      Booz Allen
 * @since       04/2024
 */
public with sharing class VCC_E911ViewCallNumberController {
    @TestVisible
    private static VCR_E911MetricsRepo memoizedE911MetricsRepo;

    @TestVisible
    private static VCR_E911MetricsRepo e911MetricsRepo {
        get {
            if (memoizedE911MetricsRepo == null) {
                memoizedE911MetricsRepo = new VCR_E911MetricsRepo();
            }
            return memoizedE911MetricsRepo;
        }
    }

    /**
     * @description Retrieved the e911 metric record as well as the temporary e911 number and updates the metric record
     * @param recordId - record id for the e911 metric
     * @return VCC_E911IntradoService.E911Response - response information from Intrado call
     */
    @InvocableMethod(
        label='Set e911 Transfer Number'
        description='Callout to Intrado to get e911 transfer number and set it on the respective record'
    )
    public static List<VCC_E911IntradoService.E911Response> getTransferNumberCallout(List<String> recordId) {
        VCC_E911IntradoService.E911Response responseObj;
        VCC_e911_Metrics__c e911Metric = (VCC_e911_Metrics__c) e911MetricsRepo.fetchById(recordId.get(0));
        String requestBody = VCC_E911IntradoService.buildReqBodyFromMetric(e911Metric);
        String serializedResponse = VCC_E911IntradoService.handleCallout(requestBody, 'vccGetTransferNumber');
        if (serializedResponse != null) {
            responseObj = (VCC_E911IntradoService.E911Response) JSON.deserialize(
                serializedResponse,
                VCC_E911IntradoService.E911Response.class
            );
            if (responseObj.success != null && responseObj.success == 'true') {
                e911Metric.VCC_Temporary_e911_Number__c = responseObj.response.transferNumber;
                e911MetricsRepo.doUpdate(e911Metric);
            }
        }
        return new List<VCC_E911IntradoService.E911Response>{ responseObj };
    }

    /**
     * @description  retrieves the e911 metric record according to the record id passed in
     * @param recordId - record id of the e911 metric
     * @return         `VCC_e911_Metrics__c` - e911 metric record with data
     */
    @AuraEnabled(cacheable=true)
    public static VCC_e911_Metrics__c getE911MetricRecord(String recordId) {
        return (VCC_e911_Metrics__c) e911MetricsRepo.fetchById(recordId);
    }
}
