/**
 * @description Test class.
 * @author Booz Allen Hamilton
 * @since 06/20/2024
 * @see `VCC_SiteId`
 */
@IsTest
private with sharing class VCC_SiteIdTest {
    private static List<String> badSiteIdList = new List<String>{
        'abc',
        null,
        '12',
        '1234',
        '123ABCDE',
        ',abc123',
        'abc123;',
        'abc123 ',
        'a bc123'
    };
    private static List<String> goodSiteIdList = new List<String>{ '983az', '984CRNR', '512', '666AZ', '516AZaz' };

    @IsTest
    static void unitFormatExceptionMessagePositive() {
        String siteId = '983';
        Test.startTest();
        String formattedExceptionMessage = VCC_SiteId.formatExceptionMessage(siteId);
        Assert.isTrue(
            formattedExceptionMessage.contains(siteId),
            'Expected exception message to contain the given siteId string.'
        );
        Assert.isTrue(
            formattedExceptionMessage.contains(VCC_SiteId.SITE_ID_REGEX),
            'Expected exception message to contain the regex pattern.'
        );
        Assert.areEqual(
            String.format(VCC_SiteId.ILLEGAL_ARGUMENT_TEMPLATE, new List<String>{ siteId, VCC_SiteId.SITE_ID_REGEX }),
            formattedExceptionMessage,
            'Expected VCC_SiteId.formatExceptionMessage to result in the formatted VCC_SiteId.ILLEGAL_ARGUMENT_TEMPLATE'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitFormatExceptionMessageNegative() {
        Test.startTest();
        String formattedExceptionMessage = VCC_SiteId.formatExceptionMessage(null);
        Assert.isTrue(
            formattedExceptionMessage.contains('null'),
            'Expected exception message to contain the given siteId string.'
        );
        Assert.isTrue(
            formattedExceptionMessage.contains(VCC_SiteId.SITE_ID_REGEX),
            'Expected exception message to contain the regex pattern.'
        );
        Assert.areEqual(
            String.format(VCC_SiteId.ILLEGAL_ARGUMENT_TEMPLATE, new List<String>{ 'null', VCC_SiteId.SITE_ID_REGEX }),
            formattedExceptionMessage,
            'Expected VCC_SiteId.formatExceptionMessage to result in the formatted VCC_SiteId.ILLEGAL_ARGUMENT_TEMPLATE'
        );
        Test.stopTest();
    }
    @IsTest
    static void unitRaiseIllegalArgumentExceptionPositive() {
        String siteId = '983 ';
        Test.startTest();
        try {
            VCC_SiteId.raiseIllegalArgumentException(siteId);
        } catch (IllegalArgumentException illegalArgumentException) {
            Assert.areEqual(
                VCC_SiteId.formatExceptionMessage(siteId),
                illegalArgumentException.getMessage(),
                'Expected exception message to be that generated by VCC_SiteId.formattedExceptionMessage'
            );
        }
        Test.stopTest();
    }
    @IsTest
    static void unitRaiseIllegalArgumentExceptionNegative() {
        String siteId = null;
        Test.startTest();
        try {
            VCC_SiteId.raiseIllegalArgumentException(siteId);
        } catch (IllegalArgumentException illegalArgumentException) {
            Assert.areEqual(
                VCC_SiteId.formatExceptionMessage(siteId),
                illegalArgumentException.getMessage(),
                'Expected exception message to be that generated by VCC_SiteId.formattedExceptionMessage'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateSiteIdPositive() {
        Test.startTest();
        for (String goodSiteId : goodSiteIdList) {
            VCC_SiteId.validateSiteId(goodSiteId);
        }
        Assert.isTrue(
            true,
            'Tautological assert. Test passes if no exceptions are thrown by VCC_SiteId.validateSiteId.'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitValidateSiteIdNegative() {
        Test.startTest();
        for (String badSiteId : badSiteIdList) {
            try {
                VCC_SiteId.validateSiteId(badSiteId);
                Assert.fail('Expected an IllegalArgumentException but did not recieve one.');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.isTrue(true, 'Tautological assert. Test passes because the exception is thrown.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void unitToStringPositive() {
        String siteId = '983';
        Test.startTest();
        Assert.areEqual(
            siteId,
            new VCC_SiteId(siteId).toString(),
            'Expected original same siteId string to result from VCC_SiteId.toString'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        Assert.isNotNull(new VCC_SiteId('983'), 'Expected constructor to produce an instance of VCC_SiteId');
        Test.stopTest();
    }

    @IsTest
    static void unitConstructorNegative() {
        Test.startTest();
        try {
            new VCC_SiteId(null);
            Assert.fail('Expected an IllegalArgumentException');
        } catch (IllegalArgumentException illegalArgumentException) {
            ASsert.isTrue(true, 'Tautological assert. Exception caught, so test passes.');
        }
        Test.stopTest();
    }
}
