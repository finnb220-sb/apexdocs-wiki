@IsTest
/**
 * @description codescan
 */
public with sharing class VCC_VetRetrieveResponseMockGeneratorTest {
    @IsTest
    static void respondTest() {
        Test.startTest();
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            Assert.isNotNull(new VCC_VetRetrieveResponseMockGenerator().respond(req));
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
