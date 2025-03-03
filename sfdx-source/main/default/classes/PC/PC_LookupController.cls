/**
* @description       : Class used in conjunction with LookupSearchResult for use in pcScheduleShiftsController
					   Used to provide a custom lookup when Selecting PC Team Members on the Schedule Tab of the PC_Service__c record page.
* @author            : Edwin Schaeffer
* @group             : Booz Allen Hamilton
* @last modified on  : 02-15-2023
* Modifications Log
* Ver   Date         Author                               Modification
* 1.0   02-14-2023   Edwin Schaeffer                      Initial Version
**/
public without sharing class PC_LookupController {
    private final static Integer MAX_RESULTS = 5;

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> search(String searchTerm, String serviceId) {
        // Prepare query parameters
        searchTerm += '%';

        // Execute search query
        List<PC_Service_Team_Member__c> searchResults = [
            SELECT Id, PC_Service_Resource__r.Name
            FROM PC_Service_Team_Member__c
            WHERE PC_Service__c = :serviceId AND PC_Service_Resource__r.Name LIKE :searchTerm
            WITH SECURITY_ENFORCED
            LIMIT :MAX_RESULTS
        ];
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Extract Team Members & convert them into LookupSearchResult
        String stmIcon = 'standard:key_dates';
        PC_Service_Team_Member__c[] pcServiceTeamMembers = (List<PC_Service_Team_Member__c>) searchResults;
        for (PC_Service_Team_Member__c pcstm : pcServiceTeamMembers) {
            String subtitle = 'Service Team Member';
            results.add(new LookupSearchResult(pcstm.Id, 'PC_Service_Team_Member__c', stmIcon, pcstm.PC_Service_Resource__r.Name, subtitle));
        }
        // Optionally sort all results on title
        results.sort();

        return results;
    }

    @AuraEnabled(cacheable=true scope='global')
    public static List<LookupSearchResult> getSomeResults(String serviceId) {
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        List<PC_Service_Team_Member__c> pcTeamMemberList = [
            SELECT Id, PC_Service_Resource__r.Name
            FROM PC_Service_Team_Member__c
            WHERE PC_Service__c = :serviceId AND PC_Service_Resource__r.Name != NULL
            WITH SECURITY_ENFORCED
            LIMIT 5
        ];
        // Convert recent records into LookupSearchResult
        for (PC_Service_Team_Member__c pcMember : pcTeamMemberList) {
            results.add(new LookupSearchResult(pcMember.Id, '', 'standard:key_dates', pcMember.PC_Service_Resource__r.Name, ''));
        }
        return results;
    }
}
