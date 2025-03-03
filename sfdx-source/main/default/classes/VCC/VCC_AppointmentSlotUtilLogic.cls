/**
 * @description This class is used to calculate the slot utilization for the provided list of appointment schedule aggregates.
 * It fetches the list of VCC Appointment Utilization records within the range of the provided appointment schedule aggregate.
 * It then compares and updates the records based on the provided appointment schedule aggregate and VCC Appointment Utilization records.
 * @author Booz Allen
 * @see VCC_AppointmentSlotUtilBatch
 * @see VCC_AppointmentSlotUtilLogicTest
 * @see VCC_AppointmentSlotUtilScheduleAggrRepo
 * @see VCC_AppointmentSlotUtilizationRepo
 */
public with sharing class VCC_AppointmentSlotUtilLogic {
    @TestVisible
    private List<AppointmentScheduleAggr> aggrSchedules;
    @TestVisible
    private List<VCC_Appointment_Utilization__c> appUtilizations;
    @TestVisible
    private Date startDate;
    @TestVisible
    private Date endDate;

    /**
     * @description TestVisible variable that defines an instance of VCR_AppointmentScheduleAggrRepo.
     */
    @TestVisible
    private static VCR_AppointmentScheduleAggrRepo aggrScheduleRepo {
        get {
            return aggrScheduleRepo == null
                ? aggrScheduleRepo = new VCR_AppointmentScheduleAggrRepo()
                : aggrScheduleRepo;
        }
        set;
    }

    /**
     * @description TestVisible variable that defines an instance of VCR_AppointmentUtilizationRepo.
     */
    @TestVisible
    private static VCR_AppointmentUtilizationRepo utilizationRepo {
        get {
            return utilizationRepo == null ? utilizationRepo = new VCR_AppointmentUtilizationRepo() : utilizationRepo;
        }
        set;
    }

    /**
     * @description method is used to calculate the slot utilization for the provided list of appointment schedule aggregates.
     * The inputList is passed down from the context of the batch class.
     * It fetches the list of VCC Appointment Utilization records within the range of the provided appointment schedule aggregate.
     * It then compares and updates the records based on the provided appointment schedule aggregate and VCC Appointment Utilization records.
     * @param inputList The list of Appointment Schedule Aggregate records for which the slot utilization needs to be calculated.
     */
    public void calculateSlotUtilization(List<AppointmentScheduleAggr> inputList) {
        if (isEmpty(inputList)) {
            return;
        }
        aggrSchedules = inputList;
        appUtilizations = fetchAppointmentUtilizationRecords();
        compareAndUpdateRecords();
    }

    /**
     * @description method is used to fetch the list of VCC Appointment Utilization records within the range of the provided appointment schedule aggregate.
     * This method will fetch a list of VCC Appointment Utilization records within the range of the provided appointment schedule aggregate.
     * The range is determined by the start and end date of the appointment schedule aggregate list, these are sorted in DESC.
     * It retrieves the start and end date of the appointment schedule aggregate list.
     * It then fetches the list of VCC Appointment Utilization records within the range of the start and end date.
     * @return List<VCC_Appointment_Utilization__c> Returns the list of VCC Appointment Utilization records within the range of the provided appointment schedule aggregate.
     */
    @TestVisible
    private List<VCC_Appointment_Utilization__c> fetchAppointmentUtilizationRecords() {
        if (isEmpty(aggrSchedules)) {
            return null;
        }
        //get start and end date
        endDate = getAppointmentAggrDate(aggrSchedules[0]); //since on DESC order the first record is the end date
        startDate = getAppointmentAggrDate(aggrSchedules[aggrSchedules.size() - 1]); //since on DESC order the last record is the start date
        //List already sorted by date DESC
        List<VCC_Appointment_Utilization__c> outputList = utilizationRepo.getAppointmentUtilizationWithinRange(
            startDate,
            endDate
        );
        return outputList;
    }

    /**
     * @description This is a private method that updates a list of VCC_Appointment_Utilization__c records.
     * If appUtilizations is not empty, it calls the method createAndUpdateUtilizationObjects() to create
     * or update Utilization objects which are then added to the upsertList. If appUtilizations is empty,
     * it iterates over aggrSchedules and calls createUtilization() on each of them and adds the returned
     * Utilization objects to the upsertList. It then upserts all the records in upsertList using
     * upsertAppointmentUtilization().
     */
    @TestVisible
    private void compareAndUpdateRecords() {
        if (isEmpty(this.aggrSchedules)) {
            return;
        }
        List<VCC_Appointment_Utilization__c> upsertList = new List<VCC_Appointment_Utilization__c>();

        if (!isEmpty(this.appUtilizations)) {
            upsertList = createAndUpdateUtilizationObjects();
        } else {
            for (AppointmentScheduleAggr aggr : this.aggrSchedules) {
                createUtilization(aggr, upsertList);
            }
        }
        upsertAppointmentUtilization(upsertList);
    }

    /**
     * @description method is used to create and update the utilization objects.
     * It iterates through the list of Appointment Schedule Aggregate records and the list of VCC Appointment Utilization records.
     * If a utilization record exists for the given aggregate, it updates the utilization record with the new values.
     * If a utilization record does not exist for the given aggregate, it creates a new utilization record.
     * @return List<VCC_Appointment_Utilization__c> Returns the list of VCC Appointment Utilization records with the updated values.
     */
    @TestVisible
    private List<VCC_Appointment_Utilization__c> createAndUpdateUtilizationObjects() {
        List<VCC_Appointment_Utilization__c> upsertList = new List<VCC_Appointment_Utilization__c>();
        for (AppointmentScheduleAggr aggr : this.aggrSchedules) {
            Boolean isFound = false;
            for (VCC_Appointment_Utilization__c utilization : this.appUtilizations) {
                if (isUtilizationExists(aggr, utilization)) {
                    updateUtilization(aggr, utilization, upsertList);
                    isFound = true;
                    break;
                }
            }
            if (!isFound) {
                createUtilization(aggr, upsertList);
            }
        }
        return upsertList;
    }

    /**
     * @description method is used to check if a utilization exists for the given appointment schedule aggregate.
     * It compares the date, provider, and division of the aggregate with the corresponding values in the utilization.
     * @param aggr The AppointmentScheduleAggr object that includes the date, provider, and division to compare.
     * @param utilization The VCC_Appointment_Utilization__c object that includes the date, provider, and VISN to compare.
     * @return Boolean Returns true if the utilization exists for the given appointment schedule aggregate; otherwise, it returns false.
     */
    @TestVisible
    private Boolean isUtilizationExists(AppointmentScheduleAggr aggr, VCC_Appointment_Utilization__c utilization) {
        if (aggr == null || utilization == null) {
            return false;
        }
        return aggr.AppointmentDate == utilization.VCC_Date__c &&
            aggr.ServiceResource.RelatedRecordId == utilization.VCC_Provider__c &&
            aggr.ServiceResource.RelatedRecord.Division == utilization.VCC_VISN__c;
    }

    /**
     * @description method is used to update the utilization record associated with the provided Appointment Schedule Aggregate.
     * It updates the utilization record with the new values of the Appointment Schedule Aggregate.
     * @param aggr The Appointment Schedule Aggregate, which the utilization record will be updated with.
     * @param utilization The VCC Appointment Utilization record to be updated.
     * @param upsertList The list where the updated utilization record will be added.
     */
    @TestVisible
    private void updateUtilization(
        AppointmentScheduleAggr aggr,
        VCC_Appointment_Utilization__c utilization,
        List<VCC_Appointment_Utilization__c> upsertList
    ) {
        if (aggr == null || utilization == null) {
            return;
        }
        utilization.VCC_Count_of_Used_Appointment_Slots__c = aggr.ResourceUtilizationCount;
        upsertList.add(utilization);
    }

    /**
     * @description method to create a utilization record associated with the provided Appointment Schedule Aggregate.
     * @param aggr The Appointment Schedule Aggregate, which the new utilization record will be associated with.
     * @param upsertList The list where the newly created utilization record will be added.
     */
    @TestVisible
    private void createUtilization(AppointmentScheduleAggr aggr, List<VCC_Appointment_Utilization__c> upsertList) {
        if (aggr == null) {
            Logger.error('AppointmentScheduleAggr is null' + aggrSchedules);
            Logger.saveLog();
        } else if (aggr != null) {
            VCC_Appointment_Utilization__c newUtilization = new VCC_Appointment_Utilization__c();
            newUtilization.VCC_Date__c = aggr.AppointmentDate;
            newUtilization.VCC_Provider__c = aggr.ServiceResource?.RelatedRecordId;
            newUtilization.VCC_Count_of_Used_Appointment_Slots__c = aggr.ResourceUtilizationCount;
            newUtilization.VCC_VISN__c = aggr.ServiceResource?.RelatedRecord.Division;
            upsertList.add(newUtilization);
        }
    }

    /**
     * @description method is used for logging failed records in the system.
     * It captures the log of failed records, marks them as an 'error' and then saves the logged information.
     * @param failedRecords The list of failed records to be logged.
     */
    @TestVisible
    private void logFailedRecords(List<VCC_Appointment_Utilization__c> failedRecords) {
        if (isEmpty(failedRecords)) {
            return;
        }
        //log failed records
        Logger.error('Failed upsert records: ' + failedRecords);
        Logger.saveLog();
    }

    /**
     * @description method is used to upsert the list of VCC Appointment Utilization records.
     * The method checks if the input list is null or empty before proceeding with the upsert operation.
     * In case of any failed upsert operations, sends the list of failed records to the logFailedRecords() method.
     * @param inputUpsertList The list of VCC Appointment Utilization records to be upserted.
     */
    @TestVisible
    private void upsertAppointmentUtilization(List<VCC_Appointment_Utilization__c> inputUpsertList) {
        if (isEmpty(inputUpsertList)) {
            return;
        }
        List<VCC_Appointment_Utilization__c> failedUpsertRecords = utilizationRepo.upsertAppointmentUtilizationRecords(
            inputUpsertList
        );
        if (!isEmpty(failedUpsertRecords)) {
            logFailedRecords(failedUpsertRecords);
        }
    }

    /**
     * @description retrieves the date of the appointment from the aggregate appointment record.
     * @param appt The aggregate appointment schedule record
     * @return Returns the date of the appointment
     */
    @TestVisible
    private static Date getAppointmentAggrDate(AppointmentScheduleAggr appt) {
        return appt?.AppointmentDate;
    }

    /**
     * @description if the input list is null or empty
     * @param inputList the list of objects to check
     * @return Boolean returns true if the input list is empty or null; otherwise, it returns false
     */
    @TestVisible
    private static Boolean isEmpty(List<Object> inputList) {
        return inputList == null || inputList.isEmpty();
    }
}
