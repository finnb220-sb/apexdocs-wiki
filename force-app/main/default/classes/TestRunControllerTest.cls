/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Test class for TestRunController
 */
@IsTest
private class TestRunControllerTest {
    @IsTest
    static void testCreateTestRun() {
        List<ApexClass> classes = [SELECT Id, Name, Body FROM ApexClass WHERE Name = 'TestRunServiceTest'];

        // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_testing_SOSL.htm
        Test.setFixedSearchResults(new List<Id>{ classes[0].Id });

        String jsonResponse =
            '{"totalSize":1,"size":1,"records":[{"Name":"TestRunServiceTest","Id":"' +
            classes[0].Id +
            '","FullName":null}],"queryLocator":null,"nextRecordsUrl":null,"entityTypeName":"ApexClass"}';

        Test.startTest();
        CalloutRequestMock fakeResponse = new CalloutRequestMock(200, 'OK', jsonResponse, null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        TestRunAdminController.runTests();
        Test.stopTest();

        Test_Run__c testRun = [
            SELECT Id, Name, Parent_Job_Ids__c, Processed__c, Start_Date__c
            FROM Test_Run__c
            LIMIT 1
        ];
        System.assertEquals('testingParentJobId', testRun.Parent_Job_Ids__c);
        System.assertEquals(false, testRun.Processed__c);
    }

    @IsTest
    static void testGetLongRunningTestMethodsForTestRun() {
        Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
        Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, false);
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            insert tr;

            List<Test_Run_Method_Result__c> methodResults = new List<Test_Run_Method_Result__c>();
            Test_Run_Method_Result__c methodResult1 = DTCTestUtil.createTestRunMethodResult(tr.Id, 'Foo', 'test1');
            methodResult1.Run_Time__c = 30000;
            Test_Run_Method_Result__c methodResult2 = DTCTestUtil.createTestRunMethodResult(tr.Id, 'Foo', 'test2');
            methodResult2.Run_Time__c = 29999;
            methodResults.add(methodResult1);
            methodResults.add(methodResult2);
            insert methodResults;
        }

        System.runAs(DTCTestUtil.createTestRunnerViewer()) {
            Test.startTest();
            List<Test_Run_Method_Result__c> recs = TestRunController.getLongRunningTestMethodsForTestRun(tr.Id);
            Test.stopTest();
            System.assertEquals(1, recs.size());
        }
    }
}
