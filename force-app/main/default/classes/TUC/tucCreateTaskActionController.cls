public with sharing class tucCreateTaskActionController {
    @AuraEnabled
    public static void createTask(
        Id whatId,
        String SelectedSubject,
        Date SelectedOrderDate,
        Date SelectedDueDate,
        String SpecificOrder,
        String CommentsProgress,
        Id vccCase,
        Id whoId
    ) {
        try {
            //Getting the TED_Task RecordTypeId to change the Task to that specific record type
            RecordType recordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'TED_Task' WITH USER_MODE];
            Id recordtypeId = recordtype.Id;

            //Getting the TED_Tasks_Queue Id so the task can be owned by the queue
            Group tedTasksQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'TED_Tasks_Queue' WITH USER_MODE];
            Id tedTasksQueueId = tedTasksQueue.Id;

            //Create a new task object
            Task task = new Task();
            //Set all the variables with the passed in paramaters and the two querys above
            task.WhatId = whatId;
            task.Subject = SelectedSubject;
            task.TED_Task_Order_Date__c = SelectedOrderDate;
            task.ActivityDate = SelectedDueDate;
            task.TED_Additional_Task_Needs__c = SpecificOrder;
            task.TED_Partial_Results_and_or_APPTS__c = CommentsProgress;
            task.VCC_Case__c = vccCase;
            task.OwnerId = tedTasksQueueId;
            task.WhoId = whoId;
            task.RecordTypeId = recordtypeId;
            task.Status = 'New';

            if (!Schema.SobjectType.Task.isUpdateable()) {
                throw new AuraHandledException('You do not have permission to create a Task');
            } else {
                insert task; //NOPMD
            }
        } catch (DMLException e) {
            throw new AuraHandledException('You do not have permission to create a Task');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
