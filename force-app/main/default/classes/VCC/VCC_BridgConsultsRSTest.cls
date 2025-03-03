@isTest
public with sharing class VCC_BridgConsultsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgConsultsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsConsults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsConsult() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsDocuments() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsDocument() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsReason() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsProvDx() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsOrderID() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsProcedure() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsRequested() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsUrgency() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsService() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgConsultsRS.ConsultsResult() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgConsultsRS bridg = new VCC_BridgConsultsRS();
        bridg.sites.add(new VCC_BridgConsultsRS.ConsultsSite());
        bridg.sites[0].results.version = 'Exceeded Max';

        bridg.isMaxRecordsError = false;
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgConsultsRS bridg2 = new VCC_BridgConsultsRS(base);
        System.assertEquals(true, bridg2.isMaxRecordsError);
        Test.stopTest();
    }
}
