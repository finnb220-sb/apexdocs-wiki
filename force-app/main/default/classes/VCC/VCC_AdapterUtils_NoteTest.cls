/**
 * @description       : Test class for VCC_AdapterUtils_Note
 * @author            : Unknown
 * @group             :
 * @last modified on  : 05-11-2023
 * @last modified by  : WagnerJ@BAH
 **/
@isTest
public with sharing class VCC_AdapterUtils_NoteTest {
    //adding small change here so it gets deployed to stage3 - again

    @TestSetup
    static void makeData() {
        @SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult')
        Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());
        insert c;

        insert new VCC_Progress_Note__c(VCC_Case__c = c.Id, VCC_Nurse_Summary__c = 'test');
    }

    @isTest
    public static void prepNoteTest() {
        VCC_Progress_Note__c preppedNote;

        User u = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', u);
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');

        Test.startTest();
        System.runAs(u) {
            @SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult')
            Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());
            insert c;

            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c.Id, VCC_Nurse_Summary__c = 'test');
            insert pn;

            preppedNote = (VCC_Progress_Note__c) VCC_AdapterUtils_Note.prepNote(pn, new Set<String>{ 'VCC_Nurse_Summary__c', 'VCC_Case__c' });
        }
        Test.stopTest();

        System.assert(preppedNote.get('VCC_Nurse_Summary__c') == 'test', 'Expected the required field value.');
    }

    @isTest
    public static void generateQueryStringTest() {
        VCC_Progress_Note__c someProgressNote = [SELECT Id FROM VCC_Progress_Note__c LIMIT 1];
        String queryString;

        Test.startTest();
        queryString = VCC_AdapterUtils_Note.generateQueryString(someProgressNote, new Set<String>{ 'VCC_Nurse_Summary__c', 'VCC_Allergies__c' });
        Test.stopTest();

        System.assert(queryString.contains('VCC_Nurse_Summary__c'), 'Expected query string to contains the "VCC_Nurse_Summary__c"');
        System.assert(queryString.contains('VCC_Allergies__c'), 'Expected query string to contain "VCC_Allergies__c"');
    }

    @isTest
    public static void generateQueryStringWithExistingFieldTest() {
        VCC_Progress_Note__c someProgressNote = [SELECT Id, VCC_Nurse_Summary__c FROM VCC_Progress_Note__c LIMIT 1];
        String queryString;

        User u = VCC_TestDataFactory.insertUser('Standard User');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', u);
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');

        Test.startTest();
        System.runAs(u) {
            queryString = VCC_AdapterUtils_Note.generateQueryString(someProgressNote, new Set<String>{ 'VCC_Nurse_Summary__c', 'VCC_Allergies__c' });
        }
        Test.stopTest();

        System.assert(!queryString.contains('VCC_Nurse_Summary__c'), 'Expected query string to exclude "VCC_Nurse_Summary__c"');
        System.assert(queryString.contains('VCC_Allergies__c'), 'Expected query string to contain "VCC_Allergies__c"');
    }

    @isTest
    public static void mergeNotesTest() {
        VCC_Progress_Note__c copyFrom = new VCC_Progress_Note__c(VCC_Nurse_Summary__c = 'test');
        VCC_Progress_Note__c copyTo = new VCC_Progress_Note__c();

        Test.startTest();
        VCC_AdapterUtils_Note.mergeNotes(copyFrom, copyTo, new Set<String>{ 'VCC_Nurse_Summary__c' });
        Test.stopTest();

        System.assert(copyTo.VCC_Nurse_Summary__c == 'test', 'Field not copied successfully.');
    }

    @isTest
    public static void getLayoutInfoTest() {
        List<VCC_Progress_Note_Custom_Section__mdt> customSections = [SELECT Id, VCC_Fields__c FROM VCC_Progress_Note_Custom_Section__mdt LIMIT 1];
        //System.debug('No custom sections to test with.');
        if (customSections == null) {
            return;
        }

        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');

        VCC_LayoutService.LayoutInfo layoutInfo;

        Test.startTest();
        layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(VCC_Progress_Note__c.SObjectType, config);
        Test.stopTest();

        System.assert(layoutInfo != null, 'Unexpected null.');
    }

    @isTest
    public static void getAllFieldNamesTest() {
        List<VCC_Progress_Note_Custom_Section__mdt> customSections = [SELECT Id, VCC_Fields__c FROM VCC_Progress_Note_Custom_Section__mdt LIMIT 1];
        //System.debug('No custom sections to test with.');
        if (customSections == null) {
            return;
        }

        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');

        VCC_LayoutService.LayoutInfo layoutInfo = VCC_LayoutService.getLayoutInfo(VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', config.VCC_Page_Layout_Name__c));

        Set<String> fieldNames;

        Test.startTest();

        fieldNames = VCC_AdapterUtils_Note.getAllFieldNames(layoutInfo, customSections);

        Test.stopTest();

        System.assert(fieldNames != null && fieldNames.size() > 0, 'Expected a set of size greater than zero.');
        System.assert(
            fieldNames.containsAll(VCC_String_Utilities.splitUnique(customSections[0].VCC_Fields__c, ',')),
            'Expected custom sections fields in "fieldNames" but did not find them.'
        );
        System.assert(fieldNames.containsAll(layoutInfo.fieldSet), 'Expected all fields in page layout to be in "fieldNames" but did not find them.');
    }

    @isTest
    public static void getAllFieldNamesNoCustomTest() {
        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');

        VCC_LayoutService.LayoutInfo layoutInfo = VCC_LayoutService.getLayoutInfo(VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', config.VCC_Page_Layout_Name__c));

        Set<String> fieldNames;

        Test.startTest();

        fieldNames = VCC_AdapterUtils_Note.getAllFieldNames(layoutInfo, new List<VCC_Progress_Note_Custom_Section__mdt>());

        Test.stopTest();

        System.assert(fieldNames != null && fieldNames.size() > 0, 'Expected a set of size greater than zero.');
    }

    @isTest
    public static void getRelationshipFieldNamesTest() {
        SObjectType sobType = VCC_Progress_Note__c.SObjectType;
        Set<String> testFields = new Set<String>{ 'VCC_Case__c' };

        Map<String, String> relationshipFieldMap;
        Test.startTest();
        relationshipFieldMap = VCC_AdapterUtils_Note.getRelationshipFieldNames(testFields, sobType);
        Test.stopTest();

        System.assert(relationshipFieldMap.get('VCC_Case__c') == 'VCC_Case__r', 'Expected a relationship name.');
    }

    @isTest
    public static void getCustomSectionFieldNamesTest() {
        List<VCC_Progress_Note_Custom_Section__mdt> customSections = [SELECT Id, VCC_Fields__c FROM VCC_Progress_Note_Custom_Section__mdt LIMIT 100];
        System.assert(customSections != null, 'No custom sections to test with.');

        Set<String> customFields;
        Test.startTest();
        customFields = VCC_AdapterUtils_Note.getCustomSectionFieldNames(customSections);
        Test.stopTest();

        System.assert(customFields != null && customFields.size() > 0, 'Fields not extracted as expected.');
    }
}
