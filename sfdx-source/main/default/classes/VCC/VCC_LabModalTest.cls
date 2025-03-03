@IsTest
public with sharing class VCC_LabModalTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_LabModal labModal = VCC_TestDataFactory.createLabModal();
        Test.stopTest();

        System.assert(labModal != null, 'Expected the class to be initialized.');
        System.assertEquals(1, labModal.sites.size(), 'Expected the list to be initialized.');
        System.assert(labModal.sites[0].results != null, 'Expected the list to be initialized.');
        System.assert(labModal.sites[0].results.labs != null, 'Expected the list to be initialized.');
        System.assertEquals(1, labModal.sites[0].results.labs.lab.size(), 'Expected the list to be initialized.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].testName.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].collected.value, 'Expected values to match.');
        labModal.sites[0].results.labs.lab[0].collected = new VCC_LabModal.Collected();
        labModal.sites[0].results.labs.lab[0].collected.value = '3130308.131706';
        System.assertEquals('3130308.131706', labModal.sites[0].results.labs.lab[0].collected.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].provider.name, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].result.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].performingLab.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].sample.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].units.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].high.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].low.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].interpretation.value, 'Expected values to match.');
        System.assertEquals(null, labModal.sites[0].results.labs.lab[0].labOrderID.value, 'Expected values to match.');
    }
}
