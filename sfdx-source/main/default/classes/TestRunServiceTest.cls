/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Test class for TestRunService
 */
@IsTest
private class TestRunServiceTest {
    @IsTest
    static void testClearOldRuns() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, true);
            insert tr;
            DTCTestUtil.setCreatedDate(new List<SObject>{ tr }, Date.today().addDays(-91));

            Test.startTest();
            System.assertEquals(1, [SELECT COUNT() FROM Test_Run__c]);
            TestRunService.clearOldRuns();
            Test.stopTest();

            System.assertEquals(0, [SELECT COUNT() FROM Test_Run__c]);
        }
    }

    @IsTest
    static void testOldRunsNotCleared() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, true);
            insert tr;
            DTCTestUtil.setCreatedDate(new List<SObject>{ tr }, Date.today().addDays(-89));

            Test.startTest();
            TestRunService.clearOldRuns();
            Test.stopTest();

            System.assertEquals(1, [SELECT COUNT() FROM Test_Run__c]);
        }
    }

    @IsTest
    static void testCancelTestRuns() {
        TestRunService.cancelTestRuns();
        TestRunService.cancelProcessorJob();
        TestRunService.testRunsAlreadyScheduled();
        System.assertEquals(0, TestRunService.getScheduledTestRunJobs().size());
    }
}
