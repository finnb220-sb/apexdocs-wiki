/**
 * VCC_ResetTrainingModeDataBatch
 * @description Provides batch capability for resetting training data.
 * @author Liberty
 * @date 2/24/2022
 */

global with sharing class VCC_ResetTrainingModeDataBatch implements Database.Batchable<SObject> {
    global Set<String> userIds;

    global VCC_ResetTrainingModeDataBatch(Set<String> userIds) {
        this.userIds = userIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM User WHERE Id IN :this.userIds]);
    }

    global void execute(Database.BatchableContext bc, List<User> users) {
        Set<Id> userIdsToProcess = new Set<Id>();
        for (User user : users) {
            userIdsToProcess.add(user.Id);
        }
        VCC_TrainingModeService.resetTrainingDataForUsers(userIdsToProcess);
    }

    global void finish(Database.BatchableContext bc) {
    }
}
