/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 11-09-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/
public without sharing class FunctionalQueueHandler {
    // Staged Properties
    List<FunctionalQueue_Supported_Objects_By_App__mdt> functionalQueueSupportedObjectsSettings;

    // DML Properties
    List<QueueSobject> queueSObjectsToDelete = new List<QueueSobject>();
    List<QueueSobject> queueSobjectsToSave = new List<QueueSobject>();
    List<Functional_Queue__share> sharingRulesToSave = new List<Functional_Queue__share>();

    public void onAfterInsert(List<Functional_Queue__c> insertedFunctionalQueues) {
        applyAfterInsertLogic(insertedFunctionalQueues);
        performDMLOperationsForAfterInsert();
    }

    public void onAfterDelete(List<Functional_Queue__c> deletedFunctionalQueues) {
        deleteFunctionalQueueGroups(deletedFunctionalQueues);
    }

    public void deleteFunctionalQueueGroups(List<Functional_Queue__c> deletedFunctionalQueues) {
        Set<Id> groupIdsToDelete = new Set<Id>();
        for (Functional_Queue__c deletedFunctionalQueue : deletedFunctionalQueues) {
            if (deletedFunctionalQueue.Public_Group_ID__c != null) {
                groupIdsToDelete.add(deletedFunctionalQueue.Public_Group_ID__c);
            }
            if (deletedFunctionalQueue.Queue_ID__c != null) {
                groupIdsToDelete.add(deletedFunctionalQueue.Queue_ID__c);
            }
        }

        List<Group> groupsToDelete = [SELECT Id FROM Group WHERE Id IN :groupIdsToDelete];
        delete groupsToDelete;
    }

    public void onAfterUpdate(List<Functional_Queue__c> updatedFunctionalQueues, List<Functional_Queue__c> oldFunctionalQueues) {
        stageRelatedPropertiesForAfterUpdate(updatedFunctionalQueues, oldFunctionalQueues);
        for (Functional_Queue__c functionalQueue : updatedFunctionalQueues) {
            applyAfterUpdateLogic(oldFunctionalQueues, functionalQueue);
        }

        performDMLOperationsForAfterUpdate();
    }

    private void stageRelatedPropertiesForAfterUpdate(List<Functional_Queue__c> updatedFunctionalQueues, List<Functional_Queue__c> oldFunctionalQueues) {
        stageFunctionalQueueSupportedObjectsProperties(updatedFunctionalQueues, oldFunctionalQueues);
    }

    private void applyAfterUpdateLogic(List<Functional_Queue__c> oldFunctionalQueues, Functional_Queue__c functionalQueue) {
        updateFunctionalQueueWithUpdatedApplicationSupportedObjects(functionalQueue);
    }

    private void performDMLOperationsForAfterUpdate() {
        FunctionalQueueUtility.addSerializedSupportedObjectsToQueue(JSON.serialize(queueSobjectsToSave));
        if (queueSObjectsToDelete != null && !queueSObjectsToDelete.isEmpty()) {
            FunctionalQueueUtility.deleteSerializedSupportedQueueObjects(JSON.serialize(queueSObjectsToDelete));
        }
        if (!sharingRulesToSave.isEmpty()) {
            insert sharingRulesToSave;
        }
    }

    private void applyAfterInsertLogic(List<Functional_Queue__c> insertedFunctionalQueues) {
    }

    private void performDMLOperationsForAfterInsert() {
        if (!sharingRulesToSave.isEmpty()) {
            insert sharingRulesToSave;
        }
    }

    private void stageFunctionalQueueSupportedObjectsProperties(List<Functional_Queue__c> updatedFunctionalQueues, List<Functional_Queue__c> oldFunctionalQueues) {
        Set<Id> updatedApplicationNameQueueIds = new Set<Id>();
        Set<String> updatedFunctionalQueueApplicationNames = new Set<String>();
        for (Functional_Queue__c updatedFunctionalQueue : updatedFunctionalQueues) {
            for (Functional_Queue__c oldFunctionalQueue : oldFunctionalQueues) {
                if (functionalQueueUpdateRequiresSupportedObjectsUpdate(updatedFunctionalQueue, oldFunctionalQueue)) {
                    updatedApplicationNameQueueIds.add(updatedFunctionalQueue.Queue_ID__c);
                    updatedFunctionalQueueApplicationNames.add(updatedFunctionalQueue.Associated_Application__c);
                }
            }
        }

        queueSObjectsToDelete = FunctionalQueueUtility.getQueueSObjectsByQueueIds(updatedApplicationNameQueueIds);
        functionalQueueSupportedObjectsSettings = FunctionalQueueUtility.getFunctionalQueueSupportedObjectsCustomMetaDataByAppNames(updatedFunctionalQueueApplicationNames);
    }

    private Boolean functionalQueueUpdateRequiresSupportedObjectsUpdate(Functional_Queue__c updatedFunctionalQueue, Functional_Queue__c oldFunctionalQueue) {
        return (functionalQueueAssociatedQueueIdIsUpdated(updatedFunctionalQueue.Queue_ID__c, oldFunctionalQueue.Queue_ID__c) ||
        functionalQueueAssociatedApplicationIsUpdated(updatedFunctionalQueue, oldFunctionalQueue.Associated_Application__c));
    }

    private Boolean functionalQueueAssociatedQueueIdIsUpdated(String updatedAssociatedQueueId, String oldAssociatedQueueId) {
        return (updatedAssociatedQueueId != oldAssociatedQueueId);
    }

    private Boolean functionalQueueAssociatedApplicationIsUpdated(Functional_Queue__c updatedFunctionalQueue, String oldAssociatedApplicationName) {
        return (updatedFunctionalQueue.Associated_Application__c != oldAssociatedApplicationName && String.isNotBlank(updatedFunctionalQueue.Queue_ID__c));
    }

    private void updateFunctionalQueueWithUpdatedApplicationSupportedObjects(Functional_Queue__c functionalQueue) {
        for (FunctionalQueue_Supported_Objects_By_App__mdt functionalQueueSupportedObjectsSetting : functionalQueueSupportedObjectsSettings) {
            if (functionalQueue.Associated_Application__c == functionalQueueSupportedObjectsSetting.Application_Name__c) {
                List<String> applicationSupportedObjects = functionalQueueSupportedObjectsSetting.Supported_Objects__c.split(',');
                for (String supportedObjectType : applicationSupportedObjects) {
                    queueSobjectsToSave.add(FunctionalQueueUtility.buildQueueSobjectByQueueIdAndSupportedObjectName(supportedObjectType, functionalQueue.Queue_ID__c));
                }
            }
        }
    }

    private void buildSharingRulesForFunctionalQueues(List<Functional_Queue__c> functionalQueues) {
        Map<Id, Account> accountMap = FunctionalQueueUtility.getRelatedOfficeMap(functionalQueues);

        for (Functional_Queue__c fq : functionalQueues) {
            // build sharing rules by record type
        }
    }
}
