@isTest
public with sharing class VCC_BridgLabsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgLabsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLabs() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLab() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsResulted() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsPerformingLab() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsTest() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsOrderID() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsCollected() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsUnits() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsSample() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsVuid() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsResult() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLocalName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsGroupName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsHigh() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsInterpretation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLow() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsSpecimen() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsComment() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLabOrderID() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsLoinc() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgLabsRS.LabsStatus() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgLabsRS bridg = new VCC_BridgLabsRS();
        bridg.sites.add(new VCC_BridgLabsRS.LabsSite());
        bridg.sites[0].isMaxRecordsError = false;
        bridg.sites[0].results.timeZone = 'Exceeded Max';

        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.sites[0].isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgLabsRS bridg2 = new VCC_BridgLabsRS(base);
        System.assertEquals(true, bridg2.sites[0].isMaxRecordsError);
        Test.stopTest();
    }
}
