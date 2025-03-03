@IsTest
public with sharing class VCC_VdifParametersTest {
    private static String username = 'vdifparamstest';

    /**
     * @description test setup by creating base user
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    /**
     * @description retrieves the test user created during setup
     * @return  `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void intantiationTest() {
        VCC_VdifParameters vdifParameters2;
        System.runAs(getTestUser()) {
            Test.startTest();
            vdifParameters2 = new VCC_VdifParameters();
            Test.stopTest();
        }

        System.assert(vdifParameters2 != null, 'Did not intantiate correctly.');
    }
}
