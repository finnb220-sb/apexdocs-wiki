/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for TestRunEmailController
 */
@IsTest
private class TestRunEmailControllerTest {
    @IsTest
    public static void controllerTest() {
        Id jobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
        Test_Run__c testRun = DTCTestUtil.createTestRun('Testing Test Run', jobId, false);
        insert testRun;

        Test_Run_Method_Result__c rec1 = DTCTestUtil.createTestRunMethodResult(testRun.Id, 'Test Class', 'Test Method');
        rec1.Message__c = 'Testing email controller';
        rec1.First_Failure__c = Datetime.now();
        rec1.Method_Pass__c = false;

        Test_Run_Method_Result__c rec2 = DTCTestUtil.createTestRunMethodResult(testRun.Id, 'Test Class2', 'Test Method');
        rec2.Message__c = 'Testing email controller';
        rec2.First_Failure__c = Datetime.now();
        rec2.Method_Pass__c = false;
        List<Test_Run_Method_Result__c> methodResults = new List<Test_Run_Method_Result__c>{ rec1, rec2 };

        insert methodResults;

        TestRunEmailController cont = new TestRunEmailController();
        cont.testRunId = testRun.Id;
        Map<String, List<Test_Run_Method_Result__c>> failMap = cont.getFailureMap();
        System.assertEquals(2, failMap.size());
        System.assertNotEquals(null, cont.getbaseURL());
    }
}
