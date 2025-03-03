@IsTest
public with sharing class VCC_AccountServiceTest {
    private static String username = 'acctService';

    @TestSetup
    public static void makeData() {
        User vahcStandardUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        vahcStandardUser.Username = username + vahcStandardUser.Username;
        VCC_TestDataFactory.assignPermissionSetByName(vahcStandardUser, 'VAHC_Standard_VCC_User');

        update vahcStandardUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub accountServiceStub = VCC_AccountService.stub();
        System.assert(accountServiceStub.instance === VCC_AccountService.instance, 'Expected stub instance and service instance to be the same.');
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestHappy() {
        Account a = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert a;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_AccountService.instance.getIcn(a.Id) == a.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestHappy2() {
        Account a = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert a;

        Object id = (Object) a.Id;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_AccountService.instance.getIcn(id) == a.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestHappy3() {
        Account a = new Account(
            LastName = 'test',
            VCC_MVI_External_Id__pc = 'test',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );

        insert a;

        String id = (String) a.Id;

        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_AccountService.instance.getIcn(id) == a.VCC_MVI_External_Id__pc, 'Expected correct ICN.');
        }
        Test.stopTest();
    }

    @IsTest
    static void getIcnTestSad() {
        Test.startTest();
        System.runAs(getTestUser()) {
            System.assert(VCC_AccountService.instance.getIcn('143123141') == null, 'Expected null.');
        }
        Test.stopTest();
    }
}
