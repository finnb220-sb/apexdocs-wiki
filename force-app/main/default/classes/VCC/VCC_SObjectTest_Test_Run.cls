@IsTest
public with sharing class VCC_SObjectTest_Test_Run {
    // private static String username = 'sobjTestRun';

    // @TestSetup
    // public static void makeData(){
    //     User testUser = VCC_TestDataFactory.insertUser('Standard User');
    //     VCC_TestDataFactory.assignPermissionSetByName(testUser, 'VCC_Integration_Test_Utility_Base');
    //     testUser.Username = username+testUser.Username;
    //     update testUser;
    // }

    // public static User getTestUser(){
    //     return [SELECT Id FROM User WHERE Username LIKE :username+'%' LIMIT 1 ];
    // }

    @IsTest
    static void vdifTestRunLayoutTest() {
        Test.startTest();

        List<Metadata.Metadata> retrieveResults = Metadata.Operations.retrieve(Metadata.MetadataType.LAYOUT, new List<String>{ 'PersonAccount-VCC Person Account' });

        System.assert(retrieveResults.size() == 1, 'Expected one page layout.');

        Metadata.Layout vdifTestRunLayout = (Metadata.Layout) retrieveResults[0];

        Boolean allReadOnly = true;

        for (Metadata.LayoutSection layoutSection : vdifTestRunLayout.layoutSections) {
            for (Metadata.LayoutColumn layoutColumn : layoutSection.layoutColumns) {
                if (layoutColumn?.layoutItems == null || layoutColumn.layoutItems.isEmpty()) {
                    continue;
                }
                for (Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
                    if (String.isBlank(layoutItem.field)) {
                        continue;
                    }
                    if (layoutItem.behavior !== Metadata.UiBehavior.READONLY) {
                        allReadOnly = false;
                    }
                }
            }
        }

        Set<String> layoutExcludedButtons = new Set<String>();
        for (String excludedButton : vdifTestRunLayout.excludeButtons) {
            layoutExcludedButtons.add(excludedButton);
        }

        Set<String> relatedListExcludedButtons = new Set<String>();

        System.assert(layoutExcludedButtons.contains('Edit'), 'Expected no Edit button.');
        System.assert(layoutExcludedButtons.contains('ChangeRecordType'), 'Expected no ChangeRecordType button.');

        System.assert(allReadOnly = true, 'Expected all read only.');

        Test.stopTest();
    }

    @IsTest
    static void testRunLayoutTest() {
        Test.startTest();

        List<Metadata.Metadata> retrieveResults = Metadata.Operations.retrieve(Metadata.MetadataType.LAYOUT, new List<String>{ 'VCC_Test_Run__c-Test Run Layout' });

        System.assert(retrieveResults.size() == 1, 'Expected one page layout.');

        Metadata.Layout testRunLayout = (Metadata.Layout) retrieveResults[0];

        Boolean allReadOnly = true;

        for (Metadata.LayoutSection layoutSection : testRunLayout.layoutSections) {
            for (Metadata.LayoutColumn layoutColumn : layoutSection.layoutColumns) {
                if (layoutColumn?.layoutItems == null || layoutColumn.layoutItems.isEmpty()) {
                    continue;
                }
                for (Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
                    if (String.isBlank(layoutItem.field)) {
                        continue;
                    }
                    if (layoutItem.behavior !== Metadata.UiBehavior.READONLY) {
                        allReadOnly = false;
                    }
                }
            }
        }

        System.assert(allReadOnly = true, 'Expected all read only.');

        Test.stopTest();
    }
}
