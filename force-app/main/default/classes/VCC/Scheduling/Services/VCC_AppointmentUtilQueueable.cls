/**
 * @author Booz Allen Hamilton
 * @since 5/23/24
 * @description Queueable for VCC_AppointmentUtilizationService - class that runs on a schedule to generate Daily
 *  Appointment Utilization records for a given Date Range. The set of Provider(s) is all Providers across
 *  all VISNs.
 *
 *  Due to a SF limitation with serializing QueryLocator object, we have built our own flavor of it. The plan is to
 *  eventually replace it with the (currently Beta) SF Apex Cursors feature
 *  https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta.%20%20/apexcode/apex_cursors.htm
 *
 *
 *  LIMITATION: For 1st release, date range will be limited to 1 months worth of utilization data.
 *
 * @see VTC_BaseQueueable
 * @see VCC_AppointmentUtilizationService
 * @see VCC_AppointmentUtilQueueableTest
 *
 * Suppressing warning for Class Naming Conventions since it is complaining about our inner class
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_AppointmentUtilQueueable extends VTC_BaseQueueable implements Queueable {
    private VCC_AppointmentUtilQueueableService service;
    private VCC_Appointment_Utilization_Config__mdt config;

    @TestVisible
    private static VCC_AppointmentUtilQueueableService memoizedService {
        get {
            if (memoizedService == null) {
                memoizedService = new VCC_AppointmentUtilQueueableService();
            }
            return memoizedService;
        }
        set;
    }

    /**
     * @description Default constructor - create a queueable instance to iterate over the last 31 days worth of
     *  Appointments for all active VISNs and their providers in the system
     */
    public VCC_AppointmentUtilQueueable() {
        this(new List<ServiceTerritory>(), null, null);
    }

    /**
     * @description Constructor overloading that accepts a single VISN and no Dates - defaults to past 31 days.
     *
     * @param visnName `String` containing Name of VISN (ServiceTerritory) to run metrics on
     */
    public VCC_AppointmentUtilQueueable(String visnName) {
        this(new List<String>{ visnName });
    }

    /**
     * @description Constructor overloading that accepts a list of VISN names and no Dates - defaults to past 31 days.
     *
     * @param visnNames `List<String>` List of String(s), one for each VISN for which we
     *  are to calculate appointment utilization metrics for past days (defaulting to 31 days of data)
     */
    public VCC_AppointmentUtilQueueable(List<String> visnNames) {
        this(visnNames, null, null);
    }

    /**
     * @description Constructor overloading that accepts a list of VISN names & no Dates - defaults to past 31 days.
     *
     * @param visnNames `List<String>` List of String(s), one for each VISN for which we
     *  are to calculate appointment utilization metrics for given date range (endDate - startDate)
     * @param startDate Date to start (inclusive) calculation of appointment utilization metrics
     * @param endDate Date to end (inclusive) calculation of appointment utilization metrics
     */
    public VCC_AppointmentUtilQueueable(List<String> visnNames, Date startDate, Date endDate) {
        this.service = memoizedService;
        this.config = VCC_Appointment_Utilization_Config__mdt.getAll().values()[0];
        startDate = this.initializeStartDate(startDate);
        endDate = this.initializeEndDate(startDate, endDate);
        this.service.setConfig(this.config);
        this.service.fetchData(new AppointmentUtilizationData(visnNames, startDate, endDate));
        this.passthrough = this.service;
    }

    /**
     * @description Constructor overloading that accepts a single VISN and no Dates - defaults to past 31 days.
     *
     * @param visn VISN for which we are to calculate appointment utilization metrics for past 31 days
     */
    public VCC_AppointmentUtilQueueable(ServiceTerritory visn) {
        this(new List<ServiceTerritory>{ visn }, null, null);
    }

    /**
     * @description Create a Queueable instance to iterate over ALL VISNs for the given startDate to endDate timeframe.
     *  NOTE: If time elapsed between startDate to endDate (inclusive) is greater than the Maximum # of Days (31), we
     *  default to 31 days. The data is aggregated for a Day period.
     *
     * @param visns List of VISNs for which we are to calculate appointment utilization metrics
     * @param startDate Date to start (inclusive) calculation of appointment utilization metrics
     * @param endDate Date to end (inclusive) calculation of appointment utilization metrics
     */
    public VCC_AppointmentUtilQueueable(List<ServiceTerritory> visns, Date startDate, Date endDate) {
        this.service = memoizedService;
        this.config = VCC_Appointment_Utilization_Config__mdt.getAll().values()[0];
        startDate = this.initializeStartDate(startDate);
        endDate = this.initializeEndDate(startDate, endDate);
        this.service.setConfig(this.config);
        AppointmentUtilizationData data = new AppointmentUtilizationData(visns, startDate, endDate);
        this.service.fetchData(data);
        this.passthrough = this.service;
    }

    /**
     * @description Create a Queueable instance to iterate over ALL VISNs for the given startDate to endDate timeframe.
     *  NOTE: If time elapsed between startDate to endDate (inclusive) is greater than the Maximum # of Days (31), we
     *  default to 31 days. The data is aggregated for a Day period.
     *
     * @param startDate Date to start (inclusive) collection of appointment utilization metrics
     * @param endDate Date to end (inclusive) collection of appointment utilization metrics
     */
    public VCC_AppointmentUtilQueueable(Date startDate, Date endDate) {
        // get All ServiceTerritories as no VISN was given
        this(new List<ServiceTerritory>(), startDate, endDate);
    }

    /**
     * @description this method is called by VTC_BaseQueueable & its Finalizer to
     *  determine  whether or not to re-enqueue our Queueable.
     *
     * @return Boolean True if the exit criteria has been met.
     */
    public override Boolean hasExitCriteriaBeenMet() {
        return this.service.hasExitCriteriaBeenMet();
    }

    /**
     * @description This is called to execute business logic on each iteration of the Ouroboros (queueable)
     */
    public override void execute() {
        try {
            // if we have passthrough data, it means this is not the first iteration
            if (this.passthrough != null) {
                this.service = (VCC_AppointmentUtilQueueableService) this.passthrough;
                memoizedService = this.service;
            }
            this.service.execute();
        } catch (Exception unexpectedProblem) {
            // log the problem & exit. In the future, we may want to consider adding re-try logic
            Logger.error('Unexpected exception thrown when generating Utilization Metrics. ', unexpectedProblem);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Initialize our Start & End Date if not already provided/set. Defaults to past Max_Number_of_Days_to_Process__c days
     *  specified by VCC Appointment Config metadata
     *
     * @param startDate Date to start collecting metrics. If null, use configured Max # of Days to Process
     * @param endDate Date to end collecting metrics.  If null, end on Today.
     * @return `Date` Date that is either the given endDate or is startDate + Maximum # of Days to Process
     *  if endDate is too far in the future or is null
     */
    private Date initializeEndDate(Date startDate, Date endDate) {
        Integer maxNumberOfDaysToProcess = Integer.valueOf(this.config.Max_Number_of_Days_to_Process__c);
        if (endDate == null) {
            endDate = Date.today();
        }
        // make sure we are not iterating over more than the maximum # of dates
        if (startDate.daysBetween(endDate) > maxNumberOfDaysToProcess) {
            endDate = startDate.addDays(maxNumberOfDaysToProcess);
        }
        return endDate;
    }

    /**
     * @description Initialize our Start & End Date if not already provided/set. Defaults to past Max_Number_of_Days_to_Process__c days
     *  specified by VCC Appointment Config metadata
     *
     * @param startDate Date to start collecting metrics. If null, use configured Max # of Days to Process
     * @return `Date` Date that is either the given startDate if it is null or it is Maximum # of Days to Process
     *      in arrears so if Max # is 31, it will return 31 days ago (ie Today = June 1, returns startDate = May 1)
     */
    private Date initializeStartDate(Date startDate) {
        Integer maxNumberOfDaysToProcess = Integer.valueOf(this.config.Max_Number_of_Days_to_Process__c);
        if (startDate == null) {
            startDate = Date.today().addDays(-1 * maxNumberOfDaysToProcess);
        }
        return startDate;
    }

    /**
     * @description Class to hold data required for calculating Utilization metrics for input values.
     */
    public class AppointmentUtilizationData {
        public List<Id> visnIds = new List<Id>();
        public List<String> visnNames = new List<String>();
        public Date startDate;
        public Date endDate;

        /**
         * @description Construct an instance of the data class to hold values when querying by visns
         * @param visnsToProcess `List<ServiceTerritory>` List of VISNs by which to query ServiceTerritoryMembers
         * @param startDateForMetrics `Date` Start Date for collecting metrics
         * @param endDateForMetrics `Date` End Date for collecting metrics
         */
        public AppointmentUtilizationData(
            List<ServiceTerritory> visnsToProcess,
            Date startDateForMetrics,
            Date endDateForMetrics
        ) {
            if (visnsToProcess != null && !visnsToProcess.isEmpty()) {
                for (ServiceTerritory visn : visnsToProcess) {
                    this.visnIds.add(visn.Id);
                }
            }
            this.startDate = startDateForMetrics;
            this.endDate = endDateForMetrics;
        }

        /**
         * @description Construct an instance of the data class to hold values when querying by visnNames
         * @param visnNamesToProcess `List<String>` List of VISN names by which to query ServiceTerritoryMembers
         * @param startDateForMetrics `Date` Start Date for collecting metrics
         * @param endDateForMetrics `Date` End Date for collecting metrics
         */
        public AppointmentUtilizationData(
            List<String> visnNamesToProcess,
            Date startDateForMetrics,
            Date endDateForMetrics
        ) {
            this.visnNames = new List<String>(visnNamesToProcess);
            this.startDate = startDateForMetrics;
            this.endDate = endDateForMetrics;
        }

        /**
         * @description Return the VISN data to be used in querying our records. We are either querying by VISN Names,
         *  VISN Ids, or all VISNs depending on how instance was constructed.
         *
         * @return `Object` Returns data structure containing VISN data to query as follows
         *  by VISN Names: `List<String>`
         *  by VISN Ids: `List<Id>`
         *  all VISNs: `null`
         */
        public Object getVisnData() {
            if (doQueryByIds()) {
                return this.visnIds;
            } else if (!this.visnNames.isEmpty()) {
                return this.visnNames;
            } else {
                return null;
            }
        }

        /**
         * @description Determine if we are querying for records based on visnIds
         *
         * @return `Boolean`  true if we have VISN Ids to query by, false otherwise (query by VISN Names or nothing to fetch all VISNs)
         */
        public Boolean doQueryByIds() {
            return !this.visnIds.isEmpty();
        }
    }
}
