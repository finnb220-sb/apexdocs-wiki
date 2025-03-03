@IsTest
public with sharing class VCC_EndpointStatusCodeSelectorTest {
    @IsTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();
        Test.stopTest();

        System.assert(escs != null, 'Did not instantiate as expected.');
    }

    @IsTest
    public static void addSObjectFieldsTest() {
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();

        System.assert(!escs.getSObjectFieldList().contains(CodeSet.IsActive), 'Selector already contains the field to test.');

        Test.startTest();
        escs.addSObjectFields(new List<SObjectField>{ CodeSet.IsActive });
        Test.stopTest();

        System.assert(escs.getSObjectFieldList().contains(CodeSet.IsActive), 'Selector did not add SObject field correctly.');
    }

    @IsTest
    public static void selectByCodeAndEndpointTest() {
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();
        Integer statusCode = 400;
        String endpointName = 'vccVdifIsValidEsig';
        List<VCC_Endpoint_Status_Code__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code__mdt
            WHERE VCC_Endpoint__c = :endpointName AND VCC_App_Name__c = NULL AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode
        ];
        List<VCC_Endpoint_Status_Code__mdt> esccList = escs.selectByCodeAndEndpoint(statusCode, endpointName);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectByCodeAndAppTest() {
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();
        Integer statusCode = 400;
        String appName = 'Vdif';
        List<VCC_Endpoint_Status_Code__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code__mdt
            WHERE VCC_Endpoint__c = NULL AND VCC_App_Name__c = :appName AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode
        ];
        List<VCC_Endpoint_Status_Code__mdt> esccList = escs.selectByCodeAndApp(statusCode, appName);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectGlobalByCodeTest() {
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();
        Integer statusCode = 400;
        List<VCC_Endpoint_Status_Code__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code__mdt
            WHERE VCC_Endpoint__c = NULL AND VCC_App_Name__c = NULL AND VCC_Status_Code__r.VCC_Status_Code__c = :statusCode
        ];
        List<VCC_Endpoint_Status_Code__mdt> esccList = escs.selectGlobalByCode(statusCode);

        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }

    @IsTest
    public static void selectEndpointNameTest() {
        VCC_EndpointStatusCodeSelector escs = new VCC_EndpointStatusCodeSelector();
        String endpointName = 'vccVdifIsValidEsig';
        List<VCC_Endpoint_Status_Code__mdt> controlList = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code__mdt
            WHERE VCC_Endpoint__c = :endpointName
        ];
        List<VCC_Endpoint_Status_Code__mdt> esccList = escs.selectByEndpointName(endpointName);
        System.assert(controlList.size() == esccList.size(), 'Size mismatch.');
    }
}
