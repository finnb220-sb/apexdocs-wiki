@IsTest
public with sharing class VCC_VdifEncounterTest {
    @IsTest
    static void instantiationTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_Util.addPermSetGroupToUser('VAHC_Super_User', testuser);
        System.runAs(testuser) {
            Test.startTest();
            System.assert(new VCC_VdifEncounter() != null, 'Did not instantiate correctly.');
            Test.stopTest();
        }
    }
}
