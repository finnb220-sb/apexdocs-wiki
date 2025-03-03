@isTest
public with sharing class VCC_DASCreateAddendumRQTest {
    @isTest
    public static void instantiationTest() {
        Exception unexpectedException;
        VCC_DASCreateAddendumRQ createAddendumRQEmpty;

        Test.startTest();
        try {
            createAddendumRQEmpty = new VCC_DASCreateAddendumRQ();
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        Assert.isNotNull(createAddendumRQEmpty, 'Expected non-null.');
    }

    @isTest
    public static void isValidTest() {
        VCC_DASCreateAddendumRQ createAddendumRQ = new VCC_DASCreateAddendumRQ();

        Assert.areEqual(false, createAddendumRQ.isValid(), 'Expected an invalid request.');

        createAddendumRQ.itemId = 'test';
        createAddendumRQ.type = 'test';
        createAddendumRQ.criteria = 'test';
        createAddendumRQ.providerLoginSiteCode = 'test';
        createAddendumRQ.providerUserId = 'test';
        createAddendumRQ.providerName = 'test';

        Assert.areEqual(true, createAddendumRQ.isValid(), 'Expected a valid request.');
    }
}
