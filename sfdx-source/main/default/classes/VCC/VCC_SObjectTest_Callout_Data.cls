@IsTest
public with sharing class VCC_SObjectTest_Callout_Data {
    @IsTest
    static void calloutLayoutTest() {
        Test.startTest();

        List<Metadata.Metadata> retrieveResults = Metadata.Operations.retrieve(Metadata.MetadataType.LAYOUT, new List<String>{ 'VCC_Callout_Data__c-Callout Layout' });

        System.assert(retrieveResults.size() == 1, 'Expected one page layout.');

        Metadata.Layout calloutLayout = (Metadata.Layout) retrieveResults[0];

        Boolean allReadOnly = true;

        for (Metadata.LayoutSection layoutSection : calloutLayout.layoutSections) {
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
        for (String excludedButton : calloutLayout.excludeButtons) {
            layoutExcludedButtons.add(excludedButton);
        }

        System.assert(layoutExcludedButtons.contains('Edit'), 'Expected no Edit button.');
        System.assert(layoutExcludedButtons.contains('ChangeRecordType'), 'Expected no ChangeRecordType button.');
        System.assert(allReadOnly = true, 'Expected all read only.');

        Test.stopTest();
    }
}
