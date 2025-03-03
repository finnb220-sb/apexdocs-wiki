@isTest
public class tucAssignFromQueueTest {
    @testSetup
    static void setup() {
        // Create test data
        Group testGroup = new Group(Name = 'Onboarding queue', DeveloperName = 'TUC_0_testgroup', Type = 'Queue');
        insert testGroup;

        QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        User testUser = new User(Id = UserInfo.getUserId());
        GroupMember groupMemberTemp = new GroupMember(GroupId = testGroup.Id, UserOrGroupId = testUser.Id);
        insert groupMemberTemp;
        System.runAs(testUser) {
            //Create DUZUsers
            IAM_SSOi_Vista_Instance_to_User_DUZ__c duz1 = new IAM_SSOi_Vista_Instance_to_User_DUZ__c();
            duz1.Name = 'TestDuz';
            duz1.DUZ__c = '1234';
            duz1.User_Id__c = UserInfo.getUserId();
            duz1.VistA_Instance__c = '1';
            insert duz1;

            insert testQueue;
            Contact con = new Contact();
            con.LastName = 'demo';
            insert con;

            RecordType caseType = [
                SELECT Id, DeveloperName
                FROM RecordType
                WHERE DeveloperName = 'Tele_Urgent_Care_0_2_Hours'
                LIMIT 1
            ];

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

    @isTest
    public static void testFetchRecords() {
        User testUser = new User(Id = UserInfo.getUserId());
        System.runAs(testUser) {
            String tempobject = 'Case';

            String filter = 'Status=\'new\'';

            String fields = 'CaseNumber,Id,Subject,Contact.Name';
            String fields1 = 'Id,CASENUMBER,subject,Contact.Name';

            String sortByField = 'TUC_Wait_Time__c';
            Boolean stationFiltering = false;
            Test.startTest();
            tucAssignFromQueue.DataTableResponse respNormal = tucAssignFromQueue.getObjectRecords(
                tempobject,
                filter,
                fields,
                sortByField,
                stationFiltering
            );
            tucAssignFromQueue.DataTableResponse respFieldsMixed = tucAssignFromQueue.getObjectRecords(
                tempobject,
                filter,
                fields1,
                sortByField,
                stationFiltering
            );
            tucAssignFromQueue.DataTableResponse respNoStatusFilter = tucAssignFromQueue.getObjectRecords(
                tempobject,
                '',
                fields,
                sortByField,
                stationFiltering
            );
            Test.stopTest();
            Assert.isNotNull(respNormal, 'Expected to get the object record');
            Assert.isNotNull(respFieldsMixed, 'Expected to get the object record');
            Assert.isNotNull(respNoStatusFilter, 'Expected to get the object record');
        }
    }
    @isTest
    public static void testFetchRecordsWithoutFilter() {
        User testUser = new User(Id = UserInfo.getUserId());
        System.runAs(testUser) {
            String tempobject = 'Case';

            String filter = 'Status=\'new\'';

            String fields = 'CaseNumber,Id,Subject,Contact.Name';
            String fields1 = 'Id,CASENUMBER,subject,Contact.Name';

            String sortByField = 'TUC_Wait_Time__c';
            Boolean stationFiltering = true; //this is the main difference
            Test.startTest();
            tucAssignFromQueue.DataTableResponse respNormal = tucAssignFromQueue.getObjectRecords(
                tempobject,
                filter,
                fields,
                sortByField,
                stationFiltering
            );
            tucAssignFromQueue.DataTableResponse respFieldsMixed = tucAssignFromQueue.getObjectRecords(
                tempobject,
                filter,
                fields1,
                sortByField,
                stationFiltering
            );
            tucAssignFromQueue.DataTableResponse respNoStatusFilter = tucAssignFromQueue.getObjectRecords(
                tempobject,
                '',
                fields,
                sortByField,
                stationFiltering
            );
            Test.stopTest();
            Assert.isNotNull(respNormal, 'Expected to get the object record');
            Assert.isNotNull(respFieldsMixed, 'Expected to get the object record');
            Assert.isNotNull(respNoStatusFilter, 'Expected to get the object record');
        }
    }
    @isTest
    public static void testOwnerUpdate() {
        User testUser = new User(Id = UserInfo.getUserId());
        System.runAs(testUser) {
            List<Case> caseList = [SELECT Id FROM Case WHERE Subject = 'test case'];
            Case newCase = caseList[0];
            Test.startTest();
            String message = tucAssignFromQueue.updateSelectedRow(newCase.id, 'Case');
            Test.stopTest();
            Assert.areEqual(message, 'success', 'Expected to update the selected row correctly');
        }
    }

    @isTest
    public static void testOwnerUpdateError() {
        User testUser = new User(Id = UserInfo.getUserId());
        RecordType caseType = [
            SELECT Id, DeveloperName
            FROM RecordType
            WHERE DeveloperName = 'Tele_Urgent_Care_0_2_Hours'
            LIMIT 1
        ];
        Case newCase = new Case();
        newCase.subject = 'test case1';
        newCase.RecordTypeId = caseType.Id;
        insert newCase;
        System.runAs(testUser) {
            Test.startTest();
            String message = tucAssignFromQueue.updateSelectedRow(newCase.id, 'Case');
            Test.stopTest();
            Assert.isTrue(message.contains('error'), 'Expected to fail in updating selected row');
        }
    }
}
