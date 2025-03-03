global without sharing class VCC_HeartbeatTemplateRunner implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable {
    global final string query { get; set; }

    global VCC_HeartbeatTemplateRunner() {
        Datetime now = Datetime.now();
        List<Integer> everyThreeHours = new List<Integer>{ 0, 3, 6, 9, 12, 15, 18, 21 };
        List<Integer> everySixHours = new List<Integer>{ 0, 6, 12, 18 };
        List<Integer> everyTwelveHours = new List<Integer>{ 0, 12 };

        string soqlQuery = 'SELECT Id, Method__c, AutoRun_Schedule__c, Endpoint__c, Expected_Response__c, CreatedById FROM VCC_Heartbeat_Template__c ';
        soqlQuery += 'WHERE (AutoRun_Schedule__c = \'Every Hour\') ';

        if (everyThreeHours.contains(now.hour()))
            soqlQuery += 'OR (AutoRun_Schedule__c = \'Every 3 Hours\') ';
        if (everySixHours.contains(now.hour()))
            soqlQuery += 'OR (AutoRun_Schedule__c = \'Every 6 Hours\') ';
        if (everyTwelveHours.contains(now.hour()))
            soqlQuery += 'OR (AutoRun_Schedule__c = \'Every 12 Hours\') ';

        this.query = soqlQuery;
    }

    public static void schedule() {
        System.schedule('Heartbeat API Template Runner', '0 0 * * * ?', new VCC_HeartbeatTemplateRunner());
    }

    global void execute(SchedulableContext sc) {
        VCC_HeartbeatTemplateRunner runner = new VCC_HeartbeatTemplateRunner();
        Database.executeBatch(runner, 1);
    }

    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext batchableContext, List<SObject> scope) {
        List<Id> templateIds = new List<Id>();
        for (SObject data : scope)
            templateIds.add(data.Id);

        List<VCC_Heartbeat_Template_Parameter__c> params = [
            SELECT Id, Data_Type__c, Default_Value__c, Format__c, Heartbeat_Template__c, Name, Is_Required__c
            FROM VCC_Heartbeat_Template_Parameter__c
            WHERE Heartbeat_Template__c IN :templateIds
            WITH SECURITY_ENFORCED
        ];

        List<VCC_Heartbeat_Template_Parameter__c> paramList;
        Map<Id, List<VCC_Heartbeat_Template_Parameter__c>> paramsMap = new Map<Id, List<VCC_Heartbeat_Template_Parameter__c>>();
        for (VCC_Heartbeat_Template_Parameter__c param : params) {
            paramList = paramsMap.get(param.Heartbeat_Template__c);
            if (paramList == null)
                paramList = new List<VCC_Heartbeat_Template_Parameter__c>();

            paramsMap.remove(param.Heartbeat_Template__c);

            paramList.add(param);
            paramsMap.put(param.Heartbeat_Template__c, paramList);
        }

        VCC_Heartbeat_Template__c template;
        for (SObject data : scope) {
            template = (VCC_Heartbeat_Template__c) data;
            if (template == null)
                continue;

            paramList = paramsMap.get(template.Id);
            processApiTemplate(template, paramList);
        }
    }

    global void processApiTemplate(VCC_Heartbeat_Template__c template, List<VCC_Heartbeat_Template_Parameter__c> paramList) {
        Datetime startTime, endTime;
        Integer responseCode;
        string responseBody, status;
        HttpResponse response;
        Boolean success;
        CompareResult result = new CompareResult();

        VCC_HttpRequest request = new VCC_HttpRequest();
        request.requestMethod = template.Method__c;
        request.NAMED_CRED_NAME = template.Endpoint__c;

        for (VCC_Heartbeat_Template_Parameter__c param : paramList) {
            request.addBodyParameter(param.Name, param.Default_Value__c);
        }

        startTime = Datetime.now();
        try {
            if (!Test.isRunningTest())
                response = request.makeRequestAndGetResponse();
            if (!Test.isRunningTest())
                success = (response.getStatusCode() >= 200 && response.getStatusCode() <= 299);
            if (!Test.isRunningTest())
                responseBody = response.getBody();
            if (!Test.isRunningTest())
                responseCode = response.getStatusCode();

            result = compareResponses(template.Expected_Response__c, responseBody);
            if (result.status != 'Success' && result.issues.size() > 0)
                responseBody = string.join(result.issues, ',');
        } catch (Exception e) {
            result.status = 'Error';
            result.issues.add(e.getMessage());
            responseBody = e.getMessage();
            responseCode = 500;
        }

        endTime = Datetime.now();

        recordTemplateResult(template, startTime, endTime, responseBody, responseCode, result.status);
    }

    global void recordTemplateResult(VCC_Heartbeat_Template__c template, Datetime startTime, Datetime endTime, string responseBody, Integer responseCode, string status) {
        VCC_Heartbeat_Template_Run__c run = new VCC_Heartbeat_Template_Run__c();
        run.Heartbeat_Template__c = template.Id;
        run.Start_Time__c = startTime;
        run.End_Time__c = endTime;
        run.Response__c = responseBody;
        run.Response_Code__c = string.valueOf(responseCode);
        run.Status__c = status;
        run.Triggered_By__c = 'AutoRun';

        Database.insert(run);

        if (status != 'Success')
            notifyUsers(template, run);
    }

    global class CompareResult {
        global boolean hasMissingFields { get; set; }
        global boolean hasAdditionalFields { get; set; }
        global string status { get; set; }
        global List<string> issues { get; set; }

        global CompareResult() {
            this.hasAdditionalFields = false;
            this.hasMissingFields = false;
            this.status = '';
            this.issues = new List<string>();
        }
    }

    global static CompareResult compareResponses(string expectedResponse, string actualResponse) {
        //test
        //expectedResponse = '{"sites":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';

        CompareResult result = new CompareResult();
        result.status = 'Success';

        Map<string, string> expectedFieldMap = jsonToFieldMap(expectedResponse);
        Map<string, string> actualFieldMap = jsonToFieldMap(actualResponse);

        for (string field : expectedFieldMap.keySet()) {
            if (!actualFieldMap.containsKey(field)) {
                result.issues.add(field + ': The field was NOT found in the response.');
                result.hasMissingFields = true;
                continue;
            }
        }

        for (string field : actualFieldMap.keySet()) {
            if (!expectedFieldMap.containsKey(field)) {
                result.issues.add(field + ': The field was NOT EXPECTED in the response.');
                result.hasAdditionalFields = true;
                continue;
            }
        }

        if (result.hasMissingFields)
            result.status = 'Failed';
        if (result.status != 'Failed' && result.hasAdditionalFields)
            result.status = 'Warning';
        return result;
    }

    global static Map<string, string> jsonToFieldMap(string jsonString) {
        Map<string, string> fieldMap = new Map<string, string>();

        try {
            string currentName, currentType, currentParent;
            JSONParser parser = JSON.createParser(jsonString);
            while (parser.nextToken() != null) {
                currentName = parser.getCurrentName();
                if (string.isBlank(currentName))
                    currentName = 'ROOT';

                if (parser.getCurrentToken() == JSONToken.START_ARRAY)
                    fieldMap = extractArrayFields(parser, fieldMap, currentName);
                if (parser.getCurrentToken() == JSONToken.START_OBJECT)
                    fieldMap = extractObjectFields(parser, fieldMap, currentName);
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
                    fieldMap.put(currentName, 'Field');
            }
        } catch (Exception e) {
        }

        return fieldMap;
    }

    static Map<string, string> extractArrayFields(JSONParser parser, Map<string, string> fieldMap, string parentName) {
        string currentName = string.isBlank(parentName) ? parser.getCurrentName() : parentName + '.' + parser.getCurrentName();
        fieldMap.put(parentName, 'Array');

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.END_ARRAY)
                break;
            if (parser.getCurrentToken() == JSONToken.START_ARRAY)
                fieldMap = extractArrayFields(parser, fieldMap, currentName);
            if (parser.getCurrentToken() == JSONToken.START_OBJECT)
                fieldMap = extractObjectFields(parser, fieldMap, parentName);
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME)
                fieldMap.put(parentName + '.' + currentName, 'Field');
        }

        return fieldMap;
    }

    static Map<string, string> extractObjectFields(JSONParser parser, Map<string, string> fieldMap, string parentName) {
        string currentName = string.isBlank(parentName) ? parser.getCurrentName() : parentName + '.' + parser.getCurrentName();
        fieldMap.put(currentName, 'Object');

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.END_OBJECT)
                break;
            if (parser.getCurrentToken() == JSONToken.START_ARRAY)
                fieldMap = extractArrayFields(parser, fieldMap, currentName);
            if (parser.getCurrentToken() == JSONToken.START_OBJECT)
                fieldMap = extractObjectFields(parser, fieldMap, currentName);
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                currentName = parentName + '.' + parser.getCurrentName();
                fieldMap.put(currentName, 'Field');
            }
        }

        return fieldMap;
    }

    global void notifyUsers(VCC_Heartbeat_Template__c template, VCC_Heartbeat_Template_Run__c runResult) {
        List<CustomNotificationType> types = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Hearbeat_API_Notifications'
        ];

        if (types.size() == 0)
            return;

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        if (runResult.Status__c == 'Warning')
            notification.setTitle('API Run Warning: ' + template.Name);
        if (runResult.Status__c == 'Error')
            notification.setTitle('API Run ERROR: ' + template.Name);
        notification.setBody('Click to see the details.');
        notification.setNotificationTypeId(types[0].Id);
        notification.setTargetId(runResult.id);

        try {
            set<string> recipientsId = new Set<string>{ template.CreatedById };
            notification.send(recipientsId);
        } catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }

    global void finish(Database.BatchableContext batchableContext) {
    }
}
