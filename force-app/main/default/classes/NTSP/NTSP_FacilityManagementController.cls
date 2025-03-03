/**
 * @description       : Class used as the controller for the ntsp_faciltiyButton Lightning Web Component
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
public with sharing class NTSP_FacilityManagementController {
    /**
     * @description Method to check if the user is a facility manager
     * @author George Elias | 02-16-2022
     * @return  Boolean - returns true if user has access to use the add site button
     **/
    @AuraEnabled(cacheable=true)
    public static boolean canAccessButton() {
        return Schema.sObjectType.NTSP_Facility__c.fields.NTSP_Registered_Site__c.isUpdateable();
    }

    @AuraEnabled(cacheable=true)
    public static List<NTSP_Facility__c> fetchNTSPSite(Id locationId) {
        return [SELECT Id, Name, NTSP_Registered_Site__c, Station_Code__c FROM NTSP_Facility__c WHERE Location__c = :locationId LIMIT 1];
    }
}
