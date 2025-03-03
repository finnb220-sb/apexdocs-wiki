/**
 * @description Class that handles the unit test schedule for updating the appointment slot utilization records.
 * @author Booz Allen
 */
@IsTest
private class VCC_AppointmentSlotUtilScheduleTest {
    private static VCC_AppointmentSlotUtilSchedule appointmentSlotUtilSchedule;
    private static final String DEFAULT_CRON_EXPRESSION = '0 0 1 * * ?';
    /**
     * @description Test method to validate proper instantiation of the VCC_AppointmentSlotUtilSchedule class.
     * Positive test case.
     */
    @IsTest
    static void funcTestVCCAppointmentSlotUtilSchedulePositive() {
        Test.startTest();
        appointmentSlotUtilSchedule = new VCC_AppointmentSlotUtilSchedule(null);
        Test.stopTest();
        Assert.isTrue(
            appointmentSlotUtilSchedule != null,
            'Expected an instance of VCC_AppointmentSlotUtilSchedule to be created.'
        );
    }

    /**
     * @description Test method to validate the schedule job method.
     * Static method that schedules a job to run the execute method of the VCC_AppointmentSlotUtilSchedule class.
     * Positive test case.
     */
    @IsTest
    static void funcTestScheduleJobPositive() {
        String cronTriggerId = null;
        Test.startTest();
        cronTriggerId = VCC_AppointmentSlotUtilSchedule.scheduleJob();
        Test.stopTest();
        Assert.areNotEqual(
            null,
            cronTriggerId,
            'Expected cronTriggerId to not be null when a job is scheduled from the method scheduleJob.'
        );
    }

    /**
     * @description Test method to validate the unschedule job method.
     * Static method that unschedules a job based on the cronTriggerId passed.
     * Positive test case.
     */
    @IsTest
    static void funcTestUnscheduleJobPositive() {
        Test.startTest();
        String cronTriggerId = VCC_AppointmentSlotUtilSchedule.scheduleJob();
        String message = VCC_AppointmentSlotUtilSchedule.unscheduleJob(cronTriggerId);
        Test.stopTest();
        Assert.areNotEqual(
            null,
            message,
            'A message indicating the job was unscheduled should be returned from the method unscheduleJob.'
        );
    }

    /**
     * @description Test method to validate the execute method.
     * Counting that the number of AsyncApexJob records increases after the execute method is called.
     * Positive test case.
     */
    @IsTest
    static void funcTestExecutePositive() {
        Integer initialCount = [SELECT COUNT() FROM AsyncApexJob];
        Boolean isExceptionThrown = false;
        appointmentSlotUtilSchedule = new VCC_AppointmentSlotUtilSchedule(null);
        try {
            Test.startTest();
            appointmentSlotUtilSchedule.execute(null);
            Test.stopTest();
        } catch (Exception genericException) {
            isExceptionThrown = true;
        }
        Assert.isFalse(
            isExceptionThrown,
            'No exception should have been thrown from the execute method of VCC_AppointmentSlotUtilSchedule when passing a null schedulableContext.'
        );
        Integer finalCount = [SELECT COUNT() FROM AsyncApexJob];
        Assert.isTrue(
            finalCount > initialCount,
            'Expected the number of AsyncApexJob records to increase after initiating the execute method on VCC_AppointmentSlotUtilSchedule Class.'
        );
    }

    /**
     * @description Test method to validate the cron expression is proper input.
     * Passing a proper cron expression will have the class compile and run without error.
     * If the expression is proper the expression passed will be used to schedule the job.
     * Otherwise the default cron expression will be used.
     * Positive test case.
     */
    @IsTest
    static void funcTestArgumentConstructorCronExpressionPositive() {
        Boolean isExceptionThrown = false;
        String jobId = null;
        String cronExpression = '0 0 0 15 3 ?';
        Integer batchSize = null;
        try {
            Test.startTest();
            jobId = VCC_AppointmentSlotUtilSchedule.scheduleJob(cronExpression, batchSize);
            Test.stopTest();
        } catch (Exception genericException) {
            isExceptionThrown = true;
        }
        CronTrigger cronTrigger = [SELECT Id, CronTrigger.CronExpression FROM CronTrigger WHERE Id = :jobId];
        Assert.isFalse(
            isExceptionThrown,
            'No exception should have been thrown from null value passed as parameter to VCC_AppointmentSlotUtilSchedule constructor.'
        );
        Assert.areEqual(
            cronExpression,
            cronTrigger.CronExpression,
            'Expected the cron expression to be set to the value passed to the constructor.'
        );
    }

    /**
     * @description Test method validate the cron expression is proper input.
     * Passing an improper cron expression will have the class compile and run without error.
     * If the expression is improper the default cron expression will be used.
     * Negative test case.
     */
    @IsTest
    static void funcTestArgumentConstructorCronExpressionNegative() {
        Boolean isExceptionThrown = false;
        String jobId = null;
        String cronExpression = null;
        Integer batchSize = 100;
        try {
            Test.startTest();
            jobId = VCC_AppointmentSlotUtilSchedule.scheduleJob(cronExpression, batchSize);
            Test.stopTest();
        } catch (Exception genericException) {
            isExceptionThrown = true;
        }
        CronTrigger cronTrigger = [SELECT Id, CronTrigger.CronExpression FROM CronTrigger WHERE Id = :jobId];
        Assert.isFalse(
            isExceptionThrown,
            'No exception should have been thrown from improper values passed to the constructor of VCC_AppointmentSlotUtilSchedule.'
        );
        Assert.areEqual(
            cronTrigger.CronExpression,
            DEFAULT_CRON_EXPRESSION,
            'Expected the cron expression to be set to the default value when passing an invalid value.'
        );
    }
}
