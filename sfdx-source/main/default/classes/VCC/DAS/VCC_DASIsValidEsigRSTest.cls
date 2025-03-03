@isTest
public with sharing class VCC_DASIsValidEsigRSTest {
    @IsTest
    static void constructorTest() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_DASIsValidEsigRS(), 'Expected non-null');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
