/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for TestRunProcessorBatch
 */
@IsTest
private class TestRunProcessorBatchTest {
    @IsTest
    static void testRunWithOnlySuccessfulTests() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            // Create a new mock provider
            MockProvider mock = new MockProvider();

            // Create mock instances
            ApexTestQueueItemSelector mockApexTestQueueItemSelector = (ApexTestQueueItemSelector) mock.createMock(ApexTestQueueItemSelector.class);
            ApexTestResultSelector mockApexTestResultSelector = (ApexTestResultSelector) mock.createMock(ApexTestResultSelector.class);
            OrganizationSelector mockOrganizationSelectorSelector = (OrganizationSelector) mock.createMock(OrganizationSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestQueueItemSelector'), mockApexTestQueueItemSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestResultSelector'), mockApexTestResultSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('OrganizationSelector'), mockOrganizationSelectorSelector);

            // Mock return values
            ApexTestQueueItem qi = (ApexTestQueueItem) JSON.deserialize('{"ApexClass.Name":"TestRunProcessorTest","Status":"Completed"}', ApexTestQueueItem.class);
            mock.setMock().mockReturnValue(mockApexTestQueueItemSelector.getRecordByParentJobIds(new List<Id>{ testJobId }), new List<ApexTestQueueItem>{ qi });

            ApexTestResult successfulResult = new ApexTestResult();
            successfulResult.Outcome = 'Pass';
            successfulResult.MethodName = 'Test1';
            successfulResult.Message = null;
            successfulResult.StackTrace = null;
            successfulResult.AsyncApexJobId = testJobId;
            successfulResult.ApexClass = new ApexClass(Name = 'Foo');
            mock.setMock().mockReturnValue(mockApexTestResultSelector.getRecordsByAsyncApexJobId(new List<Id>{ testJobId }), new List<ApexTestResult>{ successfulResult });

            Map<String, Object> genericOrgRec = new Map<String, Object>();
            genericOrgRec.put('IsSandbox', false);
            Organization orgRec = (Organization) JSON.deserialize(JSON.serialize(genericOrgRec), Organization.class);
            mock.setMock().mockReturnValue(mockOrganizationSelectorSelector.getRecord(), orgRec);

            setToolingApiMocks();

            Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, false);
            insert tr;

            TestRunProcessorBatch testProcessor = new TestRunProcessorBatch();

            Test.startTest();
            System.schedule('Automated Test Job Queue [UNIT TESTING]', '0 0 23 * * ?', testProcessor);
            testProcessor.execute(null);
            Test.stopTest();
            List<Test_Run_Method_Result__c> methodResults = [
                SELECT Method_Name__c, Method_Pass__c, Stack_Trace__c, Message__c
                FROM Test_Run_Method_Result__c
                WHERE Apex_Class__c = 'Foo'
            ];
            System.assertEquals('Test1', methodResults[0].Method_Name__c);
            System.assertEquals(null, methodResults[0].Stack_Trace__c);
            System.assertEquals(null, methodResults[0].Message__c);
            System.assertEquals(true, methodResults[0].Method_Pass__c);
            System.assertEquals(1, methodResults.size());

            List<Test_Run__c> testRuns = [SELECT Id, Test_Failures__c, Total_Tests__c, Processed__c FROM Test_Run__c];
            System.assertEquals(true, testRuns[0].Processed__c);
            System.assertEquals(0, testRuns[0].Test_Failures__c);
            System.assertEquals(1, testRuns[0].Total_Tests__c);
        }
    }

    @IsTest
    static void testRunWithOnlyFailedTests() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            // Create a new mock provider
            MockProvider mock = new MockProvider();

            // Create mock instances
            ApexTestQueueItemSelector mockApexTestQueueItemSelector = (ApexTestQueueItemSelector) mock.createMock(ApexTestQueueItemSelector.class);
            ApexTestResultSelector mockApexTestResultSelector = (ApexTestResultSelector) mock.createMock(ApexTestResultSelector.class);
            OrganizationSelector mockOrganizationSelectorSelector = (OrganizationSelector) mock.createMock(OrganizationSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestQueueItemSelector'), mockApexTestQueueItemSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestResultSelector'), mockApexTestResultSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('OrganizationSelector'), mockOrganizationSelectorSelector);

            // Mock return values
            ApexTestQueueItem qi = (ApexTestQueueItem) JSON.deserialize('{"ApexClass.Name":"TestRunProcessorTest","Status":"Completed"}', ApexTestQueueItem.class);
            mock.setMock().mockReturnValue(mockApexTestQueueItemSelector.getRecordByParentJobIds(new List<Id>{ testJobId }), new List<ApexTestQueueItem>{ qi });

            ApexTestResult failedResult = new ApexTestResult();
            failedResult.Outcome = 'Failed';
            failedResult.MethodName = 'Test1';
            failedResult.Message = 'Test Message';
            failedResult.StackTrace = 'Test Stack';
            failedResult.AsyncApexJobId = testJobId;
            failedResult.ApexClass = new ApexClass(Name = 'Foo');
            mock.setMock().mockReturnValue(mockApexTestResultSelector.getRecordsByAsyncApexJobId(new List<Id>{ testJobId }), new List<ApexTestResult>{ failedResult });

            Map<String, Object> genericOrgRec = new Map<String, Object>();
            genericOrgRec.put('IsSandbox', false);
            Organization orgRec = (Organization) JSON.deserialize(JSON.serialize(genericOrgRec), Organization.class);
            mock.setMock().mockReturnValue(mockOrganizationSelectorSelector.getRecord(), orgRec);

            setToolingApiMocks();

            Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, false);
            insert tr;

            TestRunProcessorBatch testProcessor = new TestRunProcessorBatch();

            Test.startTest();
            System.schedule('Automated Test Job Queue [UNIT TESTING]', '0 0 23 * * ?', testProcessor);
            testProcessor.execute(null);
            Test.stopTest();
            List<Test_Run_Method_Result__c> methodResults = [
                SELECT Method_Name__c, Method_Pass__c, Stack_Trace__c, Message__c
                FROM Test_Run_Method_Result__c
                WHERE Apex_Class__c = 'Foo'
            ];
            System.assertEquals('Test1', methodResults[0].Method_Name__c);
            System.assertEquals('Test Stack', methodResults[0].Stack_Trace__c);
            System.assertEquals('Test Message', methodResults[0].Message__c);
            System.assertEquals(false, methodResults[0].Method_Pass__c);
            System.assertEquals(1, methodResults.size());

            List<Test_Run__c> testRuns = [SELECT Id, Test_Failures__c, Total_Tests__c, Processed__c FROM Test_Run__c];
            System.assertEquals(true, testRuns[0].Processed__c);
            System.assertEquals(1, testRuns[0].Test_Failures__c);
            System.assertEquals(1, testRuns[0].Total_Tests__c);
        }
    }

    @IsTest
    static void testRunWithFailedAndSuccessfulTests() {
        System.runAs(DTCTestUtil.createSysAdminUser()) {
            Id testJobId = DTCTestUtil.generateId(ApexTestQueueItem.getSObjectType());
            // Create a new mock provider
            MockProvider mock = new MockProvider();

            // Create mock instances
            ApexTestQueueItemSelector mockApexTestQueueItemSelector = (ApexTestQueueItemSelector) mock.createMock(ApexTestQueueItemSelector.class);
            ApexTestResultSelector mockApexTestResultSelector = (ApexTestResultSelector) mock.createMock(ApexTestResultSelector.class);
            OrganizationSelector mockOrganizationSelectorSelector = (OrganizationSelector) mock.createMock(OrganizationSelector.class);

            // Create a mock injector
            Injector mockInjector = (Injector) mock.createMock(Injector.class);

            // Setup the Injector to return the mock injector
            Injector.mockInjector = mockInjector;

            // Assign Mock Classes
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestQueueItemSelector'), mockApexTestQueueItemSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('ApexTestResultSelector'), mockApexTestResultSelector);
            mock.setMock().mockReturnValue(mockInjector.instantiate('OrganizationSelector'), mockOrganizationSelectorSelector);

            // Mock return values
            ApexTestQueueItem qi = (ApexTestQueueItem) JSON.deserialize('{"ApexClass.Name":"TestRunProcessorTest","Status":"Completed"}', ApexTestQueueItem.class);
            mock.setMock().mockReturnValue(mockApexTestQueueItemSelector.getRecordByParentJobIds(new List<Id>{ testJobId }), new List<ApexTestQueueItem>{ qi });

            ApexTestResult successfulResult = new ApexTestResult();
            successfulResult.Outcome = 'Pass';
            successfulResult.MethodName = 'Test1';
            successfulResult.Message = null;
            successfulResult.StackTrace = null;
            successfulResult.AsyncApexJobId = testJobId;
            successfulResult.ApexClass = new ApexClass(Name = 'Foo');

            ApexTestResult failedResult = new ApexTestResult();
            failedResult.Outcome = 'Failed';
            failedResult.MethodName = 'Test2';
            failedResult.Message = 'Test Message';
            failedResult.StackTrace = 'Test Stack';
            failedResult.AsyncApexJobId = testJobId;
            failedResult.ApexClass = new ApexClass(Name = 'Bar');
            mock.setMock()
                .mockReturnValue(mockApexTestResultSelector.getRecordsByAsyncApexJobId(new List<Id>{ testJobId }), new List<ApexTestResult>{ failedResult, successfulResult });

            Map<String, Object> genericOrgRec = new Map<String, Object>();
            genericOrgRec.put('IsSandbox', false);
            Organization orgRec = (Organization) JSON.deserialize(JSON.serialize(genericOrgRec), Organization.class);
            mock.setMock().mockReturnValue(mockOrganizationSelectorSelector.getRecord(), orgRec);

            setToolingApiMocks();

            Test_Run__c tr = DTCTestUtil.createTestRun('Test Run', testJobId, false);
            insert tr;

            TestRunProcessorBatch testProcessor = new TestRunProcessorBatch();

            Test.startTest();
            System.schedule('Automated Test Job Queue [UNIT TESTING]', '0 0 23 * * ?', testProcessor);
            testProcessor.execute(null);
            Test.stopTest();
            List<Test_Run_Method_Result__c> methodResults = [
                SELECT Method_Name__c, Method_Pass__c, Stack_Trace__c, Message__c, Apex_Class__c
                FROM Test_Run_Method_Result__c
                WHERE Apex_Class__c IN ('Foo', 'Bar')
                ORDER BY Apex_Class__c
            ];
            System.assertEquals(2, methodResults.size());

            System.assertEquals('Bar', methodResults[0].Apex_Class__c);
            System.assertEquals('Test2', methodResults[0].Method_Name__c);
            System.assertEquals('Test Stack', methodResults[0].Stack_Trace__c);
            System.assertEquals('Test Message', methodResults[0].Message__c);
            System.assertEquals(false, methodResults[0].Method_Pass__c);

            System.assertEquals('Foo', methodResults[1].Apex_Class__c);
            System.assertEquals('Test1', methodResults[1].Method_Name__c);
            System.assertEquals(null, methodResults[1].Stack_Trace__c);
            System.assertEquals(null, methodResults[1].Message__c);
            System.assertEquals(true, methodResults[1].Method_Pass__c);

            List<Test_Run__c> testRuns = [SELECT Id, Test_Failures__c, Total_Tests__c, Processed__c FROM Test_Run__c];
            System.assertEquals(true, testRuns[0].Processed__c);
            System.assertEquals(1, testRuns[0].Test_Failures__c);
            System.assertEquals(2, testRuns[0].Total_Tests__c);
        }
    }

    private static void setToolingApiMocks() {
        String unmanagedClassesResponse = '{"totalSize":2,"size":2,"records":[{"Name":"Injector","Id":"01p3R000000gpF3QAI","FullName":null},{"Name":"DTCUtils","Id":"01p3R000000gpEwQAI","FullName":null}],"queryLocator":null,"nextRecordsUrl":null,"entityTypeName":"ApexClass"}';
        CalloutRequestMock classesApiResponse = new CalloutRequestMock(200, 'OK', unmanagedClassesResponse, null);

        String unmanagedTriggersResponse = '{"totalSize":1,"size":1,"records":[{"Name":"TestRunMethodResultTrigger","Id":"01q3R000000APJbQAO","FullName":null}],"queryLocator":null,"nextRecordsUrl":null,"entityTypeName":"ApexTrigger"}';
        CalloutRequestMock triggerApiResponse = new CalloutRequestMock(200, 'OK', unmanagedTriggersResponse, null);

        String codeCoverageResponse = '{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverageAggregate","records":[{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v54.0/tooling/sobjects/ApexCodeCoverageAggregate/7153R0000004lSvQAI"},"ApexClassOrTriggerId":"01q3R000000APJbQAO","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v54.0/tooling/sobjects/ApexTrigger/01q3R000000APJbQAO"},"Name":"TestRunMethodResultTrigger"},"NumLinesCovered":1,"NumLinesUncovered":0},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v54.0/tooling/sobjects/ApexCodeCoverageAggregate/7153R0000004lSQQAY"},"ApexClassOrTriggerId":"01p3R000000gpF3QAI","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v54.0/tooling/sobjects/ApexClass/01p3R000000gpF3QAI"},"Name":"Injector"},"NumLinesCovered":12,"NumLinesUncovered":2},{"attributes":{"type":"ApexCodeCoverageAggregate","url":"/services/data/v54.0/tooling/sobjects/ApexCodeCoverageAggregate/7153R0000004lSSQAY"},"ApexClassOrTriggerId":"01p3R000000gpEwQAI","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v54.0/tooling/sobjects/ApexClass/01p3R000000gpEwQAI"},"Name":"DTCUtils"},"NumLinesCovered":0,"NumLinesUncovered":18}]}';
        CalloutRequestMock coverageApiResponse = new CalloutRequestMock(200, 'OK', codeCoverageResponse, null);

        //Assign Mock HTTP callouts
        Map<String, HttpCalloutMock> mockCallouts = new Map<String, HttpCalloutMock>();
        String classesApiUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/query/?q=ApexClasses';
        mockCallouts.put(classesApiUrl, classesApiResponse);

        String triggersApiUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/query/?q=ApexTrigger';
        mockCallouts.put(triggersApiUrl, triggerApiResponse);

        String codeCoverageUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/query/?q=ApexCodeCoverageAggregate';
        mockCallouts.put(codeCoverageUrl, coverageApiResponse);
        HttpCalloutMock multiCalloutMock = new MultiCalloutRequestMock(mockCallouts);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
    }
}
