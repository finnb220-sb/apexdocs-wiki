/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Controller class for lwc testRunClassesUnder75Percent lwc component
 */

public inherited sharing class CodeCoverageController {
    /**
     * Gets CodeCoverage__c under 75% coverage for a test run
     *
     * @param testRunId - test run record id
     *
     * @return List<CodeCoverage__c>
     */
    @AuraEnabled(Cacheable=true)
    public static List<CodeCoverage__c> getCoverageUnderSeventyFive(Id testRunId) {
        return CodeCoverageService.getCoverageUnderSeventyFiveForRun(testRunId);
    }
}
