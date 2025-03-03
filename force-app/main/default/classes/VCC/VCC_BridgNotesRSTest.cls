@isTest
public with sharing class VCC_BridgNotesRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        System.assert(new VCC_BridgNotesRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentParams() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentDataClass() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentItem() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitle() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitleType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitleSubject() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitleService() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitleRole() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentNationalTitleSetting() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentText() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgNotesRS.DocumentClinician() != null, 'Instantiation failed.');
        Test.stopTest();
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgNotesRS bridgNotes = new VCC_BridgNotesRS();
        bridgNotes.sites.add(new VCC_BridgNotesRS.DocumentSite());
        bridgNotes.sites[0].apiVersion = 'Exceeded Max';

        bridgNotes.isMaxRecordsError = false;
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridgNotes));

        Test.startTest();
        System.assert(bridgNotes.isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgNotesRS bridgNotes2 = new VCC_BridgNotesRS(base);
        System.assertEquals(true, bridgNotes2.isMaxRecordsError);
        Test.stopTest();
    }
}
