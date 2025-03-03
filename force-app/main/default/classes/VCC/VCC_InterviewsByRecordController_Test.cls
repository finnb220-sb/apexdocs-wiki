@IsTest
public with sharing class VCC_InterviewsByRecordController_Test {
    private static final String username = 'antv';
    @TestSetup
    static void makeData() {
        List<User> userList = new List<User>();
        List<String> psgNames = new List<String>{ 'VCC_Registered_Nurse', 'VCC_Medical_Provider' };
        List<Id> psgIds = new List<Id>();
        for (PermissionSetGroup psg : [SELECT Id FROM PermissionSetGroup WHERE DeveloperName IN :psgNames]) {
            psgIds.add(psg.Id);
        }
        Test.calculatePermissionSetGroup(psgIds);
        for (Integer i = 0; i < psgNames.size(); i++) {
            User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
            userList.add(testUser);
            VCC_TestDataFactory.addPermSetGroupToUser(psgNames[i], testUser);
            VCC_TestDataFactory.assignPermissionSetByName(testUser, 'HealthCloudFoundation');
            testUser.username = username + testUser.username + i;
            testUser.Title = psgNames[i];
        }
        update userList;
    }
    private static User getTestUser(Integer offset) {
        return [SELECT Id, MVIICN__c, Title FROM User WHERE Username LIKE :username + '%' LIMIT 1 OFFSET :offset];
    }
    public static VCC_Progress_Note__c insertTestPN(User testUser) {
        Account testAccount = TestUtility.createAccount('testAccount');
        insert testAccount;
        Contact testContact = TestUtility.createContact(testUser.Id, 'lastName', testAccount.Id);
        insert testContact;
        Case testCase = new Case(
            RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Virtual Clinic Visit Case').getRecordTypeId(),
            VCC_Caller_Relation__c = 'Self',
            ContactId = testContact.Id
        );
        insert testCase;
        insert new CaseShare(CaseId = testCase.Id, CaseAccessLevel = 'Edit', UserOrGroupId = testUser.Id);
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            VCC_Case__r = testCase,
            VCC_Case__c = testCase.Id,
            VCC_Relative_Type__c = 'Self',
            VCC_Additional_Comments__c = 'Some additional comment.',
            VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
            RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Virtual_Visit_Progress_Note').getRecordTypeId()
        );
        insert pn;
        return pn;
    }
    @IsTest
    private static void getPausedIdTestRN() {
        User testUser = getTestUser(0);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<VCC_Progress_Note__c> recordIds = [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ];
        Test.startTest();
        String paused;
        System.runAs(testUser) {
            try {
                paused = VCC_InterviewsByRecordController.getPausedId(recordIds.get(0).Id);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
            System.assertEquals(null, paused, 'Paused interview incorrectly retrieved');
        }
        Test.stopTest();
    }

    @IsTest
    private static void getPausedIdTestMP() {
        User testUser = getTestUser(1);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<VCC_Progress_Note__c> recordIds = [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ];
        Test.startTest();
        String paused;
        System.runAs(testUser) {
            try {
                paused = VCC_InterviewsByRecordController.getPausedId(recordIds.get(0).Id);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
            System.assertEquals(null, paused, 'Paused interview incorrectly retrieved');
        }
        Test.stopTest();
    }
    @IsTest
    private static void retrieveInterviewsTestRN() {
        User testUser = getTestUser(0);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<String> PNID = new List<String>();
        for (VCC_Progress_Note__c notes : [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ])
            PNID.add(notes.Id);

        Test.startTest();
        List<String> paused;
        System.runAs(testUser) {
            try {
                paused = VCC_InterviewsByRecordController.retrieveInterviews(PNID);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals(null, paused, 'Paused interviews found where none exist');
        Test.stopTest();
    }

    @IsTest
    private static void retrieveInterviewsTestMP() {
        User testUser = getTestUser(1);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<String> PNID = new List<String>();
        for (VCC_Progress_Note__c notes : [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ])
            PNID.add(notes.Id);

        Test.startTest();
        List<String> paused;
        System.runAs(testUser) {
            try {
                paused = VCC_InterviewsByRecordController.retrieveInterviews(PNID);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals(null, paused, 'Paused interviews found where none exist');
        Test.stopTest();
    }
    @IsTest
    private static void removeInterviewsTestRN() {
        User testUser = getTestUser(0);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<Id> PNID = new List<String>();
        for (VCC_Progress_Note__c notes : [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ])
            PNID.add(notes.Id);

        Test.startTest();
        Boolean removed;
        System.runAs(testUser) {
            try {
                removed = VCC_InterviewsByRecordController.removeInterview(PNID.get(0));
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
            System.assertEquals(false, removed, 'Removed interviews where none exist');
        }
        Test.stopTest();
    }

    @IsTest
    private static void removeInterviewsTestMP() {
        User testUser = getTestUser(1);
        VCC_Progress_Note__c pn = insertTestPN(testUser);
        List<Id> PNID = new List<String>();
        for (VCC_Progress_Note__c notes : [
            SELECT Id
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ])
            PNID.add(notes.Id);

        Test.startTest();
        Boolean removed;
        System.runAs(testUser) {
            try {
                removed = VCC_InterviewsByRecordController.removeInterview(PNID.get(0));
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
            System.assertEquals(false, removed, 'Removed interviews where none exist');
        }
        Test.stopTest();
    }
    public static VCC_Progress_Note__c insertTestPNforData(User testUser) {
        Account testAccount = TestUtility.createAccount('testAccount');
        insert testAccount;
        Contact testContact = TestUtility.createContact(testUser.Id, 'lastName', testAccount.Id);
        insert testContact;
        Case testCase = new Case(
            RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Virtual Clinic Visit Case').getRecordTypeId(),
            VCC_Caller_Relation__c = 'Self',
            ContactId = testContact.Id
        );
        insert testCase;
        insert new CaseShare(CaseId = testCase.Id, CaseAccessLevel = 'Edit', UserOrGroupId = testUser.Id);
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            VCC_Case__r = testCase,
            VCC_Case__c = testCase.Id,
            VCC_Relative_Type__c = 'Self',
            VCC_Additional_Comments__c = 'Some additional comment.',
            VCC_Comments_patient_in_crisis__c = 'some long string that will be longer than 80 characters long to demonstrate the line breaking',
            RecordTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Virtual_Visit_Progress_Note').getRecordTypeId(),
            VCC_T2T_Assessment_Completed__c = true
        );
        insert pn;
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = pn.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"},' +
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}]';
        insert note;
        return pn;
    }
    @IsTest
    static void testresetT2TDataRN() {
        User testUser = getTestUser(0);
        VCC_Progress_Note__c pn = insertTestPNforData(testUser);
        String recordId = pn.Id;
        Test.startTest();
        VCC_Progress_Note__c pResult;
        VCC_Progress_Note_Detail__c dResult;
        System.runAs(testUser) {
            try {
                VCC_InterviewsByRecordController.resetT2TData(recordId);
                pResult = [
                    SELECT Id, Name, LastModifiedDate, VCC_Signed__c, VCC_Relative_Type__c, VCC_Caller_Name_Text__c, VCC_Caregiver_Name__c, VCC_T2T_Assessment_Completed__c
                    FROM VCC_Progress_Note__c
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                dResult = [
                    SELECT Id, Name, VCC_Progress_Note__c, VCC_T2T_Data__c
                    FROM VCC_Progress_Note_Detail__c
                    WHERE VCC_Progress_Note__c = :recordId
                    LIMIT 1
                ];
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals(null, dResult.VCC_T2T_Data__c);
        System.assertEquals(false, pResult.VCC_T2T_Assessment_Completed__c);
        Test.stopTest();
    }

    @IsTest
    static void testresetT2TDataMP() {
        User testUser = getTestUser(1);
        VCC_Progress_Note__c pn = insertTestPNforData(testUser);
        String recordId = pn.Id;
        Test.startTest();
        VCC_Progress_Note__c pResult;
        VCC_Progress_Note_Detail__c dResult;
        System.runAs(testUser) {
            try {
                VCC_InterviewsByRecordController.resetT2TData(recordId);
                pResult = [
                    SELECT Id, Name, LastModifiedDate, VCC_Signed__c, VCC_Relative_Type__c, VCC_Caller_Name_Text__c, VCC_Caregiver_Name__c, VCC_T2T_Assessment_Completed__c
                    FROM VCC_Progress_Note__c
                    WHERE Id = :recordId
                    LIMIT 1
                ];
                dResult = [
                    SELECT Id, Name, VCC_Progress_Note__c, VCC_T2T_Data__c
                    FROM VCC_Progress_Note_Detail__c
                    WHERE VCC_Progress_Note__c = :recordId
                    LIMIT 1
                ];
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals(null, dResult.VCC_T2T_Data__c);
        System.assertEquals(false, pResult.VCC_T2T_Assessment_Completed__c);
        Test.stopTest();
    }
    @IsTest
    private static void testGetFieldValueRN() {
        User testUser = getTestUser(0);
        VCC_Progress_Note__c pn = insertTestPNforData(testUser);

        // Arrange
        List<VCC_Progress_Note__c> recordIds = [
            SELECT Id, VCC_T2T_Assessment_Completed__c
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ];
        VCC_Progress_Note__c progressNote = recordIds.get(0);
        // Act
        Test.startTest();
        Boolean fieldValue;
        System.runAs(testUser) {
            try {
                fieldValue = VCC_InterviewsByRecordController.getFieldValue(progressNote.Id);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert
        System.assertEquals(progressNote.VCC_T2T_Assessment_Completed__c, fieldValue, 'Field value mismatch');
        Test.stopTest();
    }
    @IsTest
    private static void testGetFieldValueMP() {
        User testUser = getTestUser(1);
        VCC_Progress_Note__c pn = insertTestPNforData(testUser);

        // Arrange
        List<VCC_Progress_Note__c> recordIds = [
            SELECT Id, VCC_T2T_Assessment_Completed__c
            FROM VCC_Progress_Note__c
            WHERE Id = :pn.Id
            LIMIT 1
        ];
        VCC_Progress_Note__c progressNote = recordIds.get(0);
        // Act
        Test.startTest();
        Boolean fieldValue;
        System.runAs(testUser) {
            try {
                fieldValue = VCC_InterviewsByRecordController.getFieldValue(progressNote.Id);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert
        System.assertEquals(progressNote.VCC_T2T_Assessment_Completed__c, fieldValue, 'Field value mismatch');
        Test.stopTest();
    }
}
