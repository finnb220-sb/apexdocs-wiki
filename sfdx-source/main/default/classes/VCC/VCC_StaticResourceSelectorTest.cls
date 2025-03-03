@IsTest
public with sharing class VCC_StaticResourceSelectorTest {
    @IsTest
    private static void ctor() {
        VCC_StaticResourceSelector staticResourceSelector = new VCC_StaticResourceSelector();

        System.assert(staticResourceSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        VCC_StaticResourceSelector staticResourceSelector = new VCC_StaticResourceSelector();
        Integer fieldCount = staticResourceSelector.getSObjectFieldList().size();
        staticResourceSelector.addSObjectFields(new List<SObjectField>{ StaticResource.LastModifiedDate });
        Integer newFieldCount = staticResourceSelector.getSObjectFieldList().size();

        System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
    }

    @IsTest
    private static void selectById() {
        StaticResource staticResource = [SELECT Id FROM StaticResource LIMIT 1];
        List<StaticResource> staticResources = new VCC_StaticResourceSelector().selectById(new Set<Id>{ staticResource.Id });

        System.assert(staticResources != null, 'Expected the list to exist.');
        System.assertEquals(1, staticResources.size(), 'Expected there to be only 1 item in the list.');
        System.assertEquals(staticResource.Id, staticResources[0].Id, 'Expected the field values to match.');
    }

    @IsTest
    private static void selectByIdException() {
        try {
            List<StaticResource> staticResources = new VCC_StaticResourceSelector().selectById(null);
        } catch (VCC_InternalException e) {
            System.assertEquals(e.getMessage(), 'You must provide 1 or more ids to select static resources by id.', 'Expected the exception messages to match.');
        }
    }

    @IsTest
    private static void selectByName() {
        StaticResource staticResource = [SELECT Id, Name FROM StaticResource LIMIT 1];
        List<StaticResource> staticResources = new VCC_StaticResourceSelector().selectByName(staticResource.Name);

        System.assert(staticResources != null, 'Expected the list to exist.');
        System.assertEquals(1, staticResources.size(), 'Expected there to be only 1 item in the list.');
        System.assertEquals(staticResource.Name, staticResources[0].Name, 'Expected the field values to match.');
    }

    @IsTest
    private static void selectByNameException() {
        try {
            List<StaticResource> staticResources = new VCC_StaticResourceSelector().selectByName(new Set<String>());
        } catch (VCC_InternalException e) {
            System.assertEquals(e.getMessage(), 'You must provide 1 or more names to select static resources by name.', 'Expected the exception messages to match.');
        }
    }
}
