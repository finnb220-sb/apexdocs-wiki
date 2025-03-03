@isTest
public with sharing class VCC_DASGetAdditionalSignersRSTest {
    @isTest
    public static void ctor() {
        Test.startTest();
        try {
            VCC_DASGetAdditionalSignersRS getAdditionalSignersRS = new VCC_DASGetAdditionalSignersRS();
            Assert.isNotNull(getAdditionalSignersRS, 'Expected non-null value.');
            Assert.isNotNull(getAdditionalSignersRS.taggedTextArray, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
