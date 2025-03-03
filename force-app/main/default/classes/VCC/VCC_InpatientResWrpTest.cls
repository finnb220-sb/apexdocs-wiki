@IsTest
class VCC_InpatientResWrpTest {
    @IsTest
    static void testWrapper() {
        Test.startTest();
        new VCC_InpatientResWrp().isShowInPatientPopup = true;
        new VCC_InpatientResWrp().resBody = 'test';
        Test.stopTest();
    }
}
