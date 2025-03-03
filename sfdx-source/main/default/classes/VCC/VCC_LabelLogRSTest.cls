@isTest
private class VCC_LabelLogRSTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    static void testParse() {
        System.runAs(getTestUser()) {
            String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCLabelLogMock' })[0].Body.toString();
            VCC_LabelLogRS response = VCC_LabelLogRS.parse(responseBody);
            // Check that the response object was created correctly.

            System.assert(response.message.contains('LABEL log found'), 'Expected label log success message');
            // Check the values of the first activity log.

            VCC_LabelLogRS.LabelLog labelLog1 = response.log[0];
            System.assert(labelLog1 != null, 'expected label log to be instantiated');
        }
    }
}
