/**
 * @author Booz Allen
 * @since 05/2024
 * @description Test class for VCR_RecordTypeRepo
 * @see VCR_RecordTypeRepo
 *
 *  NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_RecordTypeRepoTest {
    /**
     * @description Test constructor for success path
     */
    @IsTest
    private static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_RecordTypeRepo repo = new VCR_RecordTypeRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_RecordTypeRepo');
    }

    /**
     * @description tests retrieval of record type when developer name matches
     */
    @IsTest
    private static void unitGetRecordTypesByNamePositive() {
        String rtName = Schema.sObjectType.Case.getRecordTypeInfosByName()
            .get('Clinical Triage Case')
            .getDeveloperName();
        Test.startTest();
        VCR_RecordTypeRepo repo = new VCR_RecordTypeRepo();
        List<RecordType> result = repo.getRecordTypesByName(rtName);
        Test.stopTest();

        Assert.areEqual(result.size(), 1, 'Expected a single record to be retrieved but was not');
        //Assert.areEqual(result.[0].DeveloperName, 'Test_record_type', 'Expected a single record to be retrieved but was not');
    }

    /**
     * @description tests retrieval of record type when no matching criteria
     */
    @IsTest
    private static void unitGetRecordTypesByNameNegative() {
        Test.startTest();
        VCR_RecordTypeRepo repo = new VCR_RecordTypeRepo();
        List<RecordType> result = repo.getRecordTypesByName('Test_record_type');
        Test.stopTest();

        Assert.areEqual(result.size(), 0, 'Expected  no records');
    }
}
