/**
 * @description       : Class used as a controller for pcChat LWC
 * @author            : George Elias
 * @group             : Booze Allen Hamilton
 * @last modified on  : 07-06-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2022   George Elias                          Initial Version
 * 2.0   01-23-2023   Edwin Schaeffer                       Changed to accomodate Streaming API (push notifications)
 **/
public with sharing class PC_ChatController {
    //max character count of a Chat Push Event's message body
    private final static Integer MAX_BODY_MSG_LENGTH = PC_Chat_Push_Event__c.Body__c.getDescribe()?.getLength();

    //Used to maintain a maximum list size for chatList
    private final static Integer MAX_CACHE_LIST_SIZE = 20;

    @TestVisible
    private static PC_FeedItemRepo feedItemRepo {
        get {
            return feedItemRepo ?? new PC_FeedItemRepo();
        }
        set;
    }

    @TestVisible
    private static PC_ChatPushEventRepo pcChatPushEventRepo {
        get {
            return pcChatPushEventRepo ?? new PC_ChatPushEventRepo();
        }
        set;
    }

    @TestVisible
    private static PC_ChatSessionRepo pcChatSessionRepo {
        get {
            return pcChatSessionRepo ?? new PC_ChatSessionRepo();
        }
        set;
    }

    /**
     * @description Method to search for the chat session and chat messages
     * @author George Elias | 07-06-2022
     * @param sessionId - Id of the PC_Chat_Session__c record
     * @param caseId - Id of the parent Case record that the PC_Chat_Session__c record is a child of
     * @param lastMessageTime - String value of datetime used to retrieve messages after this time
     * @return  PC_Chat_Session__c - The chat session record with related feed items
     **/
    @AuraEnabled
    public static PC_Chat_Session__c getChatterMessages(String sessionId, String caseId, String lastMessageTime) {
        try {
            if (String.isBlank(sessionId) && String.isBlank(caseId)) {
                throw new PC_CustomException('Session Id and Case Id cannot be both blank.');
            }
            DateTime dt = null;
            if (!String.isBlank(lastMessageTime)) {
                dt = DateTime.ValueofGmt(lastMessageTime.replace('T', ' '));
            }

            if (Schema.sObjectType.PC_Chat_Session__c.isAccessible() && Schema.sObjectType.FeedItem.isAccessible()) {
                @SuppressWarnings('PMD.ApexCRUDViolation')
                PC_Chat_Session__c session = [
                    SELECT
                        Id,
                        CreatedBy.Name,
                        Provider_Connect_Case__c,
                        CreatedDate,
                        PC_Is_Closed__c,
                        PC_Closed_Date__c,
                        PC_Closed_By__r.Name,
                        (
                            SELECT Id, Body, Type, ParentId, CreatedDate, InsertedBy.Name
                            FROM feeds
                            WHERE type = 'TextPost' AND CreatedDate > :dt
                            ORDER BY CreatedDate
                        )
                    FROM PC_Chat_Session__c
                    WHERE Id = :sessionId OR Provider_Connect_Case__c = :caseId //Cannot use security enforced with InsertedBy field, Apex Class is secured with permission set for PC users only
                    LIMIT 1
                ];

                return session;
            } else {
                throw new PC_CustomException(
                    'You do not have the proper permissions to query the PC Chat Session and/or Feed objects'
                );
            }
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.getChatterMessages Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to search for the chat session and chat messages in cache
     * @author George Elias | 07-06-2022
     * @param sessionId - Id of the PC_Chat_Session__c record
     * @param lastMessageTime - String value of datetime used to retrieve messages after this time
     * @return  PC_CacheResults - Chat session details and messages in a wrapper class
     **/
    @AuraEnabled
    public static PC_CacheResults getChatterMessagesCache(String sessionId, String lastMessageTime) {
        try {
            if (String.isBlank(sessionId)) {
                throw new PC_CustomException('Session Id cannot be blank.');
            }
            DateTime dt = null;
            if (!String.isBlank(lastMessageTime)) {
                dt = DateTime.ValueofGmt(lastMessageTime.replace('T', ' '));
            }
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pcChat');
            PC_CacheResults cacheResults = new PC_CacheResults();
            //Check if cache exists
            if (orgPart.contains(sessionId)) {
                //if exists, use cache
                cacheResults = (PC_CacheResults) orgPart.get(sessionId);
                List<FeedItem> tempList = new List<FeedItem>();
                for (FeedItem chat : cacheResults.chatList) {
                    if (chat.CreatedDate > dt || dt == null) {
                        tempList.add(chat);
                    }
                }
                cacheResults.chatList = tempList;
            } else {
                //if not query data bases
                PC_Chat_Session__c session = [
                    SELECT PC_Is_Closed__c, PC_Closed_Date__c, PC_Closed_By__r.Name
                    FROM PC_Chat_Session__c
                    WHERE Id = :sessionId
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];

                cacheResults.isClosed = session.PC_Is_Closed__c;
                cacheResults.closedBy = session.PC_Closed_By__r?.Name;
                cacheResults.closedDate = session.PC_Closed_Date__c;
                cacheResults.chatList = PC_ChatControllerHelper.queryFeedItem(sessionId, dt);
            }
            return cacheResults;
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.getChatterMessagesCache Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to a chat message to chatter
     * @author George Elias | 07-06-2022
     * @param sessionId - Id of the PC_Chat_Session__c record
     * @param message - String value the chat message
     * @param chatPushEventId - record to be updated.
     * @return Id of PC_Chat_Push_Event__c to re-use the record
     **/
    @AuraEnabled
    public static String saveChatterMessage(String sessionId, String message, String chatPushEventId) {
        try {
            if (String.isBlank(sessionId)) {
                throw new PC_CustomException('Session Id cannot be blank.');
            }

            FeedItem chat = null;
            String recipientId = null, recipientName = null;
            // ES - A push topic notification won't send if a duplicate message is sent. For example "ok", then "ok"
            PC_Chat_Push_Event__c pcpe = new PC_Chat_Push_Event__c(
                Body__c = message?.left(255),
                ChatSentByFullName__c = UserInfo.getName(),
                ChatSentById__c = UserInfo.getUserId(),
                Random_Gen__c = Integer.valueOf(Math.random() * 10000)
            );
            pcpe = resetPushTopicMsg(pcpe);

            if (String.isNotBlank(message)) {
                chat = new FeedItem(
                    ParentId = sessionId,
                    Type = 'TextPost',
                    Body = message,
                    IsRichText = false,
                    NetworkScope = 'AllNetworks',
                    Visibility = 'InternalUsers',
                    Status = 'Published'
                );

                feedItemRepo.doCreate(chat);

                //PTEMSPC-565 save Related Chatter Feed Item Id of the most recent >255 length chatter message on Chat Push Event to retrieve full message body in pcChat LWC
                if (message.length() > MAX_BODY_MSG_LENGTH) {
                    pcpe.PC_Related_Chatter_Id__c = chat.Id;
                } else {
                    pcpe.PC_Related_Chatter_Id__c = null;
                }

                chat = (FeedItem) feedItemRepo.fetchById(
                    chat.Id,
                    new Set<String>{ 'Body', 'Type', 'ParentId', 'CreatedDate', 'InsertedBy.Name' }
                );
            } else {
                pcpe.hasSpecialistEnteredChat__c = true;
            }

            //Update PC_Last_Chat_Date__c which is then used in a flow to auto close a session 20 minutes after the last chat
            pcChatSessionRepo.doUpdate(new PC_Chat_Session__c(Id = sessionId, PC_Last_Chat_Date__c = System.now()));

            //Check if cache exists
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pcChat');
            PC_CacheResults cacheResult = new PC_CacheResults();
            if (orgPart.contains(sessionId)) {
                //add to existing cache
                cacheResult = (PC_CacheResults) orgPart.get(sessionId);
                cacheResult.recipientId = recipientId;
                cacheResult.recipientName = recipientName;
                if (String.isNotBlank(message)) {
                    cacheResult.chatList.add(chat);
                }
                if (cacheResult.chatList.size() > MAX_CACHE_LIST_SIZE) {
                    cacheResult.chatList.remove(0);
                }
            } else {
                //create new cache and add chat to new cache
                PC_Chat_Session__c session = (PC_Chat_Session__c) pcChatSessionRepo.fetchById(
                    sessionId,
                    new Set<String>{ 'PC_Is_Closed__c', 'PC_Closed_Date__c', 'PC_Closed_By__r.Name' }
                );

                cacheResult.isClosed = session.PC_Is_Closed__c;
                cacheResult.closedBy = session.PC_Closed_By__r?.Name;
                cacheResult.closedDate = session.PC_Closed_Date__c;
                cacheResult.recipientId = recipientId;
                cacheResult.recipientName = recipientName;
                if (String.isNotBlank(message)) {
                    cacheResult.chatList.add(chat);
                }
            }
            orgPart.put(sessionId, cacheResult);
            if (String.isNotBlank(chatPushEventId)) {
                pcpe.Id = chatPushEventId;
                pcChatPushEventRepo.doUpdate(pcpe);
            } else {
                //Only set Chat Session master-detail field on insert (USER_MODE AccessLevel on update DML will cause failure since field cannot be re-parented)
                pcpe.PC_Chat_Session__c = sessionId;
                pcChatPushEventRepo.doCreate(pcpe);
            }

            return pcpe.Id;
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.saveChatterMessage Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /* @author Edwin Schaeffer | 01-23-2023
     * @descrption Resets event record fields
     * @return empty PC_Chat_Push_Event__c record
     * @param PC_Chat_Push_Event__c
     */
    private static PC_Chat_Push_Event__c resetPushTopicMsg(PC_Chat_Push_Event__c pcpe) {
        pcpe.closedBy__c = '';
        pcpe.closedDate__c = null;
        pcpe.hasSpecialistEnteredChat__c = false;
        pcpe.isClosed__c = false;
        return pcpe;
    }

    /**
     * @description
     * @author 06-13-2023
     * @param sessionIdSet
     * @param message
     **/
    public static void saveChatterMessageList(Set<Id> sessionIdSet, String message) {
        try {
            //Used to maintain a maximum list size for chatList
            List<PC_Chat_Session__c> sessionList = new List<PC_Chat_Session__c>();
            List<PC_Chat_Session__c> allSessions = [
                SELECT Id, PC_Is_Closed__c, PC_Last_Chat_Date__c
                FROM PC_Chat_Session__c
                WHERE Id IN :sessionIdSet
            ];
            List<PC_Chat_Push_Event__c> pcPushList = new List<PC_Chat_Push_Event__c>();

            String recipientId = null, recipientName = null;
            List<FeedItem> feedList = new List<FeedItem>();
            for (PC_Chat_Session__c session : allSessions) {
                if (!session.PC_Is_Closed__c) {
                    FeedItem chat = new FeedItem(
                        ParentId = session.Id,
                        Type = 'TextPost',
                        Body = message,
                        IsRichText = false,
                        NetworkScope = 'AllNetworks',
                        Visibility = 'InternalUsers',
                        Status = 'Published'
                    );
                    feedList.add(chat);
                    PC_Chat_Session__c pcSession = new PC_Chat_Session__c(
                        Id = session.Id,
                        PC_Last_Chat_Date__c = System.now()
                    );
                    sessionList.add(pcSession);
                    PC_Chat_Push_Event__c pcpe = new PC_Chat_Push_Event__c(
                        Body__c = message?.left(255),
                        PC_Chat_Session__c = session.Id,
                        ChatSentByFullName__c = UserInfo.getName(),
                        ChatSentById__c = UserInfo.getUserId(),
                        Random_Gen__c = Integer.valueOf(Math.random() * 10000)
                    );
                    pcPushList.add(pcpe);
                }
            }
            if (Schema.sObjectType.FeedItem.isCreateable()) {
                insert feedList;
                insert pcPushList;
            } else {
                throw new PC_CustomException('You do not have the proper permissions to create a chat message.');
            }
            List<FeedItem> feedListPostInsert = [
                SELECT Body, Type, ParentId, CreatedDate, InsertedBy.Name
                FROM FeedItem
                WHERE Id IN :feedList
            ]; //Cannot use security enforced with InsertedBy field
            Map<Id, FeedItem> feedMap = new Map<Id, FeedItem>();
            for (FeedItem fi : feedListPostInsert) {
                feedMap.put(fi.ParentId, fi);
            }

            if (Schema.sObjectType.PC_Chat_Session__c.isUpdateable()) {
                //Update PC_Last_Chat_Date__c which is then used in a flow to auto close a session 20 minutes after the last chat
                update sessionList;
            } else {
                throw new PC_CustomException('You do not have the proper permissions to update the chat session.');
            }
            Set<Id> sessionsWithoutCache = new Set<Id>();
            //Check if cache exists
            Cache.OrgPartition orgPart = Cache.Org.getPartition('local.pcChat');
            for (PC_Chat_Session__c session : sessionList) {
                PC_CacheResults cacheResult = new PC_CacheResults();
                if (orgPart.contains(session.Id)) {
                    //add to existing cache
                    cacheResult = (PC_CacheResults) orgPart.get(session.Id);
                    cacheResult.chatList.add(feedMap.get(session.Id));
                    if (cacheResult.chatList.size() > MAX_CACHE_LIST_SIZE) {
                        cacheResult.chatList.remove(0);
                    }
                } else {
                    sessionsWithoutCache.add(session.Id);
                }
                orgPart.put(session.Id, cacheResult);
            }
            if (!sessionsWithoutCache.isEmpty()) {
                //create new cache and add chat to new cache
                List<PC_Chat_Session__c> sessionWithoutCacheList = [
                    SELECT PC_Is_Closed__c, PC_Closed_Date__c, PC_Closed_By__r.Name
                    FROM PC_Chat_Session__c
                    WHERE Id IN :sessionsWithoutCache
                    WITH SECURITY_ENFORCED
                ];
                for (PC_Chat_Session__c session : sessionWithoutCacheList) {
                    PC_CacheResults cacheResult = new PC_CacheResults();
                    cacheResult.isClosed = session.PC_Is_Closed__c;
                    cacheResult.closedBy = session.PC_Closed_By__r?.Name;
                    cacheResult.closedDate = session.PC_Closed_Date__c;
                    cacheResult.chatList.add(feedMap.get(session.Id));
                    orgPart.put(session.Id, cacheResult);
                }
            }
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.saveChatterMessage Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to close the chat session
     * @author George Elias | 07-06-2022
     * @param sessionId - Id of the PC_Chat_Session__c record
     * @return  PC_Chat_Session__c - The closed PC_Chat_Session__c record
     **/
    @AuraEnabled
    public static void closeChatSession(String sessionId) {
        try {
            if (String.isBlank(sessionId)) {
                throw new PC_CustomException('Session Id cannot be blank.');
            }
            PC_Chat_Session__c session = [
                SELECT PC_Is_Closed__c
                FROM PC_Chat_Session__c
                WHERE Id = :sessionId
                WITH SECURITY_ENFORCED
            ];
            if (session.PC_Is_Closed__c == false) {
                update new PC_Chat_Session__c(
                    Id = sessionId,
                    PC_Is_Closed__c = true,
                    PC_Closed_Date__c = Datetime.now(),
                    PC_Closed_By__c = UserInfo.getUserId()
                );
            }
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.closeChatSession Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description
     * @author 06-13-2023
     * @param  caseId
     * @return PC_Chat_Session__c
     **/
    @AuraEnabled
    public static PC_Chat_Session__c handleTeamsMeetingConversion(Id caseId) {
        try {
            PC_Chat_Session__c session = getChatParticipantsEmail(caseId);
            PC_Case__c pcCase = new PC_Case__c(Id = caseId, Channel__c = 'Teams');

            if (Schema.sObjectType.PC_Case__c.isUpdateable()) {
                update pcCase;
            } else {
                throw new PC_CustomException('You do not have the proper permissions to update the PC Case.');
            }

            saveChatterMessage(session.Id, 'Teams Video initiated please use Chat as needed.', null);
            return session;
        } catch (Exception e) {
            log_LogService.log(
                'PC_ChatController.handleTeamsMeetingConversion Exception',
                log_LogService.LogType.ERROR,
                e
            );
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description
     * @author 06-13-2023
     * @param caseId
     * @return PC_Chat_Session__c
     **/
    @AuraEnabled
    public static PC_Chat_Session__c getChatParticipantsEmail(Id caseId) {
        if (String.isBlank(caseId)) {
            throw new PC_CustomException('Case Id cannot be blank.');
        }

        if (Schema.sObjectType.PC_Chat_Session__c.isAccessible() && Schema.sObjectType.FeedItem.isAccessible()) {
            @SuppressWarnings('PMD.ApexCRUDViolation')
            PC_Chat_Session__c session = [
                SELECT
                    Id,
                    Provider_Connect_Case__r.CreatedBy.Email,
                    (
                        SELECT Id, ParentId, InsertedById, InsertedBy.Name, InsertedBy.Email
                        FROM feeds
                        WHERE type = 'TextPost'
                        ORDER BY CreatedDate
                    )
                FROM PC_Chat_Session__c
                WHERE Provider_Connect_Case__c = :caseId
                LIMIT 1
            ];
            return session;
        } else {
            throw new PC_CustomException(
                'You do not have the proper permissions to query the PC Chat Session and/or Feed objects'
            );
        }
    }

    /**
     * @description retrieve the full message Body for a Chat Push Event from its related Chatter Feed Item
     * @author WagnerJ@BAH | 07-06-2023
     * @param Id relatedFeedItemId the Feed Item id of the chat message (pulled off the Chat Push Event)
     * @return String
     **/
    @AuraEnabled
    public static String getFullMessageBody(Id relatedFeedItemId) {
        if (String.isBlank(relatedFeedItemId)) {
            return null;
        }

        try {
            List<FeedItem> feedItemList = new List<FeedItem>{
                (FeedItem) feedItemRepo.fetchById(relatedFeedItemId, new Set<String>{ 'Body' })
            };
            return feedItemList.size() > 0 ? feedItemList[0].Body : null;
        } catch (Exception e) {
            log_LogService.log('PC_ChatController.getFullMessageBody Exception', log_LogService.LogType.ERROR, e);
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
