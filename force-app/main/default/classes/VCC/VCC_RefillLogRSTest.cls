@isTest
private class VCC_RefillLogRSTest {
    @isTest
    static void testParse() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCRefillLogMock' })[0].Body.toString();
        VCC_RefillLogRS response = VCC_RefillLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        System.assert(response.message.contains('REFILL log found'), 'Expected refill log success message');
        // Check the values of the first activity log.

        VCC_RefillLogRS.RefillLog refillLog1 = response.log[0];
        System.assertEquals('MAIL', refillLog1.routing, 'Routing expected to be "MAIL');
    }
}
