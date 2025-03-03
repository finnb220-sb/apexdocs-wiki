/**
 * @description VCC_SOT_ServiceUserAssignTriggerhandler is for the VAHC Service Onboarding Tracker App to search for existing
 * Service User Assignments by checking for existing records with matching fields CRM Service VISN Assignment and SOT User
 */
public with sharing class VCC_SOT_ServiceUserAssignTriggerHandler {
    /**
     * @description dupSUAError is called by the VCC_SOT_ServiceUserAssignmentTrigger
     * @param newTrigSUA
     */
    public static void dupSUAError(List<VCC_Service_User_Assignment__c> newTrigSUA) {
        List<VCC_Service_User_Assignment__c> allSUAs = [
            SELECT Id, Name, VCC_CRM_VISN_Service_Assignment__c, VCC_SOT_User__c
            FROM VCC_Service_User_Assignment__c
            WITH SECURITY_ENFORCED
            LIMIT 10000
        ];

        for (VCC_Service_User_Assignment__c oneSUATrig : newTrigSUA) {
            for (Integer i = 0; i < allSUAs.size(); i++) {
                if (oneSUATrig.VCC_CRM_VISN_Service_Assignment__c == allSUAs[i].VCC_CRM_VISN_Service_Assignment__c && oneSUATrig.VCC_SOT_User__c == allSUAs[i].VCC_SOT_User__c) {
                    oneSUATrig.addError('This Service User Assignment already exists. Please use the existing record.');
                }
            }
        }
    }
}
