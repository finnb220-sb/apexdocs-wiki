public without sharing class VCC_HeartbeatUtility {
    public static VCC_HeartbeatTemplate getTemplate(string recordId) {
        List<VCC_Heartbeat_Template__c> templates = [
            SELECT
                Id,
                Endpoint__c,
                Description__c,
                Name,
                Method__c,
                AutoRun_Schedule__c,
                Expected_Response__c,
                (
                    SELECT Id, Data_Type__c, Description__c, Format__c, Name, Heartbeat_Template__c, Is_Required__c, Default_Value__c
                    FROM Heartbeat_Template_Parameters__r
                )
            FROM VCC_Heartbeat_Template__c
            WHERE Id = :recordId
            WITH USER_MODE
        ];

        if (templates.size() == 0)
            return null;

        return new VCC_HeartbeatTemplate(templates[0]);
    }

    public static VCC_HeartbeatTemplate saveTemplate(VCC_HeartbeatTemplate template) {
        VCC_Heartbeat_Template__c data = new VCC_Heartbeat_Template__c();
        if (!string.isBlank(template.id))
            data.Id = template.id;
        data.Name = template.name;
        data.Description__c = template.description;
        data.Endpoint__c = template.endpoint;
        data.Method__c = template.method;
        data.Expected_Response__c = template.expectedResponse;
        data.AutoRun_Schedule__c = template.schedule;
        Database.upsertResult result;
        if (Schema.sObjectType.VCC_Heartbeat_Template__c.isCreateable() && Schema.sObjectType.VCC_Heartbeat_Template__c.isUpdateable()) {
            result = Database.upsert(data);
        }
        if (!result.isSuccess()) {
            template.id = '';
        } else {
            template.id = result.getId();
            List<VCC_Heartbeat_Template_Parameter__c> params;
            if (string.isNotBlank(template.id)) {
                params = [SELECT Id FROM VCC_Heartbeat_Template_Parameter__c WHERE Heartbeat_Template__c = :template.id WITH USER_MODE];
                if (params.size() > 0 && Schema.sObjectType.VCC_Heartbeat_Template_Parameter__c.isDeletable()) {
                    Database.delete(params, true);
                }
            }

            params = new List<VCC_Heartbeat_Template_Parameter__c>();
            VCC_Heartbeat_Template_Parameter__c item;
            for (VCC_HeartbeatTemplate.Parameter param : template.params) {
                item = new VCC_Heartbeat_Template_Parameter__c();
                item.Data_Type__c = param.dataType;
                item.Description__c = param.description;
                item.Format__c = param.format;
                item.Is_Required__c = param.isRequired;
                item.Name = param.name;
                item.Heartbeat_Template__c = result.getId();
                item.Default_Value__c = param.value;
                params.add(item);
            }
            if (params.size() > 0 && Schema.sObjectType.VCC_Heartbeat_Template_Parameter__c.isCreateable()) {
                Database.insert(params, true);
            }
            template = getTemplate(template.id);
        }

        return template;
    }
}
