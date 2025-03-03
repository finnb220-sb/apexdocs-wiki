@IsTest
public with sharing class VCC_MpiRetrieveRQTest {
    private static String username = 'mpiretrq';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VAHC_Standard_VCC_User');
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void constructorTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_MpiRetrieveRQ rq = new VCC_MpiRetrieveRQ();
            System.assert(rq != null, 'Expected non null.');
            System.assert(rq.datasets != null, 'Expected non null.');
        }
        Test.stopTest();
    }

    @IsTest
    static void isValidTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_MpiRetrieveRQ rq = new VCC_MpiRetrieveRQ();
            rq.userId = 'hi';
            rq.id = 'hi';
            rq.idType = 'hi';
            System.assert(rq.isValid(), 'Expected valid.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitNegativeisInvalidTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_MpiRetrieveRQ rq = new VCC_MpiRetrieveRQ();
            System.assert(!rq.isValid(), 'Expected invalid.');
        }
        Test.stopTest();
    }
}
