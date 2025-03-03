@isTest
public with sharing class VCC_BridgMedsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgMedsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsMeds() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsMed() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsExpires() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsDoses() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsVaStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFillsAllowed() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsMedId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsPharmacist() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsLastFilled() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsProducts() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsSig() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsRouting() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFillsRemaining() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFills() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsVaType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsOrdered() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsOrderingProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsQuantity() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsOrderID() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsDaysSupply() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsStart() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFillCost() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsForm() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsStop() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsPrescription() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsLocation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsCurrentProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsPtInstructions() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsImo() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsParent() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsIvLimit() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsDose() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsProduct() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsVaGeneric() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsVaProduct() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsClass() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsOrdItem() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgMedsRS.MedsFill() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgMedsRS bridg = new VCC_BridgMedsRS();
        bridg.sites.add(new VCC_BridgMedsRS.MedsSite());
        bridg.sites[0].results.version = 'Exceeded Max';

        bridg.isMaxRecordsError = false;
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgMedsRS bridg2 = new VCC_BridgMedsRS(base);
        System.assertEquals(true, bridg2.isMaxRecordsError);
        Test.stopTest();
    }
}
