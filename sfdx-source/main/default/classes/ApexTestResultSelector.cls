/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Selector Class for ApexTestResultSelector
 */
public inherited sharing class ApexTestResultSelector {
    /**
     * Gets records by AsyncApexJobId
     *
     * @param parentJobIds - Set of AsyncApexJobId
     *
     * @return List<ApexTestResult>
     */
    public List<ApexTestResult> getRecordsByAsyncApexJobId(List<String> parentJobIds) {
        return [
            SELECT Outcome, MethodName, Message, StackTrace, AsyncApexJobId, ApexClass.Name, RunTime
            FROM ApexTestResult
            WHERE AsyncApexJobId IN :parentJobIds
        ];
    }
}
