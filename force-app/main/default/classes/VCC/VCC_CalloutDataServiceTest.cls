@IsTest
public with sharing class VCC_CalloutDataServiceTest {
    private static String username = 'calloutdata';

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
    static void stubTest() {
        Test.startTest();
        VCC_Stub stub = VCC_CalloutDataService.stub();
        System.assert(VCC_CalloutDataService.instance === stub.instance, 'Expected privateInstance to be stub.');
        Test.stopTest();
    }

    @IsTest
    static void insertNewCalloutDataHappy() {
        VCC_Stub calloutDataDomainStub = new VCC_Stub(VCC_CalloutDataDomain.class);
        VCC_CalloutDataDomain calloutDataDomain = (VCC_CalloutDataDomain) calloutDataDomainStub.instance;
        calloutDataDomainStub.setReturnValue('convertHttpDataToCalloutData', new VCC_Callout_Data__c(VCC_Endpoint__c = 'test'));

        Exception unexpectedException;

        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_Callout_Data__c calloutData;

            try {
                calloutData = VCC_CalloutDataService.instance.insertNewCalloutData(null, calloutDataDomain);
            } catch (Exception e) {
                unexpectedException = e;
            }

            System.assert(calloutData != null, 'Unexpected null.');
            System.assert(unexpectedException == null, 'Unexpected exception.');
        }
        Test.stopTest();
    }
}
