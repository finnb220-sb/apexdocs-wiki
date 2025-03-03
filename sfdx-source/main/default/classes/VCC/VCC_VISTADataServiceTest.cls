@isTest
private class VCC_VISTADataServiceTest {
    @isTest
    static void testGetDemographicsByVista() {
        // Create a mock VCC_BridgRequest
        VCC_BridgRequest rq = new VCC_BridgRequest();
        rq.assigningFacility = 'Facility123';

        // Create mock VCC_BridgDemographicsRS data
        new VCC_BridgDemographicsRS();

        // Call the method to test
        VCC_VISTAModel model;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        //VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_HDRClient.bypassCallout = true;
            model = VCC_VISTADataService.getDemographicsByVista(rq);
            Test.stopTest();
        }

        // Assert the model returned
        System.assert(model != null, 'model was not exepected to be null');
        // ... Add assertions as needed for the VCC_VISTAModel instance
    }
}
