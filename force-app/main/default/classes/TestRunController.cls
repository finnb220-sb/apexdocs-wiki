/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Controller class for Test Run or Test Run Method Result items
 */
public inherited sharing class TestRunController {
    /**
     * Gets Test_Run_Method_Result__c records that are ran a long time.
     *
     * @param testRunId - test run record id
     *
     * @return - List<Test_Run_Method_Result__c>
     */
    @AuraEnabled(Cacheable=true)
    public static List<Test_Run_Method_Result__c> getLongRunningTestMethodsForTestRun(Id testRunId) {
        return TestRunService.getLongRunningTestMethodsForTestRun(testRunId);
    }
}
