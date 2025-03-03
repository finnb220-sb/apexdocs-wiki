@IsTest
public with sharing class VCC_SudServiceTest {
    @IsTest
    private static void updateProgressNoteWithSUDInformation() {
        VCC_LabModal labModal = VCC_TestDataFactory.createLabModal();

        Test.startTest();
        String sudString = new VCC_SudService(new List<VCC_LabModal.Lab>{ labModal.sites[0].results.labs.lab[0] }).toSudString();
        Test.stopTest();

        System.assert(String.isNotBlank(sudString), 'Expected string to exist.');
    }

    @IsTest
    private static void toSudStringException() {
        try {
            new VCC_SudService(new List<VCC_LabModal.Lab>()).toSudString();
        } catch (VCC_InternalException e) {
            System.assertEquals('VCC_SudService: Constructor invalid, please pass in a valid list of labs.', e.getMessage(), 'Expected exception messages to match.');
        }
    }
}
