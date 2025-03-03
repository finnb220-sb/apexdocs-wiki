/**
 * @description This class is to be scheduled to run on a nightly basis.
 * It exists and uses Callable interface to remove any hard dependancies
 * to the repos and other classes referenced in the ApptDataBatchDelete class.
 * Since this class does not have any hard dependancies, we will not get any
 * conflicts when the job is scheduled, except in a rare case this class itself
 * needs to be modified.
 * @author Booz Allen Hamilton
 * @see VCC_AppointmentDataBatchDelete
 * @see VCC_AppointmentDataSchedulableTest
 */
public class VCC_AppointmentDataSchedulable implements Schedulable {
    @TestVisible
    /**
     * @description Metadata to store class name as string for callable.
     * Number of hours and days can be adjusted, such as lower values for testing.
     * Boolean Run_Batch__c switch to turn batch job off temporarily but keep schedulable job running.
     * Note: This needs to be set within the execute method so that
     * it reflects the current values of the Custom Metadata. If it gets the metadata values
     * as a class level variable, it will only have the values when the job was originally scheduled.
     */
    private VCC_Appointment_Batch_Delete_Config__mdt batchParameters;

    /**
     * @description Default value to use if Custom Metadata is null.
     */
    private final static Integer DEFAULT_HOURS_PAST = 24;

    /**
     * @description Default value to use if Custom Metadata is null.
     */
    private final static Integer DEFAULT_DAYS_PAST = 7;

    /**
     * @description Default value to use if Custom Metadata is null.
     */
    private final static Integer DEFAULT_BATCH_SIZE = 2000;

    @TestVisible
    /**
     * @description List of the appointment data object names that we want to delete in the batch class.
     */
    private final static List<String> APPOINTMENT_OBJECTS = new List<String>{
        'VCC_Appointment__c',
        'VCC_AppointmentRequest__c'
    };

    /**
     * @description Required execute method to implement Schedulable.
     * Exits if Run_Batch is false in metadata.
     * Otherwise it populates a Map with values from metadata.
     * Uses callable to execute batch class.
     * Logs job Id if successful; logs error message if not successful.
     * @param sc - Required SchedulableContext for scheduled async job.
     */
    public void execute(SchedulableContext sc) {
        batchParameters = VCC_Appointment_Batch_Delete_Config__mdt.getInstance('Batch_Config');
        if (batchParameters.Run_Batch__c) {
            try {
                Map<String, Object> batchParams = setParameters();
                Callable automationJob = (Callable) Type.forName(batchParameters.Class_Name__c).newInstance();
                Object responseObj = automationJob.call('executeNewBatchJob', batchParams);
                String executeBatchResponse = (String) responseObj;
                Logger.info('Execute batch job result: ' + executeBatchResponse);
            } catch (VCC_AppointmentDataBatchDelete.AppointmentDataBatchDeleteException batchDeleteException) {
                Logger.error(batchDeleteException.getMessage());
            } finally {
                Logger.saveLog();
            }
        }
    }

    /**
     * @description Populates a Map based on metadata.
     * If metadata fields are blank, it assigns default values.
     * @return `Map<String, Object>` Populates a Map which is required parameter for callable.
     */
    private Map<String, Object> setParameters() {
        // default values
        Integer hoursPast = DEFAULT_HOURS_PAST;
        Integer daysPast = DEFAULT_DAYS_PAST;
        Integer batchSize = DEFAULT_BATCH_SIZE;
        // update based on metadata
        if (batchParameters.Number_of_Hours_for_Appts_and_Open_Reqs__c != null) {
            hoursPast = (Integer) batchParameters.Number_of_Hours_for_Appts_and_Open_Reqs__c;
        }
        if (batchParameters.Number_of_Days_for_Closed_Reqs__c != null) {
            daysPast = (Integer) batchParameters.Number_of_Days_for_Closed_Reqs__c;
        }
        if (batchParameters.Batch_Size__c != null) {
            batchSize = (Integer) batchParameters.Batch_Size__c;
            if (batchSize > 2000) {
                batchSize = DEFAULT_BATCH_SIZE;
            }
        }
        return new Map<String, Object>{
            'objectNames' => APPOINTMENT_OBJECTS,
            'numberOfHours' => hoursPast,
            'numberOfDays' => daysPast,
            'batchSize' => batchSize
        };
    }
}
