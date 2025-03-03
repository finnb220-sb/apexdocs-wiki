@isTest
public with sharing class VCC_BridgFlagsRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgFlagsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsFlags() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsFlag() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsOrigSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsOwnSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsApprovedBy() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsAssigned() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsCategory() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsContent() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsReviewDue() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgFlagsRS.FlagsDocument() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgFlagsRS bridg = new VCC_BridgFlagsRS();
        bridg.sites.add(new VCC_BridgFlagsRS.FlagSite());
        bridg.sites[0].results.version = 'Exceeded Max';

        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();

        VCC_BridgFlagsRS bridg2 = new VCC_BridgFlagsRS(base);

        Test.stopTest();
    }
}
