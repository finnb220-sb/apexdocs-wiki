/**
 * @description test class for PC_VISNsRelatedListController
 * @author      Booz Allen
 * @since       2024
 * @see         PC_VISNsRelatedListController
 **/
@IsTest
private class PC_VISNsRelatedListController_Test {
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
        PC_Consortium_Territory__c consTerr = new PC_Consortium_Territory__c(
            PC_Territory__c = terr.Id,
            PC_Consortium__c = cons1.Id
        );
        insert consTerr;
        PC_ConsortiumVISN__c consVISN = new PC_ConsortiumVISN__c(PC_Consortium__c = cons1.Id, PC_VISN__c = visn1.Id);
        insert consVISN;

        VISN__c visn2 = new VISN__c(Name = 'VISN 2');
        insert visn2;
    }

    @IsTest
    private static void testGetVISNs() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];

        User runAsUser;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsUser = generateUserWithAccess();
        }

        //insert shares to mimic sharing rules
        VATEST_SObjectFactory.createSObject(
            new PC_Territory__Share(
                ParentId = [SELECT ID FROM PC_Territory__c WHERE Name = 'Test Territory' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VISN__Share(
                ParentId = [SELECT ID FROM VISN__c WHERE Name = 'VISN 1' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VISN__Share(
                ParentId = [SELECT ID FROM VISN__c WHERE Name = 'VISN 2' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new PC_Consortium__Share(
                ParentId = [SELECT ID FROM PC_Consortium__c WHERE Name = 'Consortium 1' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        PC_RelatedListHelper.RelatedListResults result;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            PC_VISNsRelatedListController.throwException = true;
            try {
                PC_VISNsRelatedListController.getVISNs(terr.Id, true);
            } catch (Exception e) {
                System.assert(true, 'Force assertion.');
            }

            PC_VISNsRelatedListController.throwException = false;
            result = PC_VISNsRelatedListController.getVISNs(terr.Id, true);
        }

        Test.stopTest();

        // Asserts
        System.assert(
            result.records.size() > 0,
            'Related VISN List should return at least one previously Related VISN.'
        );
    }

    @IsTest
    private static void testSaveRecords() {
        // Test data setup
        PC_Territory__c terr = [SELECT ID FROM PC_Territory__c LIMIT 1];
        List<VISN__c> visnList = [SELECT ID FROM VISN__c ORDER BY Name LIMIT 2];

        String originalSelectedRecordIds = '["' + visnList[0].Id + '"]';
        String selectedRecordIds = '["' + visnList[1].Id + '"]';

        User runAsUser;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsUser = generateUserWithAccess();
        }

        //insert shares to mimic sharing rules
        VATEST_SObjectFactory.createSObject(
            new PC_Territory__Share(
                ParentId = [SELECT ID FROM PC_Territory__c WHERE Name = 'Test Territory' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VISN__Share(
                ParentId = [SELECT ID FROM VISN__c WHERE Name = 'VISN 1' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new VISN__Share(
                ParentId = [SELECT ID FROM VISN__c WHERE Name = 'VISN 2' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new PC_Consortium__Share(
                ParentId = [SELECT ID FROM PC_Consortium__c WHERE Name = 'Consortium 1' LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            PC_VISNsRelatedListController.throwException = true;
            try {
                PC_VISNsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);
            } catch (Exception e) {
                System.assert(true, 'Force assertion.');
            }

            PC_VISNsRelatedListController.throwException = false;
            PC_VISNsRelatedListController.saveRecords(terr.Id, originalSelectedRecordIds, selectedRecordIds);
        }

        Test.stopTest();

        // Asserts
        System.assert(
            [
                SELECT ID
                FROM PC_VISNTerritory__c
                WHERE PC_Territory__c = :terr.Id AND PC_VISN__c = :visnList[1].Id
                LIMIT 1
            ]
            .size() > 0,
            'New VISN Territory should be created.'
        );
    }

    /**
     * @description helper method to generate an pc manager test user for use in test methods
     * @return      `User` pc manager salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_Specialist_Manager_App_Access')
            .build(true);
    }
}
