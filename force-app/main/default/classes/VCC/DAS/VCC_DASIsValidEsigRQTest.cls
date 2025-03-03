@isTest
public with sharing class VCC_DASIsValidEsigRQTest {
    @isTest
    public static void constructorTest() {
        try {
            Assert.isNotNull(new VCC_DASIsValidEsigRQ(), 'Expected non-null value');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
    }

    @isTest
    public static void isValidTest() {
        VCC_DASIsValidEsigRQ isValidEsigRq = new VCC_DASIsValidEsigRQ();

        Assert.areEqual(false, isValidEsigRq.isValid(), 'Expected false.');

        isValidEsigRq.providerLoginSiteCode = 'test';
        isValidEsigRq.providerName = 'test';
        isValidEsigRq.providerUserId = 'test';
        isValidEsigRq.criteria = 'test';

        Assert.areEqual(true, isValidEsigRq.isValid(), 'Expected true.');
    }
}
