public with sharing class tucLookupController {
    @AuraEnabled
    public static List<sobject> findRecords(String siteId, String searchParam, String persona) {
        String nameCondition = '';
        if (persona == 'VCC_Virtual_Visit_Progress_Note') {
            nameCondition = ' AND (Name LIKE \'%' + String.escapeSingleQuotes('ARNP') + '%\'' + ' OR Name LIKE \'%' + String.escapeSingleQuotes('MD') + '%\')';
        }
        if (persona == 'VCC_Scheduling_Progress_Note') {
            nameCondition = ' AND (Name LIKE \'%' + String.escapeSingleQuotes('ADMIN MSA') + '%\')';
        }
        if (persona == 'VCC_Tier_I_Progress_Note') {
            nameCondition = ' AND (Name LIKE \'%' + String.escapeSingleQuotes('PHARM PHONE') + '%\')';
        }
        if (persona == 'VCC_Tier_II_Progress_Note') {
            nameCondition = ' AND (Name LIKE \'%' + String.escapeSingleQuotes('PHARM') + '%\')';
        }
        if (persona == 'VCC_Clinical_Triage_Note_Progress_Note') {
            nameCondition = ' AND (Name LIKE \'%' + String.escapeSingleQuotes('RN ') + '%\')';
        }
        String query = 'SELECT Id, Name ,VCC_Site_Id__c FROM HealthcareFacility WHERE VCC_Site_Id__c = ' + siteId + nameCondition;
        if (String.isNotBlank(searchParam)) {
            if (persona == 'VCC_Virtual_Visit_Progress_Note') {
                query = query.replace(')', ') AND ( Name LIKE \'%' + String.escapeSingleQuotes(searchParam) + '%\')');
            } else {
                query = query.replace(')', ' AND Name LIKE \'%' + String.escapeSingleQuotes(searchParam) + '%\')');
            }
        }
        List<HealthcareFacility> lstObject = Database.query(query); //NOPMD
        return lstObject;
    }
}
