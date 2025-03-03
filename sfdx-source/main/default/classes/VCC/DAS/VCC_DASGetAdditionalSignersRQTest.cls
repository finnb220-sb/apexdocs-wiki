@isTest
public with sharing class VCC_DASGetAdditionalSignersRQTest {
    @IsTest
    static void constructorTest() {
        Test.startTest();
        try {
            VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();
            Assert.isNotNull(getAdditionalSignersRq, 'Expected non-null');
            Assert.isNotNull(getAdditionalSignersRq.supplementalParameters, 'Expected non-null');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void isValidTest() {
        Test.startTest();
        try {
            VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq = new VCC_DASGetAdditionalSignersRQ();
            Assert.areEqual(false, getAdditionalSignersRq.isValid(), 'Expected false.');
            getAdditionalSignersRq.itemId = 'test';
            getAdditionalSignersRq.providerLoginSiteCode = 'test';
            getAdditionalSignersRq.supplementalParameters.add('test');
            getAdditionalSignersRq.providerUserId = 'test';
            Assert.areEqual(true, getAdditionalSignersRq.isValid(), 'Expected true.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
