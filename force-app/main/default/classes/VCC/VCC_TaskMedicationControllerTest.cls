/**
 * @author Booz Allen
 * @date 12/2024
 * @description Test Class for the VCC_TaskMedicationController methods
 * - these changes are to bring class up to date for release 1.18.0 only
 * - Kyle Martin overhauled the class for 1.19.0
 */
@IsTest
private with sharing class VCC_TaskMedicationControllerTest {
    private static String testMviId = '1013429125V999999';
    private static String testMeds = '[{"vaStatusValue":"ACTIVE","sig":"TAKE 1 TAB BY MOUTH ONE TIME TESTING TESTING","quantityValue":1,"prescriptionValue":"10952041","lastFilledValue":"2023-05-25","fillsRemainingValue":4,"expiresValue":"2024-05-22","drugName":"A-HEFT STUDY DRUG","facilityName":"CLEVELAND VAMC - 541","indication":"","csSchedule":"","providerComments":""},{"vaStatusValue":"ACTIVE","sig":"TAKE ONE TABLET BY MOUTH TWICE A DAY HEADACHES CS SCHEDULE 6 DRUG","quantityValue":60,"prescriptionValue":"10952028","lastFilledValue":"","fillsRemainingValue":11,"expiresValue":"2024-05-22","drugName":"ZAFIRLUKAST 2OMG TAB","facilityName":"CLEVELAND VAMC - 541","indication":"","csSchedule":"","providerComments":""}]';

    /**
     * @description test setup method for VCC_TaskMedicationControllerTest
     */
    @TestSetup
    private static void makeData() {
        String uniqueUserName = 'taskmedicationcontrollertest' + Datetime.now().getTime() + '@testorg.com';
        Profile prof = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile' LIMIT 1];
        PermissionSetGroup psgTierI = [
            SELECT Id, Status
            FROM PermissionSetGroup
            WHERE DeveloperName = 'VCC_Pharmacy_I'
        ];

        if (psgTierI.Status != 'Updated') {
            Test.calculatePermissionSetGroup(psgTierI.Id);
        }

        User frrUser = new User(
            Alias = 'standt',
            Division = 'VISN 8',
            Email = 'standarduser-ooo@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName
        );
        insert frrUser;

        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Pharmacy_I', frrUser);
        VCC_TestDataFactory.assignPermissionSetByName(frrUser, 'VAHC_Access_Future_Renewal_Request');
        VCC_TestDataFactory.assignPermissionSetByName(frrUser, 'HealthCloudFoundation');
        insert new PermissionSetAssignment(PermissionSetGroupId = psgTierI.Id, AssigneeId = frrUser.Id);

        uniqueUserName = 'taskmedicationcontrollertest' + Datetime.now().getTime() + '@testorg.com';
        User frrUserInOffice = new User(
            Alias = 'standt',
            Division = 'VISN 8',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = prof.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName + '.office'
        );

        insert frrUserInOffice;

        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Pharmacy_III', frrUserInOffice);
        VCC_TestDataFactory.assignPermissionSetByName(frrUserInOffice, 'VAHC_Access_Future_Renewal_Request');
        VCC_TestDataFactory.assignPermissionSetByName(frrUserInOffice, 'HealthCloudFoundation');
        insert new PermissionSetAssignment(PermissionSetGroupId = psgTierI.Id, AssigneeId = frrUserInOffice.Id);

        System.runAs(frrUser) {
            // get the record type id for Person Accounts
            Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('PersonAccount')
                .getRecordTypeId();
            // create and insert a new account, which also creates a contact
            Account acct = new Account(
                FirstName = 'Testly',
                LastName = 'Person Accounted',
                RecordTypeId = rtId,
                VCC_MVI_External_Id__pc = testMviId
            );
            insert acct;
            Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Pharmacy')
                .getRecordTypeId();
            Contact con = [SELECT Id, VCC_MVI_External_Id__c FROM Contact LIMIT 1];
            con.VCC_MVI_External_Id__c = testMviId;
            update con;
            //Create a Pharmacy Case
            Case cse = new Case(
                RecordTypeId = caseRecTypeId,
                VCC_Case_Type__c = 'Pharmacy',
                ContactId = con.Id,
                Status = 'Pending Future Renewal Request',
                VCC_Case_Sub_Type__c = 'Pharmacy',
                VCC_Case_Outcome__c = 'Pharmacist Resolved'
            );
            insert cse;
            //Create 3 Pharmacy Tasks
            Id taskRecTypeId = Schema.SobjectType.Task.getRecordTypeInfosByDeveloperName()
                .get('VCC_Pharmacy_FRR')
                .getRecordTypeId();
            // Id queueId = [SELECT Id FROM Group WHERE DeveloperName = 'VCC_Pharmacy_FRR_Queue' LIMIT 1].Id;
            List<Task> tskList = new List<Task>();
            for (Integer itgr = 0; itgr < 3; itgr++) {
                Task tsk = new Task(
                    Subject = 'Test ' + itgr,
                    Description = testMeds,
                    WhatId = cse.Id,
                    WhoId = cse.ContactId,
                    RecordTypeId = taskRecTypeId,
                    VISN__c = 'VISN 8'
                );
                tskList.add(tsk);
            }
            insert tskList;
        }
    }

    /**
     * @description method to create a test admin user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestAdminUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withStandardData()
            .build(true);
    }

    /**
     * @description helper method to get the Task from testSetup
     * @return 'Task' returns a task
     */
    private static Task getSingleTaskRecord() {
        return [
            SELECT Id, WhatId, Subject, Description, OwnerId, VISN__c
            FROM Task
            WHERE VISN__c = 'VISN 8'
            LIMIT 1
        ];
    }

    /**
     * @description helper method to get the Case from testSetup
     * @return 'Case' returns a Case
     */
    private static Case getSingleCaseRecord() {
        return [
            SELECT Id, VCC_Case_Type__c, Status, VCC_Case_Sub_Type__c, VCC_Case_Outcome__c, OwnerId
            FROM Case
            LIMIT 1
        ];
    }

    /**
     * @description helper method to build inputMap
     * @return 'Map<String, Object>' returns a map of input values
     */
    private static Map<String, Object> buildInputMap() {
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('pnString', '');
        inputMap.put('controlled', true);
        inputMap.put('nonControlled', false);
        inputMap.put('newDescription', '');
        inputMap.put('facilityName', '');
        return inputMap;
    }

    /**
     * @description unit test get table data positive
     * @see VCC_TaskMedicationController.getTableData
     */
    @IsTest
    private static void unitGetTableDataSuccess() {
        System.runAs(createTestAdminUser()) {
            // get meds details for Create Progress Note component
            Task tsk = getSingleTaskRecord();
            Test.startTest();
            List<Task> tskList = VCC_TaskMedicationController.getTableData(tsk.Id);
            Test.stopTest();
            Assert.areEqual(testMeds, tskList[0].Description, 'Description should match');
            Assert.areEqual(1, tskList.size(), 'List should have found 1 Task');
        }
    }

    /**
     * @description unit test to find unsigned PMs, expecting no unsigned
     * @see VCC_TaskMedicationController.checkCaseForUnsignedPNs
     */
    @IsTest
    private static void checkCaseForUnsignedPNsNoUnsignedPNs() {
        System.runAs(createTestAdminUser()) {
            Task tsk = [SELECT Id, WhatId FROM Task WHERE VISN__c = 'VISN 8' LIMIT 1];
            Test.startTest();
            Boolean hasUnsignedPNs = VCC_TaskMedicationController.checkCaseForUnsignedPNs(tsk.WhatId);
            Test.stopTest();
            Assert.areEqual(false, hasUnsignedPNs, 'No Unsigned Progress Notes should be found');
        }
    }

    /**
     * @description unit test to find unsigned PMs, expecting unsigned
     * @see VCC_TaskMedicationController.checkCaseForUnsignedPNs
     */
    @IsTest
    private static void checkCaseForUnsignedPNsHasUnsignedPNs() {
        System.runAs(createTestAdminUser()) {
            Task tsk = [SELECT Id, WhatId FROM Task WHERE VISN__c = 'VISN 8' LIMIT 1];
            // add a unsigned PN
            Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                .get('VCC_Tier_I_Progress_Note')
                .getRecordTypeId();
            VCC_Progress_Note__c pNote = new VCC_Progress_Note__c(
                VCC_Case__c = tsk.WhatId,
                RecordTypeId = pnRecTypeId,
                VCC_Caregiver_Name__c = 'Unit Test'
            );
            insert pNote;

            Test.startTest();
            Boolean hasUnsignedPNs = VCC_TaskMedicationController.checkCaseForUnsignedPNs(tsk.WhatId);
            Test.stopTest();
            Assert.areEqual(true, hasUnsignedPNs, 'Has Unsigned Progress Notes');
        }
    }

    /**
     * @description unit test createProgressNoteFromTask
     * @see VCC_TaskMedicationController.createProgressNoteFromTask
     */
    @IsTest
    private static void createProgressNoteFromTaskSuccess() {
        System.runAs(createTestAdminUser()) {
            Task tsk = getSingleTaskRecord();
            Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                .get('VCC_Tier_I_Progress_Note')
                .getRecordTypeId();

            User testUser = [SELECT Id FROM User WHERE Email = 'standarduser-ooo@testorg.com' LIMIT 1];

            Test.startTest();
            System.runAs(testUser) {
                tsk.OwnerId = testUser.Id;
                update tsk;

                Case relatedCase = VCC_TaskMedicationController.getCaseToReturn(tsk.WhatId);

                Map<String, Object> inputMap = buildInputMap();
                inputMap.put('relatedCase', relatedCase);
                inputMap.put('recordId', tsk.Id);
                inputMap.put('recordTypeName', 'VCC_Tier_I_Progress_Note');
                //build a note via stub
                Set<String> myAdditionalPNoteFields = new Set<String>{
                    'VCC_Requested_Medication__c',
                    'VCC_Medication_Fill_Renewal__c',
                    'VCC_Controlled_medication__c',
                    'VCC_Non_controlled_medication__c',
                    'RecordTypeId',
                    'VCC_Case__c',
                    'VCC_Relative_Type__c',
                    'VCC_If_Other_Describe_Relation_Patient__c',
                    'VCC_Caller_Name_Text__c',
                    'VCC_Facility__c'
                };
                VCC_Progress_Note__c tempNote = VCC_TaskMedicationController.setPNoteFields(inputMap);
                Id pNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.SobjectType);
                VCR_ProgressNoteRepo stubPNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                        VCR_ProgressNoteRepo.class
                    )
                    .mockingMethodCall('insertProgressNotesAllOrNoneFalse')
                    .withParameterTypes(List<VCC_Progress_Note__c>.class)
                    .withParameterValues(new List<VCC_Progress_Note__c>{ tempNote })
                    .returning(
                        (List<Database.SaveResult>) JSON.deserialize(
                            '[{"success":true, "id":"' + pNoteId + '"}]',
                            List<Database.SaveResult>.class
                        )
                    )
                    .mockingMethodCall('fetchById')
                    .withParameterTypes(Id.class, Set<String>.class)
                    .withParameterValues(pNoteId, myAdditionalPNoteFields)
                    .returning(tempNote)
                    .defineStub();
                VCC_TaskMedicationController.pNoteRepo = stubPNoteRepo;

                //stubbed task repo
                VCR_TaskRepo stubTaskRepo = (VCR_TaskRepo) new VATEST_StubBuilder(VCR_TaskRepo.class)
                    .mockingMethodCall('updateTasks')
                    .withParameterTypes(List<Task>.class)
                    .withParameterValues(new List<Task>{ tsk })
                    .returning(
                        (List<Database.SaveResult>) JSON.deserialize(
                            '[{"success":true}]',
                            List<Database.SaveResult>.class
                        )
                    )
                    .mockingMethodCall('fetchById')
                    .withParameterTypes(Id.class, Set<String>.class)
                    .withParameterValues(tsk.Id, new Set<String>{ 'WhatId' })
                    .returning(tsk)
                    .defineStub();
                VCC_TaskMedicationController.taskRepo = stubTaskRepo;

                //make the call
                VCC_Progress_Note__c pNote = VCC_TaskMedicationController.createProgressNoteFromTask(inputMap);
                Assert.areEqual(true, pNote.VCC_Controlled_medication__c, 'Expected Controlled to be true');
                Assert.areEqual(false, pNote.VCC_Non_controlled_medication__c, 'Expected Non-controlled to be false');
                Assert.areEqual('', pNote.VCC_Requested_Medication__c, 'Expected Requested Med to match');
                Assert.areEqual(true, pNote.VCC_Medication_Fill_Renewal__c, 'Expected Renewal to be true');
                Assert.areEqual(pnRecTypeId, pNote.RecordTypeId, 'Expected Rec Type value to match');
            }
            Test.stopTest();
        }
    }

    /**
     * @description unit test createProgressNoteFromTask
     * @see VCC_TaskMedicationController.createProgressNoteFromTask
     */
    @IsTest
    private static void createProgressNoteFromTaskSuccessTierIII() {
        System.runAs(createTestAdminUser()) {
            User testUser = [SELECT Id FROM User WHERE Username LIKE '%office' LIMIT 1];

            Test.startTest();
            System.runAs(testUser) {
                VCC_Progress_Note__c tempNote = new VCC_Progress_Note__c();
                Id pNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.SobjectType);
                VCR_ProgressNoteRepo stubPNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                        VCR_ProgressNoteRepo.class
                    )
                    .mockingMethodCall('insertProgressNotesAllOrNoneFalseUnsafe')
                    .withParameterTypes(List<VCC_Progress_Note__c>.class)
                    .withParameterValues(new List<VCC_Progress_Note__c>{ tempNote })
                    .returning(
                        (List<Database.SaveResult>) JSON.deserialize(
                            '[{"success":true, "id":"' + pNoteId + '"}]',
                            List<Database.SaveResult>.class
                        )
                    )
                    .defineStub();
                VCC_TaskMedicationController.pNoteRepoUnsafe = stubPNoteRepo;
                List<DataBase.SaveResult> savRes = VCC_TaskMedicationController.insertProgressNote(tempNote);
                Assert.areEqual(pNoteId, savRes[0].getId(), 'Expected PNote ID to be equal to save result getId');
            }
            Test.stopTest();
        }
    }

    /**
     * @description unit test createProgressNoteFromTask throwing exception
     * @see VCC_TaskMedicationController.createProgressNoteFromTask
     */
    @IsTest
    private static void createProgressNoteFromTaskException() {
        System.runAs(createTestAdminUser()) {
            AuraHandledException expectedException;
            Map<String, Object> inputMap = new Map<String, Object>();
            Test.startTest();
            try {
                VCC_TaskMedicationController.createProgressNoteFromTask(inputMap);
            } catch (AuraHandledException exc) {
                expectedException = exc;
            }
            Test.stopTest();
            Assert.isNotNull(expectedException, 'Expected an exception.');
        }
    }

    /**
     * @description unit test getRelatedTaskDetail positive
     * @see VCC_TaskMedicationController.getRelatedTaskDetail
     */
    @IsTest
    private static void getRelatedTaskDetailSuccess() {
        System.runAs(createTestAdminUser()) {
            Task tsk = [SELECT Id, WhatId FROM Task WHERE VISN__c = 'VISN 8' LIMIT 1];
            Test.startTest();
            List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(tsk.WhatId);
            Test.stopTest();
            Assert.areEqual(3, tskList.size(), 'Should have found 3 Tasks');
        }
    }
    /**
     * @description Test for PN. Retrieve one of the FRR tasks, then relate it to a PN.
     * Then pass getRelatedTaskDetail the PN Id, and expect the returned task list to be size 1
     */
    @IsTest
    private static void getRelatedTaskDetailPN() {
        System.runAs(createTestAdminUser()) {
            Task tsk = getSingleTaskRecord();

            User testUser = [SELECT Id FROM User WHERE Email = 'standarduser-ooo@testorg.com' LIMIT 1];
            Map<String, Object> inputMap = new Map<String, Object>();
            Test.startTest();
            System.runAs(testUser) {
                tsk.OwnerId = testUser.Id;
                update tsk;
                Case relatedCase = VCC_TaskMedicationController.getCaseToReturn(tsk.WhatId);

                inputMap = buildInputMap();
                inputMap.put('relatedCase', relatedCase);
                inputMap.put('recordId', tsk.Id);
                inputMap.put('recordTypeName', 'VCC_Tier_I_Progress_Note');
                //build a note via stub
                Set<String> myAdditionalPNoteFields = new Set<String>{
                    'VCC_Requested_Medication__c',
                    'VCC_Medication_Fill_Renewal__c',
                    'VCC_Controlled_medication__c',
                    'VCC_Non_controlled_medication__c',
                    'RecordTypeId',
                    'VCC_Case__c',
                    'VCC_Relative_Type__c',
                    'VCC_If_Other_Describe_Relation_Patient__c',
                    'VCC_Caller_Name_Text__c',
                    'VCC_Facility__c'
                };
                VCC_Progress_Note__c tempNote = VCC_TaskMedicationController.setPNoteFields(inputMap);
                Id pNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.SobjectType);
                VCR_ProgressNoteRepo stubPNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                        VCR_ProgressNoteRepo.class
                    )
                    .mockingMethodCall('insertProgressNotesAllOrNoneFalse')
                    .withParameterTypes(List<VCC_Progress_Note__c>.class)
                    .withParameterValues(new List<VCC_Progress_Note__c>{ tempNote })
                    .returning(
                        (List<Database.SaveResult>) JSON.deserialize(
                            '[{"success":true, "id":"' + pNoteId + '"}]',
                            List<Database.SaveResult>.class
                        )
                    )
                    .mockingMethodCall('fetchById')
                    .withParameterTypes(Id.class, Set<String>.class)
                    .withParameterValues(pNoteId, myAdditionalPNoteFields)
                    .returning(tempNote)
                    .defineStub();
                VCC_TaskMedicationController.pNoteRepo = stubPNoteRepo;

                //stubbed task repo
                VCR_TaskRepo stubTaskRepo = (VCR_TaskRepo) new VATEST_StubBuilder(VCR_TaskRepo.class)
                    .mockingMethodCall('updateTasks')
                    .withParameterTypes(List<Task>.class)
                    .withParameterValues(new List<Task>{ tsk })
                    .returning(
                        (List<Database.SaveResult>) JSON.deserialize(
                            '[{"success":true}]',
                            List<Database.SaveResult>.class
                        )
                    )
                    .mockingMethodCall('fetchById')
                    .withParameterTypes(Id.class, Set<String>.class)
                    .withParameterValues(tsk.Id, new Set<String>{ 'WhatId' })
                    .returning(tsk)
                    .mockingMethodCall('fetchTaskFromPNoteRecordId')
                    .withParameterTypes(Id.class, String.class)
                    .withParameterValues(pNoteId, 'VCC_Progress_Note__c')
                    .returning(new List<Task>{ tsk })
                    .defineStub();
                VCC_TaskMedicationController.taskRepo = stubTaskRepo;

                //make the call
                VCC_TaskMedicationController.createProgressNoteFromTask(inputMap);
                List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(pNoteId);
                Assert.areEqual(1, tskList.size(), 'Should have found 1 Tasks');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test for Task with WhatId as Case. Retrieve one of the FRR tasks.
     *  Then pass getRelatedTaskDetail the task Ids, and expect the returned task list to be size 2
     */
    @IsTest
    private static void getRelatedTaskDetailTask() {
        System.runAs(createTestAdminUser()) {
            Task tsk = getSingleTaskRecord();
            Test.startTest();
            List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(tsk.Id);
            Test.stopTest();
            Assert.areEqual(2, tskList.size(), 'Should have found 2 Tasks');
        }
    }
    /**
     *@description Test for Task with WhatId as VCC_Progress_Note__c. Retrieve one of the FRR tasks.
     *Then pass getRelatedTaskDetail the task Ids, and expect the returned task list to be size 2
     */
    @IsTest
    private static void getRelatedTaskDetailTaskPN() {
        System.runAs(createTestAdminUser()) {
            User testUser = [SELECT Id FROM User WHERE Email = 'standarduser-ooo@testorg.com' LIMIT 1];
            System.runAs(testUser) {
                Case cse = getSingleCaseRecord();
                // add a unsigned PN
                Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Tier_I_Progress_Note')
                    .getRecordTypeId();
                VCC_Progress_Note__c progNote = new VCC_Progress_Note__c(
                    VCC_Case__c = cse.Id,
                    RecordTypeId = pnRecTypeId
                );
                insert progNote;
                Id taskRecTypeId = Schema.SobjectType.Task.getRecordTypeInfosByDeveloperName()
                    .get('VCC_Pharmacy_FRR')
                    .getRecordTypeId();
                Task tsk = new Task(
                    Subject = 'Test ' + 3,
                    Description = testMeds,
                    WhatId = progNote.Id,
                    RecordTypeId = taskRecTypeId,
                    VISN__c = 'VISN 8'
                );
                insert tsk;

                Test.startTest();

                tsk.OwnerId = testUser.Id;
                update tsk;
                List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(tsk.Id);
                Assert.areEqual(3, tskList.size(), 'Should have found 3 Tasks');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Test for Case. Retrieve the pharm case created.
     *Then pass Then pass getRelatedTaskDetail the Case ID, and expect the returned task list to be size 3
     */
    @IsTest
    private static void getRelatedTaskDetailCase() {
        System.runAs(createTestAdminUser()) {
            Case cse = [SELECT Id, VCC_Case_Type__c FROM Case WHERE VCC_Case_Type__c = 'Pharmacy' LIMIT 1];
            Test.startTest();
            List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(cse.Id);
            Test.stopTest();
            Assert.areEqual(3, tskList.size(), 'Should have found 3 Tasks');
        }
    }
    /**
     * @description Test for PersonAccount. Create an FRR task under a case for a particular account. Then pass getRelatedTaskDetail the account ID
     * Then expect the returned task list to be size 1
     * */
    @IsTest
    private static void getRelatedTaskDetailAccount() {
        System.runAs(createTestAdminUser()) {
            Account acct = [
                SELECT Id, VCC_MVI_External_Id__pc
                FROM Account
                WHERE VCC_MVI_External_Id__pc = '1013429125V999999'
                LIMIT 1
            ];
            Test.startTest();
            List<Task> tskList = VCC_TaskMedicationController.getRelatedTaskDetail(acct.Id);
            Test.stopTest();
            Assert.areEqual(3, tskList.size(), 'Should have found 3 Tasks');
        }
    }

    /**
     * @description unit test of changing case owner
     * @see VCC_TaskMedicationController.updateCaseOwner
     */
    @IsTest
    static void unitUpdateCaseOwnerPositive() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            Case testCase;
            Case cse = getSingleCaseRecord();

            Test.startTest();
            testCase = VCC_TaskMedicationController.updateCaseOwner(cse);
            Test.stopTest();
            Assert.areEqual(adminUser.Id, testCase.OwnerId, 'Expected UserId to be Case Owner Id');
        }
    }

    /**
     * @description unit test of changing case owner, negative case
     * @see VCC_TaskMedicationController.updateCaseOwner
     */
    @IsTest
    static void unitUpdateCaseOwnerNegative() {
        Case cse = getSingleCaseRecord();
        //stubbed Case repo
        VCR_CaseRepo stubCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('upsertCasesAllOrNoneFalse')
            .withParameterTypes(List<Case>.class)
            .withParameterValues(new List<Case>{ cse })
            .returning(
                (List<Database.UpsertResult>) JSON.deserialize(
                    '[{"success":false,"errors":[{"message":"test error","statusCode":"00"}]}]',
                    List<Database.UpsertResult>.class
                )
            )
            .defineStub();
        VCC_TaskMedicationController.caseRepo = stubCaseRepo;
        User baseUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
        System.runAs(baseUser) {
            Boolean isExceptionThrown = false;
            Test.startTest();
            try {
                VCC_TaskMedicationController.updateCaseOwner(cse);
            } catch (Exception expectedException) {
                isExceptionThrown = true;
            }
            Assert.areEqual(
                true,
                isExceptionThrown,
                'Expected Exception to be thrown when attempting to change case owner'
            );
            Test.stopTest();
        }
    }
}
