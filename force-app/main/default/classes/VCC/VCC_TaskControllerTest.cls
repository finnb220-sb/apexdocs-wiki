/**
 * @description       : Test class for VCC_TaskController
 * @author            : Ronald Stewart
 * @group             : Test Classes
 * @last modified on  : 05-12-2023
 * @last modified by  : Ronald Stewart
 **/
@isTest
public with sharing class VCC_TaskControllerTest {
    /**
     * @description This test method tests the deletion of Follow-Up Tasks
     * @author Ronald Stewart | 05-12-2023
     **/
    @isTest
    static void preventFollowUpTaskDeleteTest() {
        // Get the profile ID for the VAVET Base Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];

        // Create a user to run the test as
        User testUser = new User(
            Username = 'standarduser' + DateTime.now().getTime() + '@testorg.com',
            Email = 'testuser@example.com',
            Alias = 'testuser',
            LastName = 'Test',
            FirstName = 'User',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {
            // record type which can be deleted
            string nonCallsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CarePlanTask').getRecordTypeId();
            // record types which should throw delete error

            string followUpRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCC_VCV_Follow_Up').getRecordTypeId();

            // task to delete successfully
            Task taskRec1 = new Task(RecordTypeId = nonCallsRecTypeId, Status = 'Open');
            // task that will fire trigger to prevent delete
            Task taskRec2 = new Task(RecordTypeId = followUpRecTypeId, Status = 'Open');

            List<Task> taskRecs = new List<Task>{ taskRec1, taskRec2 };
            insert taskRecs;

            try {
                delete taskRecs;
            } catch (DMLexception e) {
                // assert dmlException contains the error custom label text
                system.assert(e.getMessage().contains(System.Label.VCC_Prevent_Delete_Task_Message), 'Prevent deletion of Follow-Up Tasks');
            }
        }
    }

    /**
     * @description This test method tests the deletion of Calls Tasks
     * @author Ronald Stewart | 05-12-2023
     **/
    @isTest
    static void preventCallsTaskDeleteTest() {
        // record type which can be deleted
        string nonCallsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CarePlanTask').getRecordTypeId();
        // record type which should throw delete error
        string callsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCC_Calls').getRecordTypeId();
        // task to delete successfully
        Task taskRec1 = new Task(RecordTypeId = nonCallsRecTypeId, Status = 'Open');
        // task that will fire trigger to prevent delete
        Task taskRec2 = new Task(RecordTypeId = callsRecTypeId, Status = 'Open');

        List<Task> taskRecs = new List<Task>{ taskRec1, taskRec2 };
        insert taskRecs;

        try {
            delete taskRecs;
        } catch (DMLexception e) {
            // assert dmlException contains the error custom label text
            system.assert(e.getMessage().contains(System.Label.VCC_Prevent_Delete_Generic_Task_Message), 'Prevent deletion of Calls Tasks');
        }
    }
}
