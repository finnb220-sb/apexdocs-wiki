@IsTest
public with sharing class VCC_IdServiceTest {
    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub idServiceStub = VCC_IdService.stub();
        Assert.areEqual(idServiceStub.instance, VCC_IdService.instance, 'Expected stub instance and service instance to be the same.');
        Test.stopTest();
    }

    @IsTest
    static void isIdTestHappy() {
        Account a = new Account(LastName = 'test');
        insert a;

        Test.startTest();
        Assert.isTrue(VCC_IdService.instance.isId(a.Id), 'Expected true.');
        Test.stopTest();
    }

    @IsTest
    static void isIdTestSad() {
        Test.startTest();
        String s = '12345';
        Integer i = 1;
        Assert.isFalse(VCC_IdService.instance.isId(s), 'Expected false.');
        Assert.isFalse(VCC_IdService.instance.isId(i), 'Expected false.');
        Assert.isFalse(VCC_IdService.instance.isId(null), 'Expected false.');
        Test.stopTest();
    }

    @IsTest
    static void isIdOfTypeTestHappy() {
        Account a = new Account(LastName = 'test');
        insert a;
        Test.startTest();
        Assert.isTrue(VCC_IdService.instance.isIdOfType(a.Id, Account.getSObjectType()), 'Expected true.');
        Test.stopTest();
    }

    @IsTest
    static void isIdOfTypeTestSad() {
        Account a = new Account(LastName = 'test');
        insert a;

        Test.startTest();

        Assert.isFalse(VCC_IdService.instance.isIdOfType(a.Id, VCC_Progress_Note__c.getSObjectType()), 'Expected false.');

        Test.stopTest();
    }
}
