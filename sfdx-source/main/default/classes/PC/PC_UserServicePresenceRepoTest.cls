/**
 * @description test class for PC_UserServicePresenceRepo.
 *              NOTE: Cannot insert UserServicePresence records in test class
 * @author      Booz Allen
 * @since       2024
 * @see         PC_UserServicePresenceRepo
 * @see         VCR_UserServicePresenceRepo
 */
@IsTest
private class PC_UserServicePresenceRepoTest {
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of getCurrentUserServicePresence
     */
    @IsTest
    private static void funcGetCurrentUserServicePresenceTestPositive() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = SPECIALIST_USER;

        // Actual test
        Test.startTest();

        List<UserServicePresence> results;
        System.runAs(runAsUser) {
            results = testRepo.getCurrentUserServicePresence();
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert UserServicePresence in test class so impossible to directly test query result
        Assert.isNotNull(results, 'User Server Presences for agents not retrieved successfully.');
    }

    /**
     * @description negative test of getCurrentUserServicePresence with user without access
     */
    @IsTest
    private static void funcGetCurrentUserServicePresenceTestNegative() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        //user with basic access
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);
        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getCurrentUserServicePresence();
            } catch (Exception e) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(threwError, 'Failed to throw error during test getCurrentUserServicePresence method call.');
    }

    /**
     * @description positive test of getCurrentUserServicePresence
     */
    @IsTest
    private static void funcGetCurrentUserServicePresenceWithDivisionTestPositive() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = true;

        User runAsUser = SPECIALIST_USER;

        // Actual test
        Test.startTest();

        List<UserServicePresence> results;
        System.runAs(runAsUser) {
            results = testRepo.getCurrentUserServicePresence('VISN 1');
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert UserServicePresence in test class so impossible to directly test query result
        Assert.isNotNull(results, 'User Server Presences for VISN 1 agents not retrieved successfully.');
    }

    /**
     * @description positive test of getCurrentUserServicePresencebyUserId
     */
    @IsTest
    private static void funcGetCurrentUserServicePresencebyUserIdTestPositive() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = true;

        User runAsUser = SPECIALIST_USER;

        List<Id> userIdList = new List<Id>();
        userIdList.add(runAsUser.Id);

        // Actual test
        Test.startTest();

        List<UserServicePresence> results;
        System.runAs(runAsUser) {
            results = testRepo.getCurrentUserServicePresencebyUserId(userIdList);
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert UserServicePresence in test class so impossible to directly test query result
        Assert.isNotNull(results, 'User Service Presences for VISN 1 agents not retrieved successfully.');
    }

    /**
     * @description negative test of getCurrentUserServicePresence with user without access
     */
    @IsTest
    private static void funcGetCurrentUserServicePresenceWithDivisionTestNegative() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = true;

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getCurrentUserServicePresence('VISN 1');
            } catch (Exception e) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(threwError, 'Failed to throw error during test getCurrentUserServicePresence method call.');
    }

    /**
     * @description positive test of getCurrentUserServicePresenceForRunningUser
     */
    @IsTest
    private static void funcGetCurrentUserServicePresenceForRunningUserTestPositive() {
        // Test data setup
        PC_UserServicePresenceRepo testRepo = new PC_UserServicePresenceRepo();
        PC_PrcConfigSettingsUtility.visnRoutingEnabled = false;

        User runAsUser = SPECIALIST_USER;

        List<Id> userIdList = new List<Id>();
        userIdList.add(runAsUser.Id);

        // Actual test
        Test.startTest();

        List<UserServicePresence> results;
        System.runAs(runAsUser) {
            results = testRepo.getCurrentUserServicePresenceForRunningUser();
        }

        Test.stopTest();

        // Asserts
        //NOTE: cannot insert UserServicePresence in test class so impossible to directly test query result
        Assert.isNotNull(results, 'User Service Presences for running user not retrieved successfully.');
    }
}
