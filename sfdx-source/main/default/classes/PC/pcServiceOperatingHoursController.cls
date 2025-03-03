/**
 * @description       : controller for Service's Operating Hours component
 * @author            : BAH
 * @group             :
 * @last modified on  : 09-07-2023
 * @last modified by  : BAH
 **/
@SuppressWarnings(
    'PMD.ApexDoc, PMD.ClassNamingConventions, PMD.ExcessivePublicCount, PMD.VariableNamingConventions, PMD.LocalVariableNamingConventions, PMD.FieldDeclarationsShouldBeAtStart, PMD.PropertyNamingConventions'
)
public with sharing class pcServiceOperatingHoursController {
    /**
     * @description
     * @author BAH | 09-07-2023
     * @param String serviceId
     * @return DataTableResponse
     **/
    @AuraEnabled
    public static DataTableResponse getOperatingHours(String serviceId) {
        DataTableResponse res = new DataTableResponse();
        List<PC_Service__c> serviceList = [SELECT Id, PC_Time_Zone__c, PC_Operating_Hours_Lookup__r.Id FROM PC_Service__c WHERE Id = :serviceId WITH SECURITY_ENFORCED];

        if (serviceList == null || serviceList.isEmpty()) {
            return res;
        } else {
            PC_Service__c service = serviceList[0];
            String opHourId = service.PC_Operating_Hours_Lookup__r.Id;
            List<PC_Operating_Hours__c> opHoursList = [
                SELECT
                    Id,
                    (SELECT Id, Name, PC_Day_of_Week__c, PC_Start__c, PC_End__c FROM Time_Slot__r),
                    (SELECT Id, Name, PC_Date__c, Day_of_Week_fmla__c, PC_End_Time__c, PC_Start_Time__c FROM PC_Exceptions__r)
                FROM PC_Operating_Hours__c
                WHERE Id = :opHourId
                WITH SECURITY_ENFORCED
            ];

            if (opHoursList == null || opHoursList.isEmpty()) {
                return res;
            } else {
                PC_Operating_Hours__c operatingHours = opHoursList[0];

                res.Id = service.Id;
                res.Timezone = service.PC_Time_Zone__c;
                res.opHoursId = operatingHours.Id;
                List<HourTableWrapper> timeslots = new List<HourTableWrapper>();
                for (PC_Time_Slot__c ts : operatingHours.Time_Slot__r) {
                    HourTableWrapper timeslotWrap = new HourTableWrapper();
                    timeslotWrap.Id = ts.Id;
                    timeslotWrap.DayOfWeek = ts.PC_Day_of_Week__c;
                    DateTime dtStart = DateTime.newInstance(Date.today(), ts.PC_Start__c);
                    DateTime dtEnd = DateTime.newInstance(Date.today(), ts.PC_End__c);
                    timeslotWrap.Timeslot = '' + dtStart.format('hh:mm a') + '-' + dtEnd.format('hh:mm a');
                    timeslots.add(timeslotWrap);
                }
                timeslots.sort();
                res.TimeSlots = timeslots;
                List<ExceptionTableWrapper> exceptionslots = new List<ExceptionTableWrapper>();
                for (PC_Exception__c ex : operatingHours.PC_Exceptions__r) {
                    ExceptionTableWrapper exceptionWrap = new ExceptionTableWrapper();
                    exceptionWrap.Id = ex.Id;
                    exceptionWrap.Name = ex.Name;
                    exceptionWrap.DateOf = ex.PC_Date__c.format();
                    exceptionWrap.DateHold = ex.PC_Date__c;
                    exceptionWrap.DayOfWeek = ex.Day_of_Week_fmla__c;
                    DateTime dtStart = DateTime.newInstance(ex.PC_Date__c, ex.PC_Start_Time__c);
                    DateTime dtEnd = DateTime.newInstance(ex.PC_Date__c, ex.PC_End_Time__c);
                    exceptionWrap.StartTime = dtStart.format('hh:mm a');
                    exceptionWrap.EndTime = dtEnd.format('hh:mm a');
                    exceptionslots.add(exceptionWrap);
                }
                exceptionslots.sort();
                res.Exceptions = exceptionslots;
            }
        }
        return res;
    }

    /**
     * @description       : DataTable Response wrapper
     * @author            : BAH
     **/
    public class DataTableResponse {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Timezone { get; set; }
        @AuraEnabled
        public String opHoursId { get; set; }
        @AuraEnabled
        public List<HourTableWrapper> TimeSlots { get; set; }
        @AuraEnabled
        public List<ExceptionTableWrapper> Exceptions { get; set; }
    }

    /**
     * @description       : HourTable wrapper
     * @author            : BAH
     **/
    public class HourTableWrapper implements Comparable {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String DayOfWeek { get; set; }
        @AuraEnabled
        public String Timeslot { get; set; }

        private List<String> dayOrder = new List<String>{ 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' };

        /**
         * @description
         * @author BAH | 09-07-2023
         * @param Object compareTo
         * @return Integer
         **/
        public Integer compareTo(Object compareTo) {
            //this sorts the returned list by day order
            HourTableWrapper compareToSlot = (HourTableWrapper) compareTo;
            Integer positionOf = dayOrder.indexOf(DayOfWeek);
            Integer positionOfCompare = dayOrder.indexOf(compareToSlot.DayOfWeek);
            if (positionOf == positionOfCompare) {
                return 0;
            }
            if (positionOf > positionOfCompare) {
                return 1;
            }
            return -1;
        }
    }

    /**
     * @description       : ExceptionTable wrapper
     * @author            : BAH
     **/
    public class ExceptionTableWrapper implements Comparable {
        @AuraEnabled
        public String Id { get; set; }
        @AuraEnabled
        public String Name { get; set; }
        @AuraEnabled
        public String DateOf { get; set; }
        @AuraEnabled
        public Date DateHold { get; set; }
        @AuraEnabled
        public String DayOfWeek { get; set; }
        @AuraEnabled
        public String StartTime { get; set; }
        @AuraEnabled
        public String EndTime { get; set; }

        /**
         * @description
         * @author BAH | 09-07-2023
         * @param Object compareTo
         * @return Integer
         **/
        public Integer compareTo(Object compareTo) {
            //this sorts the returned list by date
            ExceptionTableWrapper compareToSlot = (ExceptionTableWrapper) compareTo;
            Date DateHoldCompare = compareToSlot.DateHold;
            if (DateHold == DateHoldCompare) {
                return 0;
            }
            if (DateHold > DateHoldCompare) {
                return 1;
            }
            return -1;
        }
    }
}
