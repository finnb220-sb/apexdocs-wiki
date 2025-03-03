/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Controller class for TestRun Admin tab
 */
public inherited sharing class TestRunAdminController {
    /**
     * Schedule Test runs
     *
     * @return - Job ids
     */
    @AuraEnabled
    public static List<Id> scheduleTestRuns() {
        return TestRunService.scheduleTestRuns();
    }

    /**
     * Initiates test run
     *
     * @return - Test_Run__c Id
     */
    @AuraEnabled
    public static Id runTests() {
        return TestRunService.createTestRun();
    }

    /**
     * Gets the current CronTrigger records for automated test runs
     *
     * @return - List<CronTrigger>
     */
    @AuraEnabled
    public static List<CronTrigger> getScheduledTestRuns() {
        return TestRunService.getScheduledTestRunJobs();
    }

    @AuraEnabled
    public static String getOrgWideCodeCoverage() {
        return CodeCoverageService.getOrgCodeCoverage();
    }
}
