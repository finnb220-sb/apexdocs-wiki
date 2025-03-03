/**
 * @description       : test class for PC_LocationsRelatedListController-
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 01-23-2023
 * @last modified by  : WagnerJ@BAH
 **/
@isTest
private class PC_LocationsRelatedListController_Test {
    @TestSetup
    static void makeData() {
        PC_Territory__c terr = new PC_Territory__c(Name = 'Test Territory');
        insert terr;

        //create direct VISNs
        VISN__c visn1 = new VISN__c(Name = 'VISN 1');
        insert visn1;
        PC_VISNTerritory__c visnTerr = new PC_VISNTerritory__c(PC_VISN__c = visn1.Id, PC_Territory__c = terr.Id);
        insert visnTerr;

        //create direct Consortiums (indirect VISNs)
        PC_Consortium__c cons1 = new PC_Consortium__c(Name = 'Consortium 1');
        insert cons1;
        PC_Consortium_Territory__c consTerr = new PC_Consortium_Territory__c(PC_Territory__c = terr.Id, PC_Consortium__c = cons1.Id);
        insert consTerr;
        PC_ConsortiumVISN__c consVISN = new PC_ConsortiumVISN__c(PC_Consortium__c = cons1.Id, PC_VISN__c = visn1.Id);
        insert consVISN;

        //create direct Locations
        Id locRecTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName().get('VA Facility').getRecordTypeId();
        Schema.Location loc = new Schema.Location(
            Name = 'Test Location',
            VISN_Lookup__c = visn1.Id,
            RecordTypeId = locRecTypeId,
            VAF_Facility_Type__c = 'va_health_facility',
            LocationType = 'Site',
            VAF_Facility_ID__c = '123'
        );
        insert loc;
        PC_Territory_Location__c terrLoc = new PC_Territory_Location__c(PC_Territory__c = terr.Id, PC_Location__c = loc.Id);
        insert terrLoc;

        Schema.Location loc2 = new Schema.Location(
            Name = 'Test Location 2',
            VISN_Lookup__c = visn1.Id,
            RecordTypeId = locRecTypeId,
            VAF_Facility_Type__c = 'va_health_facility',
            LocationType = 'Site',
            VAF_Facility_ID__c = '456'
        );
        insert loc2;
    }

    @isTest
    private static void testGetLocations() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];

        // Actual test
        Test.startTest();

        //throw exception
        PC_LocationsRelatedListController.throwException = true;
        try {
            PC_LocationsRelatedListController.getLocations(terr.Id, true, true);
        } catch (Exception e) {
            System.assert(true, 'Force assertion.');
        }

        PC_LocationsRelatedListController.throwException = false;
        PC_RelatedListHelper.RelatedListResults result = PC_LocationsRelatedListController.getLocations(terr.Id, true, true);

        Test.stopTest();

        // Asserts
        System.assert(result.records.size() > 0, 'Related Locations list should return at least one previously related Location.');
    }

    @isTest
    private static void testSaveRecords() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];
        List<Schema.Location> locList = [SELECT ID FROM Location ORDER BY Name LIMIT 2];

        String originalSelectedRecordIds = '["' + locList[0].Id + '"]';
        String selectedRecordIds = '["' + locList[1].Id + '"]';

        // Actual test
        Test.startTest();

        //throw exception
        PC_LocationsRelatedListController.throwException = true;
        try {
            PC_LocationsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);
        } catch (Exception e) {
            System.assert(true, 'Force assertion.');
        }

        PC_LocationsRelatedListController.throwException = false;
        PC_LocationsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);

        Test.stopTest();

        // Asserts
        System.assert(
            [SELECT ID FROM PC_Territory_Location__c WHERE PC_Territory__c = :terr.Id AND PC_Location__c = :locList[1].Id LIMIT 1].size() > 0,
            'New Territory Location should be created.'
        );
    }
}
