/**
 * @description Test class for VCC_DASConsolidatedEndpointBaseRQ
 * @author      BAH
 * @since       April 17, 2024
 * @see         VCC_DASConsolidatedEndpointBaseRQ
 * @see         VCC_DASBaseRQ
 */
@SuppressWarnings('PMD.ClassNamingConventions, PMD.DescriptionMustHaveText, PMD.ApexDoc')
@IsTest
private class VCC_DASConsolidatedEndpointBaseRQTest {
    /**
     * @description Concrete class to test abstact class VCC_DASConsolidatedEndpointBaseRQ
     */
    private class TestConsolidatedEndpointRQ extends VCC_DASConsolidatedEndpointBaseRQ {
        public String testProperty {
            get {
                return propertyGetter(testProperty);
            }
            set;
        }
    }

    // class can be created, with out exception
    @IsTest
    private static void unitConstructorPositive() {
        Test.startTest();
        try {
            TestConsolidatedEndpointRQ baseRQ = new TestConsolidatedEndpointRQ();
            Assert.isNotNull(baseRQ, 'unitConstructorPositive test failed. Expected non-null value for constructor.');
            Assert.isNotNull(
                baseRQ.supplementalParameters,
                'unitConstructorPositive test failed. Expected non-null value for supplemental parameters.'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitConstructorNegative() {
        Test.startTest();
        TestConsolidatedEndpointRQ baseRQ;
        Test.stopTest();
        Assert.isNull(baseRQ, 'unitConstructorNegative test failed. Expected null for constructor.');
    }

    @IsTest
    // properties can be read and that they are empty strings (or an empty list in the case of the one property)
    private static void unitPropertyGetNullsNegative() {
        Test.startTest();
        try {
            TestConsolidatedEndpointRQ baseRQ = new TestConsolidatedEndpointRQ();
            Assert.isTrue(String.isBlank(baseRQ.esig), 'Expected esig to be a non-null value');
            Assert.isTrue(String.isBlank(baseRQ.providerName), 'Expected providerName to be a non-null value');
            Assert.isTrue(String.isBlank(baseRQ.providerUserId), 'Expected providerUserId to be a non-null value');
            Assert.isTrue(
                String.isBlank(baseRQ.providerLoginSiteCode),
                'Expected providerLoginSiteCode to be a non-null value'
            );
            Assert.isTrue(
                baseRQ.supplementalParameters.isEmpty(),
                'Expected supplementalParameters to be a non-null value'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    // values can be set and retrieved
    private static void unitLoadedPropertiesPositive() {
        Test.startTest();
        try {
            String testEsig = 'test esig';
            String testProviderName = 'test provider name';
            String testProviderUserId = 'test provider user id';
            String testProviderLoginSiteCode = 'test provider login site code';
            List<String> testSupplementalParameters = new List<String>{ 'test supplemental parameter' };
            TestConsolidatedEndpointRQ baseRQ = new TestConsolidatedEndpointRQ();
            baseRQ.esig = testEsig;
            baseRQ.providerName = testProviderName;
            baseRQ.providerLoginSiteCode = testProviderLoginSiteCode;
            baseRQ.providerUserId = testProviderUserId;
            baseRQ.supplementalParameters = testSupplementalParameters;
            Assert.areEqual(testEsig, baseRQ.esig, 'Expected to find test value on property.');
            Assert.areEqual(testProviderName, baseRQ.providerName, 'Expected to find test value on property.');
            Assert.areEqual(
                testProviderLoginSiteCode,
                baseRQ.providerLoginSiteCode,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testSupplementalParameters,
                baseRQ.supplementalParameters,
                'Expected to find test value on property.'
            );
            Assert.areEqual(testProviderUserId, baseRQ.providerUserId, 'Expected to find test value on property.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, but instead found: ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitIsValidPositive() {
        Test.startTest();
        TestConsolidatedEndpointRQ baseRQ = new TestConsolidatedEndpointRQ();
        baseRQ.esig = 'test';
        baseRQ.providerLoginSiteCode = 'test';
        baseRQ.providerUserId = '13425';
        List<String> params = new List<String>();
        params.add('232443');
        params.add('436455');
        baseRQ.supplementalParameters = params;
        Assert.isTrue(baseRQ.isValid(), 'Expected return value to be true.');
        Assert.areEqual('test', baseRQ.esig, 'Expected esig to be test.');
        Assert.areEqual('test', baseRQ.providerLoginSiteCode, 'Expected providerLoginSiteCode to be test.');
        Assert.areEqual('13425', baseRQ.providerUserId, 'Expected providerUserId to be test.');
        Assert.areEqual(params, baseRQ.supplementalParameters, 'Expected supplemental parameters to match.');
        Test.stopTest();
    }

    @IsTest
    private static void unitIsValidNegative() {
        Test.startTest();
        TestConsolidatedEndpointRQ baseRQ = new TestConsolidatedEndpointRQ();
        Assert.isFalse(baseRQ.isValid(), 'Expected return value to be false.');
        Test.stopTest();
    }
}
