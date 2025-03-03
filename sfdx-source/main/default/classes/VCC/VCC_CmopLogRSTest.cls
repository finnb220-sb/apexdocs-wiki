@isTest
private class VCC_CmopLogRSTest {
    @isTest
    static void testParse() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCCMOPLogMock' })[0].Body.toString();
        VCC_CmopLogRS response = VCC_CmopLogRS.parse(responseBody, new VCC_PharmacyLogRQ('982', '001118'));
        // Check that the response object was created correctly.

        Assert.isTrue(response.message.contains('CMOP log found'), 'Expected log success message');
        // Check the values of the first activity log.

        VCC_CmopLogRS.CmopLog log = response.log[0];
        Assert.isNotNull(log, 'expected label log to be instantiated');
    }
}
