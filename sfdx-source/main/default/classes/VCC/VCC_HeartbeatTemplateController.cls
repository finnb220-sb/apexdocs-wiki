public without sharing class VCC_HeartbeatTemplateController {
    @TestVisible
    @AuraEnabled
    public static string getTemplateInfo(string recordId) {
        VCC_HeartbeatTemplate template = new VCC_HeartbeatTemplate();
        if (!string.isBlank(recordId)) {
            template = VCC_HeartbeatUtility.getTemplate(recordId);
        }

        return JSON.serialize(template);
    }

    @AuraEnabled
    public static string saveTemplateInfo(string data) {
        VCC_HeartbeatTemplate template;

        try {
            template = (VCC_HeartbeatTemplate) JSON.deserialize(data, VCC_HeartbeatTemplate.class);
            template = VCC_HeartbeatUtility.saveTemplate(template);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serialize(template);
    }

    @TestVisible
    static VCC_HeartbeatTemplate.TestResult setErrors(Exception e, VCC_HeartbeatTemplate.TestResult result) {
        result.success = false;
        result.status = 500;
        result.message = e.getMessage();
        return result;
    }

    @AuraEnabled
    public static string runTest(string testData) {
        VCC_HeartbeatTemplate.TestResult result = new VCC_HeartbeatTemplate.TestResult();
        VCC_HeartbeatTemplate.TestRunInfo info;
        DateTime startTime, endTime;
        string status;
        VCC_HeartbeatTemplateRunner.CompareResult compareResult = new VCC_HeartbeatTemplateRunner.CompareResult();

        try {
            info = (VCC_HeartbeatTemplate.TestRunInfo) JSON.deserialize(testData, VCC_HeartbeatTemplate.TestRunInfo.class);

            VCC_HttpRequest request = new VCC_HttpRequest();
            request.requestMethod = info.method;
            request.NAMED_CRED_NAME = info.endpoint;

            for (VCC_HeartbeatTemplate.Param param : info.params)
                request.addBodyParameter(param.name, param.value);

            HttpResponse response;
            startTime = Datetime.now();
            if (!Test.isRunningTest())
                response = request.makeRequestAndGetResponse();
            endTime = Datetime.now();
            if (!Test.isRunningTest())
                result.success = (response.getStatusCode() >= 200 && response.getStatusCode() <= 299);
            if (!Test.isRunningTest())
                result.message = response.getBody();
            if (!Test.isRunningTest())
                result.status = response.getStatusCode();
            if (!Test.isRunningTest())
                status = string.valueOf(response.getStatusCode());

            compareResult = VCC_HeartbeatTemplateRunner.compareResponses(info.expectedResponse, result.message);

            boolean partialSuccess = (result.success && compareResult.status != 'Success');
            if (partialSuccess && compareResult.status == 'Error')
                result.success = false;
        } catch (Exception e) {
            result = setErrors(e, result);
        }

        VCC_Heartbeat_Template_Run__c run = new VCC_Heartbeat_Template_Run__c();
        if (string.isNotBlank(info.id))
            run.Heartbeat_Template__c = info.id;
        if (string.isNotBlank(info.id))
            run.Start_Time__c = startTime;
        if (string.isNotBlank(info.id))
            run.End_Time__c = endTime;
        if (string.isNotBlank(info.id))
            run.Response__c = result.message;
        if (string.isNotBlank(info.id))
            run.Response_Code__c = status;
        if (string.isNotBlank(info.id))
            run.Status__c = compareResult.status;
        if (string.isNotBlank(info.id))
            run.Triggered_By__c = 'Manual Run';
        if (string.isNotBlank(info.id) && Schema.sObjectType.VCC_Heartbeat_Template_Run__c.isCreateable())
            Database.insert(run);

        //notify users
        CustomNotificationType notificationType = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Hearbeat_API_Notifications'
            WITH USER_MODE
        ];

        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('API Run Failure.');
        notification.setBody('The API template run for ' + 'Test Run failed.');
        notification.setNotificationTypeId(notificationType.Id);
        if (string.isNotBlank(info.id))
            notification.setTargetId(run.id);

        // Actually send the notification
        try {
            set<string> recipientsId = new Set<string>{ UserInfo.getUserId() };
            notification.send(recipientsId);
        } catch (Exception e) {
        }

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static List<VCC_LookupSearchResult> search(String searchTerm, List<String> selectedIds) {
        searchTerm = '%' + searchTerm + '%';

        List<vccEndpoint__mdt> endpoints = [
            SELECT Id, MasterLabel, DeveloperName
            FROM vccEndpoint__mdt
            WHERE MasterLabel LIKE :searchTerm
            WITH USER_MODE
        ];

        List<VCC_LookupSearchResult> results = new List<VCC_LookupSearchResult>();
        for (vccEndpoint__mdt endpoint : endpoints) {
            results.add(convertItemToResult(endpoint));
        }

        results.sort();
        return results;
    }

    public static VCC_LookupSearchResult convertItemToResult(vccEndpoint__mdt endPoint) {
        return new VCC_LookupSearchResult(endPoint.DeveloperName, 'Endpoint', 'standard:portal', endPoint.MasterLabel, endPoint.DeveloperName);
    }
}
