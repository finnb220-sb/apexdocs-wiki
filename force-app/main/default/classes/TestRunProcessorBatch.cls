/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Processes Test_Run__c records.  Once all tests are completed Test_Run_Method_Result__c record are created.
 */
public without sharing class TestRunProcessorBatch implements Database.Batchable<SObject>, Schedulable, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext context) {
        //Add user to failure group to get notifications
        TestRunService.addRunningUserToFailureGroup();
        return Database.getQueryLocator([SELECT Id, Parent_Job_Ids__c FROM Test_Run__c WHERE Processed__c = FALSE ORDER BY CreatedDate ASC]);
    }

    public void execute(Database.BatchableContext context, List<Test_Run__c> testRuns) {
        Test_Run__c testRun = testRuns[0];
        if (allTestsComplete(testRun.Parent_Job_Ids__c)) {
            List<ApexTestResult> testResults = getTestResults(testRun.Parent_Job_Ids__c);
            List<Test_Run_Method_Result__c> results = new List<Test_Run_Method_Result__c>();
            Set<String> testMethodNames = new Set<String>();
            Map<String, Test_Run_Method_Result__c> classToMethodResultMap = new Map<String, Test_Run_Method_Result__c>();
            for (ApexTestResult apexTestResult : testResults) {
                Test_Run_Method_Result__c trmr = new Test_Run_Method_Result__c();
                trmr.Message__c = apexTestResult.Message;
                trmr.Message__c = apexTestResult.Message;
                trmr.Method_Name__c = apexTestResult.MethodName;
                trmr.Method_Pass__c = apexTestResult.Outcome == 'Pass' ? true : false;
                trmr.Apex_Class__c = apexTestResult.ApexClass.Name;
                trmr.Stack_Trace__c = apexTestResult.StackTrace;
                trmr.Run_Time__c = apexTestResult.RunTime;
                trmr.Test_Run__c = testRun.Id;

                if (trmr.Method_Pass__c == true) {
                    trmr.Last_Success__c = Datetime.now();
                } else {
                    trmr.New_Failure__c = true;
                    trmr.First_Failure__c = Datetime.now();
                }
                results.add(trmr);
                testMethodNames.add(trmr.Method_Name__c);
                String hash = buildClassToMethodHash(apexTestResult.ApexClass.Name, apexTestResult.MethodName);
                classToMethodResultMap.put(hash, trmr);
            }

            AggregateResult maxTestRun = [SELECT MAX(Id) recId FROM Test_Run__c WHERE Processed__c = TRUE];
            Id previousTestRunId = String.valueOf(maxTestRun.get('recId'));
            if (previousTestRunId != null) {
                List<Test_Run_Method_Result__c> previousResults = [
                    SELECT Id, Apex_Class__c, Method_Name__c, Method_Pass__c, CreatedDate, First_Failure__c
                    FROM Test_Run_Method_Result__c
                    WHERE Test_Run__c = :previousTestRunId
                ];

                Map<String, Test_Run_Method_Result__c> previousClassToMethodResultMap = new Map<String, Test_Run_Method_Result__c>();
                for (Test_Run_Method_Result__c prev : previousResults) {
                    String hash = buildClassToMethodHash(prev.Apex_Class__c, prev.Method_Name__c);
                    previousClassToMethodResultMap.put(hash, prev);
                }

                for (Test_Run_Method_Result__c resultRec : results) {
                    String hash = buildClassToMethodHash(resultRec.Apex_Class__c, resultRec.Method_Name__c);
                    Test_Run_Method_Result__c previousResult = null;
                    if (previousClassToMethodResultMap.containsKey(hash)) {
                        previousResult = previousClassToMethodResultMap.get(hash);
                        resultRec.PreviousMethodResults__c = previousResult.Id;
                    }
                    if (!resultRec.Method_Pass__c) {
                        if (previousResult?.Method_Pass__c == false) {
                            resultRec.New_Failure__c = false;
                            resultRec.First_Failure__c = previousResult.First_Failure__c;
                        }
                    }
                }
            }

            List<AggregateResult> lastSuccessfulRecords = [
                SELECT MAX(CreatedDate) successDate, Apex_Class__c, Method_Name__c
                FROM Test_Run_Method_Result__c
                WHERE Method_Pass__c = TRUE AND Method_Name__c IN :testMethodNames
                GROUP BY Apex_Class__c, Method_Name__c
            ];
            Map<String, Datetime> lastSuccessMap = new Map<String, Datetime>();
            if (lastSuccessfulRecords.size() > 0) {
                for (AggregateResult ar : lastSuccessfulRecords) {
                    Datetime lastSuccessDate = Datetime.valueOf(ar.get('successDate'));
                    String className = String.valueOf(ar.get('Apex_Class__c'));
                    String method = String.valueOf(ar.get('Method_Name__c'));
                    String hash = buildClassToMethodHash(className, method);
                    lastSuccessMap.put(hash, lastSuccessDate);
                }
            }
            Integer newTestFailures = 0;
            for (Test_Run_Method_Result__c resultRec : results) {
                String hash = buildClassToMethodHash(resultRec.Apex_Class__c, resultRec.Method_Name__c);
                if (lastSuccessMap.containsKey(hash)) {
                    resultRec.Last_Success__c = lastSuccessMap.get(hash);
                }
                if (resultRec.New_Failure__c) {
                    newTestFailures++;
                }
            }

            List<CodeCoverage__c> codeCoverageRecs = new CodeCoverageService().getCodeCoverageForUnmanagedItems();
            for (CodeCoverage__c rec : codeCoverageRecs) {
                rec.TestRun__c = testRun.Id;
            }

            if (codeCoverageRecs.size() > 0) {
                insert codeCoverageRecs;
            }

            insert results;

            testRun.Processed__c = true;
            testRun.End_Date__c = Datetime.now();
            testRun.New_Failures__c = newTestFailures;
            update testRun;
            TestRunService.sendFailureNotification(testRun.Id);
        }
    }

    public void finish(Database.BatchableContext context) {
        AsyncApexJob aaj = [SELECT NumberOfErrors FROM AsyncApexJob WHERE Id = :context.getJobId()];
        if (aaj.NumberOfErrors > 0) {
            //Only send batch compelted if failure happened.
            DTCUtils.sendCompletedBatchJobEmail(context.getJobId());
        }
        //Self Schedule job.
        TestRunService.scheduleProcessor();
    }

    /**
     * Checks if all tests are completed
     *
     * @param parentJobIds -r ec ids
     *
     * @return true or false
     */
    private Boolean allTestsComplete(String parentJobIds) {
        List<ApexTestQueueItem> classTestStatuses = getClassTestStatuses(parentJobIds);

        if (classTestStatuses == null || classTestStatuses.size() == 0) {
            return false;
        }

        Set<String> completedItemStatues = new Set<String>{ 'Completed', 'Failed', 'Aborted' };

        for (ApexTestQueueItem classTestStatus : classTestStatuses) {
            if (!completedItemStatues.contains(classTestStatus.Status)) {
                return false;
            }
        }

        return true;
    }

    /**
     * Gets the apex unt test statuses
     *
     * @param parentJobIds
     *
     * @return List<ApexTestQueueItem>
     */
    private List<ApexTestQueueItem> getClassTestStatuses(String parentJobIds) {
        ApexTestQueueItemSelector selector = (ApexTestQueueItemSelector) Injector.getInjector().instantiate('ApexTestQueueItemSelector');
        return selector.getRecordByParentJobIds(parentJobIds.split(','));
    }

    /**
     * Gets the unt tests results.
     *
     * @param parentJobIds
     *
     * @return List<ApexTestResult>
     */
    private List<ApexTestResult> getTestResults(String parentJobIds) {
        ApexTestResultSelector selector = (ApexTestResultSelector) Injector.getInjector().instantiate('ApexTestResultSelector');
        return selector.getRecordsByAsyncApexJobId(parentJobIds.split(','));
    }

    private String buildClassToMethodHash(String className, String method) {
        return className + '-' + method;
    }

    /**
     * Easy way to run batch job
     */
    public static void run() {
        Database.executeBatch(new TestRunProcessorBatch(), 1);
    }

    /**
     * Implementation of Schedulable interface
     *
     * @param SC
     */
    public void execute(SchedulableContext SC) {
        run();
    }
}
