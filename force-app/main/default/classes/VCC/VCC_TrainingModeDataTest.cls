@IsTest
private with sharing class VCC_TrainingModeDataTest {
    @IsTest
    private static void unitVCC_TrainingModeDataCtor1() {
        VCC_TrainingModeData trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeData();
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeData, 'Expected class to be initialized.');
    }
    @IsTest
    private static void unitVCC_TrainingModeDataCtor2() {
        VCC_TrainingModeData trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeData('Test', 'Test');
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeData, 'Expected class to be initialized.');
    }
}
