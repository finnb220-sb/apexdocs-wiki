/**
 * @description         This Class facilitates the automatic pausing and resuming of Tele-EC Case Escalation
 *                      To facilitate this need, it checks active VISNs that have a Tuc Pause Control metadata then
 *                      creates new escalation records as needed based on Operating Hour information for the related
 *                      Tele-EC Operating Hour for that VISN.
 * @author              Booz Allen Hamilton
 * @see TUC_VISN_Pause_Control__mdt Custom metadata that contains the checkbox that enables a VISN to automatically Open/Pause
 * @see TUC_VISNPauseControlRepo repo class to retrieve the TUC_VISN_Pause_Control__mdt metadata
 * @see OperatingHours Standard Object that contains the relevant Timezone and TimeSlot information
 * @see VCR_OperatingHoursRepo repo class to retrieve the OperatingHours object
 * @see TUC_ScheduleTeleEcQueuePauseTest for unit tests
 **/
public with sharing class TUC_ScheduleTeleEcQueuePause implements Schedulable {
    private static final String DAY_OF_WEEK_FORMAT = 'EEEE';
    private static final String HIGH_ACUITY_STRING = 'High Acuity';
    private static final String INTERMEDIATE_ACUITY_STRING = 'Intermediate Acuity';
    private static final String VISN_REPLACE_STRING = 'VISN ';
    private static final String PAUSED_STRING = 'Paused';
    private static final String RESUMED_STRING = 'Resumed';
    private static final String CLOSED_PAUSE_REASON_STRING = 'Tele-EC closed (after hours)';
    private static final String OPERATING_HOURS_TYPE_STRING = 'Tele-EC';
    private static final String NO_PAUSE_CONTROL_METADATA_FOUND_ERROR_MESSAGE_STRING = Label.get(
        '',
        'TeleECNoPauseControlMetadataFound'
    );
    private static final String RESUME_ONLY_STRING = 'Tele-EC Start Time Only';
    private static final String PAUSE_ONLY_STRING = 'Tele-EC End Time Only';

    @TestVisible
    /**
     * @description - Static instantiation of the TUC_VISNPauseControlRepo for test memoization.
     */
    private static TUC_VISNPauseControlRepo memoizedTucVisnPauseRepo;

    @TestVisible
    /**
     * @description - Static instantiation of the TUC_VISNPauseControlRepo.
     */
    private static TUC_VISNPauseControlRepo tucVisnPauseRepo {
        get {
            memoizedTucVisnPauseRepo = memoizedTucVisnPauseRepo ?? new TUC_VISNPauseControlRepo();
            return memoizedTucVisnPauseRepo;
        }
    }

    /**
     * @description - Static instantiation of the VTC_RepoFactory. Currently not mockable for this class.
     */
    private static final VTC_RepoFactory repoFactory {
        get {
            return VTC_RepoFactory.repoFactory;
        }
    }

    /**
     * @description - The main execute function. Collects data for the Pause Control mdt and OperatingHours, then calls the schedule creation method
     *                for the TimeSlot matching current dayOfWeek for both High and Intermediate Acuity Tele-EC queues
     * @param schedulableContext - incoming SchedulableContext
     */
    public void execute(SchedulableContext schedulableContext) {
        List<TUC_VISN_Pause_Control__mdt> pauseControlList = tucVisnPauseRepo.getAllActiveTucVisnPauseControlRecords();
        if (pauseControlList.isEmpty()) {
            HandledException exceptionToThrow = new HandledException(
                NO_PAUSE_CONTROL_METADATA_FOUND_ERROR_MESSAGE_STRING
            );
            exceptionToThrow.setMessage(NO_PAUSE_CONTROL_METADATA_FOUND_ERROR_MESSAGE_STRING);
            throw exceptionToThrow;
        }
        List<String> providerVisnList = new List<String>();
        for (TUC_VISN_Pause_Control__mdt pauseControl : pauseControlList) {
            providerVisnList.add(pauseControl.TUC_VISN__c);
        }

        VCR_OperatingHoursRepo operatingHoursRepo = (VCR_OperatingHoursRepo) repoFactory.createRepo(
            OperatingHours.SObjectType,
            'VCR_OperatingHoursRepo'
        );
        List<OperatingHours> operatingHoursList = operatingHoursRepo.fetchMultipleOperatingHoursWithTimeSlotsByType(
            providerVisnList,
            OPERATING_HOURS_TYPE_STRING
        );
        for (OperatingHours operatingHoursItem : operatingHoursList) {
            if (calculateIfTodayIsHoliday(operatingHoursItem)) {
                continue;
            }
            for (TimeSlot timeSlotItem : operatingHoursItem.TimeSlots) {
                String dayOfWeek = Datetime.now().format(DAY_OF_WEEK_FORMAT); //grab the formatted name of the current day from Datetime.now()
                if (timeSlotItem.DayOfWeek == dayOfWeek) {
                    checkIfNewStatusRecordIsNeeded(operatingHoursItem, HIGH_ACUITY_STRING, timeSlotItem);
                    checkIfNewStatusRecordIsNeeded(operatingHoursItem, INTERMEDIATE_ACUITY_STRING, timeSlotItem);
                }
            }
        }
    }

    /**
     * @description - Takes in an OperatingHours, then retrieves Holiday information for that OperatingHour and calculates if today's date is present
     *                in the returned data, and thus today is a holiday
     * @param opHour - The Operating Hour to be parsed and checked
     * @return Boolean - True or False based on if today is a holiday
     */
    private Boolean calculateIfTodayIsHoliday(OperatingHours opHour) {
        Boolean isTodayHoliday = false;

        VCR_OperatingHoursHolidayRepo opHoursHolidayRepo = (VCR_OperatingHoursHolidayRepo) repoFactory.createRepo(
            OperatingHoursHoliday.SObjectType,
            'VCR_OperatingHoursHolidayRepo'
        );
        List<OperatingHoursHoliday> operatingHoursHolidays = opHoursHolidayRepo.fetchHolidaysForVISNOperatingHours(
            new Set<Id>{ opHour.Id }
        );
        for (OperatingHoursHoliday operatingHoursHolidayItem : operatingHoursHolidays) {
            VCC_HolidayServiceHelper holidayServiceHelper = new VCC_HolidayServiceHelper();
            if (holidayServiceHelper.calculateIfTodayIsHoliday(operatingHoursHolidayItem.Holiday)) {
                isTodayHoliday = true;
                break;
            }
        }

        return isTodayHoliday;
    }

    /**
     * @description - Checks the current status for the provided queue, checks if the start or end time is within 15 minutes of the current run to account for schedule variation,
     *                then kicks off an escalation creation if conditions are met
     * @param operatingHours - The OperatingHour for the VISN currently being worked with
     * @param queueType - The queue an escalation status is being created for
     * @param timeSlot - The TimeSlot matching the current day
     */
    private void checkIfNewStatusRecordIsNeeded(OperatingHours operatingHours, String queueType, TimeSlot timeSlot) {
        String providedVISN = operatingHours.VCC_VISN__c.replace(VISN_REPLACE_STRING, '');
        String specialSettings = timeSlot?.TUC_Schedule_Settings__c ?? null;

        Tele_EC_Escalation_Status__c currentStatusRecord = TUC_EscalatePauseButtonController.getCurrentStatusRecord(
            providedVISN,
            queueType
        );
        String currentStatus = currentStatusRecord?.TUC_Status_Type__c ?? null;

        Boolean isCreationNeeded = false;
        Integer timeTillOpeningMinutes = calculateNearestInstanceInMinutes(timeSlot.StartTime, operatingHours.TimeZone);
        Integer timeTillClosingMinutes = calculateNearestInstanceInMinutes(timeSlot.EndTime, operatingHours.TimeZone);

        String pauseReason = '';
        if (
            (timeTillClosingMinutes <= 15) &&
            (currentStatus == RESUMED_STRING ||
            currentStatus == null) &&
            (specialSettings != RESUME_ONLY_STRING)
        ) {
            //Sets variables to create a pause escalation record
            isCreationNeeded = true;
            pauseReason = CLOSED_PAUSE_REASON_STRING;
        } else if (
            (timeTillOpeningMinutes <= 15) &&
            (currentStatus == PAUSED_STRING) &&
            (specialSettings != PAUSE_ONLY_STRING)
        ) {
            //Sets variables to create a resume escalation record
            isCreationNeeded = true;
        }

        if (isCreationNeeded) {
            Map<String, String> fieldsMap = new Map<String, String>();
            fieldsMap.put('providedVISN', providedVISN);
            fieldsMap.put('queueType', queueType);
            fieldsMap.put('pauseReason', pauseReason);

            TUC_EscalatePauseButtonController.createTeleEcStatusRecordMap(fieldsMap);
        }
    }

    /**
     * @description - Gets difference in time between the current time and a provided time. This method starts by calculating the offset in
     *                between the running Timezone and the provided target timezone. From there a simple subtraction between the current time
     *                and a fabricated DateTime gets the difference in milliseconds. We then calculate the time from or until the next instance
     *                by yesterday, today, and tomorrow instances and return the most recent or upcoming time difference calculation.
     * @param timeToCalc - A provided Time to be calculated against. The end goal is to see if this Time is within 30 minutes to now()
     * @param opHourTimezone - The Timezone of the OperatingHours to correctly calculate the time difference
     * @return Integer - the calculated difference until the next instance of the schedule time, in minutes.
     */
    private Integer calculateNearestInstanceInMinutes(Time timeToCalc, String opHourTimezone) {
        TimeZone tzOp = TimeZone.getTimeZone(opHourTimezone);
        TimeZone tzCurrent = UserInfo.getTimeZone();
        Datetime currentDateTime = Datetime.now();
        Integer offsetInt = ((tzOp.getOffset(currentDateTime) - tzCurrent.getOffset(currentDateTime)) / 1000 / 60);
        //All calculations are done in milliseconds, and we want minutes. Dividing by 1000 then 60 converts appropriately
        //We calculate based on yesterday, today, and tomorrow so that we make sure to get the closest interval of the schedule
        //Having multiple DateTimes corrects for late night operations that could roll over into the next day and cuase issues
        //when accounting for larger timezone offset calculations
        DateTime timeSlotDateTimeYesterday = DateTime.newInstance(currentDateTime.date().addDays(-1), timeToCalc);
        DateTime timeSlotDateTimeToday = DateTime.newInstance(currentDateTime.date(), timeToCalc);
        DateTime timeSlotDateTimeTomorrow = DateTime.newInstance(currentDateTime.date().addDays(1), timeToCalc);
        Integer yesterdayCalc = calculateMinutesBetween(currentDateTime, timeSlotDateTimeYesterday, offsetInt);
        Integer todayCalc = calculateMinutesBetween(currentDateTime, timeSlotDateTimeToday, offsetInt);
        Integer tomorrowCalc = calculateMinutesBetween(currentDateTime, timeSlotDateTimeTomorrow, offsetInt);
        List<Integer> numList = new List<Integer>{ yesterdayCalc, todayCalc, tomorrowCalc };
        //Sort list and retrieve smallest number for return. This Integer will be the closest interval, whether past or future.
        numList.sort();
        return numList.get(0);
    }

    /**
     * @description - Calculates the difference in minutes between two datetimes, also using a provided offset to calculate for timezone differences.
     * 				  The difference in minutes is converted to Integer, then the offset is factored in using subtraction to move the hour needle
     * 				  in the appropriate direction. The return is put through Absolute as we just want the difference in minutes, 5 minutes ago vs
     *                5 minutes from now is still a 5 minute difference.
     * @param currentDateTime - The current Date and Time for the code at run time
     * @param targetDateTime - The target DateTime to calculate difference time in minutes against
     * @param offsetInt - The calculated offset in minutes provided from the previous method
     * @return Integer - the calculated minutes until the provided time
     */
    private Integer calculateMinutesBetween(DateTime currentDateTime, DateTime targetDateTime, Integer offsetInt) {
        Long diffInMinutes = ((targetDateTime.getTime() - currentDateTime.getTime()) / 1000 / 60);
        Integer diffInMinutesInt = diffInMinutes.intValue();
        Integer calculatedMinutesWithOffset = Math.abs(diffInMinutesInt - offsetInt);
        return calculatedMinutesWithOffset;
    }
}
