/**
 * @description test class that handles the batch logic for updating the appointment slot utilization records.
 * VCC_AppointmentSlotUtilBatch is the implementation class and this class performs the unit tests for it.
 * @author Booz Allen
 * @see VCC_AppointmentSlotUtilBatch
 */
@IsTest
private class VCC_AppointmentSlotUtilBatchTest {
    private static String apexJobId;
    private static VCC_AppointmentSlotUtilBatch vccBatch = new VCC_AppointmentSlotUtilBatch();

    /**
     * @description functional test for the start method.
     * Positive test case.
     */
    @IsTest
    static void funcTestStartPositive() {
        Test.startTest();
        Database.BatchableContext batchableContext;
        Database.QueryLocator queryLocator = vccBatch.start(batchableContext);
        Test.stopTest();
        Assert.areNotEqual(null, queryLocator, 'QueryLocator should not be null');
    }

    /**
     * @description functional test for the execute method.
     * Positive test case, testing that the asyncapexjob was created.
     */
    @IsTest
    static void funcTestExecutePositive() {
        Test.startTest();
        Id jobId = Database.executeBatch(vccBatch);
        Test.stopTest();
        VCR_AsyncApexJobRepo repo = new VCR_AsyncApexJobRepo();
        AsyncApexJob job = repo.getAsyncApexJobById(jobId);
        apexJobId = job.Id;
        Assert.isNotNull(apexJobId, 'Job should have been created');
    }

    /**
     * @description testing that the batch process finishes without errors.
     * By retrieving the job and checking that the status is 'Completed'.
     *
     */
    @IsTest
    static void funcTestBatchOnCompletionPositive() {
        Test.startTest();
        Id jobId = Database.executeBatch(vccBatch);
        Test.stopTest();
        VCR_AsyncApexJobRepo repo = new VCR_AsyncApexJobRepo();
        AsyncApexJob job;
        job = repo.getAsyncApexJobById(jobId);
        Assert.areEqual(job.Status, 'Completed', 'Job should have been completed');
    }

    /**
     * @description unit test getAsyncApexJobById method.
     * Positive test case.
     */
    @IsTest
    static void unitTestGetAsyncApexJobByIdPositve() {
        AsyncApexJob testUtil = (AsyncApexJob) VATEST_SObjectFactory.createSObject(new AsyncApexJob());
        Id jobId = testUtil.Id;
        VCR_AsyncApexJobRepo stubUtilRepo = (VCR_AsyncApexJobRepo) new VATEST_StubBuilder(VCR_AsyncApexJobRepo.class)
            .mockingMethodCall('getAsyncApexJobById', String.class)
            .withParameterValues(jobId)
            .returning(testUtil)
            .defineStub();
        VCC_AppointmentSlotUtilBatch.asyncApexJobRepo = stubUtilRepo;
        Test.startTest();
        AsyncApexJob result = VCC_AppointmentSlotUtilBatch.getAsyncApexJobById(jobId);
        Test.stopTest();
        Assert.areEqual(
            testUtil,
            result,
            'Expected getAsyncApexJobById to return the mocked apex async job that was created in the test'
        );
    }

    /**
     * @description unit test getAsyncApexJobById method.
     * Negative test case, testing that the method returns null.
     */
    @IsTest
    static void unitTestGetAsyncApexJobByIdNegative() {
        AsyncApexJob testUtil = (AsyncApexJob) VATEST_SObjectFactory.createSObject(new AsyncApexJob());
        Id jobId = testUtil.Id;
        VCR_AsyncApexJobRepo stubUtilRepo = (VCR_AsyncApexJobRepo) new VATEST_StubBuilder(VCR_AsyncApexJobRepo.class)
            .mockingMethodCall('getAsyncApexJobById', String.class)
            .withParameterValues(jobId)
            .returning(null)
            .defineStub();
        VCC_AppointmentSlotUtilBatch.asyncApexJobRepo = stubUtilRepo;
        Test.startTest();
        AsyncApexJob result = VCC_AppointmentSlotUtilBatch.getAsyncApexJobById(jobId);
        Test.stopTest();
        Assert.areEqual(null, result, 'ApexSyncJob should be null');
    }

    /**
     * @description unit test getAsyncApexJobById method.
     * Negative test case, testing that the method throws an exception.
     */
    @IsTest
    static void unitTestGetAsyncApexJobByIdRepoThrowsAnErrorNegative() {
        AsyncApexJob testUtil = (AsyncApexJob) VATEST_SObjectFactory.createSObject(new AsyncApexJob());
        Id jobId = testUtil.Id;
        VCR_AsyncApexJobRepo stubUtilRepo = (VCR_AsyncApexJobRepo) new VATEST_StubBuilder(VCR_AsyncApexJobRepo.class)
            .mockingMethodCall('getAsyncApexJobById', String.class)
            .withParameterValues(jobId)
            .throwingException()
            .defineStub();
        VCC_AppointmentSlotUtilBatch.asyncApexJobRepo = stubUtilRepo;
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            VCC_AppointmentSlotUtilBatch.getAsyncApexJobById(jobId);
        } catch (HandledException handledException) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected VCC_AppointmentSlotUtilBatch to catch exception and rethrow as type HandledException.'
        );
    }

    /**
     * @description unit test getAppointmentScheduleAggrStringAll method.
     * Positive test case, testing that the query string is returned.
     */
    @IsTest
    static void unitTestGetAppointmentScheduleAggrStringAllPositive() {
        String query = 'SELECT Id FROM AppointmentScheduleAggr';
        VCR_AppointmentScheduleAggrRepo stubRepo = (VCR_AppointmentScheduleAggrRepo) new VATEST_StubBuilder(
                VCR_AppointmentScheduleAggrRepo.class
            )
            .mockingMethodCall('getAppointmentScheduleAggrAllQueryString')
            .withParameterTypes()
            .returning(query)
            .defineStub();
        VCC_AppointmentSlotUtilBatch.appointmentScheduleAggrRepo = stubRepo;
        Test.startTest();
        String result = VCC_AppointmentSlotUtilBatch.getAppointmentScheduleAggrStringAll();
        Test.stopTest();
        Assert.areEqual(
            query,
            result,
            'Query should be equal to the returned query string from the stub repo method getAppointmentScheduleAggrAllQueryString.'
        );
    }

    /**
     * @description unit test getAppointmentScheduleAggrStringAll method.
     * Negative test case, testing that the query string is null.
     */
    @IsTest
    static void unitTestGetAppointmentScheduleAggrStringAllNegative() {
        VCR_AppointmentScheduleAggrRepo stubRepo = (VCR_AppointmentScheduleAggrRepo) new VATEST_StubBuilder(
                VCR_AppointmentScheduleAggrRepo.class
            )
            .mockingMethodCall('getAppointmentScheduleAggrAllQueryString')
            .withParameterTypes()
            .returning(null)
            .defineStub();
        VCC_AppointmentSlotUtilBatch.appointmentScheduleAggrRepo = stubRepo;
        Test.startTest();
        String result = VCC_AppointmentSlotUtilBatch.getAppointmentScheduleAggrStringAll();
        Test.stopTest();
        Assert.areEqual(null, result, 'Query should be null');
    }

    /**
     * @description unit test getAppointmentScheduleAggrStringAll method.
     * Negative test case, testing that the method throws an exception.
     */
    @IsTest
    static void unitTestGetAppointmentScheduleAggrStringRepoThrowsExceptionNegative() {
        VCR_AppointmentScheduleAggrRepo stubRepo = (VCR_AppointmentScheduleAggrRepo) new VATEST_StubBuilder(
                VCR_AppointmentScheduleAggrRepo.class
            )
            .mockingMethodCall('getAppointmentScheduleAggrAllQueryString')
            .withParameterTypes()
            .throwingException()
            .defineStub();
        VCC_AppointmentSlotUtilBatch.appointmentScheduleAggrRepo = stubRepo;
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            VCC_AppointmentSlotUtilBatch.getAppointmentScheduleAggrStringAll();
        } catch (HandledException handledExcept) {
            exceptionThrown = true;
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected VCC_AppointmentSlotUtilBatch to catch thrown exception and rethrow as type HandledException.'
        );
    }
}
