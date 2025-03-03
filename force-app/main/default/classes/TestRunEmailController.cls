/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Controller class for FailureTable component
 */
public class TestRunEmailController {
    List<Test_Run_Method_Result__c> queryResults;
    public Id testRunId { get; set; }

    /**
     * Gets the base url
     *
     * @return url
     */
    public String getbaseURL() {
        return DTCUtils.getOrgUrl();
    }

    /**
     * Gets the failure record
     *
     * @return
     */
    public Map<String, List<Test_Run_Method_Result__c>> getFailureMap() {
        if (queryResults == null) {
            queryTestRun();
        }
        Map<String, List<Test_Run_Method_Result__c>> failureMap = new Map<String, List<Test_Run_Method_Result__c>>();
        for (Test_Run_Method_Result__c r : queryResults) {
            String key = r.Apex_Class__c;

            if (r.DTCModule__c != null) {
                key += ' - ' + r.DTCModule__r.Name;
            } else {
                key += ' - No Module Assigned';
            }

            if (failureMap.containsKey(key)) {
                failureMap.get(key).add(r);
            } else {
                failureMap.put(key, new List<Test_Run_Method_Result__c>{ r });
            }
        }
        return failureMap;
    }

    private void queryTestRun() {
        queryResults = [
            SELECT Id, Name, Method_Name__c, Message__c, First_Failure__c, New_Failure__c, DTCModule__r.Name, Apex_Class__c
            FROM Test_Run_Method_Result__c
            WHERE Test_Run__c = :testRunId AND Method_Pass__c = FALSE
        ];
    }
}
