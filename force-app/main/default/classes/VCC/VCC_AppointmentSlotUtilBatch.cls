/**
 * @description This class is responsible for starting the processing of the batchable job for updating the appointment slot utilization records.
 * @author Booz Allen
 * VCC_AppointmentSlotUtilLogic is the implementation class and this batch implements it.
 *
 * @see VCC_AppointmentSlotUtilLogic
 * @see VCC_AppointmentSlotUtilSchedule
 */
public class VCC_AppointmentSlotUtilBatch implements Database.Batchable<SObject> {
    /**
     * @description set the instance of VCC_AppointmentSlotUtilLogic for use in the batch class.
     */
    @TestVisible
    private VCC_AppointmentSlotUtilLogic appointmentSlotUtilLogic = new VCC_AppointmentSlotUtilLogic();

    /**
     * @description is a private static class variable of type `VCR_AsyncApexJobRepo`.
     * The variable is lazily initialized in the getter method.
     * There is also a setter method for this variable.
     */
    @TestVisible
    private static VCR_AsyncApexJobRepo asyncApexJobRepo {
        get {
            if (asyncApexJobRepo == null) {
                asyncApexJobRepo = new VCR_AsyncApexJobRepo();
            }
            return asyncApexJobRepo;
        }
        set;
    }

    /**
     * @description test visible private static repository instance of VCR_AppointmentScheduleAggrRepo.
     * This instance is lazy-loaded, i.e., it is created only upon accessing the getter method when it is null,
     * and thereafter the same instance is returned each time the getter method is accessed.
     */
    @TestVisible
    private static VCR_AppointmentScheduleAggrRepo appointmentScheduleAggrRepo {
        get {
            if (appointmentScheduleAggrRepo == null) {
                appointmentScheduleAggrRepo = new VCR_AppointmentScheduleAggrRepo();
            }
            return appointmentScheduleAggrRepo;
        }
        set;
    }

    /**
     * @description This public method is responsible for starting the processing of the batchable job.
     * The method gets the list of appointment slot utilization records
     * and Appointment Schedule records to iterate over.
     * The method uses the repository to retrieve a query string that represents
     * all aggregate appointment schedule records, and then constructs a
     * QueryLocator object from the string which will be used to handle the records.
     * @param batchableContext Represents the parameter related to Database.BatchableContext, which allows to interface with the Lightning platform batch job and scheduling infrastructure.
     * @return Returns a QueryLocator object due to the fact that it can be iterated over to handle query results.
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return appointmentScheduleAggrRepo.getQueryLocator(getAppointmentScheduleAggrStringAll());
    }

    /**
     * @description public method is responsible for processing the appointment slot utilization records
     * and updating the appointment schedule records.
     * The method executes within a Database Batchable Context, and it primarily deals with lists
     * of AppointmentScheduleAggr objects.
     * @param batchableContext The Database Batchable Context within which the method executes.
     * @param scope A list of AppointmentScheduleAggr objects that are to be processed
     * in the current batch.
     *
     * @see VCC_AppointmentSlotUtilLogic class and refer to the runAppointmentSlotUtilizationCalculation method for details
     */
    public void execute(Database.BatchableContext batchableContext, List<AppointmentScheduleAggr> scope) {
        appointmentSlotUtilLogic.calculateSlotUtilization(scope);
    }

    /**
     * @description method is called after all batches of a Batch Apex job have been executed.
     * The method retrieves the status of the Batch Apex job and sends a notification email
     * to the user who initiated the Batch Apex job with the status and the total number of processed items.
     * @param batchableContext The BatchableContext object is automatically passed into the method and contains methods to retrieve the Batch Job's ID and the Batch Job's Result object.
     * The Batch Job ID can be used to query for information related to the Batch Job execution, such as the number of error records, the number of records processed, and the status of the Batch Job.
     */
    public void finish(Database.BatchableContext batchableContext) {
        AsyncApexJob job = getAsyncApexJobById(batchableContext.getJobId());
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ job.CreatedBy.Email };
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch Apex Job Status: ' + job.Status);
        mail.setPlainTextBody(
            'The batch Apex job processed ' + job.TotalJobItems + ' batches with ' + job.NumberOfErrors + ' failures.'
        );

        try {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        } catch (System.EmailException genericException) {
            Logger.error('Failed to send email: ' + genericException.getMessage());
            Logger.debug(genericException.getStackTraceString());
            Logger.saveLog();
        }
    }

    /**
     * @description This method fetches an AsyncApexJob by its ID. It first tries to fetch the job details using the AsyncApexJob repository. If it successfully retrieves the job, it returns the job else it logs the error and throws a custom exception.
     * Finally, regardless of the outcome, an attempt is made to save the logs.
     * @param jobId The ID of the AsyncApexJob to be retrieved.
     * @return It returns the AsyncApexJob corresponding to the ID.
     * @throws HandledException Throws this exception with the error message, if any exception occurs while retrieving the job.
     */
    @TestVisible
    private static AsyncApexJob getAsyncApexJobById(Id jobId) {
        try {
            return asyncApexJobRepo.getAsyncApexJobById(jobId);
        } catch (Exception genericException) {
            Logger.error(
                'VCC_AppointmentSlotUtilBatch - Error getting AsyncApexJob by Id: ' +
                genericException.getStackTraceString()
            );
            throw new HandledException(genericException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description is a private static method that fetches query string for all appointment schedules.
     * It calls the AppointmentScheduleAggrRepo to get the desired query string.
     * The method employs exception handling capabilities to prevent undesirable outcomes from errors,
     * and logs these errors using Logger.error for further troubleshooting.
     * Logger.saveLog() method is called when the execution is complete.
     * It throws a handled exception with the message of the caught exception.
     * @return A string representing the desired query for all appointment schedules.
     * @throws HandledException If an error occurs when getting the query string.
     */
    @TestVisible
    private static String getAppointmentScheduleAggrStringAll() {
        try {
            return appointmentScheduleAggrRepo.getAppointmentScheduleAggrAllQueryString();
        } catch (Exception genericException) {
            Logger.error(
                'VCC_AppointmentSlotUtilBatch - Error getting query string for all AppointmentScheduleAggr records: ' +
                genericException.getStackTraceString()
            );
            throw new HandledException(genericException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
