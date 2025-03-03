@IsTest
public with sharing class VCC_VdifProviderTest {
    @IsTest
    static void instantiationTest() {
        User runningUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(runningUser) {
            Test.startTest();
            System.assert(new VCC_VdifProvider() != null, 'Did not instantiate properly.');
            Test.stopTest();
        }
    }
}
