/**
 * VCC_TrainingModeUserSelectorTest
 * @description VCC_TrainingModeUserSelectorTest class for VCC_TrainingModeUserSelector.
 * @author Liberty
 * @date 1/16/2024
 */
@IsTest
private class VCC_TrainingModeUserSelectorTest {
    private static String usernameTestPrefix = 'trainingModeUserSelectorTester';
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
            VCC_TrainingModeUserSelector trainingModeUserSelector = new VCC_TrainingModeUserSelector();
            Assert.isNotNull(trainingModeUserSelector, 'Expected class to be initialized.');
        }
    }

    /**
     * @description testing the select by Title method
     */
    @IsTest
    private static void selectByTitle() {
        System.runAs(getTestUser()) {
            List<User> traineeList = VCC_TraineeListController.searchByTitle('');
            Assert.areEqual(true, traineeList.isEmpty(), 'Expected to return empty');
        }
    }

    /**
     * @description testing the select by Division method
     */
    @IsTest
    private static void selectByDivision() {
        System.runAs(getTestUser()) {
            List<User> divisionList = VCC_TraineeListController.searchByDivision('VISN 8');
            Assert.areEqual(true, !divisionList.isEmpty(), 'Expected to return true');
        }
    }

    /**
     * @description testing the select by Emp Number method
     */
    @IsTest
    private static void selectByEmployeeNumber() {
        System.runAs(getTestUser()) {
            List<User> employeeList = VCC_TraineeListController.searchByRange(null, null);
            Assert.areEqual(true, !employeeList.isEmpty(), 'Expected to return empty');
        }
    }

    /**
     * @description testing the findBySearchString method
     */
    @IsTest
    private static void searchUsers() {
        System.runAs(getTestUser()) {
            List<User> userList = VCC_TraineeListController.searchUsers('');
            Assert.areEqual(true, userList.isEmpty(), 'Expected to return empty');
        }
    }
}
