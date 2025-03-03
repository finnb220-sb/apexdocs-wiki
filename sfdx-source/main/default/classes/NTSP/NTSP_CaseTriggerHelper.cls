/**
 * @description       : Class used as the helper for the NTSP Case Trigger
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 03-22-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2022   George Elias                          Initial Version
 **/
public with sharing class NTSP_CaseTriggerHelper {
    /**
     * @description Method to search and return all results based on the search criteria
     * @author George Elias | 03-22-2022
     * @return  void
     **/
    public static void populateESTHour() {
        if (Trigger.isBefore) {
            if (Trigger.isInsert) {
                handlePopulateESTHour(Trigger.new);
            }
            if (Trigger.isUpdate) {
                handlePopulateESTHour(Trigger.new);
            }
        }
    }

    private static void handlePopulateESTHour(List<NTSP_Case__c> newCaseList) {
        List<Id> facilityIds = new List<Id>();
        for (NTSP_Case__c ntspCase : newCaseList) {
            facilityIds.add(ntspCase.NTSP_Facility__c);
        }

        Map<Id, NTSP_Facility__c> facilityMap = new Map<Id, NTSP_Facility__c>([SELECT Id, Location__r.VAF_Location_Time_Zone__c FROM NTSP_Facility__c WHERE Id IN :facilityIds]);

        for (NTSP_Case__c ntspCase : newCaseList) {
            String consultTime = ntspCase.Consult_Time_Local_Time_24_hrs__c;
            String tz = facilityMap.get(ntspCase.NTSP_Facility__c)?.Location__r?.VAF_Location_Time_Zone__c;
            if (tz != null) {
                ntspCase.Consult_Hour__c = convertToEST(ntspCase.Consult_Time_Local_Time_24_hrs__c, tz);
            }
        }
    }

    private static String convertToEST(String timeString, String tz) {
        Integer hour = Integer.valueOf(timeString.left(2));
        Integer minute = Integer.valueOf(timeString.right(2));

        Date targetDate = Date.today();
        Time targetTime = Time.newInstance(hour, minute, 0, 0);

        TimeZone targetTimezone = TimeZone.getTimeZone(tz);

        // The targetDate is used here to decide whether
        // Daylight Savings should apply.
        Integer offsetSeconds = targetTimezone.getOffset(targetDate) / 1000;

        //Convert local datetime to GMT
        Datetime targetDatetime = Datetime.newInstanceGmt(targetDate, targetTime).addSeconds(-offsetSeconds);

        TimeZone estTimezone = TimeZone.getTimeZone('America/New_York');
        offsetSeconds = estTimezone.getOffset(targetDatetime) / 1000;

        //Convert GMT to EST
        Datetime estDatetime = targetDatetime.addSeconds(offsetSeconds);

        return estDatetime.hourGMT() + '';
    }
}
