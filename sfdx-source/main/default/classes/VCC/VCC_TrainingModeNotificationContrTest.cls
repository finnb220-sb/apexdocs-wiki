/**
 * VCC_TrainingModeNotificationContrTest
 * @description Unit test for VCC_TRainingModeNotificationController class.
 * @author Liberty
 * @date 12/7/2021
 * updated 01/16/2024 by Kyle Martin - PMD compliance
 */
@IsTest
public with sharing class VCC_TrainingModeNotificationContrTest {
    private static String usernameTestPrefix = 'trainingModeNotificationTester';
    /**
     * @description creating test user to run test as
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        testUser.Username = usernameTestPrefix + testUser.Username;
        update testUser;
    }

    /**
     * @description retrieves the test user from setup
     * @return  `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :usernameTestPrefix + '%' LIMIT 1];
    }
    /**
     * @description testing the constructor
     */
    @IsTest
    private static void ctor() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_TrainingModeNotificationController trainingModeNotificationController = new VCC_TrainingModeNotificationController();
            Test.stopTest();
            Assert.isNotNull(trainingModeNotificationController, 'Expected class to be initialized.');
        }
    }
    /**
     * @description testing the getModel method
     */
    @IsTest
    private static void getModel() {
        User u = [SELECT Id FROM User WHERE Name = 'Copado IntegrationUser'];
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'VCC_Trainee'];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        System.runAs(u) {
            Test.startTest();
            VCC_TrainingModeNotificationController.Model model = VCC_TrainingModeNotificationController.getModel();
            Test.stopTest();
            System.assert(model != null, 'Expected a model to be returned.');
        }
    }
    /**
     * @description testing the resetMyTrainingData method
     */
    @IsTest
    private static void resetMyTrainingData() {
        System.runAs(getTestUser()) {
            String dbReturn;
            Test.startTest();
            dbReturn = VCC_TrainingModeNotificationController.resetMyTrainingData();
            Test.stopTest();
            Assert.isNotNull(dbReturn, 'Database.executeBatch to return not Null');
        }
    }
    /**
     * @description testing the resetTrainingDataForUsers method
     */
    @IsTest
    private static void resetTrainingDataForUsers() {
        System.runAs(getTestUser()) {
            String dbReturn;
            Test.startTest();
            dbReturn = VCC_TrainingModeNotificationController.resetTrainingDataForUsers(new List<String>());
            Test.stopTest();
            Assert.isNotNull(dbReturn, 'Database.executeBatch to return not Null');
        }
    }
    /**
     * @description testing the model is initialized with true in the isTrainingModeEnabled field
     */
    @IsTest
    private static void model() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_TrainingModeNotificationController.Model model = new VCC_TrainingModeNotificationController.Model();
            Test.stopTest();
            Assert.isNotNull(model, 'Expected the class to be initialized.');
            Assert.areEqual(VCC_TrainingModeService.isTrainingModeEnabled(), model.isTrainingModeEnabled, 'Expected field to be initialized to false.');
        }
    }
}
