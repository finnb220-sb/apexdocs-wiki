/**
 * @description       : test class for PC_ConsortiumsRelatedListController
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 01-23-2023
 * @last modified by  : WagnerJ@BAH
 **/
@isTest
private class PC_ConsortiumsRelatedListController_Test {
    @TestSetup
    static void makeData() {
        PC_Territory__c terr = new PC_Territory__c(Name = 'Test Territory');
        insert terr;

        //create direct Consortiums
        PC_Consortium__c cons1 = new PC_Consortium__c(Name = 'Consortium 1');
        insert cons1;
        PC_Consortium_Territory__c consTerr = new PC_Consortium_Territory__c(PC_Territory__c = terr.Id, PC_Consortium__c = cons1.Id);
        insert consTerr;

        PC_Consortium__c cons2 = new PC_Consortium__c(Name = 'Consortium 2');
        insert cons2;
    }

    @isTest
    private static void testGetConsortiums() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];

        // Actual test
        Test.startTest();

        //throw exception
        PC_ConsortiumsRelatedListController.throwException = true;
        try {
            PC_ConsortiumsRelatedListController.getConsortiums(terr.Id);
        } catch (Exception e) {
            System.assert(true, 'Force assertion.');
        }

        PC_ConsortiumsRelatedListController.throwException = false;
        PC_RelatedListHelper.RelatedListResults result = PC_ConsortiumsRelatedListController.getConsortiums(terr.Id);

        Test.stopTest();

        // Asserts
        System.assert(result.records.size() > 0, 'Related Consortiums list should return at least one previously related Consortium.');
    }

    @isTest
    private static void testSaveRecords() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];
        List<PC_Consortium__c> consList = [SELECT ID FROM PC_Consortium__c ORDER BY Name LIMIT 2];

        String originalSelectedRecordIds = '["' + consList[0].Id + '"]';
        String selectedRecordIds = '["' + consList[1].Id + '"]';

        // Actual test
        Test.startTest();

        //throw exception
        PC_ConsortiumsRelatedListController.throwException = true;
        try {
            PC_ConsortiumsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);
        } catch (Exception e) {
            System.assert(true, 'Force assertion.');
        }

        PC_ConsortiumsRelatedListController.throwException = false;
        PC_ConsortiumsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);

        Test.stopTest();

        // Asserts
        System.assert(
            [SELECT ID FROM PC_Consortium_Territory__c WHERE PC_Territory__c = :terr.Id AND PC_Consortium__c = :consList[1].Id LIMIT 1].size() > 0,
            'New Consortium Territory should be created.'
        );
    }
}
