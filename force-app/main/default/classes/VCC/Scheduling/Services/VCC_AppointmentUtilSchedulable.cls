/**
 * @description Entry point for scheduling the VCC_AppointmentUtilQueueable class
 *  By default, the schedule is a Daily Midnight Job. It is defined by the
 *  VCC_Appointment_Utilization_Config__mdt custom metadata.
 *
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentUtilQueueable
 */
public with sharing class VCC_AppointmentUtilSchedulable implements Schedulable {
    @TestVisible
    private List<Id> visnIds = new List<Id>();
    @TestVisible
    private List<String> visnNames = new List<String>();

    @TestVisible
    private String schedule; // making it TestVisible so it can be DI from tests
    private static final String RUN_NIGHTLY_AT_MIDNIGHT = '0 0 0 * * ? *';

    /**
     * @description Create an instance of the Schedulable to enqueue our Queueable job setting up our default
     *  schedule with value from config record
     *
     * @param config `VCC_Appointment_Utilization_Config__mdt` custom metadata that defines our CRON schedule
     */
    public VCC_AppointmentUtilSchedulable(VCC_Appointment_Utilization_Config__mdt config) {
        if (config == null || config.Default_Cron_Schedule__c == null) {
            this.schedule = RUN_NIGHTLY_AT_MIDNIGHT;
        } else {
            this.schedule = config.Default_Cron_Schedule__c;
        }
    }

    /**
     * @description Run our default schedule for a given set of VISN Names
     *
     * @param visnNames `List<String>` List of VISN Names for which we should run job
     * @return `Id` Job Id for Scheduled job
     */
    public Id runDefaultSchedule(List<String> visnNames) {
        this.visnNames = visnNames;
        return System.schedule(
            'VCCAppointmentUtilQueueable VISN Names ' + Datetime.now().format(),
            this.schedule,
            this
        );
    }

    /**
     * @description Run our default schedule for a given set of VISN Ids
     *
     * @param visnIds `List<Id>` List of VISN Ids for which we should run job
     * @return `Id` Job Id for Scheduled job
     */
    public Id runDefaultSchedule(List<Id> visnIds) {
        this.visnIds = visnIds;
        return System.schedule('VCCAppointmentUtilQueueable VISN Ids ' + Datetime.now().format(), this.schedule, this);
    }

    /**
     * @description Run our default schedule - this will execute over all VISNs in the current user's
     *  timezone
     *  Provided for convenience and testing but not expected to be run in production - use one of the
     *  overloadings that provides VISN Names or VISN Ids
     *
     * @return `Id` Job Id for Scheduled job
     */
    public Id runDefaultSchedule() {
        return System.schedule(
            'VCCAppointmentUtilQueueable ALL VISNs in User Timezone ' + Datetime.now().format(),
            this.schedule,
            this
        );
    }

    /**
     * @description Run a one-time instance of job "now"
     *
     * @return `Id` Job Id for run now job
     */
    public Id runNow() {
        return System.enqueueJob(new VCC_AppointmentUtilQueueable(), 0);
    }

    /**
     * @description Start the Queueable job that is responsible for calculating Appointment Utilization records
     *
     * @param context System Schedulable Context
     */
    public void execute(SchedulableContext context) {
        if (!this.visnNames.isEmpty()) {
            System.enqueueJob(new VCC_AppointmentUtilQueueable(this.visnNames));
        } else if (!this.visnIds.isEmpty()) {
            System.enqueueJob(new VCC_AppointmentUtilQueueable(this.visnIds));
        } else {
            System.enqueueJob(new VCC_AppointmentUtilQueueable());
        }
    }
}
