/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for ModuleClassTriggerHandler
 */
@IsTest
private class ModuleClassTriggerHandlerTest {
    @IsTest
    static void testModuleGettingAssignedToExistingRecordsOnInsert() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
        Test_Run__c tr = DTCTestUtil.createTestRun('Test', jobId, false);
        insert tr;

        List<Test_Run_Method_Result__c> results = new List<Test_Run_Method_Result__c>();
        for (Integer i = 0; i < 200; i++) {
            results.add(DTCTestUtil.createTestRunMethodResult(tr.Id, 'Foo', 'Test' + i));
        }

        insert results;

        CodeCoverage__c cc = DTCTestUtil.createCodeCoverage(tr.Id, 'Foo', 0, 0);
        insert cc;

        DTCModule__c module = DTCTestUtil.createModule('TestModule');
        insert module;

        ModuleClass__c mtc = DTCTestUtil.createModuleClass(module.Id, 'Foos');
        insert mtc;

        System.assertEquals(0, [SELECT COUNT() FROM Test_Run_Method_Result__c WHERE DTCModule__c != NULL]);
        Test.startTest();
        mtc.Name = 'Foo';
        update mtc;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Test_Run_Method_Result__c WHERE DTCModule__c != NULL]);

        System.assertEquals(1, [SELECT COUNT() FROM CodeCoverage__c WHERE DTCModule__c != NULL]);
    }
}
