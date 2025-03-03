/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Service Class for CodeCoverage related processes
 */
public inherited sharing class CodeCoverageService {
    /**
     * Gets code coverage from the tooling api and wraps the results
     * into CodeCoverage__c records
     *
     * @return List<CodeCoverage__c>
     */
    public List<CodeCoverage__c> getCodeCoverageForUnmanagedItems() {
        List<CodeCoverage__c> codeCoverageRecs = new List<CodeCoverage__c>();

        Set<Id> unmanagedIds = new Set<Id>();
        SalesforceToolingApi toolingApi = new SalesforceToolingApi();
        SalesforceToolingApi.QueryResult classResults = toolingApi.getUnmanagedClasses();
        for (SalesforceToolingApi.Record rec : classResults.records) {
            unmanagedIds.add(rec.Id);
        }

        SalesforceToolingApi.QueryResult triggerResults = toolingApi.getUnmanagedTriggers();
        for (SalesforceToolingApi.Record rec : triggerResults.records) {
            unmanagedIds.add(rec.Id);
        }

        String apiJsonResponse = CodeCoverageService.getClassCodeCoverageFromToolingAPI();
        if (String.isNotBlank(apiJsonResponse)) {
            CodeCoverageWrapper data = CodeCoverageWrapper.parse(apiJsonResponse);
            for (CodeCoverageWrapper.Record rec : data.records) {
                if (unmanagedIds.contains(rec.ApexClassorTriggerId)) {
                    codeCoverageRecs.add(rec.toCodeCoverageSobject());
                }
            }
        }
        return codeCoverageRecs;
    }

    /**
     * Builds the query to get the org wide code coverage and calls tooling api
     *
     * @return - json response
     */
    public static String getOrgCodeCoverage() {
        String soql = 'SELECT PercentCovered,LastModifiedDate FROM ApexOrgWideCoverage';
        SalesforceToolingApi toolingApi = new SalesforceToolingApi(true);
        return toolingApi.doGetQuery(soql);
    }

    /**
     * Builds the query to get the code coverage for each class/trigger and calls tooling api
     *
     * @return - json response
     */
    public static String getClassCodeCoverageFromToolingAPI() {
        String soql = 'SELECT ApexClassOrTriggerId, ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered';
        soql += ' FROM ApexCodeCoverageAggregate WHERE ApexClassOrTriggerId != NULL';
        soql += ' AND ApexClassOrTrigger.Name!=NULL';
        soql += ' AND NumLinesUncovered != NULL';
        soql += ' AND NumLinesCovered!= NULL';
        soql += ' ORDER BY ApexClassOrTrigger.Name';
        SalesforceToolingApi toolingApi = new SalesforceToolingApi();
        return toolingApi.doGetQuery(soql);
    }

    /**
     * Gets CodeCoverage__c under 75% coverage for a test run
     *
     * @param testRunId - test run record id
     *
     * @return List<CodeCoverage__c>
     */
    public static List<CodeCoverage__c> getCoverageUnderSeventyFiveForRun(Id testRunId) {
        return new CodeCoverageSelector().getCoverageUnderSeventyFiveForTestRun(testRunId);
    }
}
