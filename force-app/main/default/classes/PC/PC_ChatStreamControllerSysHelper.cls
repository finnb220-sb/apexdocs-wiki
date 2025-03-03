/**
 * @description Class used by PC_ChatStreamController to help perform actions in "without sharing" context
 * @author      Booz Allen Hamilton
 * @justification the PC_ChatStreamController.invokePushTopic invocable method can be called from record-triggered flows triggered by Front Line Providers or Specialists and although the flow and apex run with system context for the permissions, sharing rules are still observed based on the user who triggered the flow. In order to ensure existing Agent Work Push Events are updated successfully, Front Line Providers that do not have sharing access to the Specialist's Agent Work Push Events must be able to update them, so an unsafe operation is necessary. This class acts as an intermediary between the PC_ChatStreamController.invokePushTopic method and the repo class itself so that the repo class inherits without sharing and runs in a fully system context.
 */
public without sharing class PC_ChatStreamControllerSysHelper {
    /**
     * @description repository for PC_AWPushEvent__c object, true contructor is instantiated to allows this repo to run unsafe calls
     */
    @TestVisible
    private static PC_AWPushEventRepo awPushEventRepo {
        get {
            return awPushEventRepo = awPushEventRepo ?? new PC_AWPushEventRepo(true);
        }
        set;
    }

    /**
     * @description  Performs PushTopic Upsert
     * @param pushEventList List of Push Events, to be Upserted
     *
     */
    public static void performPushEventSystemUpsert(List<PC_AWPushEvent__c> pushEventList) {
        awPushEventRepo.performUpsertUnsafe(pushEventList);
    }
}
