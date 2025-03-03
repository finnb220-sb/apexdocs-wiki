@isTest
public class VCC_CmopLotExpLogRSTest {
    @isTest
    static void testParse() {
        String responseBody = new VCC_StaticResourceSelector().selectByName(new Set<String>{ 'VCCLotExpLogMock' })[0].Body.toString();
        VCC_CmopLotExpLogRS response = VCC_CmopLotExpLogRS.parse(responseBody);
        // Check that the response object was created correctly.

        Assert.isTrue(response.message.contains('LOT EXPIRATION log found'), 'Expected label log success message');
        // Check the values of the first activity log.

        VCC_CmopLotExpLogRS.CmopLotExpLog log = response.log[0];
        Assert.isNotNull(log, 'expected label log to be istantiated');
    }
}
