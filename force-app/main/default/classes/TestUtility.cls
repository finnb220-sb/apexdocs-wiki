/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 12-15-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/

@isTest
public with sharing class TestUtility {
    public static Group createGroup(String groupName) {
        Group testGroup = new Group(Name = groupName, Type = 'Regular');
        return testGroup;
    }

    public static Group createQueue(String queueName) {
        Group testQueue = new Group(Name = queueName, Type = 'Queue');
        return testQueue;
    }

    public static void insertQueueObjectTypesByQueueId(Id queueId, List<String> queueSobjectTypesToBeSupportedForQueue) {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<QueueSobject> queueSobjects = new List<QueueSobject>();
            for (String queueSobjectType : queueSobjectTypesToBeSupportedForQueue) {
                QueueSobject queueObject = new QueueSObject(QueueID = queueId, SObjectType = queueSobjectType);
                queueSobjects.add(queueObject);
            }
            insert queueSobjects;
        }
    }
    public static void insertGroupMembersByGroupId(Id queueOrGroupId, List<Id> userIdsToBeAddedToGroup) {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<GroupMember> groupMembers = new List<GroupMember>();
            for (Id userId : userIdsToBeAddedToGroup) {
                GroupMember groupMember = new GroupMember(GroupId = queueOrGroupId, UserOrGroupId = userId);
                groupMembers.add(groupMember);
            }
            insert groupMembers;
        }
    }
    public static String getFakeId(Schema.SObjectType objectType, Integer uniqueDigit) {
        return objectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - String.valueOf(uniqueDigit).length()) + String.valueOf(uniqueDigit);
    }

    public static Functional_Queue__c createFunctionalQueue(String functionalQueueName) {
        Functional_Queue__c testFunctionalQueue = new Functional_Queue__c();
        testFunctionalQueue.Name = functionalQueueName;
        return testFunctionalQueue;
    }

    public static Functional_Queue_Member__c createFunctionalQueueMember(Id functionalQueueId, Id contactId) {
        Functional_Queue_Member__c testFunctionalQueueMember = new Functional_Queue_Member__c();
        testFunctionalQueueMember.Functional_Queue__c = functionalQueueId;
        testFunctionalQueueMember.Contact_Member__c = contactId;
        return testFunctionalQueueMember;
    }

    public static String generateRandomStringByLength(Integer stringLength) {
        final String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while (randomString.length() < stringLength) {
            Integer index = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARS.length());
            randomString += CHARS.substring(index, index + 1);
        }
        return randomString;
    }

    public static User buildTestUserByFirstAndLastName(String firstName, String lastName) {
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        return new User(
            Alias = 'instMgr',
            Email = (firstName + lastName + '@example.com').remove(' '),
            EmailEncodingKey = 'UTF-8',
            FederationIdentifier = generateRandomStringByLength(15),
            FirstName = firstName,
            LastName = lastName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'GMT',
            UserName = (firstName +
                lastName +
                '@testorg.com' +
                UserInfo.getOrganizationId() +
                String.valueOf(Datetime.now()).replace(' ', '').replace(':', '').replace('-', ''))
                .remove(' ')
        );
    }

    public static Account createAccount(String accountName) {
        Account testAccount = new Account();
        testAccount.Name = accountName;
        return testAccount;
    }

    public static Contact createContact(Id userId, String lastName, Id accountId) {
        Contact testContact = new Contact();
        testContact.LastName = lastName;
        testContact.User_ID__c = userId;
        testContact.AccountId = accountId;
        testContact.FQ_Contact__c = true;
        testContact.Email = 'test@va.gov.test';
        return testContact;
    }
}
