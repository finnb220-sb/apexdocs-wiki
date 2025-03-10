/**
 * Name: BatchJobSchedulingMgr
 * @author Brenda Finn
 * @date 11/14/21
 * 
 * @description Class that controls whether an automated job should run making use of custom
 * metadata with configuration values so it can be controlled declaratively
 *
 * @group Batch Framework
 * @see BatchJobSchedulingMgrTest
 */
public with sharing class BatchJobSchedulingMgr {
    @TestVisible private static List<Do_Not_Run_Automations_Day__mdt> testConfigs;
    @TestVisible private static Date testDate;
    @TestVisible private static List<Batch_Job_Config__mdt> testBatchJobConfigs;
    public static String defaultAutomationType;

    private Map<String, Batch_Job_Config__mdt> batchJobConfigs = new Map<String, Batch_Job_Config__mdt>();
    private Map<String, List<Do_Not_Run_Automations_Day__mdt>> configs;
    private static BatchJobSchedulingMgr singleton; // singleton instance

    /**
     * @description Private constructor - singleton class
     */
    private BatchJobSchedulingMgr() {
        configs = new Map<String, List<Do_Not_Run_Automations_Day__mdt>>();
        List<Do_Not_Run_Automations_Day__mdt> lstConfigs = Do_Not_Run_Automations_Day__mdt.getAll().values();
        if (Test.isRunningTest() && testConfigs != null) {
            lstConfigs = testConfigs;
        }
        for (Do_Not_Run_Automations_Day__mdt doNotRunConfig : lstConfigs) {
            if (!doNotRunConfig.Is_Active__c) {
                continue; // do not use this configuration
            }
            if (configs.get(doNotRunConfig.Automation_Type__c) == null) {
                configs.put(doNotRunConfig.Automation_Type__c, new List<Do_Not_Run_Automations_Day__mdt>());
            }
            configs.get(doNotRunConfig.Automation_Type__c).add(doNotRunConfig);
        }

        List<Batch_Job_Config__mdt> lstBatchConfigs = Batch_Job_Config__mdt.getAll().values();
        if (Test.isRunningTest() && testBatchJobConfigs != null) {
            lstBatchConfigs = testBatchJobConfigs;
        }

        for (Batch_Job_Config__mdt batchJobConfig : lstBatchConfigs) {
            batchJobConfigs.put(batchJobConfig.DeveloperName, batchJobConfig);
        }
    }

    /**
     * @description Return the singleton instance of this class.
     *
     * @return Instance to use for determining if job should be run today
     */
    public static BatchJobSchedulingMgr instance() {
        if (singleton == null) {
            singleton = new BatchJobSchedulingMgr();
        }
        return singleton;
    }

    /**
     * @description For all currently active Batch Job Config metadata records, start the
     *  batch job on the specified schedule
     */
    public void startJobs() {
        // for each active batch job configuration, start the job with the specified config
        for (String configName : batchJobConfigs.keySet()) {
            startJob(configName, false);
        }
    }

    /**
     * @description Process the given records with the the batch job with configuration specified in batchJobConfigName
     *  without running a Batch but rather just directly processing the records by the worker/service class
     *
     * @param batchJobConfigName Developer Name for a Batch_Job_Config metadata record containing
     *  configuration details for job to be scheduled/started.
     *  @param recordIds Set of record ids to process - further filters records being processed
     *      to allow for controlling data set during testing.
     */
    public void manualProcess(String batchJobConfigName, Set<Id> recordIds) {
        try {
            Batch_Job_Config__mdt batchJobConfig = batchJobConfigs.get(batchJobConfigName);
            Type batchJobClass = Type.forName(batchJobConfig.Apex_Batch_Class_Name__c);
            BatchJobBase batchJob = (BatchJobBase)batchJobClass.newInstance();
            batchJob.setConfig(batchJobConfig);
            batchJob.manuallyProcessRecords(batchJob.manuallyFilterRecords(recordIds));
        } catch (Exception exc) {
            String errorMsg = 'There was an error manually processing recordIds ' + JSON.serializePretty(recordIds) +
                    ' for batch job ' + batchJobConfigName;
	    // TODO: Add Process Log Framework call
	    System.debug('======> ' + errorMsg + ' : Exception Details = ' + exc);
        }
    }

    /**
     * @description Start the batch job with configuration specified in batchJobConfigName
     *
     * @param batchJobConfigName Developer Name for a Batch_Job_Config metadata record containing
     *  configuration details for job to be scheduled/started.
     *  @param blnSingleRun if true, kickoff a single one-off batch job run, otherwise schedule it
     */
    public void startJob(String batchJobConfigName, Boolean blnSingleRun) {
        try {
            Batch_Job_Config__mdt batchJobConfig = batchJobConfigs.get(batchJobConfigName);
            Type batchJobClass = Type.forName(batchJobConfig.Apex_Batch_Class_Name__c);
            BatchJobBase batchJob = (BatchJobBase)batchJobClass.newInstance();
            batchJob.setConfig(batchJobConfig);
            if (blnSingleRun) {
                batchJob.execute(null);
            } else {
                batchJob.setup(batchJobConfig.Cron_Job_Schedule__c);
            }
        } catch (Exception exc) {
            String errorMsg = 'There was an error starting batch job ' + batchJobConfigName;
	    // TODO: Add Process Log Framework
	    System.debug('======> ' + errorMsg + ': Exception Details = ' + exc);
        }
    }

    /**
     * @description Returns true or false to indicate if the default automation type provided
     *  should be run today based on the currently configured metadata records
     *
     * @return true if default automation is defined and should run today, false otherwise
     *   including if no default automation is provided
     */
    public Boolean doRunAutomation() {
        if (!String.isEmpty(defaultAutomationType)) {
            return doRunAutomation(defaultAutomationType);
        }
        return false; // default to not run the job if we do not know what job to run
    }

    /**
     * @description Returns true or false to indicate if the automation type provided should be run
     *  today based on the currently configured metadata records
     *
     * @param automationType type of automation - one of the P/L values from metadata type definition.
     *  Right now, only Suspension jobs are being managed
     *
     * @return true if automation should run, false otherwise
     */
    public Boolean doRunAutomation(String automationType) {
        Date runDate = Date.today();
        if (Test.isRunningTest() && testDate != null) {
            runDate = testDate;
        }
        String dayOfWeek =  Datetime.newInstance(runDate, Time.newInstance(0,0,0,0)).format('E');
        for (Do_Not_Run_Automations_Day__mdt config : configs.get(automationType)) {
            // Look at Start_Date__c and End_Date__c, Day_of_the_Week__c
            // day of week should be abbreviations: Mon, Tue, Wed, Thu, Fri, Sat, Sun
            if (config.Day_of_the_Week__c != BatchJobConstants.USE_START_DATE && config.Day_of_the_Week__c == dayOfWeek) {
                // if config is for this day of the week then do not run job
                return false;
            }
            if (config.End_Date__c == null && config.Start_Date__c == runDate) {
                // single-day exclusion - do not run job
                return false;
            }
            if (config.End_Date__c != null && config.Start_Date__c <= runDate && config.End_Date__c >= runDate) {
                return false;
            }
        }
        // if none of the rules apply, then no exclusions for this job and date so run now
        return true;
    }
}
