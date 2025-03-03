@IsTest
public class VCC_HeartbeatTemplateRunnerTest {
    @TestSetup
    static void setup() {
        VCC_HeartbeatTemplateControllerTest.setup();
        removeAnyPendingJob();
    }

    static void removeAnyPendingJob() {
        List<AsyncApexJob> jobs = [
            SELECT Id
            FROM AsyncApexJob
            WHERE ApexClass.Name = 'VCC_HeartbeatTemplateRunner' AND Status != 'Completed' AND Status != 'Failed' AND Status != 'Aborted'
        ];
        for (AsyncApexJob job : jobs) {
            try {
                system.abortJob(job.Id);
            } catch (Exception e) {
            }
        }
    }

    static testMethod void willExecuteSchedule() {
        try {
            VCC_HeartbeatTemplateRunner runner = new VCC_HeartbeatTemplateRunner();

            SchedulableContext ctx;
            runner.execute(ctx);
        } catch (Exception e) {
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

    static testMethod void willRunJob() {
        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();

            VCC_HeartbeatTemplateControllerTest.insertTestTemplate();
            VCC_HeartbeatTemplateRunner runner = new VCC_HeartbeatTemplateRunner();
            Database.executeBatch(runner, 1);

            Test.stopTest();

            List<VCC_Heartbeat_Template_Run__c> runs = [SELECT Id FROM VCC_Heartbeat_Template_Run__c];
            System.assert(runs.size() > 0, 'The job should have ran.');
        }
    }

    static testMethod void willNotifyUsers() {
        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();

            VCC_HeartbeatTemplateControllerTest.insertTestTemplate();
            VCC_HeartbeatTemplateRunner runner = new VCC_HeartbeatTemplateRunner();
            Database.executeBatch(runner, 1);

            Test.stopTest();

            List<VCC_Heartbeat_Template__c> templates = [SELECT Id, Name FROM VCC_Heartbeat_Template__c LIMIT 1];
            List<VCC_Heartbeat_Template_Run__c> runs = [SELECT Id, Status__c FROM VCC_Heartbeat_Template_Run__c LIMIT 1];
            runner.notifyUsers(templates[0], runs[0]);

            System.assert(runs.size() > 0, 'The job should have ran.');
        }
    }

    static testMethod void willScheduleJob() {
        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();

            try {
                VCC_HeartbeatTemplateRunner.schedule();
            } catch (Exception e) {
            }

            Test.stopTest();

            List<AsyncApexJob> jobs = [SELECT Id FROM AsyncApexJob WHERE ApexClass.Name = 'VCC_HeartbeatTemplateRunner'];

            System.assert(jobs.size() > 0, 'The job should have been scheduled.');
        }
    }

    static testMethod void willGetSuccessResults() {
        string expected = '{"sites":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';
        string actual = '{"sites":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';

        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();
            VCC_HeartbeatTemplateRunner.CompareResult result = VCC_HeartbeatTemplateRunner.compareResponses(expected, actual);
            Test.stopTest();

            System.assert(result.status == 'Success', 'The status should have been SUCCESS.');
        }
    }

    static testMethod void willGetFailedResults() {
        string expected = '{"site":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';
        string actual = '{"sites":[{"results":{"flagXXXX":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';

        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();
            VCC_HeartbeatTemplateRunner.CompareResult result = VCC_HeartbeatTemplateRunner.compareResponses(expected, actual);
            Test.stopTest();

            System.assert(result.status == 'Failed', 'The status should have been ERROR (NOT ' + result.status + ').');
        }
    }

    static testMethod void willGetWarningResults() {
        string expected = '{"sites":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';
        string actual = '{"sites":[{"results":{"flags":{"total":"3","flag":[{"origSite":{"extra": "value", "code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"HIGH RISK FOR SUICIDE"},"assigned":{"value":"3211027.150848"},"id":{"value":"450780~2;DGPF(26.15,"},"category":{"value":"I (NATIONAL)"},"type":{"value":"CLINICAL"},"content":{"content":"ASDF"},"reviewDue":{"value":"3220125"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"ACCORD TRIAL"},"assigned":{"value":"3211027.103235"},"id":{"value":"450780~3;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"RESEARCH"},"content":{"content":"FLAG"},"reviewDue":{"value":"3241026"},"document":{}},{"origSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"ownSite":{"code":"541","name":"CLEVELAND VAMC  (CLEVELAND VAMC)"},"approvedBy":{"code":"520824753","name":"MOULTON,KATHY J"},"name":{"value":"PAIN MANAGEMENT"},"assigned":{"value":"3211027.104724"},"id":{"value":"450780~19;DGPF(26.11,"},"category":{"value":"II (LOCAL)"},"type":{"value":"CLINICAL"},"content":{"content":"PAIN MAN"},"reviewDue":{"value":"3220425"},"document":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';

        User u = runAsUserCreation();

        System.runAs(u) {
            Test.startTest();
            VCC_HeartbeatTemplateRunner.CompareResult result = VCC_HeartbeatTemplateRunner.compareResponses(expected, actual);
            Test.stopTest();

            System.assert(result.status == 'Warning', 'The status should have been WARNING.');
        }
    }
}
