@IsTest
private class VCC_ErxLogRSTest {
    @IsTest
    static void testParse() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCErxLogMock' })[0].Body.toString();
        VCC_ErxLogRS response = VCC_ErxLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        System.assert(response.message.contains('ERX log found'), 'Expected label log success message');
        // Check the values of the first activity log.

        VCC_ErxLogRS.ErxLog log = response.log[0];
        System.assert(log != null, 'expected label log to be instantiated');
    }
}
