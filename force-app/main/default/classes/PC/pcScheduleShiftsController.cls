@SuppressWarnings('PMD.ApexDoc, PMD.ClassNamingConventions, PMD.CognitiveComplexity')
public without sharing class pcScheduleShiftsController {
    @AuraEnabled
    public static Map<Id, List<ShiftStatus>> getNext7DaysShifts(String startDay, Id pcServiceId) {
        Date startDate = Date.parse(startDay);
        Set<Date> next7Days = new Set<Date>();
        for (Integer i = 0; i < 7; i++) {
            Date day = startDate.addDays(i);
            next7Days.add(day);
        }
        List<PC_Service_Team_Member__c> pcTeamMemberList = [
            SELECT Id, PC_Service_Resource__r.RelatedRecord.Name
            FROM PC_Service_Team_Member__c
            WHERE PC_Service__c = :pcServiceId
            WITH SECURITY_ENFORCED
        ];
        List<PC_Shift__c> pcShiftList = [
            SELECT PC_End_Time__c, PC_Start_Time__c, PC_Date__c, PC_Shift_Status__c, PC_Service_Team_Member__c, PC_Service__c
            FROM PC_Shift__c
            WHERE PC_Service__c = :pcServiceId AND PC_Date__c IN :next7Days
            WITH SECURITY_ENFORCED
        ];
        Map<Id, List<ShiftStatus>> shiftTeamMemberMap = new Map<Id, List<ShiftStatus>>();
        for (PC_Service_Team_Member__c pcstm : pcTeamMemberList) {
            List<ShiftStatus> stList = new List<ShiftStatus>();
            for (Date d : next7Days) {
                ShiftStatus st = new ShiftStatus();
                st.serviceResourceId = pcstm.PC_Service_Resource__c;
                st.serviceResourceName = pcstm.PC_Service_Resource__r.RelatedRecord.Name;
                st.serviceTeamMemberId = pcstm.Id;
                st.serviceDate = d;
                //PTEMSPC-473 used to make make LWC column header date in "Day of Week" M/dd format
                DateTime serviceDateTime = DateTime.newInstance(d, Time.newInstance(0, 0, 0, 0));
                st.serviceDateString = serviceDateTime != null ? serviceDateTime.format('E. M/dd') : '';
                stList.add(st);
            }
            shiftTeamMemberMap.put(pcstm.Id, stList);
        }

        for (Id key : shiftTeamMemberMap.keySet()) {
            List<ShiftStatus> stList = shiftTeamMemberMap.get(key);
            for (ShiftStatus shiftStatus : stList) {
                List<PC_Shift__c> shiftList = new List<PC_Shift__c>();
                for (PC_Shift__c shift : pcShiftList) {
                    if (shiftStatus.serviceDate == shift.PC_Date__c && shift.PC_Service_Team_Member__c == shiftStatus.serviceTeamMemberId) {
                        shiftList.add(shift);
                    }
                }
                shiftStatus.shifts = shiftList;
            }
        }
        return shiftTeamMemberMap;
    }
    @AuraEnabled
    public static List<PC_Time_Slot__c> getSpecialistAvailability(Id serviceTeamMemberId) {
        List<PC_Service_Team_Member__c> pcServiceTeamMember = [
            SELECT PC_Service_Resource__c
            FROM PC_Service_Team_Member__c
            WHERE Id = :serviceTeamMemberId
            WITH SECURITY_ENFORCED
        ];
        if (String.isBlank(pcServiceTeamMember[0].PC_Service_Resource__c)) {
            throw new PC_CustomException('Error: The Team Member selected must be linked to a Service Resource.');
        }
        List<PC_Specialist_Availability__c> pcSpecAvailList = [
            SELECT Id, PC_Week_Ending_Date__c
            FROM PC_Specialist_Availability__c
            WHERE PC_Service_Resource__c = :pcServiceTeamMember[0].PC_Service_Resource__c
            WITH SECURITY_ENFORCED
            ORDER BY PC_Week_Ending_Date__c DESC
            LIMIT 1
        ];
        if (pcSpecAvailList.isEmpty()) {
            throw new PC_CustomException('The Team Member did not create a Specialist Availability record.');
        }
        List<PC_Time_Slot__c> pcTs = [
            SELECT Id, PC_Service_Resource__c, PC_Day_of_Week__c, Availability__r.LastModifiedDate, PC_Operating_Hours__c, PC_End__c, PC_Start__c
            FROM PC_Time_Slot__c
            WHERE Availability__c = :pcSpecAvailList[0].Id
            WITH SECURITY_ENFORCED
        ];
        if (pcTs.isEmpty()) {
            throw new PC_CustomException(
                'There is no time slots created for the Team Member\'s most recent Availability record. Please ask the Team member to make time slots for the "Specialist Availabilty" record with the week ending: ' +
                pcSpecAvailList[0].PC_Week_Ending_Date__c
            );
        }
        return pcTs;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    @AuraEnabled
    public static Map<Id, List<ShiftStatus>> insertShift(Id pcServiceId, Id pcServiceMemberId, String startTime, String endTime, Date shiftDate, String startDay) {
        PC_Shift__c pcShift = new PC_Shift__c(PC_Service__c = pcServiceId, PC_Service_Team_Member__c = pcServiceMemberId, PC_Date__c = shiftDate, PC_Shift_Status__c = 'Tentative');
        Time startT = convertStringtoTime(startTime);
        Time endT = convertStringtoTime(endTime);
        pcShift.PC_Start_Time__c = startT;
        pcShift.PC_End_Time__c = endT;
        if (Schema.sObjectType.PC_Shift__c.isCreateable()) {
            insert pcShift;
            return getNext7DaysShifts(startDay, pcServiceId);
        } else {
            throw new PC_CustomException('You do not have permission to create a Shift.');
        }
    }
    @AuraEnabled
    public static Map<Id, List<ShiftStatus>> updateShift(Id pcShiftId, String startTime, String endTime, Date shiftDate, String startDay, Id pcServiceId) {
        PC_Shift__c pcShift = new PC_Shift__c(Id = pcShiftId);
        Time startT = convertStringtoTime(startTime);
        Time endT = convertStringtoTime(endTime);
        pcShift.PC_Start_Time__c = startT;
        pcShift.PC_End_Time__c = endT;
        pcShift.PC_Date__c = shiftDate;
        if (Schema.sObjectType.PC_Shift__c.isUpdateable()) {
            update pcShift;
            return getNext7DaysShifts(startDay, pcServiceId);
        } else {
            throw new PC_CustomException('You do not have permission to update a Shift.');
        }
    }
    @AuraEnabled
    public static Map<Id, List<ShiftStatus>> deleteShift(Id pcShiftId, String startDay, Id pcServiceId) {
        PC_Shift__c pcShift = new PC_Shift__c(Id = pcShiftId);
        if (Schema.sObjectType.PC_Shift__c.isDeletable()) {
            delete pcShift;
            return getNext7DaysShifts(startDay, pcServiceId);
        } else {
            throw new PC_CustomException('You do not have permission to delete a Shift.');
        }
    }

    @AuraEnabled
    public static Map<Id, String> getSpecialities(List<String> serviceResourceIds) {
        try {
            List<ServiceResource> serviceResources = [
                SELECT Id, PC_Assigned_Specialty__c
                FROM ServiceResource
                WHERE Id = :serviceResourceIds
                WITH SECURITY_ENFORCED
            ];
            Map<Id, String> specialities = new Map<Id, String>();
            for (ServiceResource sr : serviceResources) {
                specialities.put(sr.Id, sr.PC_Assigned_Specialty__c);
            }
            return specialities;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Time convertStringtoTime(String strTime) {
        String[] strTimeSplit = strTime.split(':');
        Time timeChange = Time.newInstance(Integer.valueOf(strTimeSplit[0]), Integer.valueOf(strTimeSplit[1]), 0, 0);
        return timeChange;
    }

    public class ShiftStatus {
        @AuraEnabled
        public Id serviceTeamMemberId;
        @AuraEnabled
        public Id serviceResourceId;
        @AuraEnabled
        public String serviceResourceName;
        @AuraEnabled
        public Date serviceDate;
        @AuraEnabled
        public String serviceDateString;
        @AuraEnabled
        public List<PC_Shift__c> shifts;
    }
}
