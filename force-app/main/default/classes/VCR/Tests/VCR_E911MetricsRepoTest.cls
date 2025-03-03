/**
 * @description Tests the VCR_E911MetricsRepo class
 * @author Booz Allen
 *
 * @see VCR_E911MetricsRepo for class being tested
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@isTest
public class VCR_E911MetricsRepoTest {
    /**
     * @description Test to ensure init of repo is not null
     */
    @IsTest
    private static void funcInitTestPositive() {
        Test.startTest();
        VCR_E911MetricsRepo metricRepo = new VCR_E911MetricsRepo();
        Test.stopTest();

        Assert.isTrue(metricRepo != null, 'Expected repo to be initialized but was not.');
    }

    /**
     * @description Test fetching E911 Metric Record with correspondiong contact id for success path
     */
    @IsTest
    private static void unitTestGetE911MetricsByContactIdPositive() {
        Id contactId = ((Contact) VATEST_SObjectFactory.createSObject(new Contact(), true)).Id;
        VATEST_SObjectFactory.createSObject(new VCC_e911_Metrics__C(VCC_Patient_Account__c = contactId), true);
        Test.startTest();
        VCR_E911MetricsRepo metricsRepo = new VCR_E911MetricsRepo();
        List<VCC_e911_Metrics__c> results = metricsRepo.getE911MetricsByContactId(contactId);
        Test.stopTest();

        Assert.areEqual(
            results.size(),
            1,
            'Expected single record to be returned but ' + results.size() + ' were returned'
        );
    }

    /**
     * @description Test fetching E911 Metric Record when non exist that meet the criteria
     */
    @IsTest
    private static void unitTestGetE911MetricsByContactIdNegative() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.sObjectType);
        Test.startTest();
        VCR_E911MetricsRepo metricsRepo = new VCR_E911MetricsRepo();
        List<VCC_e911_Metrics__c> results = metricsRepo.getE911MetricsByContactId(fakeContactId);
        Test.stopTest();

        Assert.areEqual(
            results.size(),
            0,
            'Expected no records to be returned but ' + results.size() + ' were returned'
        );
    }
}
