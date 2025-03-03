/**
 * @description       : Class used as to serve data to the Gantt Chart
 * @author            : Edwin Schaeffer
 * @group             : Salesforce
 * @last modified on  : 09-11-2023
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   09-11-2023   Edwin Schaeffer                     Initial Version
 **/
public without sharing class PC_AvailabilityGanttChart {
    /**
     * @description       : Fetches shift data, aggregates shift times, and organizes data given a date. The main driver for the Gantt Chart
     * @param             : Date formatted string in MM/DD/YYYY form
     * @return            : returns a complex object shifts by Service Resources organized by Skill.
     **/
    @AuraEnabled
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static Map<String, Object> getChartData(String startDateStr) {
        if (String.isEmpty(startDateStr)) {
            throw new PC_CustomException('The date cannot be blank.');
        }
        Date startDate = Date.parse(startDateStr);
        Map<String, Object> data = new Map<String, Object>();
        List<PC_Shift__c> shifts;
        if (Schema.sObjectType.PC_Shift__c.isAccessible()) {
            // Cannot assign PCP (provider) users Read permissions to ServiceResource due to Platform license restrictions. Cannnot Security Enforce.
            shifts = [
                SELECT
                    Id,
                    PC_Start_Time__c,
                    PC_End_Time__c,
                    PC_Date__c,
                    PC_Shift_Status__c,
                    PC_Service_Team_Member__r.PC_Service_Resource__c,
                    PC_Service_Team_Member__r.PC_Service_Resource__r.Name,
                    PC_Service_Team_Member__r.PC_Service_Resource__r.PC_Assigned_Specialty__c,
                    PC_Service__c
                FROM PC_Shift__c
                WHERE PC_Date__c = :startDate AND PC_Service_Team_Member__r.PC_Service_Resource__r.IsActive = TRUE
                ORDER BY PC_Service_Team_Member__r.PC_Service_Resource__r.PC_Assigned_Specialty__c ASC, PC_Start_Time__c ASC
            ];
        }

        Map<String, Object> serviceResourceById = new Map<String, Object>();
        Map<String, Object> skillsById = new Map<String, Object>();

        // Check for overlap and aggregate shift times
        String prevSpecialty = '';
        PC_Shift__c prevShift = null;
        Map<Id, PC_Shift__c> overlapMap = new Map<Id, PC_Shift__c>();
        for (PC_Shift__c shift : shifts) {
            String currentSpecialty = shift.PC_Service_Team_Member__r.PC_Service_Resource__r.PC_Assigned_Specialty__c;
            if (prevShift != null && prevSpecialty == currentSpecialty && shift.PC_Start_Time__c <= prevShift.PC_End_Time__c && shift.PC_End_Time__c >= prevShift.PC_End_Time__c) {
                shift.PC_Start_Time__c = prevShift.PC_Start_Time__c;
                overlapMap.put(prevShift.Id, prevShift);
            } // else if other shift completely overlaps, no need to aggregate. Just eliminate from Gantt.
            else if (
                prevShift != null &&
                prevSpecialty == currentSpecialty &&
                shift.PC_Start_Time__c <= prevShift.PC_End_Time__c &&
                shift.PC_End_Time__c <= prevShift.PC_End_Time__c
            ) {
                overlapMap.put(shift.Id, shift);
                continue;
            }
            prevShift = shift;
            prevSpecialty = currentSpecialty;
        }
        // Organize aggregated shifts
        List<PC_Shift__c> finalShiftList = new List<PC_Shift__c>();
        for (PC_Shift__c shift : shifts) {
            if (!overlapMap.containsKey(shift.Id)) {
                finalShiftList.add(shift);
            }
        }

        // display all active resources, skills, and shifts
        for (Object s : PC_AvailabilityGanttChart.getResources()) {
            Map<String, Object> skill = (Map<String, Object>) s;
            Map<String, Object> shiftsByServiceResource = new Map<String, Object>();
            for (PC_Shift__c shift : finalShiftList) {
                String specialty = shift.PC_Service_Team_Member__r.PC_Service_Resource__r.PC_Assigned_Specialty__c;
                if (skill.get('Name') == specialty) {
                    String srId = shift.PC_Service_Team_Member__r.PC_Service_Resource__c;
                    String srName = shift.PC_Service_Team_Member__r.PC_Service_Resource__r.Name;
                    Decimal hoursStart = getHours(String.valueOf(shift.PC_Start_Time__c));
                    Decimal hoursEnd = getHours(String.valueOf(shift.PC_End_Time__c));
                    String timeRange = getHoursRangeString(String.valueOf(shift.PC_Start_Time__c), String.valueOf(shift.PC_End_Time__c));
                    shiftsByServiceResource.put(
                        srId,
                        new Map<String, Object>{
                            'Id' => shift.Id,
                            'PC_Start_Time__c' => shift.PC_Start_Time__c,
                            'PC_End_Time__c' => shift.PC_End_Time__c,
                            'PC_Shift_Status__c' => shift.PC_Shift_Status__c,
                            'timeRange' => timeRange,
                            'SRName' => srName,
                            'left' => hoursStart,
                            'right' => hoursEnd
                        }
                    );
                }
            }

            skillsById.put(
                (String) skill.get('Id'),
                new Map<String, Object>{ 'Id' => skill.get('Id'), 'Name' => skill.get('Name'), 'shiftsByServiceResource' => shiftsByServiceResource }
            );
        }
        data.put('skills', skillsById.values());
        return data;
    }
    /**
     * @description       : Fetches Service Resource and Skills Data to be used on the Gantt Chart
     * @param             : Date formatted string in MM/DD/YYYY form
     * @return            : Returns a list of Skills-By-Resource complex object
     */
    @AuraEnabled
    public static List<Object> getResources() {
        Id pcRTId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('PC_Resource').getRecordTypeId();

        //Cannot grant pcp access through permission set for the Skills object. Cannot enforce security in this query. Apex class is secured by permission set for PC users onlu
        @SuppressWarnings('PMD.ApexCRUDViolation')
        List<ServiceResourceSkill> relevantSkills = [
            SELECT Skill.MasterLabel
            FROM ServiceResourceSkill
            WHERE ServiceResource.ResourceType = 'A' AND ServiceResource.IsActive = TRUE AND ServiceResource.RecordTypeId = :pcRTId
            ORDER BY Skill.MasterLabel ASC
        ];
        List<Object> skills = new List<Object>();
        Set<String> skillSet = new Set<String>();
        for (ServiceResourceSkill sk : relevantSkills) {
            String skillLabel = sk.Skill.MasterLabel;
            if (skillLabel != 'Chat' && skillLabel != 'Phone' && skillLabel != 'Teams') {
                skillSet.add(skillLabel);
            }
        }
        Integer key = 0;
        for (String s : skillSet) {
            skills.add(new Map<String, Object>{ 'Id' => String.valueOf(key), 'Name' => s });
            key++;
        }
        return skills;
    }
    private static Decimal getHours(String strTime) {
        String[] timeStr = strTime.split(':');
        Integer timeHour = Integer.valueOf(timeStr[0]);
        Integer timeMin = Integer.valueOf(timeStr[1]);
        return Decimal.valueOf(timeHour) + timeMin / 60.0;
    }

    private static String getHoursRangeString(String startTime, String endTime) {
        String[] timeStr1 = startTime.split(':');
        String[] timeStr2 = endTime.split(':');
        return timeStr1[0] + ':' + timeStr1[1] + ' - ' + timeStr2[0] + ':' + timeStr2[1];
    }
}
