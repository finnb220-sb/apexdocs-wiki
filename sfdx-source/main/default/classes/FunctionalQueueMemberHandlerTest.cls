/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 12-15-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
@IsTest
public with sharing class FunctionalQueueMemberHandlerTest {
    @IsTest
    private static void addNewMembersToCorrespondingGroups_givenNewFunctionalQueueMember_shouldAddUserToCorrespondingPublicGroup() {
        User testUser = createStandardTestUser('testUser');
        Account testAccount = createTestAccount('testAccount');
        Contact testContact = createTestContact(testUser.Id, 'testUser', testAccount.Id);
        Functional_Queue__c testFunctionalQueue = createTestFunctionalQueue('Test Functional Queue');

        Test.startTest();
        createTestFunctionalQueueMember(testFunctionalQueue.Id, testContact.Id);
        Test.stopTest();

        testFunctionalQueue = [SELECT Queue_ID__c, Public_Group_ID__c FROM Functional_Queue__c WHERE Id = :testFunctionalQueue.Id];
        System.assertNotEquals(null, testFunctionalQueue.Queue_ID__c);
        System.assertNotEquals(null, testFunctionalQueue.Public_Group_ID__c);

        // Check that the user was successfully added to group
        GroupMember functionalQueueMember = [SELECT Id FROM GroupMember WHERE GroupId = :testFunctionalQueue.Public_Group_ID__c AND UserOrGroupId = :testUser.Id];
        System.assertNotEquals(null, functionalQueueMember);
    }

    @IsTest
    private static void deleteFunctionalQueueGroupMembers_givenDeletedFunctionalQueueMember_shouldRemoveUserFromCorrespondingPublicGroup() {
        User testUser = createStandardTestUser('testUser');
        Account testAccount = createTestAccount('testAccount');
        Contact testContact = createTestContact(testUser.Id, 'testUser', testAccount.Id);
        Functional_Queue__c testFunctionalQueue = createTestFunctionalQueue('Test Functional Queue');

        Functional_Queue_Member__c testQueueMember = createTestFunctionalQueueMember(testFunctionalQueue.Id, testContact.Id);

        Test.startTest();
        delete testQueueMember;
        Test.stopTest();

        testFunctionalQueue = [SELECT Queue_ID__c, Public_Group_ID__c FROM Functional_Queue__c WHERE Id = :testFunctionalQueue.Id];
        List<GroupMember> functionalQueueMembers = [SELECT Id FROM GroupMember WHERE GroupId = :testFunctionalQueue.Public_Group_ID__c];
        System.assertEquals(0, functionalQueueMembers.size());
    }

    private static User createStandardTestUser(String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(
            Alias = lastName,
            Email = lastName + '@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            FederationIdentifier = lastName,
            TimeZoneSidKey = 'America/New_York',
            UserName = lastName + '@testorg.com' + UserInfo.getOrganizationId() + String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '')
        );
        insert u;
        return u;
    }

    private static Functional_Queue__c createTestFunctionalQueue(String functionalQueueName) {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Name = functionalQueueName;
        testFunctionalQueue.Associated_Application__c = 'PSIP';
        insert testFunctionalQueue;
        return testFunctionalQueue;
    }

    private static Functional_Queue_Member__c createTestFunctionalQueueMember(Id functionalQueueId, Id contactId) {
        Functional_Queue_Member__c testFunctionalQueueMember = new Functional_Queue_Member__c();
        testFunctionalQueueMember.Functional_Queue__c = functionalQueueId;
        testFunctionalQueueMember.Contact_Member__c = contactId;
        insert testFunctionalQueueMember;
        return testFunctionalQueueMember;
    }

    private static Account createTestAccount(String accountName) {
        Account testAccount = new Account();
        testAccount.Name = accountName;
        insert testAccount;
        return testAccount;
    }

    private static Contact createTestContact(Id userId, String lastName, Id accountId) {
        Contact testContact = new Contact();
        testContact.LastName = lastName;
        testContact.User_ID__c = userId;
        testContact.AccountId = accountId;
        testContact.FQ_Contact__c = true;
        testContact.Email = 'test@va.gov.test';
        insert testContact;
        return testContact;
    }
}
