/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for TestRunMethodResultTriggerHandler
 */
@IsTest
private class TestRunMethodResultTriggerHandlerTest {
    @IsTest
    static void testModuleGettingAssigned() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());

        DTCModule__c module = DTCTestUtil.createModule('TestModule');
        insert module;

        ModuleClass__c mtc = DTCTestUtil.createModuleClass(module.Id, 'Foo');
        insert mtc;

        Test_Run__c tr = DTCTestUtil.createTestRun('Test', jobId, false);
        insert tr;

        Test_Run_Method_Result__c result = DTCTestUtil.createTestRunMethodResult(tr.Id, 'Foo', 'Test');

        Test.startTest();
        insert result;
        Test.stopTest();
        System.assertEquals(module.Id, [SELECT Id, DTCModule__c FROM Test_Run_Method_Result__c WHERE Id = :result.Id].DTCModule__c);
    }

    @IsTest
    static void testModuleGettingAssignedBulk() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());

        DTCModule__c module = DTCTestUtil.createModule('TestModule');
        insert module;

        ModuleClass__c mtc = DTCTestUtil.createModuleClass(module.Id, 'Foo');
        insert mtc;

        Test_Run__c tr = DTCTestUtil.createTestRun('Test', jobId, false);
        insert tr;

        List<Test_Run_Method_Result__c> results = new List<Test_Run_Method_Result__c>();
        for (Integer i = 0; i < 200; i++) {
            results.add(DTCTestUtil.createTestRunMethodResult(tr.Id, 'Foo', 'Test' + i));
        }

        Test.startTest();
        insert results;
        Test.stopTest();
        System.assertEquals(200, [SELECT COUNT() FROM Test_Run_Method_Result__c WHERE DTCModule__c != NULL]);
    }
}
