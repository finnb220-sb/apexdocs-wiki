/**
 * @description VCC_AccountModuleTest
 * @author      Frederick Mackmiller
 * @since       Jan 10 2023
 */
@IsTest
public with sharing class VCC_AccountModuleTest {
    private static String username = 'acctService';
    public static VCC_AccountModule accountModule = (VCC_AccountModule) VCC_ModuleService.getModule(VCC_AccountModule.class);

    /**
     * @description Creates test data for unit tests. This method generates a user with a specified profile and assigns a permission set.
     * It modifies the username to include a unique identifier and sets a custom field 'MVIICN__c'.
     * This setup is crucial for testing scenarios involving a standard VAHC VCC user.
     */
    @TestSetup
    public static void makeData() {
        User vahcStandardUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        vahcStandardUser.Username = username + vahcStandardUser.Username;
        VCC_TestDataFactory.assignPermissionSetByName(vahcStandardUser, 'VAHC_Standard_VCC_User');
        vahcStandardUser.MVIICN__c = 'test';
        update vahcStandardUser;
    }

    /**
     * @description Retrieves a test user record from the database. It performs a SOQL query to find a user whose username starts with the specified 'username' variable.
     * This method is typically used in unit tests to obtain a user record for testing purposes.
     * @return User - The first User record that matches the username criteria.
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void getIcnTestHappy() {
        Account accnt = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert accnt;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(accountModule.getIcn(accnt.Id) == accnt.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestHappy2() {
        Account accnt = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert accnt;

        Object objId = (Object) accnt.Id;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(accountModule.getIcn(objId) == accnt.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestHappy3() {
        Account accnt = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert accnt;

        String strId = (String) accnt.Id;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(accountModule.getIcn(strId) == accnt.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestSad() {
        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(accountModule.getIcn('143123141') == null, 'Expected null.');
        }
        Test.stopTest();
    }

    @IsTest
    static void isRunningUsersAccountTestHappyNegative() {
        Account accnt = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'something',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert accnt;

        Test.startTest();
        System.runAs(getTestUser()) {
            Assert.isFalse(accountModule.isRunningUsersAccount(accnt.Id), 'Expected false.');
        }
        Test.stopTest();
    }

    @IsTest
    static void isRunningUsersAccountTestHappyPositive() {
        Account accnt = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert accnt;

        Test.startTest();
        System.runAs(getTestUser()) {
            Assert.isTrue(accountModule.isRunningUsersAccount(accnt.Id), 'Expected true.');
        }
        Test.stopTest();
    }

    @IsTest
    static void isRunningUsersAccountTestSadBadId() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_AccountModule.InvalidAccountIdException expectedException;
            try {
                accountModule.isRunningUsersAccount('000000000000000000');
            } catch (VCC_AccountModule.InvalidAccountIdException e) {
                expectedException = e;
            }
            Assert.isNotNull(expectedException, 'Expected an exception.');
            Test.stopTest();
        }

    }

    @IsTest
    static void isRunningUsersAccountTestSadNoAccount() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_AccountModule.AccountNotFoundException expectedException;
            try {
                //accountModule.isRunningUsersAccount('0013R000005Sz1IQAS');
                accountModule.isRunningUsersAccount('0013R00000XXXXXXXX'); // Mock Account ID
            } catch (VCC_AccountModule.AccountNotFoundException e) {
                expectedException = e;
            }
            Assert.isNotNull(expectedException, 'Expected an exception.');
            Test.stopTest();
        }
    }
    @isTest
    static void validateAccountIdNull() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_AccountModule.InvalidAccountIdException expectedException;
            try {
                accountModule.validateAccountId(null);
            } catch (VCC_AccountModule.InvalidAccountIdException e) {
                expectedException = e;
            }
            Assert.isNotNull(expectedException, 'Expected exception');
            Test.stopTest();
        }
    }
}
