@IsTest
public with sharing class VCC_IdModuleTest {
    @IsTest
    static void isIdTestHappy() {
        Account a = new Account(LastName = 'test');
        insert a;

        VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

        Test.startTest();
        Assert.isTrue(idModule.isId(a.Id), 'Expected true.');
        Test.stopTest();
    }

    @IsTest
    static void isIdTestSad() {
        VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

        Test.startTest();
        String s = '12345';
        Integer i = 1;
        Assert.isFalse(idModule.isId(s), 'Expected false.');
        Assert.isFalse(idModule.isId(i), 'Expected false.');
        Assert.isFalse(idModule.isId(null), 'Expected false.');
        Test.stopTest();
    }

    @IsTest
    static void isIdOfTypeTestHappy() {
        Account a = new Account(LastName = 'test');
        insert a;
        VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

        Test.startTest();
        Assert.isTrue(idModule.isIdOfType(a.Id, Account.getSObjectType()), 'Expected true.');
        Test.stopTest();
    }

    @IsTest
    static void isIdOfTypeTestSad() {
        Account a = new Account(LastName = 'test');
        insert a;
        VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

        Test.startTest();
        Assert.isFalse(idModule.isIdOfType(a.Id, VCC_Progress_Note__c.getSObjectType()), 'Expected false.');
        Test.stopTest();
    }

    @IsTest
    static void isIdOfTypeTestSadAgain() {
        Object id = 'a';
        VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);
        Test.startTest();
        Assert.isFalse(idModule.isIdOfType(id, VCC_Progress_Note__c.getSObjectType()), 'Expected false.');
        Test.stopTest();
    }
}
