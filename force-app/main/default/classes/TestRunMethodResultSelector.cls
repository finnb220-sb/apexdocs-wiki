/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Selector Class for Test_Run_Method_Result__c
 */
public inherited sharing class TestRunMethodResultSelector {
    /**
     * Gets Test_Run_Method_Result__c records that are ran a long time.
     *
     * @param testRunId - test run record id
     *
     * @return - List<Test_Run_Method_Result__c>
     */
    public List<Test_Run_Method_Result__c> getLongRunningTestMethodsForTestRun(Id testRunId) {
        return [
            SELECT Id, Name, Apex_Class__c, Method_Name__c, Run_Time__c
            FROM Test_Run_Method_Result__c
            WHERE Test_Run__c = :testRunId AND Run_Time__c >= 30000
            ORDER BY Run_Time__c
        ];
    }
}
