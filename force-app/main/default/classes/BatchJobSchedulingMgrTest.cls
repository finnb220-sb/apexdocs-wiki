/**
 * Name: BatchJobSchedulingMgrTest
 * @author Brenda Finn
 * @date 11/14/21
 * 
 * @description Unit tests for BatchJobSchedulingMgrT
 *
 * @see BatchJobSchedulingMgr.cls
 */
@IsTest
private class BatchJobSchedulingMgrTest {

    @TestSetup
    static void buildData() {
        // create Account records
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Phone = '1234567890';
        acct.ShippingStreet = '123 Some Street';
        acct.ShippingCity = 'Some City';
        acct.ShippingState = 'VA';
        acct.ShippingPostalCode = '21212';
        insert acct;
    }

    @IsTest
    static void testExclusions() {
        Integer thisYear = Date.today().year();
        BatchJobSchedulingMgr.testConfigs = new List<Do_Not_Run_Automations_Day__mdt>();
        BatchJobSchedulingMgr.testConfigs.add(new Do_Not_Run_Automations_Day__mdt(DeveloperName='ChristmasWeek',
                Start_Date__c=Date.newInstance(thisYear, 12, 24),
                End_Date__c=Date.newInstance(thisYear+1, 1, 1),
                Day_of_the_Week__c=BatchJobConstants.USE_START_DATE, Is_Active__c=true,
                Automation_Type__c=BatchJobConstants.TEST_AUTOMATION_TYPE));
        BatchJobSchedulingMgr.testConfigs.add(new Do_Not_Run_Automations_Day__mdt(DeveloperName='July4th',
                Start_Date__c=Date.newInstance(thisYear, 7, 4),
                Day_of_the_Week__c=BatchJobConstants.USE_START_DATE, Is_Active__c=true,
                Automation_Type__c=BatchJobConstants.TEST_AUTOMATION_TYPE));
        BatchJobSchedulingMgr.testConfigs.add(new Do_Not_Run_Automations_Day__mdt(DeveloperName='Veterans Day',
                Start_Date__c=Date.newInstance(thisYear, 11, 11),
                Day_of_the_Week__c=BatchJobConstants.USE_START_DATE, Is_Active__c=false,
                Automation_Type__c=BatchJobConstants.TEST_AUTOMATION_TYPE));

        BatchJobSchedulingMgr instance = BatchJobSchedulingMgr.instance();
        Test.startTest();
        BatchJobSchedulingMgr.testDate = Date.newInstance(thisYear, 12, 24);
        System.assertEquals(false, instance.doRunAutomation(BatchJobConstants.TEST_AUTOMATION_TYPE),
                'Failed to return false for day of week exclusion');

        BatchJobSchedulingMgr.testDate = Date.today().toStartOfWeek(); // Sunday
        System.assertEquals(true, instance.doRunAutomation(BatchJobConstants.TEST_AUTOMATION_TYPE),
                'Returned false for day of week that is not excluded');

        BatchJobSchedulingMgr.testDate = Date.newInstance(thisYear, 11,11);
        System.assertEquals(true, instance.doRunAutomation(BatchJobConstants.TEST_AUTOMATION_TYPE),
                'Returned false for exclusion that is not active');

        BatchJobSchedulingMgr.defaultAutomationType = BatchJobConstants.TEST_AUTOMATION_TYPE;
        BatchJobSchedulingMgr.testDate = Date.newInstance(thisYear, 7,4);
        System.assertEquals(false, instance.doRunAutomation(),
                'Returned true for exclusion for a single day');

        Test.stopTest();
    }

    @IsTest
    static void testDayOfWeekExclusion() {
        BatchJobSchedulingMgr.testConfigs = new List<Do_Not_Run_Automations_Day__mdt>();
        BatchJobSchedulingMgr.testConfigs.add(new Do_Not_Run_Automations_Day__mdt(DeveloperName='Thursdays',
                Day_of_the_Week__c='Thu', Is_Active__c=true, Automation_Type__c=BatchJobConstants.TEST_AUTOMATION_TYPE));
        Test.startTest();
        BatchJobSchedulingMgr instance = BatchJobSchedulingMgr.instance();
        BatchJobSchedulingMgr.testDate = Date.today().toStartOfWeek().addDays(4);
        System.assertEquals(false, instance.doRunAutomation(BatchJobConstants.TEST_AUTOMATION_TYPE),
                'Returned true for day of week that is excluded');
        Test.stopTest();
    }

    @IsTest
    static void testStartJobs() {
        createTestBatchJobConfigs();
        Integer batchJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE
                ApexClass.Name=:BatchJobConstants.BATCH_JOB_BASE_MOCK_CLASS_NAME];
        Test.startTest();
        BatchJobSchedulingMgr.instance().startJobs();
        Test.stopTest();
        System.assertEquals(batchJobCount+4, [SELECT COUNT() FROM AsyncApexJob WHERE
            ApexClass.Name=:BatchJobConstants.BATCH_JOB_BASE_MOCK_CLASS_NAME],
            'Failed to start all configured jobs as expected.');
    }

    @IsTest
    private static void testManualRun() {
        createTestBatchJobConfigs();
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id FROM Account]);
        BatchJobSchedulingMgr.defaultAutomationType = '';
        Test.startTest();
        BatchJobSchedulingMgr.instance().manualProcess(BatchJobConstants.TEST_JOB_NAME, accounts.keySet());
        System.assertEquals(false, BatchJobSchedulingMgr.instance().doRunAutomation(), 'Failed to return false when no default config');
        Test.stopTest();
        System.assertEquals(true, BatchJobBaseMock.blnExecuteInvoked, 'Failed to execute records manually');
    }

    private static void createTestBatchJobConfigs() {
        BatchJobSchedulingMgr.testBatchJobConfigs = new List<Batch_Job_Config__mdt>();
        BatchJobSchedulingMgr.testBatchJobConfigs.add(new Batch_Job_Config__mdt(DeveloperName=BatchJobConstants.TEST_JOB_NAME,
                Is_Active__c=true, Apex_Batch_Class_Name__c=BatchJobConstants.BATCH_JOB_BASE_MOCK_CLASS_NAME, Batch_Size__c=100,
                Query_Filter__c='',
                Cron_Job_Schedule__c='0 0 0 * ?', Status_Email_Group_Name__c='Batch_Status_Email_Group'));
        BatchJobSchedulingMgr.testBatchJobConfigs.add(new Batch_Job_Config__mdt(DeveloperName='TEST_Batch_Job_2',
                Is_Active__c=true, Apex_Batch_Class_Name__c=BatchJobConstants.BATCH_JOB_BASE_MOCK_CLASS_NAME, Batch_Size__c=100,
                Query_Filter__c='',
                Cron_Job_Schedule__c='0 0 1 * ?', Status_Email_Group_Name__c='Batch_Status_Email_Group'));
    }
}
