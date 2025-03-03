@isTest
public class tucCreateTaskActionControllerTest {
    @isTest
    public static void tucCreateTaskActionController() {
        //Creating Test Data
        Account tempAccount = new Account(Name = 'Test Account');
        insert tempAccount;
        Contact tempContact = new Contact(FirstName = 'TestBob', LastName = 'BobTest', AccountId = tempAccount.Id);
        insert tempContact;
        Case tempCase = new Case(Subject = 'Test Case', Description = 'This is a test case', AccountId = tempAccount.Id, ContactId = tempContact.Id);
        insert tempCase;

        //whatId, SelectedSubject, SelectedOrderDate, SelectedDueDate, SpecificOrder, CommentsProgress, vccCase, whoId
        tucCreateTaskActionController.createTask(
            tempCase.Id,
            'Lab',
            Date.today(),
            Date.today().addDays(14),
            'Specific order test',
            'Test comments/progress',
            tempCase.Id,
            tempContact.Id
        );

        //Checking if the task creation worked
        List<Task> tasks = [
            SELECT
                Id,
                Subject,
                WhoId,
                WhatId,
                ActivityDate,
                TED_Task_Order_Date__c,
                TED_Additional_Task_Needs__c,
                TED_Partial_Results_and_or_APPTS__c,
                VCC_Case__c,
                OwnerId,
                RecordTypeId,
                Status
            FROM Task
        ];
        System.assertEquals(1, tasks.size());
        Task task = tasks[0];

        System.assertEquals('Lab', task.Subject);
        System.assertEquals(tempContact.Id, task.WhoId);
        System.assertEquals(tempCase.Id, task.WhatId);
        System.assertEquals(Date.today(), task.TED_Task_Order_Date__c);
        System.assertEquals(Date.today().addDays(14), task.ActivityDate);
        System.assertEquals('Specific order test', task.TED_Additional_Task_Needs__c);
        System.assertEquals('Test comments/progress', task.TED_Partial_Results_and_or_APPTS__c);
        System.assertEquals(tempCase.Id, task.VCC_Case__c);
        System.assertEquals('New', task.Status);
        System.assertNotEquals(null, task.OwnerId);
        System.assertNotEquals(null, task.RecordTypeId);

        //Query the RecordTypeId and the Queue Id to check if it is the same one inisde createTask

        RecordType recordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'TED_Task'];
        Id recordtypeId = recordtype.Id;

        Group tedTasksQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'TED_Tasks_Queue'];
        Id tedTasksQueueId = tedTasksQueue.Id;

        System.assertEquals(recordtypeId, task.RecordTypeId);
        System.assertEquals(tedTasksQueueId, task.OwnerId);
    }
}
