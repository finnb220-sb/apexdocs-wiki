public with sharing class tucTestUtils {
    public static void createStandardDataset() {
        // Create test data
        Group testGroup = new Group(Name = 'Onboarding queue', DeveloperName = 'TUC_0_testgroup', Type = 'Queue');
        insert testGroup;

        QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        insert testQueue;

        User testUser = new User(Id = UserInfo.getUserId());
        testUser.Division = 'VISN 0';
        update testUser;

        Profile base = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];
        User teleECDoctor = UnitTestHelper.createTestUser(null, base.Id, 'test', 'Test TeleEC Doctor');
        teleECDoctor.Division = 'VISN 0';
        insert teleECDoctor;

        GroupMember gm = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id);
        insert gm;

        GroupMember gmDoctor = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = teleECDoctor.Id);
        insert gmDoctor;
        System.runAs(testUser) {
            //Create DUZUsers
            IAM_SSOi_Vista_Instance_to_User_DUZ__c duz1 = new IAM_SSOi_Vista_Instance_to_User_DUZ__c();
            duz1.Name = 'TestDuz';
            duz1.DUZ__c = '1234';
            duz1.User_Id__c = UserInfo.getUserId();
            duz1.VistA_Instance__c = '1';
            insert duz1;

            Contact con = new Contact();
            con.LastName = 'demo';
            insert con;

            RecordType caseType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Tele_Urgent_Care_0_2_Hours' LIMIT 1];

            Case newCase = new Case();
            newCase.subject = 'test case';
            newCase.status = 'new';
            newCase.ownerId = testGroup.id;
            newCase.contactId = con.Id;
            newCase.RecordTypeId = caseType.Id;
            insert newCase;

            Case newCase2 = new Case();
            newCase2.subject = 'test case1';
            newCase2.ownerId = testGroup.id;
            newCase2.RecordTypeId = caseType.Id;
            insert newCase2;
        }
    }
}
