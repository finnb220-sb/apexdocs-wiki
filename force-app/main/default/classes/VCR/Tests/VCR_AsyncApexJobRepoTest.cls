/**
 * @description         : Class used to test the VCR_AsyncApexJob
 * @author              : Booz Allen
 * @see VCR_AsyncApexJobRepo class which is being tested
 **/
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private with sharing class VCR_AsyncApexJobRepoTest {
    /**
     * @description Initialize the repo class and verify that it is not null.
     * Positive test case.
     */
    @IsTest
    static void funcTestVCRSAsyncApexJobRepository() {
        Test.startTest();
        VCR_AsyncApexJobRepo repo = new VCR_AsyncApexJobRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_AsyncApexJobRepo');
    }

    /**
     * @description Test the getAsyncApexJobById method.
     * Positive test case.
     * This test case will create a new batch job and then retrieve it using the getAsyncApexJobById method
     * The job ID retrieved should match the created job ID
     */
    @IsTest
    static void funcTestGetAsyncApexJobByIdPositiveTest() {
        Test.startTest();
        Id jobId = Database.executeBatch(new VCC_AppointmentSlotUtilBatch());
        VCR_AsyncApexJobRepo obj = new VCR_AsyncApexJobRepo();
        AsyncApexJob result = obj.getAsyncApexJobById(jobId);
        Test.stopTest();
        Assert.areEqual(jobId, result.Id, 'Job ID retrieved from getAsyncApexJobId should match the created Job ID');
    }
}
