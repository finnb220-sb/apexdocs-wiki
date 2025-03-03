@IsTest
public with sharing class VCC_LabDomainTest {
    @IsTest
    private static void flattenSites() {
        VCC_LabModal labModal = new VCC_LabModal();
        labModal.sites.add(new VCC_LabModal.Sites());
        labModal.sites[0].results = new VCC_LabModal.Results();
        labModal.sites[0].results.labs = new VCC_LabModal.Labs();
        labModal.sites[0].results.labs.lab.add(new VCC_LabModal.Lab());

        Test.startTest();
        List<VCC_LabModal.Lab> labModals = new VCC_LabDomain().flattenSites(labModal);
        Test.stopTest();

        System.AssertNotEquals(null, labModals, 'Expected the list to be initialized.');
    }
}
