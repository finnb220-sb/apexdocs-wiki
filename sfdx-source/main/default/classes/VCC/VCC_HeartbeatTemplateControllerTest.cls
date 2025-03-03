@IsTest
public class VCC_HeartbeatTemplateControllerTest {
    @TestSetup
    public static void setup() {
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];
        Id requiredPermissionId = [SELECT Id FROM PermissionSet WHERE Name = 'VAHC_API_Heartbeat_Permission' LIMIT 1].Id;
        Id testRunner = UserInfo.getUserId();

        System.runAs(adminUser) {
            List<PermissionSetAssignment> assignments = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :testRunner AND PermissionSetId = :requiredPermissionId
            ];

            if (assignments.size() == 0) {
                PermissionSetAssignment assignment = new PermissionSetAssignment();
                assignment.AssigneeId = testRunner;
                assignment.PermissionSetId = requiredPermissionId;
                insert assignment;
            }
        }
    }

    private static User runAsUserCreation() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Read Only'];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            FirstName = 'User',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'standarduser@testorg.com.test'
        );

        insert u;

        PermissionSet perm1 = [SELECT Id FROM PermissionSet WHERE PermissionSet.name = 'VAHC_API_Heartbeat_Permission'];
        PermissionSet perm2 = [SELECT Id FROM PermissionSet WHERE PermissionSet.name = 'VAHC_Standard_VCC_User'];
        PermissionSetAssignment permAssign1 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = perm1.id);
        PermissionSetAssignment permAssign2 = new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = perm2.id);
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>{ permAssign1, permAssign2 };
        insert assignments;

        return u;
    }

    public static void insertTestTemplate() {
        List<VCC_LookupSearchResult> results = VCC_HeartbeatTemplateController.search('BRIDG', new List<string>());
        if (results.size() == 0)
            results = VCC_HeartbeatTemplateController.search('vcc', new List<string>());

        VCC_Heartbeat_Template__c template = new VCC_Heartbeat_Template__c();
        template.Name = 'BRIDG Test';
        template.Endpoint__c = results[0].getId();
        template.Method__c = 'POST';
        template.AutoRun_Schedule__c = 'Every Hour';
        insert template;

        List<VCC_Heartbeat_Template_Parameter__c> params = new List<VCC_Heartbeat_Template_Parameter__c>();
        VCC_Heartbeat_Template_Parameter__c param = new VCC_Heartbeat_Template_Parameter__c();
        param.Name = 'nationalId';
        param.Default_Value__c = 'XXXXXXXXXXXXXXXXXX';
        param.Data_Type__c = 'String';
        param.Is_Required__c = true;
        param.Heartbeat_Template__c = template.Id;
        params.add(param);

        param = new VCC_Heartbeat_Template_Parameter__c();
        param.Name = 'assigningFacility';
        param.Default_Value__c = '000';
        param.Data_Type__c = 'String';
        param.Is_Required__c = true;
        param.Heartbeat_Template__c = template.Id;
        params.add(param);

        insert params;
    }

    public static testMethod void willSetErrors() {
        User u = runAsUserCreation();

        System.runAs(u) {
            VCC_HeartbeatTemplate.TestResult result = new VCC_HeartbeatTemplate.TestResult();
            DmlException dml = new DmlException();
            result = VCC_HeartbeatTemplateController.setErrors(dml, result);
        }
    }

    public static testMethod void willGetTemplate() {
        User u = runAsUserCreation();

        System.runAs(u) {
            insertTestTemplate();

            Test.startTest();

            VCC_Heartbeat_Template__c template = [SELECT Id FROM VCC_Heartbeat_Template__c LIMIT 1];
            string result = VCC_HeartbeatTemplateController.getTemplateInfo(template.Id);

            Test.stopTest();

            system.assert(string.isNotBlank(result), 'The template info should have been returned.');
        }
    }

    public static testMethod void willSaveTemplate() {
        User u = runAsUserCreation();

        System.runAs(u) {
            insertTestTemplate();

            Test.startTest();

            VCC_Heartbeat_Template__c template = [SELECT Id FROM VCC_Heartbeat_Template__c LIMIT 1];
            string result = VCC_HeartbeatTemplateController.getTemplateInfo(template.Id);
            result = VCC_HeartbeatTemplateController.saveTemplateInfo(result);

            Test.stopTest();

            system.assert(string.isNotBlank(result), 'The template info should have been returned.');
        }
    }

    public static testMethod void willRunTest() {
        User u = runAsUserCreation();

        System.runAs(u) {
            insertTestTemplate();

            Test.startTest();

            VCC_Heartbeat_Template__c template = [
                SELECT Id, Endpoint__c, Expected_Response__c, Method__c
                FROM VCC_Heartbeat_Template__c
                LIMIT 1
            ];

            string result = VCC_HeartbeatTemplateController.getTemplateInfo(template.Id);

            VCC_HeartbeatTemplate.TestRunInfo testInfo = new VCC_HeartbeatTemplate.TestRunInfo();
            testInfo.id = template.Id;
            testInfo.endpoint = template.Endpoint__c;
            testInfo.method = template.Method__c;
            testInfo.expectedResponse = template.Expected_Response__c;
            testInfo.params = new List<VCC_HeartbeatTemplate.Param>();

            List<VCC_Heartbeat_Template_Parameter__c> params = [
                SELECT Id, Name, Format__c, Data_Type__c, Default_Value__c
                FROM VCC_Heartbeat_Template_Parameter__c
                WHERE Heartbeat_Template__c = :template.Id
            ];

            VCC_HeartbeatTemplate.Param param;
            for (VCC_Heartbeat_Template_Parameter__c item : params) {
                param = new VCC_HeartbeatTemplate.Param();
                param.name = item.Name;
                param.value = item.Default_Value__c;
                testInfo.params.add(param);
            }

            result = VCC_HeartbeatTemplateController.runTest(JSON.serialize(testInfo));

            Test.stopTest();

            system.assert(string.isNotBlank(result), 'The response should have NOT been blank.');
        }
    }
}
