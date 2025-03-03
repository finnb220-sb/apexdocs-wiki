/**
 * VCC_UoWDomainTest
 * @description VCC_UoWDomainTest class for VCC_UoWDomain.
 * @author Liberty
 * @date 01/16/2024
 */
@IsTest
private with sharing class VCC_UoWDomainTest {
    private static String usernameTestPrefix = 'uoWDomainTester';
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
     * @description initializing a unit of work domain
     */
    @IsTest
    private static void ctor() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_UoWDomain uoWDomain = new VCC_UoWDomain();
            Test.stopTest();
            Assert.isNotNull(uoWDomain, 'Expected class to be initialized.');
        }
    }

    /**
     * @description creating a unit of work
     */
    @IsTest
    private static void createUoW() {
        System.runAs(getTestUser()) {
            Test.startTest();
            fflib_SObjectUnitOfWork uow = VCC_UoWDomain.createUoW();
            Test.stopTest();
            Assert.isNotNull(uow, 'Expected a new unit of work to be initialized.');
        }
    }
}
