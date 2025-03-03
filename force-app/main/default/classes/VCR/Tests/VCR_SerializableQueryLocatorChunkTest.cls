/**
 * @description Unit tests for VCR_SerializableQueryLocatorChunk
 *
 * @author Booz Allen Hamilton
 * @see  VCR_SerializableQueryLocatorChunk
 *
 * Suppressing warnings about System.runAs since this class is a framework/utility class and therefore
 * is independent of Personas/Business Contexts
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private class VCR_SerializableQueryLocatorChunkTest {
    private static VCR_SerializableQueryLocatorChunk systemUnderTest;

    /**
     * @description Test that we are able to successfully create an instance of SerializableChunk instance
     */
    @IsTest
    static void unitItConstructsPositive() {
        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        Test.stopTest();
        Assert.isNotNull(
            systemUnderTest,
            'Expected a valid instance of `VCR_SerializableQueryLocatorChunk` to be created when handed a valid SObjectType'
        );
    }

    /**
     * @description Test that we are able to successfully initialize our instance of SerializableChunk instance
     */
    @IsTest
    static void unitInitPositive() {
        String recordTypeName = 'PersonAccount';
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => recordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        systemUnderTest.init(queryString, bindVars);
        Test.stopTest();
        Assert.areEqual(
            'SELECT Id, Name'.trim(),
            systemUnderTest.selectClause.trim(),
            'Expected selectClause in our created instance to match SELECT clause from queryString provided.'
        );
        Assert.areEqual(
            'WHERE RecordType.DeveloperName=:recordTypeName'.trim(),
            systemUnderTest.whereClause.trim(),
            'Expected whereClause in our created instance to match WHERE clause from queryString provided without LIMIT & OFFSET keywords.'
        );
    }

    /**
     * @description Test that we handle a null query string successfully - in this case, throw an exception
     *
     */
    @IsTest
    static void unitInitNullQueryStringNegative() {
        String recordTypeName = 'PersonAccount';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => recordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        try {
            systemUnderTest.init(null, bindVars);
            Assert.isFalse(true, 'Expected an IllegalArgumentException to be thrown for null queryString.');
        } catch (IllegalArgumentException illegalArgExc) {
            Assert.isTrue(
                illegalArgExc.getMessage()
                    .containsIgnoreCase('A non-null & non-empty queryString and a non-null bindVars'),
                'Expected IllegalArgumentException to be thrown with our error message regarding null/empty parameters when queryString is null.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we handle an empty query string successfully - in this case, throw an exception
     *
     */
    @IsTest
    static void unitInitEmptyQueryStringNegative() {
        String recordTypeName = 'PersonAccount';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => recordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        try {
            systemUnderTest.init('', bindVars);
            Assert.isFalse(true, 'Expected an IllegalArgumentException to be thrown for null queryString.');
        } catch (IllegalArgumentException illegalArgExc) {
            Assert.isTrue(
                illegalArgExc.getMessage()
                    .containsIgnoreCase('A non-null & non-empty queryString and a non-null bindVars'),
                'Expected IllegalArgumentException to be thrown with our error message regarding null/empty parameters when queryString is empty.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we handle null bindVars successfully - in this case, throw an exception
     *
     */
    @IsTest
    static void unitInitNullBindVarsNegative() {
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        try {
            systemUnderTest.init(queryString, null);
            Assert.isFalse(true, 'Expected an IllegalArgumentException to be thrown for null queryString.');
        } catch (IllegalArgumentException illegalArgExc) {
            Assert.isTrue(
                illegalArgExc.getMessage()
                    .containsIgnoreCase('A non-null & non-empty queryString and a non-null bindVars'),
                'Expected IllegalArgumentException to be thrown with our error message regarding null/empty parameters when bindVars is null.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test that we handle getting number of records in result set successfully
     *
     */
    @IsTest
    static void unitGetTotalNumRecordsPositive() {
        String veteranRecordTypeName = 'Veteran';
        Id veteranRecTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get(veteranRecordTypeName)
            .getRecordTypeId();
        Id personAccountRecTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();

        List<Account> veteranAccounts = (List<Account>) VATEST_SObjectFactory.createSObjects(
            new Account(RecordTypeId = veteranRecTypeId),
            50,
            true
        );
        VATEST_SObjectFactory.createSObjects(new Account(RecordTypeId = personAccountRecTypeId), 10, true);
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => veteranRecordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        systemUnderTest.init(queryString, bindVars);
        Integer totalNumRecords = systemUnderTest.getNumRecords();
        Test.stopTest();
        Assert.areEqual(
            veteranAccounts.size(),
            totalNumRecords,
            'Expected the number of matching records returned to equals the # of test records created.'
        );
    }

    /**
     * @description Test that we handle getting number of records when there are no matching records
     *
     */
    @IsTest
    static void unitGetTotalNumRecordsNegative() {
        String unknownRecordTypeName = 'Unknown';
        VATEST_SObjectFactory.createSObjects(new Account(), 50, true);
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => unknownRecordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        systemUnderTest.init(queryString, bindVars);
        Integer totalNumRecords = systemUnderTest.getNumRecords();
        Test.stopTest();
        Assert.areEqual(
            0,
            totalNumRecords,
            'Expected getNumRecords to return 0, not null, when there are no matching records for our configuration.'
        );
    }

    /**
     * @description Test that we handle getting records when there are no matching records
     *
     */
    @IsTest
    static void unitGetRecordsNegative() {
        String unknownRecordTypeName = 'Unknown';
        VATEST_SObjectFactory.createSObjects(new Account(), 50, true);
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => unknownRecordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        systemUnderTest.init(queryString, bindVars);
        List<Account> matchingRecords = (List<Account>) systemUnderTest.getRecords(0, 100);
        Test.stopTest();
        Assert.areEqual(
            0,
            matchingRecords.size(),
            'Expected getNumRecords to return an empty list, not null, when there are no matching records for our configuration.'
        );
    }

    /**
     * @description Test that we handle getting records when there are at least 1 matching record
     *
     */
    @IsTest
    static void unitGetRecordsPositive() {
        String veteranRecordTypeName = 'Veteran';
        Id veteranRecTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get(veteranRecordTypeName)
            .getRecordTypeId();
        List<Account> veteranAccounts = (List<Account>) VATEST_SObjectFactory.createSObjects(
            new Account(RecordTypeId = veteranRecTypeId),
            50,
            true
        );
        String queryString = 'SELECT Id, Name FROM Account WHERE RecordType.DeveloperName=:recordTypeName LIMIT 100';
        Map<String, Object> bindVars = new Map<String, Object>{ 'recordTypeName' => veteranRecordTypeName };

        Test.startTest();
        systemUnderTest = new VCR_SerializableQueryLocatorChunk(Account.SObjectType);
        systemUnderTest.init(queryString, bindVars);
        List<Account> matchingRecords = (List<Account>) systemUnderTest.getRecords(0, 10);
        Test.stopTest();
        Assert.areEqual(
            10,
            matchingRecords.size(),
            'Expected getNumRecords to return the requested number of records.'
        );
        Assert.areNotEqual(
            veteranAccounts.size(),
            matchingRecords.size(),
            'Expected getNumRecords to return the requested number of records, not the number in our entire result set.'
        );
    }
}
