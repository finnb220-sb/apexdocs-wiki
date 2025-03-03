/**
 * @description       : Class used as the controller for the ntsp_nurseNote and ntsp_caseSummary Lightning Web Component
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
public with sharing class NTSP_NurseNoteController {
    /**
     * @description Method to fetch and return the case and note records
     * @author George Elias | 02-16-2022
     * @return  Map<String, Object> - Map containing 'case' and 'note' values
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String, Object> fetchCaseSummary(String caseId) {
        try {
            final Map<String, Object> returnMap = new Map<String, Object>();

            returnMap.put(
                'case',
                [
                    SELECT Id, Consult_Date__c, Consult_Time_Local_Time_24_hrs__c, LKW_Date__c, LKW_Time_24_hr__c, Telestroke_Consultant__r.Name, Location__c, NTSP_Facility__r.Name
                    FROM NTSP_Case__c
                    WHERE Id = :caseId
                    LIMIT 1
                ]
            );

            returnMap.put(
                'note',
                [
                    SELECT
                        Id,
                        Name_of_Caller__c,
                        Position_of_Caller__c,
                        Other_Description__c,
                        Direct_Telephone_Number_of_Caller__c,
                        Extension_of_Caller__c,
                        Physician_Caring_for_Patient__c,
                        BEFAST_Symptoms__c,
                        LVO_Symptoms__c,
                        Criteria_Met__c,
                        Handoff_Date__c,
                        Handoff_Time__c,
                        Site_Requesting_Consultation__c,
                        Notes__c,
                        BEFAST_Balance_Difficulty__c,
                        BEFAST_Incoordination__c,
                        BEFAST_Walking_Difficulty__c,
                        BEFAST_Eyes_Vision_Changes__c,
                        BEFAST_Blurred_Vision__c,
                        BEFAST_Double_Vision__c,
                        BEFAST_Loss_of_Vision__c,
                        BEFAST_Facial_Weakness__c,
                        BEFAST_Left_Droop__c,
                        BEFAST_Right_Droop__c,
                        BEFAST_Left_Numbness__c,
                        BEFAST_Right_Numbness__c,
                        BEFAST_Arm_Leg_Weakness__c,
                        BEFAST_Left_Lower_Extremity_Weakness__c,
                        BEFAST_Right_Lower_Extremity_Weakness__c,
                        BEFAST_Left_Upper_Extremity_Weakness__c,
                        BEFAST_Right_Upper_Extremity_Weakness__c,
                        BEFAST_Arm_Leg_Numbness__c,
                        BEFAST_Left_Lower_Extremity_Numbness__c,
                        BEFAST_Right_Lower_Extremity_Numbness__c,
                        BEFAST_Left_Upper_Extremity_Numbness__c,
                        BEFAST_Right_Upper_Extremity_Numbness__c,
                        BEFAST_Speech_Changes__c,
                        BEFAST_Difficulty_Comprehending_Words__c,
                        BEFAST_Difficulty_Finding_Words__c,
                        BEFAST_Slurred_Garbled_Speech__c,
                        BEFAST_LKW__c,
                        LVO_Hemiparesis__c,
                        LVO_Right_or_Left_Hemiparesis__c,
                        LVO_Arm_Leg_Weakness__c,
                        LVO_Left_Lower_Extremity_Weakness__c,
                        LVO_Right_Lower_Extremity_Weakness__c,
                        LVO_Left_Upper_Extremity_Weakness__c,
                        LVO_Right_Upper_Extremity_Weakness__c,
                        LVO_Arm_Leg_Numbness__c,
                        LVO_Left_Lower_Extremity_Numbness__c,
                        LVO_Right_Lower_Extremity_Numbness__c,
                        LVO_Left_Upper_Extremity_Numbness__c,
                        LVO_Right_Upper_Extremity_Numbness__c,
                        LVO_Vision_Loss__c,
                        LVO_Aphasia__c,
                        LVO_Neglect__c,
                        LVO_Gaze_Deviation__c,
                        LVO_LKW__c,
                        Consult_Type__c,
                        CreatedById
                    FROM NTSP_Nurse_Note__c
                    WHERE NTSP_Case__c = :caseId
                    LIMIT 1
                ]
            );

            final Boolean isNurse = FeatureManagement.checkPermission('NTSP_Triage_Nurse');
            returnMap.put('isNurse', isNurse);

            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
