/**
 * @description Test class for PC_ChatController
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ChatController
 **/
@IsTest
private class PC_ChatControllerTest {
    /**
     * @description Method to positively test getChatterMessages method
     **/
    @IsTest
    private static void unitGetChatterMessagesTestPositive() {
        User pcProvider = generateUserWithAccess();

        System.runAs(pcProvider) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            PC_Chat_Session__c session = [
                SELECT Id
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            insert new FeedItem(
                ParentId = session.Id,
                Type = 'TextPost',
                Body = 'Test',
                IsRichText = false,
                NetworkScope = 'AllNetworks',
                Visibility = 'InternalUsers',
                Status = 'Published'
            );

            PC_Chat_Session__c returnSession = PC_ChatController.getChatterMessages(session.Id, null, '');

            Assert.isTrue(
                returnSession.Feeds.size() == 1,
                'The Chat Session should only have one associated feed item (message)'
            );

            returnSession = PC_ChatController.getChatterMessages(null, testCase.Id, '');

            Assert.isTrue(
                returnSession.Feeds.size() == 1,
                'The Case\'s Chat Session should only have one associated feed item (message)'
            );
        }
    }

    /**
     * @description Method to negatively test getChatterMessages method
     **/
    @IsTest
    private static void unitGetChatterMessagesTestNegative() {
        Boolean hasFailure = false;

        try {
            User pcProvider = generateUserWithAccess();

            System.runAs(pcProvider) {
                PC_Chat_Session__c returnSession = PC_ChatController.getChatterMessages(null, null, '');
            }
        } catch (Exception exc) {
            hasFailure = true;
        }

        Assert.isTrue(
            hasFailure,
            'The getChatterMessages method should have failed and returned an exception due to null session and case Id parameters.'
        );
    }

    /**
     * @description Method to positively test getChatterMessagesCache method
     **/
    @IsTest
    private static void unitGetChatterMessagesCacheTestPositive() {
        User pcProvider = generateUserWithAccess();

        System.runAs(pcProvider) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            PC_Chat_Session__c session = [
                SELECT Id
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            insert new FeedItem(
                ParentId = session.Id,
                Type = 'TextPost',
                Body = 'Test',
                IsRichText = false,
                NetworkScope = 'AllNetworks',
                Visibility = 'InternalUsers',
                Status = 'Published'
            );

            //Without Cache
            PC_CacheResults returnSession = PC_ChatController.getChatterMessagesCache(session.Id, '');

            Assert.isTrue(
                returnSession.chatList.size() == 1,
                'The chat list should only have one item since only one feed item was inserted. Actual list size: ' +
                returnSession.chatList.size()
            );

            PC_ChatController.saveChatterMessage(session.Id, 'Test', null);

            //With Cache
            returnSession = PC_ChatController.getChatterMessagesCache(session.Id, '');

            Assert.isTrue(
                returnSession.chatList.size() == 1,
                'The chat list should only have one item since only one feed item was inserted. Actual list size: ' +
                returnSession.chatList.size()
            );
        }
    }

    /**
     * @description Method to negatively test getChatterMessagesCache method
     **/
    @IsTest
    private static void unitGetChatterMessagesCacheTestNegative() {
        Boolean hasFailure = false;

        try {
            User pcProvider = generateUserWithAccess();

            System.runAs(pcProvider) {
                PC_CacheResults returnSession = PC_ChatController.getChatterMessagesCache(null, '');
            }
        } catch (Exception exc) {
            hasFailure = true;
        }

        Assert.isTrue(
            hasFailure,
            'The getChatterMessagesCache method should have failed and returned an exception due to null session Id parameter.'
        );
    }

    /**
     * @description Method to positively test saveChatterMessage method
     **/
    @IsTest
    private static void unitSaveChatterMessageTestPositive() {
        User pcProvider = generateUserWithAccess();

        System.runAs(pcProvider) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            PC_Chat_Session__c session = [
                SELECT Id
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            PC_ChatController.saveChatterMessage(session.Id, 'Test', null);
            PC_ChatController.saveChatterMessage(
                session.Id,
                'This is testing a message over 255 characters. This is testing a message over 255 characters. This is testing a message over 255 characters. This is testing a message over 255 characters. This is testing a message over 255 characters. This is testing a message over 255 characters.',
                null
            );
            PC_ChatController.saveChatterMessageList(new Set<Id>{ session.Id }, 'TestMultiple');

            List<PC_Chat_Session__Feed> feed = [SELECT Id FROM PC_Chat_Session__Feed WHERE ParentId = :session.Id];

            PC_Chat_Session__c cs = PC_ChatController.handleTeamsMeetingConversion(testCase.Id);

            Assert.isTrue(cs != null, 'A chat session should be returned by handleTeamsMeetingConversion');
            Assert.isTrue(
                feed.size() == 3,
                'Three chat session feeds should be returned. Actual number returned: ' + feed.size()
            );
        }
    }

    /**
     * @description test negative scenario for handleTeamsMeetingConversion where parameter is null
     */
    @IsTest
    private static void unitHandleTeamsMeetingConversionTestNegative() {
        User pcProvider = generateUserWithAccess();

        Boolean hasFailure = false;

        System.runAs(pcProvider) {
            try {
                PC_ChatController.handleTeamsMeetingConversion(null);
            } catch (Exception exc) {
                hasFailure = true;
            }
        }

        Assert.isTrue(
            hasFailure,
            'The handleTeamsMeetingConversion method should have failed and returned an exception due to null case Id parameter.'
        );
    }

    /**
     * @description Method to negatively test saveChatterMessage method
     **/
    @IsTest
    private static void unitSaveChatterMessageTestNegative() {
        User pcProvider = generateUserWithAccess();

        Boolean hasFailure = false;

        System.runAs(pcProvider) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            PC_Chat_Session__c session = [
                SELECT Id
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            try {
                PC_ChatController.saveChatterMessage(null, 'Test', null);
            } catch (Exception exc) {
                hasFailure = true;
            }

            Assert.isTrue(
                hasFailure,
                'The saveChatterMessage method should have failed and returned an exception due to null session Id parameter.'
            );

            //test specialist entering chat
            Id returnedPcpeId = PC_ChatController.saveChatterMessage(session.Id, null, null);

            Assert.isTrue(
                [SELECT Id, hasSpecialistEnteredChat__c FROM PC_Chat_Push_Event__c WHERE Id = :returnedPcpeId LIMIT 1]
                .hasSpecialistEnteredChat__c,
                'The saveChatterMessage method should have set the PC Chat Push Event record\'s hasSpecialistEnteredChat__c field to true'
            );
        }
    }

    /**
     * @description Method to positively test closeChatSession method
     **/
    @IsTest
    private static void unitCloseChatSessionTestPositive() {
        User pcProvider = generateUserWithAccess();

        System.runAs(pcProvider) {
            PC_Case__c testCase = PC_ProviderConnectController.createCase(
                'Cardiology',
                'Test Details',
                '987654321',
                'Chat',
                '1234567890'
            );

            PC_Chat_Session__c session = [
                SELECT Id, PC_Is_Closed__c
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            Assert.isTrue(session.PC_Is_Closed__c == false, 'Chat Session should not be closed.');

            PC_ChatController.closeChatSession(session.Id);

            session = [
                SELECT Id, PC_Is_Closed__c
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :testCase.Id
            ];

            Assert.isTrue(session.PC_Is_Closed__c == true, 'Chat Session should be closed.');
        }

    }

    /**
     * @description Method to negatively test closeChatSession method
     **/
    @IsTest
    private static void unitCloseChatSessionTestNegative() {
        User pcProvider = generateUserWithAccess();

        Boolean hasFailure = false;

        System.runAs(pcProvider) {
            try {
                PC_ChatController.closeChatSession(null);
            } catch (Exception exc) {
                hasFailure = true;
            }
        }

        Assert.isTrue(
            hasFailure,
            'The closeChatSession method should have failed and returned an exception due to null session Id parameter.'
        );
    }

    /**
     * @description test method for getFullMessageBody with no errors
     */
    @IsTest
    private static void unitGetFullMessageBodyTestPositive() {
        User runAsUser = generateUserWithAccess();

        String largeMessage = 'This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters.';

        /** SETUP FEED ITEM REPO STUB **/
        //Create the fake Feed Item in memory
        FeedItem expectedFeedItem = (FeedItem) VATEST_SObjectFactory.createSObject(
            new FeedItem(
                ParentId = VATEST_IdFactory.get('PC_Chat_Session__c'),
                Type = 'TextPost',
                Body = largeMessage,
                IsRichText = false,
                NetworkScope = 'AllNetworks',
                Visibility = 'InternalUsers',
                Status = 'Published'
            )
        );

        PC_FeedItemRepo stubbedFeedItemRepo = (PC_FeedItemRepo) new VATEST_StubBuilder(PC_FeedItemRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expectedFeedItem.Id, new Set<String>{ 'Body' })
            //Tell the stub builder what to return
            .returning(expectedFeedItem)
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ChatController.feedItemRepo = stubbedFeedItemRepo;

        Test.startTest();

        String returnedMessageBody;
        System.runAs(runAsUser) {
            returnedMessageBody = PC_ChatController.getFullMessageBody(expectedFeedItem.Id);
        }

        Test.stopTest();

        Assert.isTrue(
            largeMessage.equalsIgnoreCase(returnedMessageBody),
            'The wrong message body was returned. Expected a message greater than 255 characters.'
        );
    }

    /**
     * @description test method for getFullMessageBody with a thrown exception
     */
    @IsTest
    private static void unitGetFullMessageBodyExceptionTestNegative() {
        User runAsUser = generateUserWithAccess();

        Boolean hasFailure = false;

        String largeMessage = 'This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters. This is a message longer than 255 characters.';

        /** SETUP FEED ITEM REPO STUB **/
        //Create the fake Feed Item in memory
        FeedItem notExpectedFeedItem = (FeedItem) VATEST_SObjectFactory.createSObject(
            new FeedItem(
                ParentId = VATEST_IdFactory.get('PC_Chat_Session__c'),
                Type = 'TextPost',
                Body = largeMessage,
                IsRichText = false,
                NetworkScope = 'AllNetworks',
                Visibility = 'InternalUsers',
                Status = 'Published'
            )
        );

        PC_FeedItemRepo stubbedFeedItemRepo = (PC_FeedItemRepo) new VATEST_StubBuilder(PC_FeedItemRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(notExpectedFeedItem.Id, new Set<String>{ 'Body' })
            //Tell the stub builder to throw an exception
            .throwingException()
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_ChatController.feedItemRepo = stubbedFeedItemRepo;

        Test.startTest();

        System.runAs(runAsUser) {
            try {
                PC_ChatController.getFullMessageBody(notExpectedFeedItem.Id);
            } catch (Exception exc) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        Assert.isTrue(hasFailure, 'Expected an exception when a matching FeedItem could not be found.');
    }

    /**
     * @description test method for getFullMessageBody with error (null parameter)
     */
    @IsTest
    private static void unitGetFullMessageBodyNullTestNegative() {
        User runAsUser = generateUserWithAccess();

        Test.startTest();

        String returnedMessageBody;
        System.runAs(runAsUser) {
            returnedMessageBody = PC_ChatController.getFullMessageBody(null);
        }

        Test.stopTest();

        Assert.isTrue(returnedMessageBody == null, 'Expected return is a null value.');
    }

    /**
     * @description helper method to generate an FLP test user for use in test methods
     * @return      `User` FLP salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_FLP_Users')
            .build(true);
    }
}
