/**
 * @description       : Trigger Handler for PC_Service_Team_Member__c.
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen Hamilton
 * @last modified on  : 08-17-2023
 * @last modified by  : Edwin Schaeffer / Justin Wagner
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   08-16-2023   Edwin Schaeffer                      Initial Version
 * 2.0   08-17-2023   Justin Wagner                        Fixed Map/Keys appeared on the record in method: checkIfTeamMembersExist
 **/
public with sharing class PC_ServiceTeamMemberTriggerHandler {
    private String replaceText = '{specialist}';
    private String errorMessage = Label.PC_Duplicate_Service_Team_Member;
    /**
     * @description Method to search for duplicate team members and provide error messages.
     * @author Edwin Schaeffer | 08-16-2023
     * @param pcTeamListNew - List of new records from before Trigger (update and insert)
     * @param pcTeamListOldMap - Map of existing records (in the case of update)
     * @return  void
     **/
    public void checkIfTeamMembersExist(List<PC_Service_Team_Member__c> pcTeamListNew, Map<Id, PC_Service_Team_Member__c> pcTeamListOldMap) {
        Set<Id> pcServiceIds = new Set<Id>();
        Set<Id> pcServiceResourceIds = new Set<Id>();
        // Creates a extKey map using a concatenation of PC_ServiceId + PC_Service_Resource__c
        // In the case of a bulk update this throws errors if duplicate Team Members are in the same dataload
        Map<String, PC_Service_Team_Member__c> newSTMExtIdMap = new Map<String, PC_Service_Team_Member__c>();
        for (PC_Service_Team_Member__c newTeamMember : pcTeamListNew) {
            String extKey = newTeamMember.PC_Service__c + '_' + newTeamMember.PC_Service_Resource__c;
            if (newSTMExtIdMap.containsKey(extKey)) {
                newTeamMember.addError(Label.PC_Duplicate_Service_Team_Member); //only check against records inserted in this DML operation, do updates in second loop
            } else {
                newSTMExtIdMap.put(extKey, newTeamMember);
                pcServiceIds.add(newTeamMember.PC_Service__c);
                pcServiceResourceIds.add(newTeamMember.PC_Service_Resource__c);
            }
        }

        // This throws errors in case duplicate team members already exist in the database.
        List<PC_Service_Team_Member__c> pcSTMList = [
            SELECT Id, PC_Service__c, PC_Service_Resource__c, PC_Service_Resource__r.Name
            FROM PC_Service_Team_Member__c
            WHERE PC_Service__c IN :pcServiceIds AND PC_Service_Resource__c IN :pcServiceResourceIds
            WITH SECURITY_ENFORCED
        ];

        for (PC_Service_Team_Member__c pcTeamMember : pcSTMList) {
            String extKey = pcTeamMember.PC_Service__c + '_' + pcTeamMember.PC_Service_Resource__c;
            PC_Service_Team_Member__c newTeamMember = newSTMExtIdMap.get(extKey);
            if (newTeamMember != null) {
                // pcTeamListOldMap == null will be true if Insert
                if (pcTeamListOldMap == null) {
                    newTeamMember.PC_Service__c.addError(errorMessage.replace(replaceText, pcTeamMember.PC_Service_Resource__r.Name));
                } else if (
                    pcTeamListOldMap.containsKey(newTeamMember.Id) &&
                    (pcTeamListOldMap.get(newTeamMember.Id).PC_Service__c != newTeamMember.PC_Service__c ||
                    pcTeamListOldMap.get(newTeamMember.Id).PC_Service_Resource__c != newTeamMember.PC_Service_Resource__c)
                ) {
                    newTeamMember.PC_Service__c.addError(errorMessage.replace(replaceText, pcTeamMember.PC_Service_Resource__r.Name));
                }
            }
        }
    }
}
