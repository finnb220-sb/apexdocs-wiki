/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCR_TaskRepo class.
 * @group Depeche Code
 * @see VCR_TaskRepo
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
public with sharing class VCR_TaskRepoTest {
    /**
     * @description Build test data for use in test methods
     */
    @TestSetup
    private static void buildData() {
        Contact testContact;
        User adminUser = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
        User frrUser;
        System.runAs(adminUser) {
            //build FRR User
            String uniqueUserName = 'taskmedicationcontrollertest' + Datetime.now().getTime() + '@testorg.com';
            PermissionSetGroup psgTierI = [
                SELECT Id, Status
                FROM PermissionSetGroup
                WHERE DeveloperName = 'VCC_Pharmacy_I'
            ];

            if (psgTierI.Status != 'Updated') {
                Test.calculatePermissionSetGroup(psgTierI.Id);
            }
            frrUser = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withPermissionSets(
                    new Set<String>{ 'VCC_Pharmacy_I', 'VAHC_Access_Future_Renewal_Request', 'HealthCloudFoundation' }
                )
                .withStandardData()
                .setFields(
                    new Map<Schema.SObjectField, Object>{
                        User.Alias => 'standt',
                        User.Division => 'VISN 8',
                        User.Email => 'standarduser-ooo@testorg.com',
                        User.EmailEncodingKey => 'UTF-8',
                        User.LastName => 'Testing',
                        User.LanguageLocaleKey => 'en_US',
                        User.LocaleSidKey => 'en_US',
                        User.TimeZoneSidKey => 'America/Los_Angeles',
                        User.Username => uniqueUserName
                    }
                )
                .build(true);
        }
        System.runAs(frrUser) {
            Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(
                    FirstName = 'Testly',
                    LastName = 'Person Accounted',
                    RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id
                ),
                true
            );

            if (testAccount != null) {
                testContact = [SELECT Id FROM Contact LIMIT 1];
            }

            update testContact;

            Id caseRecTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id;

            Id pnRecTypeId = new VCR_ProgressNoteRepo()
                .recordTypeConstant.fromDeveloperName('VCC_Tier_II_Progress_Note')
                .Id;

            Id taskRecTypeId = new VCR_TaskRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy_FRR').Id;

            Case testCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Pharmacy', ContactId = testContact.Id),
                true
            );

            VCC_Progress_Note__c testNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                new VCC_Progress_Note__c(
                    VCC_Case__c = testCase.Id,
                    RecordTypeId = pnRecTypeId,
                    VCC_Caregiver_Name__c = 'Unit Test'
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(new Task(WhatId = testNote.Id, RecordTypeId = taskRecTypeId), true);

            VATEST_SObjectFactory.createSObject(new Task(WhatId = testCase.Id, RecordTypeId = taskRecTypeId), true);

            VATEST_SObjectFactory.createSObject(new Task(WhoId = testContact.Id, RecordTypeId = taskRecTypeId), true);
        }
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    /**
     * @description helper method to get the Contact from testsetup
     * @return      `Contact`
     */
    private static Contact getSingleContactRecord() {
        return [
            SELECT Id
            FROM Contact
            LIMIT 1
        ];
    }

    /**
     * @description helper method to get the case from testsetup
     * @return      `Case`
     */
    private static Case getSingleCaseRecord() {
        return [
            SELECT Id
            FROM Case
            LIMIT 1
        ];
    }
    /**
     * @description helper method to get the note from testsetup
     * @return      `VCC_Progress_Note__c`
     */
    private static VCC_Progress_Note__c getSingleProgressNoteRecord() {
        return [
            SELECT Id, VCC_Case__c
            FROM VCC_Progress_Note__c
            LIMIT 1
        ];
    }

    /**
     * @description helper method to get the Task from testSetup related to the PNote
     * @return 'Task' returns a task
     */
    private static Task getSingleTaskRecordPnote() {
        VCC_Progress_Note__c testNote = getSingleProgressNoteRecord();
        return [
            SELECT Id, WhatId, Subject, Description, OwnerId, Status
            FROM Task
            WHERE WhatId = :testNote.Id
            LIMIT 1
        ];
    }

    /**
     * @description helper method to get the Task from testSetup related to the Case
     * @return 'Task' returns a task
     */
    private static Task getSingleTaskRecordCase() {
        Case testCase = getSingleCaseRecord();
        return [
            SELECT Id, WhatId, Subject, Description, OwnerId
            FROM Task
            WHERE WhatId = :testCase.Id
            LIMIT 1
        ];
    }

    /**
     * @description helper method to get the Task from testSetup related to the Account
     * @return 'Task' returns a task
     */
    private static Task getSingleTaskRecordAccount() {
        Contact testContact = getSingleContactRecord();
        return [
            SELECT Id, WhatId, Subject, Description, OwnerId
            FROM Task
            WHERE WhoId = :testContact.Id
            LIMIT 1
        ];
    }

    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_TaskRepo');
    }

    /**
     * @description functional test for fetching a Task from a Progress Note Id
     * @see VCR_TaskRepo.fetchTaskFromPNoteRecordId
     */
    @IsTest
    static void funcFetchTaskFromPNoteRecordIdPositive() {
        String whatObject = 'VCC_Progress_Note__c';
        List<Task> returnList = new List<Task>();

        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        VCC_Progress_Note__c testNote = getSingleProgressNoteRecord();
        returnList = repo.fetchTaskFromPNoteRecordId(testNote.Id, whatObject);
        Test.stopTest();
        Assert.areEqual(
            1,
            returnList.size(),
            'Expected a single Task to be returned when retrieving Task from Progress Note but observed different count of Tasks'
        );
    }

    /**
     * @description functional test for fetching a Task from a Task Id
     * @see VCR_TaskRepo.fetchTaskFromTaskRecordId
     */
    @IsTest
    static void funcFetchTaskFromTaskRecordIdWithNotePositive() {
        List<Task> returnList = new List<Task>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        VCC_Progress_Note__c testNote = getSingleProgressNoteRecord();
        Task testTask = getSingleTaskRecordPnote();
        inputMap.put('recId', testNote.Id);
        inputMap.put('whatObject', 'Task');
        inputMap.put('pNoteRecord', testNote);
        inputMap.put('taskRecord', testTask);
        inputMap.put('taskWhatObject', 'VCC_Progress_Note__c');
        returnList = repo.fetchTaskFromTaskRecordId(inputMap);
        Test.stopTest();
        Assert.areEqual(
            1,
            returnList.size(),
            'Expected a single Task to be returned when retrieving Task from Task but observed different count of Tasks'
        );
    }

    /**
     * @description functional test for fetching a Task from a Task Id, this is the negative test, not expecting a return
     * @see VCR_TaskRepo.fetchTaskFromTaskRecordId
     */
    @IsTest
    static void funcFetchTaskFromTaskRecordIdWithTaskNegative() {
        List<Task> returnList = new List<Task>();
        Map<String, Object> inputMap = new Map<String, Object>();
        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        VCC_Progress_Note__c testNote = getSingleProgressNoteRecord();
        Task testTask = getSingleTaskRecordPnote();
        inputMap.put('recId', testNote.Id);
        inputMap.put('whatObject', 'Task');
        inputMap.put('pNoteRecord', testNote);
        inputMap.put('taskRecord', testTask);
        inputMap.put('taskWhatObject', 'Task');
        returnList = repo.fetchTaskFromTaskRecordId(inputMap);
        Test.stopTest();
        Assert.areEqual(
            0,
            returnList.size(),
            'Not expected to return a task when retrieving Task from Task but observed different count of Tasks'
        );
    }

    /**
     * @description func test for fetching a Task from a Case Id
     * @see VCR_TaskRepo.fetchTaskFromCaseRecordId
     */
    @IsTest
    static void funcFetchTaskFromCaseRecordIdPositive() {
        String whatObject = 'Case';
        List<Task> returnList = new List<Task>();

        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        Case testCase = getSingleCaseRecord();
        returnList = repo.fetchTaskFromCaseRecordId(testCase.Id, whatObject);
        Test.stopTest();
        Assert.areEqual(
            1,
            returnList.size(),
            'Expected a single Task to be returned when retrieving Task from Case but observed different count of Tasks'
        );
    }

    /**
     * @description functional test for fetching a Task from an Account Id
     * @see VCR_TaskRepo.fetchTaskFromAccountRecordId
     */
    @IsTest
    static void funcFetchTaskFromAccountRecordIdPositive() {
        String whatObject = 'Account';
        List<Task> returnList = new List<Task>();

        Test.startTest();
        VCR_TaskRepo repo = new VCR_TaskRepo();
        Contact testContact = getSingleContactRecord();
        returnList = repo.fetchTaskFromAccountRecordId(testContact.Id, whatObject);
        Test.stopTest();
        Assert.areEqual(
            1,
            returnList.size(),
            'Expected a single Task to be returned when retrieving Task from Account but observed different count of Tasks'
        );
    }

    /**
     * @description functional test for updating tasks with repos
     * @see VCR_TaskRepo.updateTasks
     */
    @IsTest
    static void funcUpdateTasks() {
        List<Task> taskListToInsert = new List<Task>();
        System.runAs(getTestUser()) {
            Task testTask = getSingleTaskRecordPnote();
            testTask.Status = 'Completed';
            taskListToInsert.add(testTask);
            Test.startTest();
            VCR_TaskRepo repo = new VCR_TaskRepo();
            repo.updateTasks(taskListToInsert);
            Test.stopTest();
            Assert.areEqual(
                'Completed',
                testTask.Status,
                'Status should be set to completed but found a different value'
            );
        }
    }
}
