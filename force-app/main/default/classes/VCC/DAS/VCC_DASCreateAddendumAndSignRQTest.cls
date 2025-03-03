/**
 * @description Test class for VCC_DASCreateAddendeumAndSignRQ
 * @author      BAH
 * @since       April 15 2024
 * @see         VCC_DASCreateAddendeumAndSignRQ
 * @see         VCC_DASBaseRQ
 */
@IsTest
private class VCC_DASCreateAddendumAndSignRQTest {
    @IsTest
    private static void unitConstructorPositive() {
        Test.startTest();
        try {
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
            Assert.isNotNull(
                createAddendumAndSignRQ,
                'unitConstructorPositive test failed. Expected non-null value for constructor.'
            );
            Assert.isNotNull(
                createAddendumAndSignRQ.supplementalParameters,
                'unitConstructorPositive test failed. Expected non-null value for constructor.'
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
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignEmptyRQ;
        Test.stopTest();
        Assert.isNull(
            createAddendumAndSignEmptyRQ,
            'unitConstructorNegative test failed. Expected constructor to be null.'
        );
    }

    @IsTest
    // properties can be read and that they are empty strings (or an empty list in the case of the one property)
    private static void unitPropertyGetNullsNegative() {
        Test.startTest();
        try {
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
            Assert.isTrue(String.isBlank(createAddendumAndSignRQ.esig), 'Expected esig to be a non-null value');
            Assert.isTrue(
                String.isBlank(createAddendumAndSignRQ.providerName),
                'Expected providerName to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(createAddendumAndSignRQ.providerUserId),
                'Expected providerUserId to be a non-null value'
            );
            Assert.isTrue(
                String.isBlank(createAddendumAndSignRQ.providerLoginSiteCode),
                'Expected providerLoginSiteCode to be a non-null value'
            );
            Assert.isTrue(
                createAddendumAndSignRQ.supplementalParameters.isEmpty(),
                'Expected supplementalParameters to be a non-null value'
            );

            Assert.isTrue(String.isBlank(createAddendumAndSignRQ.itemId), 'Expected itemId to be a non-null value');
            Assert.isTrue(String.isBlank(createAddendumAndSignRQ.type), 'Expected type to be a non-null value');
            Assert.isTrue(String.isBlank(createAddendumAndSignRQ.criteria), 'Expected criteria to be a non-null value');
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
            String testItemId = 'test';
            String testType = 'test';
            String testCriteria = 'test';
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
            createAddendumAndSignRQ.esig = testEsig;
            createAddendumAndSignRQ.providerName = testProviderName;
            createAddendumAndSignRQ.providerLoginSiteCode = testProviderLoginSiteCode;
            createAddendumAndSignRQ.providerUserId = testProviderUserId;
            createAddendumAndSignRQ.supplementalParameters = testSupplementalParameters;
            createAddendumAndSignRQ.itemId = testItemId;
            createAddendumAndSignRQ.criteria = testCriteria;
            createAddendumAndSignRQ.type = testType;

            Assert.areEqual(testItemId, createAddendumAndSignRQ.itemId, 'Expected to find test value on property.');
            Assert.areEqual(testCriteria, createAddendumAndSignRQ.criteria, 'Expected to find test value on property.');
            Assert.areEqual(testType, createAddendumAndSignRQ.type, 'Expected to find test value on property.');
            Assert.areEqual(testEsig, createAddendumAndSignRQ.esig, 'Expected to find test value on property.');
            Assert.areEqual(
                testProviderName,
                createAddendumAndSignRQ.providerName,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testProviderLoginSiteCode,
                createAddendumAndSignRQ.providerLoginSiteCode,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testSupplementalParameters,
                createAddendumAndSignRQ.supplementalParameters,
                'Expected to find test value on property.'
            );
            Assert.areEqual(
                testProviderUserId,
                createAddendumAndSignRQ.providerUserId,
                'Expected to find test value on property.'
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
    private static void unitIsValidPositive() {
        Test.startTest();
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
        createAddendumAndSignRQ.itemId = 'test';
        createAddendumAndSignRQ.type = 'test';
        createAddendumAndSignRQ.criteria = 'test note';
        createAddendumAndSignRQ.providerLoginSiteCode = '983';
        createAddendumAndSignRQ.providerUserId = '4324589h97hk5';
        createAddendumAndSignRQ.supplementalParameters = new List<String>();
        createAddendumAndSignRQ.esig = 'TESTER';

        Test.stopTest();
        Assert.areEqual(true, createAddendumAndSignRQ.isValid(), 'unitIsValidPositive test failed. Expected true.');
        Assert.areEqual('test', createAddendumAndSignRQ.itemId, 'Expected itemId to be test.');
        Assert.areEqual('test', createAddendumAndSignRQ.type, 'Expected type to be test.');
        Assert.areEqual('test note', createAddendumAndSignRQ.criteria, 'Expected criteria to be test note.');
        Assert.areEqual(
            '983',
            createAddendumAndSignRQ.providerLoginSiteCode,
            'Expected provider login site code to be 983.'
        );
        Assert.areEqual(
            '4324589h97hk5',
            createAddendumAndSignRQ.providerUserId,
            'Expected provider user id to be 4324589h97hk5.'
        );
        Assert.areEqual('TESTER', createAddendumAndSignRQ.esig, 'Expected esig to be TESTER.');
        Assert.areEqual(
            new List<String>(),
            createAddendumAndSignRQ.supplementalParameters,
            'Expected supplemental parameters list to match.'
        );
    }

    @IsTest
    private static void unitIsValidNegative() {
        Test.startTest();
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRQ = new VCC_DASCreateAddendumAndSignRQ();
        Test.stopTest();
        Assert.areEqual(false, createAddendumAndSignRQ.isValid(), 'unitIsValidNegative test failed. Expected false.');
    }
}
