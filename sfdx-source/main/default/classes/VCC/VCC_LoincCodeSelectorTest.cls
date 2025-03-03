@isTest
public class VCC_LoincCodeSelectorTest {
    @isTest
    private static void testSelectAll() {
        // Call the selectAll method
        List<VCC_Loinc__mdt> loincList = new VCC_LoincCodeSelector().selectAll();
    }

    @isTest
    private static void testAddSObjectFields() {
        // Create a new selector and add a field
        VCC_LoincCodeSelector selector = new VCC_LoincCodeSelector();
        selector.addSObjectFields(new List<Schema.SObjectField>{ VCC_Loinc__mdt.MasterLabel });

        // Call the getSObjectFieldList method and verify the results
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        System.assertEquals(5, fieldList.size());
        System.assert(fieldList.contains(VCC_Loinc__mdt.MasterLabel));
    }
}
