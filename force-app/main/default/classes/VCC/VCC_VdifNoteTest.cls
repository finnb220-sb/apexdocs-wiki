@IsTest
public with sharing class VCC_VdifNoteTest {
    @IsTest
    static void instantiationTest() {
        User testuser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            System.assert(new VCC_VdifNote() != null, 'Did not instantiate correctly.');
            System.assert(new VCC_VdifNote().additionalSigners != null, 'Did not instantiate correctly.');
            Test.stopTest();
        }
    }
}
