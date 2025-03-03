/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Selector Class for CodeCoverage__c object
 */
public inherited sharing class CodeCoverageSelector {
    /**
     * Gets CodeCoverage__c under 75% coverage for a test run
     *
     * @param testRunId - test run record id
     *
     * @return List<CodeCoverage__c>
     */
    public List<CodeCoverage__c> getCoverageUnderSeventyFiveForTestRun(Id testRunId) {
        return [
            SELECT Id, Name, ApexClassOrTriggerName__c, LinesCovered__c, LinesNotCovered__c, CodeCoveragePercentage__c
            FROM CodeCoverage__c
            WHERE TestRun__c = :testRunId AND CodeCoveragePercentage__c < 75
            ORDER BY CodeCoveragePercentage__c
        ];
    }
}
