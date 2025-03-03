@isTest
private class VCC_PartialsLogRSTest {
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
    static void testParse() {
        System.runAs(getTestUser()) {
            Test.startTest();
            String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCPartialLogMock' })[0].Body.toString();
            VCC_PartialsLogRS response = VCC_PartialsLogRS.parse(responseBody);
            Test.stopTest();
            // Check that the response object was created correctly.
            System.assert(response.message.contains('PARTIALS log found'), 'Expected label log success message');
            // Check the values of the first activity log.
            VCC_PartialsLogRS.PartialLog log = response.log[0];
            System.assert(log != null, 'expected label log to be instantiated');
        }
    }
}
