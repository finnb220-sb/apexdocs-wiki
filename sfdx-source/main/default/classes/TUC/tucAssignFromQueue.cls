public with sharing class tucAssignFromQueue {
    @AuraEnabled
    public static DataTableResponse getObjectRecords(
        String objectAPI,
        String filterClause,
        String fieldAPIList,
        String orderBy,
        Boolean useStationFiltering
    ) {
        String query;
        String VistaInstance;
        String fields = fieldAPIList;
        Boolean containsId = false;
        List<SObject> objectRecords = new List<SObject>();
        // if no object is sent then do nothing
        if (objectAPI != null && fieldAPIList != '') {
            // if no fields are sent then do nothing
            if (fieldAPIList != null && fieldAPIList != '') {
                // parse out the fields
                List<String> fieldAPIStringList = fieldAPIList.split(',');
                for (String apiFieldName : fieldAPIStringList) {
                    apiFieldName = apiFieldName.trim();
                    apiFieldName = apiFieldName.toLowerCase();
                    if (apiFieldName == 'id') {
                        containsId = true;
                    }
                }
                if (!containsId) {
                    fields += ',Id';
                }
                // create base query
                query = 'SELECT ' + fields + ' FROM ' + objectAPI;
                // get station list if necessary
                List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> VistaInstanceList = new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>();
                String siteSet = '';
                if (useStationFiltering) {
                    VistaInstanceList = [
                        SELECT VistA_Instance__c
                        FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
                        WHERE User_Id__c = :UserInfo.getUserId()
                        WITH SECURITY_ENFORCED
                    ];
                    for (IAM_SSOi_Vista_Instance_to_User_DUZ__c thisSite : VistaInstanceList) {
                        siteSet = SiteSet.length() > 0
                            ? siteSet + ', \'' + thisSite.VistA_Instance__c + '\''
                            : '\'' + thisSite.VistA_Instance__c + '\'';
                    }
                }

                // get VISN list
                List<Group> groupList = new List<Group>();
                List<GroupMember> memberList = new List<GroupMember>();
                List<Id> groupIdList = new List<Id>();
                String visnSet = '';
                memberList = [
                    SELECT GroupId
                    FROM GroupMember
                    WHERE UserOrGroupId = :UserInfo.getUserId()
                    WITH SECURITY_ENFORCED
                ];
                for (GroupMember member : memberList) {
                    groupIdList.add(member.GroupId);
                }
                groupList = [SELECT DeveloperName FROM Group WHERE Id IN :groupIdList WITH SECURITY_ENFORCED];
                for (Group g : groupList) {
                    if (g.DeveloperName.startsWith('TUC_') || g.DeveloperName.startsWith('tuc_')) {
                        String truncatedName = g.DeveloperName.substring(3, 6).replaceAll('_', '');
                        if (truncatedName.isNumericSpace()) {
                            visnSet = visnSet.length() > 0 ? visnSet + ', ' + truncatedName : '' + truncatedName;
                        }
                    }
                }

                // add filter clause
                if (siteSet != '') {
                    query += ' WHERE TUC_Facility_Id__c IN (' + SiteSet + ')';
                    if (filterClause != null && filterClause != '') {
                        query += ' AND ' + filterClause + ' AND TUC_Facility_Id__c IN (' + SiteSet + ')';
                        query += ' AND TUC_Assigned_VISN__c IN (' + visnSet + ')'; //add in query for visn on the end, after the site filter
                    }
                } else if (filterClause != null && filterClause != '') {
                    query += ' WHERE ' + filterClause;
                    query += ' AND TUC_Assigned_VISN__c IN (' + visnSet + ')'; //add in query for visn on the end, after the site filter
                }
                // add sort clause
                if (orderBy != null && orderBy != '') {
                    query += ' ORDER BY ' + orderBy;
                }
                // add limit
                query += ' LIMIT 50';
                // fetch records
                objectRecords = database.query(query); //NOPMD
            }
        }

        //
        //fetch requested records
        //
        // begin process of creating query

        //Check to see if records returned
        if (objectRecords == null || objectRecords.isEmpty()) {
            return new DataTableResponse();
        }
        List<DataTableColumns> columns = new List<DataTableColumns>();
        List<String> fieldNames = new List<String>();
        List<Map<String, Object>> recordFieldDetails = new List<Map<String, Object>>();

        Map<String, String> fieldTypeMapping = new Map<String, String>();

        fieldNames.addAll(fields.replaceAll(' ', '').split(','));
        for (Sobject so : objectRecords) {
            Map<String, Object> fieldDetails = new Map<String, Object>();
            for (String name : fieldNames) {
                if (name.contains('.')) {
                    String field1 = name.split('\\.', 2)[1];
                    String objectName = name.split('\\.', 2)[0];
                    String objectName1 = field1.contains('.') ? field1.split('\\.', 2)[0] : '';
                    String fieldName = objectName1 != '' ? field1.split('\\.', 2)[1] : name.split('\\.', 2)[1];
                    if (objectName1 != '') {
                        if (
                            so.getSObject(objectName) != null &&
                            so.getSObject(objectName).getSObject(objectName1) != null
                        ) {
                            fieldDetails.put(name, so.getSObject(objectName).getSObject(objectName1).get(fieldName));
                            fieldTypeMapping.put(
                                name,
                                '' + so.getSObject(objectName).getSObject(objectName1).getSObjectType()
                            );
                        } else {
                            fieldDetails.put(name, '');
                            fieldTypeMapping.put(name, objectName1);
                        }
                    } else {
                        if (so.getSObject(objectName) != null) {
                            fieldDetails.put(name, so.getSObject(objectName).get(fieldName));
                            fieldTypeMapping.put(name, '' + so.getSObject(objectName).getSObjectType());
                        } else {
                            fieldDetails.put(name, '');
                            fieldTypeMapping.put(name, objectName);
                        }
                    }
                } else {
                    fieldDetails.put(name, so.get(name));
                    fieldTypeMapping.put(name, objectAPI);
                }
            }
            recordFieldDetails.add(fieldDetails);
        }
        for (String name : fieldNames) {
            if (name.toLowerCase() != 'id') {
                DataTableColumns dt = new DataTableColumns();

                if (name.contains('.')) {
                    String instr = '';
                    if (name.contains('__r')) {
                        instr = name.replace('.', ' ').replaceAll('__r', '__c');
                    } else {
                        instr = name.replace('.', 'Id ');
                    }
                    String outStr = '';
                    List<String> words = new List<String>();
                    words.addAll(inStr.split(' '));
                    String labelstr = '';
                    labelstr = (String) Schema.getGlobalDescribe()
                        .get(objectAPI)
                        .getDescribe()
                        .fields.getMap()
                        .get(words[0])
                        .getDescribe()
                        .getLabel();
                    //only replacing multiple words containing ID
                    dt.label = labelstr.replace(' ID', ' Name');
                } else {
                    dt.Label = (String) Schema.getGlobalDescribe()
                        .get(objectAPI)
                        .getDescribe()
                        .fields.getMap()
                        .get(name)
                        .getDescribe()
                        .getLabel();
                }

                String objectToDescribe = fieldTypeMapping.get(name);
                List<String> fieldSplit = name.split('\\.');
                String fieldToDescribe = fieldSplit[fieldSplit.size() - 1];
                Schema.DescribeFieldResult dfr = Schema.getGlobalDescribe()
                    .get(objectToDescribe)
                    .getDescribe()
                    .fields.getMap()
                    .get(fieldToDescribe)
                    .getDescribe();
                dt.fieldName = name.trim();

                String fieldType = '' + dfr.getType();
                if (
                    fieldType == 'STRING' ||
                    fieldType == 'REFERENCE' ||
                    fieldType == 'PICKLIST' ||
                    fieldType == 'TEXTAREA'
                ) {
                    dt.type = 'text';
                } else if (fieldType == 'DATETIME' || fieldType == 'DATE') {
                    dt.type = 'date';
                } else if (fieldType == 'DECIMAL') {
                    dt.type = 'number';
                } else {
                    dt.type = fieldType.toLowerCase();
                }

                dt.sortable = 'true';
                dt.wrapText = 'true';

                columns.add(dt);
            }
        }
        DataTableResponse wrap = new DataTableResponse();
        wrap.recordFieldDetails = recordFieldDetails;
        wrap.columns = columns;
        wrap.objectName = objectAPI;
        return wrap;
    }

    @AuraEnabled
    public static string updateSelectedRow(String recordId, String objectName) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
        sObject sObj = targetType.newSObject();
        sObj = database.query('SELECT Id, OwnerId FROM ' + objectName + ' WHERE Id=:recordId LIMIT 1 FOR UPDATE'); //NOPMD
        if (sobj != null && ((String) sobj.get('OwnerId')).startsWith('00G')) {
            sObj.put('OwnerId', UserInfo.getUserId());

            //Database.update(sObj);
            Database.SaveResult results = Database.update(sObj);

            if (results.isSuccess()) {
                return 'success';
            } else {
                return 'error';
            }
        } else if (sobj != null && !((String) sobj.get('OwnerId')).startsWith('00G')) {
            User username = [SELECT Name FROM User WHERE Id = :(String) sobj.get('OwnerId') WITH SECURITY_ENFORCED];
            return 'error_' + username.Name;
        }

        return null;
    }

    @AuraEnabled
    public static void publishEvent(String passingField, String eventObject) {
        try {
            List<SObject> eventList = new List<SObject>(); //start with a generic list
            SObjectType eventType = ((SObject) Type.forName(eventObject).newInstance()).getSObjectType(); //eventObject instantiates the object as that event type
            Sobject genPlatformEvent = eventType.newSObject(); //actually create object
            genPlatformEvent.put('flowInputField__c', passingField); //passing field gets put into the flowInputField if that exists
            eventList.add(genPlatformEvent); //add object to list
            EventBus.publish(eventList);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class DataTableResponse {
        @AuraEnabled
        public List<Map<String, Object>> recordFieldDetails { get; set; }
        @AuraEnabled
        public List<DataTableColumns> columns { get; set; }
        @AuraEnabled
        public String buttonName { get; set; }
        @AuraEnabled
        public String objectName { get; set; }
    }
    public class DataTableColumns {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
        @AuraEnabled
        public String sortable { get; set; }
        @AuraEnabled
        public String wrapText { get; set; }
    }
}
