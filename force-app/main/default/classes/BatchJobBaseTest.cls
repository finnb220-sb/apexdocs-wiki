/**
 * Name: BatchJobBaseTest
 * @author Brenda Finn 
 * @date 2021-11-16
 * @description Unit test class for BatchJobBase
 *
 * @See BatchJobBase.cls
 * @See BatchJobBaseTest.cls for mock subclass for testing
 */
@IsTest
private class BatchJobBaseTest {
    private static final String TEST_ACCOUNT_NAME = 'BatchJobTest Account';
    @TestSetup static void buildData() {
        Map<String, Object> attrMap = new Map<String, Object> {
                'Name' => TEST_ACCOUNT_NAME
        };
        insert Assembly.build('Account', attrMap);
    }

    // test the manual method on base class - not testing actual logic executed but rather
    // verifying that batch job was created/started as expected
    @IsTest static void testManual() {
        Account acct = [SELECT Id FROM Account];
        BatchJobBaseMock batch;
        Test.startTest();
        batch = new BatchJobBaseMock();
        batch.setConfig(testConfig);
        BatchJobBaseMock.manual('Test BatchJobBaseMock ' + DateTime.now().format(), batch);
        batch.markRecordAsSuccess(acct);
        batch.markRecordAsError(acct, 'Test ERROR');
        Test.stopTest();
        System.assertEquals(batch.getJobName(), 'Test Batch Class',
                'Failed to construct batch job successfully.');
        System.assert([SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name='BatchJobBaseMock'] > 0,
                'Failed to successfully start Batch Job');
    }

    @IsTest static void testHandleException() {
        BatchJobBaseMock batch = new BatchJobBaseMock();
        batch.setConfig(testConfig);
        batch.blnThrowException = true;
        Test.startTest();
        batch.execute(null);
        Test.stopTest();
        System.assertEquals(true, MessagingServiceImpl.messagesToSend.get(0).getPlainTextBody().containsIgnoreCase('1 error'),
                'Failed to mark record in error.');
    }

    @IsTest static void testSetup() {
        BatchJobBaseMock batch;
        String cronSchedule = 'test';
        Integer batchJobCount = [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name='BatchJobBaseMock'];
        Test.startTest();
        batch = new BatchJobBaseMock();
        batch.setConfig(testConfig);

        BatchJobBaseMock.setup(batch, cronSchedule);
        Test.stopTest();
        // verify that batch job started
        System.assertEquals([SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name='BatchJobBaseMock'], batchJobCount+2,
                'Failed to successfully start Staging Batch Job');
    }

    @IsTest
    static void testBadQueryFilter() {
        BatchJobBaseMock batch = new BatchJobBaseMock();
        batch.blnReturnInvalidQuery = true;
        Test.startTest();
        try {
            batch.start(null);
            System.assert(false);
        } catch (Exception exc) {
            System.assert(true);
        }
        Test.stopTest();
    }

    @IsTest
    private static void manuallyFilterRecords() {
        BatchJobBaseMock batch = new BatchJobBaseMock();
        Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id FROM Account]);
        Test.startTest();
        List<SObject> records = batch.manuallyFilterRecords(mapAccounts.keySet());
        System.assertEquals(records, mapAccounts.values(), 'Failed to return expected records');
        batch.manuallyProcessRecords(records);
        Test.stopTest();
        System.assertEquals(true, BatchJobBaseMock.blnExecuteInvoked, 'Failed to invoke batch job logic when manually provided record ids');
    }
    private static final Batch_Job_Config__mdt testConfig = new Batch_Job_Config__mdt(DeveloperName='Test BatchJobConfig',
            Is_Active__c=true, Apex_Batch_Class_Name__c=BatchJobConstants.BATCH_JOB_BASE_MOCK_CLASS_NAME, Batch_Size__c=100,
            Query_Filter__c='Name=\'' + TEST_ACCOUNT_NAME + '\'',
            Cron_Job_Schedule__c='0 0 0 * ?', Status_Email_Group_Name__c='Batch_Status_Email_Group');
}
