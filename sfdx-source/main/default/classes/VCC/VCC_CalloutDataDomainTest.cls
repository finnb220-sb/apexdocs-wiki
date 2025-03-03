@IsTest
public with sharing class VCC_CalloutDataDomainTest {
    private static String username = 'coddomain';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void convertHttpDataToCalloutDataTestHappy() {
        VCC_HttpIntercept_Observer.HttpData httpData = new VCC_HttpIntercept_Observer.HttpData();
        httpData.requestEndpoint = VCC_EndpointUtility.getEndpoint('Vdif', 'vccVDIFGetAdditionalSigners');
        httpData.requestMethod = 'GET';
        httpData.requestIsCompressed = false;
        httpData.requestBody = 'test';
        httpData.responseStatusCode = 200;
        httpData.responseStatus = 'idk';
        httpData.responseBody = 'some text';
        httpData.timeSent = 23;
        httpData.timeReceived = 34;

        String path = [SELECT Id, DeveloperName, Path__c FROM vccEndpoint__mdt WHERE DeveloperName = 'vccVDIFGetAdditionalSigners'].Path__c;

        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Callout_Data__c calloutData = new VCC_CalloutDataDomain().convertHttpDataToCalloutData(httpData);

            System.assert(calloutData.VCC_Endpoint__c.contains(path), 'Expected path in endpoint.');
            System.assert(calloutData.VCC_Request_Time__c == httpData.timeSent, 'Expected values to match.');
            System.assert(calloutData.VCC_Request_Body__c == httpData.requestBody, 'Expected values to match.');
            System.assert(calloutData.VCC_Response_Time__c == httpData.timeReceived, 'Expected values to match.');
            System.assert(calloutData.VCC_Response_Body__c == httpData.responseBody, 'Expected null.');
            System.assert(calloutData.VCC_Status_Code__c == httpData.responseStatusCode, 'Expected values to match.');
        }
        Test.stopTest();
    }

    @IsTest
    static void convertHttpDataToCalloutDataTestNulls() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_HttpIntercept_Observer.HttpData httpData = new VCC_HttpIntercept_Observer.HttpData();
            httpData.requestEndpoint = null;
            httpData.requestMethod = null;
            httpData.requestIsCompressed = null;
            httpData.requestBody = null;
            httpData.responseStatusCode = null;
            httpData.responseStatus = null;
            httpData.responseBody = null;
            httpData.timeSent = null;
            httpData.timeReceived = null;

            VCC_Callout_Data__c calloutData = new VCC_CalloutDataDomain().convertHttpDataToCalloutData(httpData);

            System.assert(calloutData.VCC_Endpoint__c == null, 'Expected null.');
            System.assert(calloutData.VCC_Request_Time__c == null, 'Expected null.');
            System.assert(calloutData.VCC_Request_Body__c == null, 'Expected null.');
            System.assert(calloutData.VCC_Response_Time__c == null, 'Expected null.');
            System.assert(calloutData.VCC_Response_Body__c == null, 'Expected null.');
            System.assert(calloutData.VCC_Status_Code__c == null, 'Expected null.');
        }
        Test.stopTest();
    }

    @IsTest
    static void convertHttpDataToCalloutDataTestSad() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Callout_Data__c calloutData = new VCC_CalloutDataDomain().convertHttpDataToCalloutData(null);
        }
        Test.stopTest();
    }
}
