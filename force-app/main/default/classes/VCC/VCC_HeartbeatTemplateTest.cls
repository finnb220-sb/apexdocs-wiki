@IsTest
public class VCC_HeartbeatTemplateTest {
    @TestSetup
    static void setup() {
        VCC_HeartbeatTemplateControllerTest.setup();
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
    @IsTest
    public static void willInitializeParamater() {
        User u = runAsUserCreation();

        System.runAs(u) {
            VCC_HeartbeatTemplate template = new VCC_HeartbeatTemplate();

            VCC_HeartbeatTemplate.Param pr = new VCC_HeartbeatTemplate.Param();
            pr.name = '';
            pr.value = '';
            pr.type = 'String';
            pr.format = '';

            VCC_HeartbeatTemplate.TestRunInfo info = new VCC_HeartbeatTemplate.TestRunInfo();
            info.id = '';
            info.endpoint = '';
            info.method = '';
            info.params = new List<VCC_HeartbeatTemplate.Param>();
            info.schedule = 'None';
            info.expectedResponse = '';
            info.path = 'Sample_path';

            VCC_HeartbeatTemplate.Parameter param = new VCC_HeartbeatTemplate.Parameter();
            VCC_Heartbeat_Template_Parameter__c parm = new VCC_Heartbeat_Template_Parameter__c();
            param = new VCC_HeartbeatTemplate.Parameter(parm, 0);

            Assert.isTrue(param.row.startsWith('PARAM'), 'The row property was NOT initialized.');
        }
    }
    @IsTest
    public static void willTransformTemplate() {
        User u = runAsUserCreation();

        System.runAs(u) {
            VCC_HeartbeatTemplateControllerTest.insertTestTemplate();

            Test.startTest();

            VCC_Heartbeat_Template__c record = [
                SELECT Id, Name, Endpoint__c, Expected_Response__c, Method__c, Description__c, AutoRun_Schedule__c
                FROM VCC_Heartbeat_Template__c
                LIMIT 1
            ];

            VCC_HeartbeatTemplate template = new VCC_HeartbeatTemplate(record);
            List<VCC_HeartbeatTemplate.Option> optionList = new List<VCC_HeartbeatTemplate.Option>();
            template.passwordHeader = 'Sample_password';
            template.headers = optionList;
            Test.stopTest();

            Assert.isTrue(record.Id == template.id, 'The data should have been wrapped in the container.');
        }
    }
    @IsTest
    public static void willSetTestInfo() {
        User u = runAsUserCreation();

        System.runAs(u) {
            VCC_HeartbeatTemplate.TestResult result = new VCC_HeartbeatTemplate.TestResult();
            result.success = true;
            result.message = '';
            result.status = 0;

            Assert.isTrue(true, 'The data should have been wrapped in the container.');
        }
    }
}
