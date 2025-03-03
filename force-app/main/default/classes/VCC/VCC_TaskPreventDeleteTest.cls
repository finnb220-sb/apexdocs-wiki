/**
 * @description This test class tests the prevention of deletion of a Task record when its RecordType is VCC_Calls or VCC_VCV_Follow_Up.
 * The error message stored in CustomLabel VCC_Prevent_Delete_Task_Message is added to the record when it's found to be have one of these RecordTypes.
 */
@IsTest
public with sharing class VCC_TaskPreventDeleteTest {
    /**
     * @description This test method verifies that an null value passed into VCC_TaskPreventDeleteBD class correctly handled and throws no exceptions.
     */
    @IsTest
    static void unitPreventTaskDeleteNullArgNegative() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(testUser) {
            Test.startTest();
            try {
                (new VCC_TaskPreventDeleteBD()).beforeDelete(null);
            } catch (Exception thrownException) {
                Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
            }
            Test.stopTest();
        }
    }
    /**
     * @description This test method verifies that an empty list of tasks objects is correctly handled and throws no exceptions.
     */
    @IsTest
    static void unitPreventTaskDeleteEmptyListNegative() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(testUser) {
            Test.startTest();
            try {
                (new VCC_TaskPreventDeleteBD()).beforeDelete(new List<Task>());
            } catch (Exception thrownException) {
                Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
            }
            Test.stopTest();
        }
    }
    /**
     * @description This test method tests the prevention of deletion of a Task record when its RecordType is VCC_VCV_Follow_Up.
     * The error message stored in CustomLabel VCC_Prevent_Delete_Task_Message is added to the record when it's found to be have one of these RecordTypes.
     */

    @IsTest
    static void unitPreventTaskDeletePositiveFollowUp() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withPermissionSet('VCC_Medical_Provider')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        System.runAs(testUser) {
            String followUpRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('VCC_VCV_Follow_Up')
                .getRecordTypeId();
            List<Task> taskList = new List<Task>{ new Task(RecordTypeId = followUpRecTypeId, Status = 'Open') };
            Test.startTest();
            try {
                (new VCC_TaskPreventDeleteBD()).beforeDelete(taskList);
                List<Database.Error> triggerErrors = taskList[0].getErrors();
                Assert.areEqual(1, triggerErrors.size(), 'Expected one Database.Error');
                Assert.areEqual(
                    VCC_TaskPreventDeleteBD.PREVENT_DELETE_ERROR_MESSAGE,
                    triggerErrors[0].getMessage(),
                    'Expected error stored in static property PREVENT_DELETE_ERROR_MESSAGE'
                );
            } catch (Exception thrownException) {
                Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
            }
            Test.stopTest();
        }
    }
    /**
     * @description This test method tests that other record types not specified as VCC_Calls, VCC_VCV_Follow_Up and VAHC_Verify_Caller record types are deleted and no error is thrown.
     */
    @IsTest
    static void unitPreventTaskDeletePositiveCarePlan() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(testUser) {
            String nonCallsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('CarePlanTask')
                .getRecordTypeId();
            List<Task> taskList = new List<Task>{ new Task(RecordTypeId = nonCallsRecTypeId, Status = 'Open') };
            Test.startTest();
            try {
                (new VCC_TaskPreventDeleteBD()).beforeDelete(taskList);
                List<Database.Error> triggerErrors = taskList[0].getErrors();
                Assert.areEqual(0, triggerErrors.size(), 'Expected no Database.Error\'s');
            } catch (Exception thrownException) {
                Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
            }
            Test.stopTest();
        }
    }
    /**
     * @description This test method tests the prevention of deletion of a Task record when its RecordType is VCC_VCV_Follow_Up.
     * The error message stored in CustomLabel VCC_Prevent_Delete_Task_Message is added to the record when it's found to be have one of these RecordTypes.
     */

    @isTest
    static void funcPreventFollowUpTaskDeletePositiveTest() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withPermissionSet('VCC_Medical_Provider')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(testUser) {
            String nonCallsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('CarePlanTask')
                .getRecordTypeId();
            String followUpRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('VCC_VCV_Follow_Up')
                .getRecordTypeId();

            // Task to delete successfully
            Task taskRec1 = new Task(
                RecordTypeId = nonCallsRecTypeId,
                Status = 'Open',
                Task_Creation_Origin__c = 'VCC Create Task'
            );
            // Task that will fire trigger to prevent delete
            Task taskRec2 = new Task(
                RecordTypeId = followUpRecTypeId,
                Status = 'Open',
                Task_Creation_Origin__c = 'VCC Create Task'
            );

            List<Task> taskRecs = new List<Task>{ taskRec1, taskRec2 };
            insert taskRecs;

            try {
                delete taskRecs;
            } catch (DMLexception e) {
                // Assert DmlException contains the error in custom label
                System.assert(
                    e.getMessage().contains(System.Label.VCC_Prevent_Delete_Task_Message),
                    'Prevent deletion of Follow-Up Tasks'
                );
            }
        }
    }

    /**
     * @description This test method tests the prevention of deletion of a Task record when its RecordType is VCC_Calls.
     * The error message stored in CustomLabel VCC_Prevent_Delete_Generic_Task_Message is added to the record when it's found to be have one of these RecordTypes.
     */
    @isTest
    static void funPreventCallsTaskDeleteGenericPositiveTest() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(testUser) {
            String nonCallsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('CarePlanTask')
                .getRecordTypeId();
            String callsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('VCC_Calls')
                .getRecordTypeId();

            // Task to delete successfully
            Task taskRec1 = new Task(
                RecordTypeId = nonCallsRecTypeId,
                Status = 'Open',
                Task_Creation_Origin__c = 'VCC Create Task'
            );
            // Task that will fire trigger to prevent delete
            Task taskRec2 = new Task(
                RecordTypeId = callsRecTypeId,
                Status = 'Open',
                Task_Creation_Origin__c = 'VCC Create Task'
            );

            List<Task> taskRecs = new List<Task>{ taskRec1, taskRec2 };
            insert taskRecs;

            try {
                delete taskRecs;
            } catch (DMLexception e) {
                // Assert DmlException contains the error in custom label
                System.assert(
                    e.getMessage().contains(System.Label.VCC_Prevent_Delete_Generic_Task_Message),
                    'Prevent deletion of Calls Tasks'
                );
            }
        }
    }
    /**
     * @description This test method tests the prevention of deletion of a Task record when its RecordType is VCC_Verify_Caller.
     * The error message stored in CustomLabel VCC_Prevent_Delete_Generic_Task_Message is added to the record when it's found to be have one of these RecordTypes.
     */
    @IsTest
    static void unitPreventTaskDeletePositiveVerifyCaller() {
        VATEST_UserBuilder testUserBuilder = new VATEST_UserBuilder();
        User testUser = testUserBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        System.runAs(testUser) {
            String followUpRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('VCC_Verify_Caller')
                .getRecordTypeId();
            List<Task> taskList = new List<Task>{ new Task(RecordTypeId = followUpRecTypeId, Status = 'Open') };
            Test.startTest();
            try {
                (new VCC_TaskPreventDeleteBD()).beforeDelete(taskList);
                List<Database.Error> triggerErrors = taskList[0].getErrors();
                Assert.areEqual(1, triggerErrors.size(), 'Expected one Database.Error');
                Assert.areEqual(
                    System.Label.VCC_Prevent_Delete_Generic_Task_Message,
                    triggerErrors[0].getMessage(),
                    'Expected error stored in static property PREVENT_DELETE_ERROR_MESSAGE'
                );
            } catch (Exception thrownException) {
                Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
            }
            Test.stopTest();
        }
    }
}
