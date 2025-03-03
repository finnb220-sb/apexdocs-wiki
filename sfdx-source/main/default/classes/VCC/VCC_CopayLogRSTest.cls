@isTest
private class VCC_CopayLogRSTest {
    @isTest
    static void UnitTestParsePositive() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCCopayLogMock' })[0].Body.toString();
        VCC_CopayLogRS response = VCC_CopayLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        System.assert(response.message.contains('COPAY log found'), 'Expected log success message');
        // Check the values of the first activity log.

        VCC_CopayLogRS.CopayLog log = response.log[0];
        System.assert(log != null, 'expected label log to be instantiated');
    }

    static void UnitTestParseNegative() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCCopayLogMock' })[0].Body.toString();
        VCC_CopayLogRS response = VCC_CopayLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        VCC_CopayLogRS.CopayLog log = response.log[0];
        System.assert(log != null, 'expected label log to be instantiated');
    }
}
