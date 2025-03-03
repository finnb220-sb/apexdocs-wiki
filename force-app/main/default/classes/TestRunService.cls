/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Service class for Test runs
 */
public inherited sharing class TestRunService implements Schedulable {
    public static final String SCHEDULED_JOB_NAME = 'Scheduled Unit Test Runner';
    public static final String SCHEDULED_JOB_CRON = '0 0 3 ? * SAT *';
    public static final String SCHEDULED_PROCESSOR_JOB_NAME = 'Scheduled Unit Test Processor';
    public static final Integer DAYS_TO_CLEAR_TEST_RUNS = 90;
    public static final String FAILURE_GROUP_API_NAME = 'Test_Run_Failure_Notifiers';
    public static final String FAILURE_EMAIL_TEMPLATE = 'Test Run VF Notification';

    public void execute(SchedulableContext SC) {
        System.enqueueJob(new TestRunQueueable());
    }

    /**
     * Gets all the unit tests that are unmanaged unit tests and
     * starts running unit tests.
     *
     * @return
     */
    public static Id createTestRun() {
        List<ApexClass> testClassesToProcess = new List<ApexClass>();
        Id returnId;
        // get all unit test classes (excluding managed package unit tests)
        Map<Id, ApexClass> alltestClasses = new Map<Id, ApexClass>((List<ApexClass>) [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass(Id, Name)][0]);

        //If we don't get results, use a query to just double check
        if (alltestClasses.size() == 0) {
            List<ApexClass> queryClasses = [SELECT Id, Name, Body FROM ApexClass WHERE NamespacePrefix = NULL];
            for (ApexClass ac : queryClasses) {
                if (ac.Body?.containsIgnoreCase('@isTest')) {
                    alltestClasses.put(ac.Id, ac);
                }
            }
        }

        //Gets unit tests that are not part of managed or unlocked package.
        SalesforceToolingApi.QueryResult unmanagedTestClasses = new SalesforceToolingApi(true).getUnmanagedClasses();
        for (SalesforceToolingApi.Record rec : unmanagedTestClasses.records) {
            if (alltestClasses.containsKey(rec.Id)) {
                testClassesToProcess.add(alltestClasses.get(rec.Id));
            }
        }

        if (testClassesToProcess.size() > 0) {
            List<List<ApexTestQueueItem>> queueItems = new List<List<ApexTestQueueItem>>();
            List<ApexTestQueueItem> innerQueueItems = new List<ApexTestQueueItem>();
            Integer counter = 0;

            for (ApexClass testClass : testClassesToProcess) {
                counter++;
                innerQueueItems.add(new ApexTestQueueItem(ApexClassId = testClass.Id));

                //Need to group records of 200 in order for test runs to work correctly
                if (innerQueueItems.size() == 200) {
                    queueItems.add(innerQueueItems);
                    innerQueueItems = new List<ApexTestQueueItem>();
                }
            }

            if (innerQueueItems.size() > 0) {
                queueItems.add(innerQueueItems);
            }

            List<Id> parentIds = new List<Id>();
            Set<Id> testQueueIds = new Set<Id>();

            // bulk insert, when bulk inserted they will all contain the same ParentJobId
            if (!Test.isRunningTest()) {
                // can't queue unit tests while running a test
                for (List<ApexTestQueueItem> queueItemsSubset : queueItems) {
                    //Yes this is in a for loop, but this is needed to correctly initiate test runs of 200 otherwise sf only
                    //takes the last 200 to start the run.
                    insert queueItemsSubset;
                    testQueueIds.add(queueItemsSubset[0].Id);
                }

                for (ApexTestQueueItem queueItem : new ApexTestQueueItemSelector().getRecordsById(testQueueIds)) {
                    parentIds.add(queueItem.ParentJobId);
                }
            }

            Test_Run__c newRun = new Test_Run__c(
                Name = 'Test Run: ' + String.valueOf(Datetime.now()),
                Parent_Job_Ids__c = Test.isRunningTest() ? 'testingParentJobId' : String.join(parentIds, ','),
                Processed__c = false,
                Start_Date__c = Datetime.now()
            );

            insert newRun;
            returnId = newRun.Id;
        }

        clearOldRuns();
        scheduleProcessor();
        return returnId;
    }

    /**
     * Schedules test runs
     *
     * @return - List<Id>
     */
    public static List<Id> scheduleTestRuns() {
        if (testRunsAlreadyScheduled()) {
            cancelTestRuns();
        }
        List<Id> jobIds = new List<Id>();
        TestRunService testRunner = new TestRunService();
        String jobName1 = SCHEDULED_JOB_NAME;
        if (Test.isRunningTest()) {
            jobName1 += 'UNITTEST';
        }
        Id jobId1 = System.schedule(jobName1, SCHEDULED_JOB_CRON, testRunner);
        jobIds.add(jobId1);
        scheduleProcessor();
        return jobIds;
    }

    /**
     * Schedules TestRunProcessorBatch
     */
    public static void scheduleProcessor() {
        if (processorAlreadyScheduled()) {
            cancelProcessorJob();
        }
        Integer currentMinute = Datetime.now().minute();
        String jobName = SCHEDULED_PROCESSOR_JOB_NAME;
        String cronExpression;
        if (currentMinute >= 0 && currentMinute < 15) {
            jobName += ' at 15 mins';
            cronExpression = '0 15 * * * ?';
        } else if (currentMinute >= 15 && currentMinute < 30) {
            jobName += ' at 30 mins';
            cronExpression = '0 30 * * * ?';
        } else if (currentMinute >= 30 && currentMinute < 45) {
            jobName += ' at 45 mins';
            cronExpression = '0 45 * * * ?';
        } else {
            jobName += ' at 00 mins';
            cronExpression = '0 0 * * * ?';
        }
        if (Test.isRunningTest()) {
            jobName += 'UNITTEST';
        }
        System.schedule(jobName, cronExpression, new TestRunProcessorBatch());
    }

    /**
     * Determines if TestRunProcessorBatch is already scheduled.
     *
     * @return true/false
     */
    public static Boolean processorAlreadyScheduled() {
        List<CronTrigger> crons = getScheduledProcessorJob();
        Integer count = crons.size();
        return count >= 1;
    }

    /**
     * Determines if automated tests runs are scheduled.
     *
     * @return true/false
     */
    public static Boolean testRunsAlreadyScheduled() {
        List<CronTrigger> crons = getScheduledTestRunJobs();
        Integer count = crons.size();
        return count >= 1;
    }

    /**
     * Cancels scheduled TestRunProcessorBatch process
     */
    public static void cancelProcessorJob() {
        List<CronTrigger> crons = getScheduledProcessorJob();
        cancelJobs(crons);
    }

    /**
     * Cancels scheduled automated tests runs
     */
    public static void cancelTestRuns() {
        List<CronTrigger> crons = getScheduledTestRunJobs();
        cancelJobs(crons);
    }

    /**
     * Cancel cron jobs
     *
     * @param crons
     */
    private static void cancelJobs(List<CronTrigger> crons) {
        for (CronTrigger cron : crons) {
            System.abortJob(cron.Id);
        }
    }

    /**
     * Gets the scheduled automated tests run cron jobs.
     *
     * @return List<CronTrigger>
     */
    public static List<CronTrigger> getScheduledTestRunJobs() {
        Set<String> jobNames = new Set<String>();
        jobNames.add(SCHEDULED_JOB_NAME);
        return [SELECT Id, CronJobDetail.Name, CreatedBy.Name FROM CronTrigger WHERE CronJobDetail.Name IN :jobNames];
    }

    /**
     * Gets the scheduled cron job for TestRunProcessorBatch process.
     *
     * @return List<CronTrigger>
     */
    public static List<CronTrigger> getScheduledProcessorJob() {
        String filter = '%' + TestRunService.SCHEDULED_PROCESSOR_JOB_NAME + '%';
        return [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :filter];
    }

    /**
     * Clears Test_Run__c records that are older than DAYS_TO_CLEAR_TEST_RUNS
     */
    @Future
    public static void clearOldRuns() {
        List<Test_Run__c> oldRunRecs = new TestRunSelector().getRecordsToPrune(DAYS_TO_CLEAR_TEST_RUNS);
        if (oldRunRecs.size() > 0) {
            delete oldRunRecs;
        }
    }

    /**
     * Adds the running user to the failure group to be notified in case
     * there are any failures.
     */
    public static void addRunningUserToFailureGroup() {
        Group failureGroup = [SELECT Id FROM Group WHERE DeveloperName = :FAILURE_GROUP_API_NAME];
        GroupMember gm = new GroupMember();
        gm.GroupId = failureGroup.Id;
        gm.UserOrGroupId = UserInfo.getUserId();
        Database.insert(gm, false);
    }

    /**
     * Gets Test_Run_Method_Result__c records that are ran a long time.
     *
     * @param testRunId - test run record id
     *
     * @return - List<Test_Run_Method_Result__c>
     */
    public static List<Test_Run_Method_Result__c> getLongRunningTestMethodsForTestRun(Id testRunId) {
        return new TestRunMethodResultSelector().getLongRunningTestMethodsForTestRun(testRunId);
    }

    /**
     * Sends Test Run failure notifications
     *
     * @param recId - Test Run Id
     */
    public static void sendFailureNotification(Id recId) {
        Test_Run__c rec = new TestRunSelector().getByRecordId(recId);
        if (rec.Processed__c == true && rec.Test_Failures__c > 0) {
            EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE Name = :FAILURE_EMAIL_TEMPLATE];
            List<GroupMember> groupMembers = [
                SELECT Id, UserOrGroupId
                FROM GroupMember
                WHERE Group.DeveloperName = :FAILURE_GROUP_API_NAME
            ];
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            SObjectType userObjType = User.getSObjectType();
            for (GroupMember gm : groupMembers) {
                if (gm.UserOrGroupId.getSobjectType() == userObjType) {
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTargetObjectId(gm.UserOrGroupId);
                    email.setTemplateId(et.Id);
                    email.setWhatId(rec.Id);
                    email.setSaveAsActivity(false);
                    emails.add(email);
                }
            }
            if (emails.size() > 0) {
                Messaging.sendEmail(emails);
            }
        }
    }
}
