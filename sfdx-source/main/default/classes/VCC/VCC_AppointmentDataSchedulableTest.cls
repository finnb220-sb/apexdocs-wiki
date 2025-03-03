/**
 * @description Test class for VCC_AppointmentDataSchedulable
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentDataSchedulable
 */
@IsTest
private class VCC_AppointmentDataSchedulableTest {
    final static User ADMIN = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);
    private static final VCC_Appointment_Batch_Delete_Config__mdt TEST_CONFIG;

    static {
        TEST_CONFIG = new VCC_Appointment_Batch_Delete_Config__mdt(
            Class_Name__c = 'VCC_AppointmentDataBatchDelete',
            Run_Batch__c = true,
            Number_of_Hours_for_Appts_and_Open_Reqs__c = 24,
            Number_of_Days_for_Closed_Reqs__c = 7,
            Batch_Size__c = 2000
        );
    }

    /**
     * @description Test to confirm a job is scheduled using the TEST_CONFIG custom metadata.
     */
    @IsTest
    private static void funcSchedulablePositive() {
        VCC_AppointmentDataSchedulable schedulableInstance = new VCC_AppointmentDataSchedulable();
        schedulableInstance.batchParameters = TEST_CONFIG;
        String jobName = 'VCC_AppointmentDataBatchDelete';
        String cronExpression = '0 0 1 * * ?';

        Test.startTest();
        System.runAs(ADMIN) {
            System.schedule(jobName, cronExpression, schedulableInstance);
        }
        Test.stopTest();

        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        Assert.areEqual(
            1,
            scheduledJobs.size(),
            'Expected one job to be scheduled from System.schedule but observed a different result.'
        );
    }
}
