@isTest
private class VCC_VISTAModelTest {
    @isTest
    static void testVISTAModelConstructor() {
        // Create test data for VCC_BridgDemographicsRS
        VCC_BridgDemographicsRS rs = new VCC_BridgDemographicsRS();
        VCC_BridgDemographicsRS.Site site = new VCC_BridgDemographicsRS.Site();
        VCC_BridgDemographicsRS.Demographics demographics = new VCC_BridgDemographicsRS.Demographics();
        VCC_BridgDemographicsRS.PatientAddress patientAddress = new VCC_BridgDemographicsRS.PatientAddress();

        patientAddress.city = 'Anytown';
        patientAddress.postalCode = '12345';

        demographics.patient = new List<VCC_BridgDemographicsRS.Patient>();
        VCC_BridgDemographicsRS.Patient patient = new VCC_BridgDemographicsRS.Patient();
        patient.address = patientAddress;
        demographics.patient.add(patient);

        rs.sites = new List<VCC_BridgDemographicsRS.Site>();
        rs.sites.add(site);

        // Create test data for VCC_BridgRequest
        VCC_BridgRequest rq = new VCC_BridgRequest();
        rq.assigningFacility = 'Facility123';

        // Create an instance of the VCC_VISTAModel class
        VCC_VISTAModel model;

        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            Test.startTest();
            model = new VCC_VISTAModel(rs, rq);
            Test.stopTest();
        }

        // Assert the model returned
        System.assert(model != null, 'model was not exepected to be null');
    }
}
