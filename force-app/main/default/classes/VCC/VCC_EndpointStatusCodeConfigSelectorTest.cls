@IsTest
public with sharing class VCC_EndpointStatusCodeConfigSelectorTest {
    @IsTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_EndpointStatusCodeConfigSelector esccs = new VCC_EndpointStatusCodeConfigSelector();
        Test.stopTest();

        System.assert(esccs != null, 'Did not instantiate as expected.');
    }

    @IsTest
    public static void addSObjectFieldsTest() {
        // Create a new selector
        VCC_EndpointStatusCodeConfigSelector selector = new VCC_EndpointStatusCodeConfigSelector();

        // Get the list of object fields before adding
        List<Schema.SObjectField> initialFields = selector.getSObjectFieldList();

        // Check that the initial fields do not contain the field to test
        System.assert(!initialFields.contains(CodeSet.IsActive));

        // Wrap adding fields in Test.startTest() / Test.stopTest() to avoid reaching governor limits
        Test.startTest();
        selector.addSObjectFields(new List<Schema.SObjectField>{ CodeSet.IsActive });
        Test.stopTest();

        // Get the list of object fields after adding
        List<Schema.SObjectField> finalFields = selector.getSObjectFieldList();

        // Check that the number of fields has increased by 1
        System.assertEquals(initialFields.size(), finalFields.size());

        // Ensure the newly added field is there in the finalFields
        System.assert(finalFields.contains(CodeSet.IsActive));
    }

    @IsTest
    public static void selectByIdsTest() {
        VCC_EndpointStatusCodeConfigSelector esccs = new VCC_EndpointStatusCodeConfigSelector();
        VCC_Endpoint_Status_Code_Configuration__mdt escc = [
            SELECT Id
            FROM VCC_Endpoint_Status_Code_Configuration__mdt
            LIMIT 1
        ];
        Test.startTest();
        List<VCC_Endpoint_Status_Code_Configuration__mdt> esccList = esccs.selectById(new Set<Id>{ escc.Id });
        Test.stopTest();

        System.assert(esccList.size() == 1, 'Expected one record returned.');
    }
}
