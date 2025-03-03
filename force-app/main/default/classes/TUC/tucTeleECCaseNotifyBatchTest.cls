@isTest
public with sharing class tucTeleECCaseNotifyBatchTest {
    @testSetup
    static void setup() {
        // Create test data
        Group testGroup = new Group(Name = 'Onboarding queue', DeveloperName = 'TUC_0_le_Emergency_Care_0_2_Hours', Type = 'Queue');
        insert testGroup;

        QueueSobject testQueue = new QueueSObject(QueueId = testGroup.Id, SobjectType = 'Case');
        insert testQueue;

        User testUser = new User(Id = UserInfo.getUserId());
        testUser.Division = 'VISN 0';
        update testUser;

        System.runAs(testUser) {
            RecordType caseType = [SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Tele_Urgent_Care_0_2_Hours' LIMIT 1];

            Case newCase = new Case();
            newCase.subject = 'test case';
            newCase.status = 'new';
            newCase.ownerId = testGroup.id;
            newCase.RecordTypeId = caseType.Id;
            insert newCase;
            Datetime past5 = Datetime.now().addMinutes(-5);
            Test.setCreatedDate(newCase.Id, past5);

            Case newCase2 = new Case();
            newCase2.subject = 'test case1';
            newCase2.ownerId = testGroup.id;
            newCase2.RecordTypeId = caseType.Id;
            insert newCase2;
            Datetime past10 = Datetime.now().addMinutes(-10);
            Test.setCreatedDate(newCase2.Id, past10);
        }
    }

    @isTest
    public static void testBatch() {
        tucTeleECCaseNotifyBatch testBatch = new tucTeleECCaseNotifyBatch();
        testBatch.continueBatch = false;

        Test.startTest();
        Database.executeBatch(testBatch);
        Test.stopTest();
    }

    @isTest
    public static void testHandler() {
        List<Case> testCases = [
            SELECT id, CaseNumber, TUC_Assigned_VISN__c, Status, TUC_Wait_Time__c
            FROM case
            WHERE Case_Record_Type_Name__c LIKE 'Tele_Urgent%' AND VCC_Owner_Queue_type__c = 'le_Emergency_Care_0_2_Hours'
        ];
        tucTeleECCaseNotifyBatchHelper.checkCasesToNotify(testCases);

        System.assertEquals(2, tucTeleECCaseNotifyBatchHelper.events.size());

        TED_TeleECCase__e evnt1 = tucTeleECCaseNotifyBatchHelper.events.get(0);
        TED_TeleECCase__e envt2 = tucTeleECCaseNotifyBatchHelper.events.get(1);

        System.assertEquals('5min', evnt1.eventType__c);
        System.assertEquals('Case has been in High Acuity queue for more than 5 minutes', evnt1.message__c);
        System.assertEquals('10min', envt2.eventType__c);
        System.assertEquals('Case has been in High Acuity queue for more than 10 minutes', envt2.message__c);
    }
}
