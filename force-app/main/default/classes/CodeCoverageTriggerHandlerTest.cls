/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for CodeCoverageTriggerHandler
 */
@IsTest
private class CodeCoverageTriggerHandlerTest {
    @IsTest
    static void testModuleGettingAssigned() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());

        DTCModule__c module = DTCTestUtil.createModule('TestModule');
        insert module;

        ModuleClass__c mtc = DTCTestUtil.createModuleClass(module.Id, 'Foo');
        insert mtc;

        Test_Run__c tr = DTCTestUtil.createTestRun('Test', jobId, false);
        insert tr;

        CodeCoverage__c cc = DTCTestUtil.createCodeCoverage(tr.Id, 'Foo', 1, 1);

        Test.startTest();
        insert cc;
        Test.stopTest();
        System.assertEquals(module.Id, [SELECT Id, DTCModule__c FROM CodeCoverage__c WHERE Id = :cc.Id].DTCModule__c);
    }
}
