/**
 * @description class is used to schedule the batch job to run at a specific time
 * @author Booz Allen
 */
public without sharing class VCC_AppointmentSlotUtilSchedule implements Schedulable {
    private static final String REGEX_PATTERN = '^((((\\d+,)+\\d+|(\\d+(\\/|-|#)\\d+)|\\d+L?|\\*(\\/\\d+)?|L(-\\d+)?|\\?|[A-Z]{3}(-[A-Z]{3})?) ?){5,7})$';
    private static final String DEFAULT_CRON_EXPRESSION = '0 0 1 * * ?';
    private static final Integer DEFAULT_BATCH_SIZE = 200;
    private static final String JOB_PREFIX = 'VCC_AppointmentSlotUtilScheduleJob';
    private static final String JOB_VERSION = '20240405Revision1';
    private static final Long DATETIME_NOW_TIME = Datetime.now().getTime();
    private static final String JOB_NAME = JOB_PREFIX + JOB_VERSION + DATETIME_NOW_TIME;
    @TestVisible
    private static VCC_AppointmentSlotUtilBatch batch = new VCC_AppointmentSlotUtilBatch();
    private Integer batchSize;
    /**
     * @description constructor to create a new instance of the class
     * @param batchSize - the number of records to process in a single batch
     */
    public VCC_AppointmentSlotUtilSchedule(Integer batchSize) {
        this.batchSize = (batchSize != null && batchSize > 0 && batchSize <= 200) ? batchSize : DEFAULT_BATCH_SIZE;
    }

    /**
     * @description method to validate the cron expression
     * @param expr - the cron expression to validate
     * @return boolean - true if the cron expression is valid, false otherwise
     */
    private static Boolean isValidCronExpression(String expr) {
        if (String.isEmpty(expr)) {
            return false;
        }
        Pattern cronPattern = Pattern.compile(REGEX_PATTERN);
        Matcher cronMatcher = cronPattern.matcher(expr);
        return cronMatcher.matches();
    }

    /**
     * @description method to execute the batch job
     * @param schedulableContext - the context in which the job is scheduled
     */
    public void execute(SchedulableContext schedulableContext) {
        Database.executeBatch(batch, batchSize);
    }

    /**
     * @description method to schedule the job
     * @return String - the job ID
     */
    public static String scheduleJob() {
        return System.schedule(
            JOB_NAME,
            DEFAULT_CRON_EXPRESSION,
            new VCC_AppointmentSlotUtilSchedule(DEFAULT_BATCH_SIZE)
        );
    }

    /**
     * @description method to unschedule the job
     * @param jobId - the ID of the job to unschedule
     * @return String - the status of the job
     */
    public static String unscheduleJob(String jobId) {
        System.abortJob(jobId);
        return 'Job Unscheduled: ' + JOB_NAME + ' with ID: ' + jobId;
    }

    /**
     * @description Schedules the job based on the provided cron expression and batch size.
     * @param inputCronExpression The cron expression determining the schedule frequency.
     * @param batchSize The size of the data batch to be processed at each job execution.
     * @return The Id of the scheduled job.
     */
    public static String scheduleJob(String inputCronExpression, Integer batchSize) {
        String cronExpression = isValidCronExpression(inputCronExpression)
            ? inputCronExpression
            : DEFAULT_CRON_EXPRESSION;
        return System.schedule(JOB_NAME, cronExpression, new VCC_AppointmentSlotUtilSchedule(batchSize));
    }
}
