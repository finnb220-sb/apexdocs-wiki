@isTest
private with sharing class VCC_MPISearchResponseTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    private static void testInstantiation() {
        System.runAs(getTestUser()) {
            Test.startTest();
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MPISearchResponse' LIMIT 1];
            String body = sr.Body.toString();
            VCC_MPISearchResponse parseResponse = (VCC_MPISearchResponse) JSON.deserialize(body, VCC_MPISearchResponse.class);
            System.assert(parseResponse != null, 'Expected response to not be null');
            Test.stopTest();
        }
    }
}
