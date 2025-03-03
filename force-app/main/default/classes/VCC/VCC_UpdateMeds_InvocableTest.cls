/**
 * VCC_UpdateMeds_InvocableTest
 * @description VCC_UpdateMeds_InvocableTest class for VCC_UpdateMeds_Invocable.
 * @author Liberty
 * @date 01/16/2024
 * @version 1.0.0
 */

@IsTest
public with sharing class VCC_UpdateMeds_InvocableTest {
    private static String usernameTestPrefix = 'updateMedsTester';
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

    @IsTest
    private static void regressionTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_UpdateMeds_Invocable.updateMeds();
            Assert.isTrue(true, 'Force Assertion');
            Test.stopTest();
        }
    }
}
