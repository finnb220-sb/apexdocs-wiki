@isTest
public with sharing class VCC_LayoutServiceTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @isTest
    public static void getPageLayoutTest() {
        System.runAs(getTestUser()) {
            Metadata.Layout theLayout;

            Test.startTest();
            theLayout = VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note');
            Test.stopTest();

            System.assert(theLayout != null, 'Expected a Layout, got null.');
        }
    }

    @isTest
    public static void getLayoutInfoWithOptionsTest() {
        System.runAs(getTestUser()) {
            Metadata.Layout pageLayout = VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note');

            VCC_LayoutService.LayoutInfoOptions options = new VCC_LayoutService.LayoutInfoOptions();
            options.excludeSections = new Set<String>{ 'System Information' };

            VCC_LayoutService.LayoutInfo layoutInfo;
            Test.startTest();
            layoutInfo = VCC_LayoutService.getLayoutInfo(pageLayout, options);
            Test.stopTest();

            System.assert(layoutInfo != null, 'Expeced LayoutInfo, got null.');
        }
    }

    @isTest
    public static void getLayoutInfoWithExcludedSectionsTest() {
        Metadata.Layout pageLayout = VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note');
        System.runAs(getTestUser()) {
            VCC_LayoutService.LayoutInfo layoutInfo;
            Test.startTest();
            layoutInfo = VCC_LayoutService.getLayoutInfo(pageLayout, new Set<String>{ 'System Information' });
            Test.stopTest();

            System.assert(layoutInfo != null, 'Expeced LayoutInfo, got null.');
        }
    }

    @isTest
    public static void getLayoutInfoWithoutOptionsTest() {
        System.runAs(getTestUser()) {
            Metadata.Layout pageLayout = VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note');

            VCC_LayoutService.LayoutInfo layoutInfo;
            Test.startTest();
            layoutInfo = VCC_LayoutService.getLayoutInfo(pageLayout);
            Test.stopTest();

            System.assert(layoutInfo != null, 'Expeced LayoutInfo, got null.');
        }
    }

    @isTest
    public static void getRelationshipFieldsTest() {
        System.runAs(getTestUser()) {
            VCC_LayoutService.LayoutInfo layoutInfo = VCC_LayoutService.getLayoutInfo(VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note'));

            Map<String, String> relationshipMap;
            Test.startTest();
            relationshipMap = VCC_LayoutService.getRelationshipFields(layoutInfo, VCC_Progress_Note__c.SObjectType);
            Test.stopTest();

            System.assert(relationshipMap != null, 'Expected a Map<String, String>, got null.');
        }
    }

    @isTest
    public static void getMissingFieldsTest() {
        System.runAs(getTestUser()) {
            VCC_Progress_Note__c someProgressNote = new VCC_Progress_Note__c();
            VCC_LayoutService.LayoutInfo layoutInfo = VCC_LayoutService.getLayoutInfo(VCC_LayoutService.getPageLayout('VCC_Progress_Note__c', 'VCC Clinical Triage Progress Note'));

            Set<String> missingFields;
            Test.startTest();
            missingFields = VCC_LayoutService.getMissingFields(someProgressNote, layoutInfo);
            Test.stopTest();

            System.assert(missingFields != null, 'Expected Set<String>, got null.');
            System.assert(missingFields.containsAll(layoutInfo.fieldSet), 'Expected to find all layout fields in set.');
        }
    }
}
