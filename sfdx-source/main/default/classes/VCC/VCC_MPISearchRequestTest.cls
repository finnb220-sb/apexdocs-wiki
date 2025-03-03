@isTest
private with sharing class VCC_MPISearchRequestTest {
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
        VCC_MPISearchRequest req;
        System.runAs(getTestUser()) {
            Test.startTest();
            req = new VCC_MPISearchRequest(new Map<String, Object>{ 'lastName' => 'test', 'firstName' => 'test' });
            Test.stopTest();

            System.assert(req != null, 'Object did not instantiate correctly.');
        }
    }
}
