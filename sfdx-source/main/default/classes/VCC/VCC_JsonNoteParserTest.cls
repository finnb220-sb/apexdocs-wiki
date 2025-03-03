@isTest
public with sharing class VCC_JsonNoteParserTest {
    @isTest
    public static void ctor() {
        VCC_JsonNoteParser emptyCtor;
        VCC_JsonNoteParser progressNoteCtor;
        VCC_JsonNoteParser addendumCtor;

        Test.startTest();
        emptyCtor = new VCC_JsonNoteParser();
        progressNoteCtor = new VCC_JsonNoteParser(new VCC_Progress_Note__c(), null);
        addendumCtor = new VCC_JsonNoteParser(new VCC_Addendum__c(), null);
        Test.stopTest();

        System.assert(emptyCtor != null, 'Expected VCC_JsonNoteParser, got null');
        System.assert(progressNoteCtor != null, 'Expected VCC_JsonNoteParser, got null');
        System.assert(addendumCtor != null, 'Expected VCC_JsonNoteParser, got null');
    }

    @isTest
    public static void initializeCustomSectionTest() {
        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');
        VCC_JsonNoteParser jsonNoteParser = new VCC_JsonNoteParser(new VCC_Progress_Note__c(), config);

        VCC_ProgressNoteJsonModel.ProgressNoteSection section;
        Test.startTest();
        section = jsonNoteParser.initializeSection(
            [
                SELECT Id, VCC_Display_Section_Name__c, MasterLabel
                FROM VCC_Progress_Note_Custom_Section__mdt
                LIMIT 1
            ]
        );
        Test.stopTest();

        System.assert(section != null, 'Expected VCC_ProgressNoteJsonModel.ProgressNoteSection, got null');
    }

    @isTest
    public static void initializeStandardLayoutSectionTest() {
        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');
        VCC_JsonNoteParser jsonNoteParser = new VCC_JsonNoteParser(new VCC_Progress_Note__c(), config);

        VCC_ProgressNoteJsonModel.ProgressNoteSection section;
        Test.startTest();
        section = jsonNoteParser.initializeSection(VCC_AdapterUtils_Note.getLayoutInfo(VCC_Progress_Note__c.SObjectType, config).sectionHashToSectionMap.values()[0]);
        Test.stopTest();

        System.assert(section != null, 'Expected VCC_ProgressNoteJsonModel.ProgressNoteSection, got null');
    }

    @isTest
    public static void createJsonFieldTest() {
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(VCC_Nurse_Summary__c = 'test');
        VCC_JsonNoteParser jsonNoteParser = new VCC_JsonNoteParser(progressNote, null);

        VCC_ProgressNoteJsonModel.ProgressNoteField jsonField;
        Test.startTest();
        jsonField = jsonNoteParser.createJsonField(VCC_Progress_Note__c.VCC_Nurse_Summary__c.getDescribe());
        Test.stopTest();

        System.assert(jsonField != null, 'Expected VCC_ProgressNoteJsonModel.ProgressNoteField, got null');
    }

    @isTest
    public static void createJsonFieldHelpTextTest() {
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(VCC_Emergency_Department_Payment_Discl__c = true);
        VCC_JsonNoteParser jsonNoteParser = new VCC_JsonNoteParser(progressNote, null);

        VCC_ProgressNoteJsonModel.ProgressNoteField jsonField;
        Test.startTest();
        jsonField = jsonNoteParser.createJsonField(VCC_Progress_Note__c.VCC_Emergency_Department_Payment_Discl__c.getDescribe());
        Test.stopTest();

        System.assert(jsonField != null, 'Expected VCC_ProgressNoteJsonModel.ProgressNoteField help text, got null');
    }

    @isTest
    public static void endToEnd() {
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(VCC_Nurse_Summary__c = 'test');
        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');
        VCC_JsonNoteParser jsonNoteParser = new VCC_JsonNoteParser(progressNote, config);
        VCC_LayoutService.LayoutInfo layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(VCC_Progress_Note__c.SObjectType, config);

        String jsonString;
        List<VCC_ProgressNoteJsonModel.ProgressNoteSection> sections;
        Test.startTest();
        jsonString = jsonNoteParser.parse(
            layoutInfo.sectionHashToSectionMap.values(),
            [
                SELECT Id, VCC_Display_Section_Name__c, VCC_Fields__c, MasterLabel
                FROM VCC_Progress_Note_Custom_Section__mdt
                LIMIT 1
            ]
        );
        sections = (List<VCC_ProgressNoteJsonModel.ProgressNoteSection>) JSON.deserialize(jsonString, List<VCC_ProgressNoteJsonModel.ProgressNoteSection>.class);
        Test.stopTest();

        System.assert(jsonString != null, 'Expected String output, got null');
        System.assert(sections != null, 'Expected List of VCC_ProgressNoteJsonModel.ProgressNoteSection, got null');
    }
}
