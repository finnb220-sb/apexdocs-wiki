@isTest
public with sharing class VCC_TrainingModeAccountTest {
    @IsTest
    private static void unitVCC_TrainingModeAccountCtor1() {
        VCC_TrainingModeAccount trainingModeAccount;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeAccount = new VCC_TrainingModeAccount();
            trainingModeAccount.relatedData.add(new VCC_TrainingModeData('Allergies', 'Some data'));
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeAccount, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void unitVCC_TrainingModeAccountCtor2() {
        VCC_TrainingModeAccount trainingModeAccount;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeAccount = new VCC_TrainingModeAccount('Unit', 'Test', '1234567', '000-86-132', 'Male', Date.today(), 'test@test.com');
            trainingModeAccount.relatedData.add(new VCC_TrainingModeData('Allergies', 'Some data'));
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeAccount, 'Expected the class to be initialized.');
    }
}
