@isTest
public with sharing class VCC_DASCreateAddendumRSTest {
    @IsTest
    static void constructTest() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_DASCreateAddendumRS(), 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
