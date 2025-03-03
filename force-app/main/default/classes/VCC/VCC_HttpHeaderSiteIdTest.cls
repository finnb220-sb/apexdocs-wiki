@IsTest
private with sharing class VCC_HttpHeaderSiteIdTest {
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        Assert.isInstanceOfType(
            new VCC_HttpHeaderSiteId(new VCC_SiteId('983')),
            VCC_HttpHeaderSiteId.class,
            'Expected constructor to produce an instance of VCC_HttpHeaderSiteId.class'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitConstructorNegative() {
        Test.startTest();
        try {
            new VCC_HttpHeaderSiteId(null);
            Assert.fail('Expected an IllegalArgumentException produced by VCC_SiteId');
        } catch (IllegalArgumentException illegalArgumentException) {
            Assert.isTrue(true, 'Tautological assert. Test passes because an exception was caught.');
        }
        Test.stopTest();
    }
}
