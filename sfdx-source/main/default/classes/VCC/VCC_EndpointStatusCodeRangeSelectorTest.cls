@IsTest
public with sharing class VCC_EndpointStatusCodeRangeSelectorTest {
    @IsTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        Test.stopTest();

        System.assert(escrs != null, 'Did not instantiate as expected.');
    }

    @IsTest
    public static void addSObjectFieldsTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();

        System.assert(!escrs.getSObjectFieldList().contains(CodeSet.IsActive), 'Selector already contains the field to test.');

        Test.startTest();
        escrs.addSObjectFields(new List<SObjectField>{ CodeSet.IsActive });
        Test.stopTest();

        System.assert(escrs.getSObjectFieldList().contains(CodeSet.IsActive), 'Selector did not add SObject field correctly.');
    }

    @IsTest
    public static void selectByIdsTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        VCC_Endpoint_Status_Code_Range__mdt escc = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Range__mdt
            LIMIT 1
        ];
        Test.startTest();
        List<VCC_Endpoint_Status_Code_Range__mdt> esccList = escrs.selectById(new Set<Id>{ escc.Id });
        Test.stopTest();

        System.assert(esccList.size() == 1, 'Expected one record returned.');
    }

    @IsTest
    public static void selectByCodeAndEndpointTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        Integer statusCode = 400;
        String endpointName = 'vccVdifIsValidEsig';
        List<VCC_Endpoint_Status_Code_Range__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Range__mdt
            WHERE
                VCC_Endpoint__c = :endpointName
                AND VCC_App_Name__c = NULL
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode
        ];
        List<VCC_Endpoint_Status_Code_Range__mdt> esccList = escrs.selectByCodeAndEndpoint(statusCode, endpointName);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectByCodeAndAppTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        Integer statusCode = 400;
        String appName = 'Vdif';
        List<VCC_Endpoint_Status_Code_Range__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Range__mdt
            WHERE
                VCC_Endpoint__c = NULL
                AND VCC_App_Name__c = :appName
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode
        ];
        List<VCC_Endpoint_Status_Code_Range__mdt> esccList = escrs.selectByCodeAndApp(statusCode, appName);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectGlobalByCodeTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        Integer statusCode = 400;
        List<VCC_Endpoint_Status_Code_Range__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Range__mdt
            WHERE
                VCC_Endpoint__c = NULL
                AND VCC_App_Name__c = NULL
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Lower_Bound__c <= :statusCode
                AND VCC_Status_Code_Range__r.VCC_Status_Code_Upper_Bound__c >= :statusCode
        ];
        List<VCC_Endpoint_Status_Code_Range__mdt> esccList = escrs.selectGlobalByCode(statusCode);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectEndpointNameTest() {
        VCC_EndpointStatusCodeRangeSelector escrs = new VCC_EndpointStatusCodeRangeSelector();
        String endpointName = 'vccVdifIsValidEsig';
        List<VCC_Endpoint_Status_Code_Range__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Range__mdt
            WHERE VCC_Endpoint__c = :endpointName
        ];
        List<VCC_Endpoint_Status_Code_Range__mdt> esccList = escrs.selectByEndpointName(endpointName);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }
}
