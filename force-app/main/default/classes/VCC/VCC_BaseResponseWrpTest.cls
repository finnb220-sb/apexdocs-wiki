/**
 * @description VCC Base Response Wrapper Test
 */

@IsTest
private with sharing class VCC_BaseResponseWrpTest {
    @IsTest
    private static void properties() {
        VCC_BaseResponseWrp baseResponseWrp = new VCC_BaseResponseWrp();
        System.assertEquals(0, baseResponseWrp.statusCode, 'Expected property to be initialized.');
        System.assertEquals(null, baseResponseWrp.errorMsg, 'Expected property to be initialized.');
        System.assertEquals(false, baseResponseWrp.status, 'Expected property to be initialized.');
        System.assertEquals(null, baseResponseWrp.responseBody, 'Expected property to be initialized.');
        System.assertEquals(false, baseResponseWrp.isMaxRecordsError, 'Expected property to be initialized.');
    }
}
