/**
 * @description This class is used to test parsing the JSON response from the VCC API and create a list of ProgressNoteDTO objects.
 */
@IsTest
public class VCC_ProgressNoteDTOTests {
    private final static String STATIC_RESOURCE_NAME = 'VCC_ProgressNoteDTO_TestJson';
    private static String memoizedJson;

    /**
     * @description the test json is too big to store in class, so we'll load it on demand from a static resource.
     * @return String the json body
     */
    public static String getJsonFromStaticResource() {
        if (memoizedJson != null) {
            return memoizedJson;
        }
        StaticResource myResource = [SELECT Id, Body FROM StaticResource WHERE Name = :STATIC_RESOURCE_NAME LIMIT 1];

        // Convert the Blob to a string
        memoizedJson = myResource.Body.toString();
        return memoizedJson;
    }

    @IsTest
    static void testFullParseFromStaticResourceLargePayloadPositive() {
        VCC_ProgressNoteDTO parsedObject = VCC_ProgressNoteDTO.parse(getJsonFromStaticResource());
        System.assert(parsedObject != null);
    }

    @IsTest
    static void testNationalTitleServiceConstructorMisingDataPositive() {
        String json = '';

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitleService objNationalTitleService = new VCC_ProgressNoteDTO.NationalTitleService(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitleService != null);
        System.assert(objNationalTitleService.service == null);
        System.assert(objNationalTitleService.vuid == null);
    }

    @IsTest
    static void testNationalTitleConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitle objNationalTitle = new VCC_ProgressNoteDTO.NationalTitle(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitle != null);
        System.assert(objNationalTitle.title == null);
        System.assert(objNationalTitle.vuid == null);
    }

    @IsTest
    static void testParamsObjectConstructorMisingDataPostiive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Params objParams = new VCC_ProgressNoteDTO.Params(System.JSON.createParser(json));
        System.assert(objParams != null);
        System.assert(objParams.domain == null);
        System.assert(objParams.systemId == null);
    }

    @IsTest
    static void testTextObjectConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Text objText = new VCC_ProgressNoteDTO.Text(System.JSON.createParser(json));
        System.assert(objText != null);
        System.assert(objText.clinicians == null);
        System.assert(objText.content == null);
        System.assert(objText.dateTime_Z == null);
        System.assert(objText.status == null);
        System.assert(objText.uid == null);
    }

    @IsTest
    static void testDataObjectConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Data objData = new VCC_ProgressNoteDTO.Data(System.JSON.createParser(json));
        System.assert(objData != null);
        System.assert(objData.updated == null);
        System.assert(objData.totalItems == null);
        System.assert(objData.items == null);
    }

    @IsTest
    static void testNationalTitleRoleConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitleRole objNationalTitleRole = new VCC_ProgressNoteDTO.NationalTitleRole(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitleRole != null);
        System.assert(objNationalTitleRole.role == null);
        System.assert(objNationalTitleRole.vuid == null);
    }

    @IsTest
    static void testNationalTitleSettingConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitleSetting objNationalTitleSetting = new VCC_ProgressNoteDTO.NationalTitleSetting(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitleSetting != null);
        System.assert(objNationalTitleSetting.setting == null);
        System.assert(objNationalTitleSetting.vuid == null);
    }

    @IsTest
    static void testSitesContructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Sites objSites = new VCC_ProgressNoteDTO.Sites(System.JSON.createParser(json));
        System.assert(objSites != null);
        System.assert(objSites.apiVersion == null);
        System.assert(objSites.params == null);
        System.assert(objSites.data == null);
        System.assert(objSites.errorSection == null);
    }

    @IsTest
    static void testNationalTitleSubjectConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitleSubject objNationalTitleSubject = new VCC_ProgressNoteDTO.NationalTitleSubject(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitleSubject != null);
    }

    @IsTest
    static void testDTOConstructorWithMissingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO objVCC_ProgressNoteDTO = new VCC_ProgressNoteDTO(System.JSON.createParser(json));
        System.assert(objVCC_ProgressNoteDTO != null);
        System.assert(objVCC_ProgressNoteDTO.sites == null);
    }

    @IsTest
    static void testNationalTitleTypeConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.NationalTitleType objNationalTitleType = new VCC_ProgressNoteDTO.NationalTitleType(
            System.JSON.createParser(json)
        );
        System.assert(objNationalTitleType != null);
        System.assert(objNationalTitleType.type == null);
        System.assert(objNationalTitleType.vuid == null);
    }

    @IsTest
    static void testDocumentItemConstructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Items objItems = new VCC_ProgressNoteDTO.Items(System.JSON.createParser(json));
        System.assert(objItems != null);
        System.assert(objItems.documentClass == null);
        System.assert(objItems.documentTypeCode == null);
        System.assert(objItems.documentTypeName == null);
        System.assert(objItems.encounterName == null);
        System.assert(objItems.encounterUid == null);
        System.assert(objItems.entered == null);
        System.assert(objItems.facilityCode == null);
        System.assert(objItems.facilityName == null);
        System.assert(objItems.localId == null);
        System.assert(objItems.localTitle == null);
        System.assert(objItems.nationalTitle == null);
        System.assert(objItems.nationalTitleType == null);
        System.assert(objItems.referenceDateTime == null);
        System.assert(objItems.statusName == null);
        System.assert(objItems.text == null);
        System.assert(objItems.uid == null);
        System.assert(objItems.nationalTitleSubject == null);
        System.assert(objItems.nationalTitleService == null);
        System.assert(objItems.nationalTitleRole == null);
        System.assert(objItems.nationalTitleSetting == null);
        System.assert(objItems.images == null);
    }

    @IsTest
    static void testErrorSectionContructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.ErrorSection objErrorSection = new VCC_ProgressNoteDTO.ErrorSection(
            System.JSON.createParser(json)
        );
        System.assert(objErrorSection != null);
        System.assert(objErrorSection.errors == null);
        System.assert(objErrorSection.fatalErrors == null);
        System.assert(objErrorSection.warnings == null);
    }

    @IsTest
    static void testCliniciansContructorMisingDataPositive() {
        String json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VCC_ProgressNoteDTO.Clinicians objClinicians = new VCC_ProgressNoteDTO.Clinicians(
            System.JSON.createParser(json)
        );
        System.assert(objClinicians != null);
        System.assert(objClinicians.name == null);
        System.assert(objClinicians.role == null);
        System.assert(objClinicians.uid == null);
        System.assert(objClinicians.signature == null);
        System.assert(objClinicians.signedDateTime == null);
    }
}
