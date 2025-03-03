/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Test class for lwc CodeCoverageController
 */

@IsTest
private class CodeCoverageControllerTest {
    @IsTest
    static void testGetCoverageUnderSeventyFive() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
        Test_Run__c tr = DTCTestUtil.createTestRun('Test', jobId, false);

        System.runAs(DTCTestUtil.createSysAdminUser()) {
            insert tr;

            List<CodeCoverage__c> coverageRecs = new List<CodeCoverage__c>();
            coverageRecs.add(DTCTestUtil.createCodeCoverage(tr.Id, 'Class1', 7, 1000));
            coverageRecs.add(DTCTestUtil.createCodeCoverage(tr.Id, 'Class2', 90, 10));
            coverageRecs.add(DTCTestUtil.createCodeCoverage(tr.Id, 'Class3', 8, 10));
            insert coverageRecs;
        }

        System.runAs(DTCTestUtil.createTestRunnerViewer()) {
            Test.startTest();
            List<CodeCoverage__c> recs = CodeCoverageController.getCoverageUnderSeventyFive(tr.Id);
            Test.stopTest();
            System.assertEquals(2, recs.size());
        }
    }
}
