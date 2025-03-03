@isTest
private class VCC_EcmeLogRSTest {
    @isTest
    static void testParse() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCEcmeLogMock' })[0].Body.toString();
        VCC_EcmeLogRS response = VCC_EcmeLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        System.assert(response.message.contains('ECME log found'), 'Expected log success message');
        // Check the values of the first activity log.

        VCC_EcmeLogRS.EcmeLog log = response.log[0];
        System.assert(log != null, 'expected label log to be instantiated');
    }
}
