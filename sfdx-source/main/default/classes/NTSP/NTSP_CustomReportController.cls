/**
 * @description       : Class used as the contoller for the ntsp_CaseReport LWC
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 03-22-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-22-2022   George Elias                          Initial Version
 **/
public with sharing class NTSP_CustomReportController {
    /**
     * @description Method to dynamically compile combobox options based on a look up field and where clause
     * @author George Elias | 03-22-2022
     * @param searchFieldName - API Name of the look up field to use to build combobox options
     * @param relatedWhereClause - SOQL Where clause used as a look up filter
     * @return  List of maps that hold the combobox options
     **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> fetchPicklistOptions(String searchFieldName, String relatedWhereClause) {
        try {
            List<Map<String, String>> returnList = new List<Map<String, String>>();
            if (searchFieldName != 'None') {
                Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('NTSP_Case__c');
                Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
                Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
                Schema.DescribeFieldResult lookupField = mapFields.get(searchFieldName).getDescribe();

                String referenceObj = lookupField.getReferenceTo()[0].getDescribe().getName();

                String query =
                    'SELECT Id, Name FROM ' +
                    String.escapeSingleQuotes(referenceObj) +
                    ' ' +
                    (relatedWhereClause != 'None' ? 'WHERE ' + relatedWhereClause : '') +
                    ' ORDER BY Name';
                List<SObject> refSearch = Database.query(query);
                if (refSearch.size() > 0) {
                    returnList.add(new Map<String, String>{ 'label' => 'All', 'value' => 'all' });
                }
                for (SObject sObj : refSearch) {
                    returnList.add(new Map<String, String>{ 'label' => (String) sObj.get('Name'), 'value' => (String) sObj.get('Id') });
                }
            }
            return returnList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to dynamically compile SOQL queries used to cuild the report on the front end
     * @author George Elias | 03-22-2022
     * @param whereClause - SOQL Where clause used as the report filter
     * @param searchId - related record Id used to filter the report data
     * @param searchFieldName - Lookup API Name of the searchId parameter
     * @param daySubField - API Name of the field used to build the sub count of the daily report
     * @param quarterSubClause - SOQL Where clause used as a report filter for the sub quarterly report
     * @return  Map containing lists of report data
     **/
    @AuraEnabled(cacheable=true)
    public static Map<String, List<sObject>> fetchCustomReportData(String whereClause, String searchId, String searchFieldName, String daySubField, String quarterSubClause) {
        try {
            Map<String, List<SObject>> returnMap = new Map<String, List<SObject>>();

            String objDayQuery =
                'SELECT Consult_Date__c' +
                (daySubField != 'None' ? ', ' + daySubField : '') +
                ' FROM NTSP_Case__c' +
                ' WHERE ' +
                whereClause +
                (searchId != 'all' && searchFieldName != 'None' ? ' AND ' + searchFieldName + ' = \'' + searchId + '\' ' : '') +
                ' ORDER BY Consult_Date__c';
            returnMap.put('countByDay', Database.query(objDayQuery));

            String objQuarterQuery =
                'SELECT CALENDAR_YEAR(Consult_Date__c) calendarYear, CALENDAR_QUARTER(Consult_Date__c) calendarQuarter, Count(Id) recCount ' +
                'FROM NTSP_Case__c ' +
                'WHERE Consult_Date__c = LAST_N_QUARTERS:3 ' +
                (whereClause != 'None' ? 'AND ' + whereClause + ' ' : '') +
                (searchId != 'all' &&
                    searchFieldName != 'None'
                    ? ' AND ' + String.escapeSingleQuotes(searchFieldName) + ' = \'' + String.escapeSingleQuotes(searchId) + '\' '
                    : '') +
                'GROUP BY CALENDAR_YEAR(Consult_Date__c), CALENDAR_QUARTER(Consult_Date__c) ' +
                'ORDER BY CALENDAR_YEAR(Consult_Date__c) desc, CALENDAR_QUARTER(Consult_Date__c) desc';

            returnMap.put('countByQuarter', Database.query(objQuarterQuery));

            String quarterSubField =
                'SELECT CALENDAR_YEAR(Consult_Date__c) calendarYear, CALENDAR_QUARTER(Consult_Date__c) calendarQuarter, Count(Id) recCount ' +
                'FROM NTSP_Case__c ' +
                'WHERE Consult_Date__c = LAST_N_QUARTERS:3 ' +
                (whereClause != 'None' ? 'AND ' + whereClause + ' ' : '') +
                (quarterSubClause != 'None' ? 'AND ' + quarterSubClause + ' ' : '') +
                (searchId != 'all' &&
                    searchFieldName != 'None'
                    ? ' AND ' + String.escapeSingleQuotes(searchFieldName) + ' = \'' + String.escapeSingleQuotes(searchId) + '\' '
                    : '') +
                'GROUP BY CALENDAR_YEAR(Consult_Date__c), CALENDAR_QUARTER(Consult_Date__c) ' +
                'ORDER BY CALENDAR_YEAR(Consult_Date__c) desc, CALENDAR_QUARTER(Consult_Date__c) desc';

            returnMap.put('subCountByQuarter', Database.query(quarterSubField));

            String relatedQuarterQuery =
                'SELECT CALENDAR_YEAR(Consult_Date__c) calendarYear, CALENDAR_QUARTER(Consult_Date__c) calendarQuarter, Count(Id) recCount ' +
                'FROM NTSP_Case__c ' +
                'WHERE Consult_Date__c = LAST_N_QUARTERS:3 ' +
                (whereClause != 'None' ? 'AND ' + whereClause + ' ' : '') +
                (searchId != 'all' &&
                    searchFieldName != 'None'
                    ? ' AND ' + String.escapeSingleQuotes(searchFieldName) + ' = \'' + String.escapeSingleQuotes(searchId) + '\' '
                    : '') +
                'GROUP BY CALENDAR_YEAR(Consult_Date__c), CALENDAR_QUARTER(Consult_Date__c) ' +
                'ORDER BY CALENDAR_YEAR(Consult_Date__c) desc, CALENDAR_QUARTER(Consult_Date__c) desc';

            returnMap.put('countByQuarter', Database.query(relatedQuarterQuery));

            String peerQuarterQuery =
                'SELECT CALENDAR_YEAR(Date_of_Review__c) calendarYear, CALENDAR_QUARTER(Date_of_Review__c) calendarQuarter, Count(Id) recCount ' +
                'FROM NTSP_Peer_Review__c ' +
                'WHERE (Date_of_Review__c = THIS_QUARTER OR Date_of_Review__c = LAST_N_QUARTERS:3) ' +
                (searchId != 'all' &&
                    searchFieldName != 'None'
                    ? ' AND NTSP_Case__r.' + String.escapeSingleQuotes(searchFieldName) + ' = \'' + String.escapeSingleQuotes(searchId) + '\' '
                    : '') +
                'GROUP BY CALENDAR_YEAR(Date_of_Review__c), CALENDAR_QUARTER(Date_of_Review__c) ' +
                'ORDER BY CALENDAR_YEAR(Date_of_Review__c) desc, CALENDAR_QUARTER(Date_of_Review__c) desc';

            //RecordType.Name = \'Consultant Peer Review\' AND

            returnMap.put('prCountByQuarter', Database.query(peerQuarterQuery));

            return returnMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
