/**
 * @description test class for PC_PrcUserRepo
 * @author      Booz Allen
 * @since       2024
 * @see         PC_PrcUserRepo
 */
@isTest
private class PC_PrcUserRepoTest {
    @testSetup
    private static void testSetup() {
        Id locRecTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName().get('VA Facility').getRecordTypeId();
        Schema.Location location1 = new Schema.Location(
            Name = 'Test Location1',
            RecordTypeId = locRecTypeId,
            VAF_Facility_Type__c = 'va_health_facility',
            LocationType = 'Site',
            VAF_Facility_ID__c = '100'
        );
        insert location1;

        Set<String> flpPermissionSetNames = new Set<String>{
            'PrC_FLP_App_Access',
            'PC_User_BaseObjectWithNoTabVisibility_ReadWrite'
        };

        VATEST_UserBuilder pcTestFLPWithAccessBuilder = new VATEST_UserBuilder();
        pcTestFLPWithAccessBuilder.withPermissionSets(flpPermissionSetNames)
            .withUserProfile('VAVET Base Profile')
            .withStandardData();
        pcTestFLPWithAccessBuilder.resultingUser.LastName = 'WithAccess';
        pcTestFLPWithAccessBuilder.build(true);

        VATEST_UserBuilder pcTestFLPWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestFLPWithoutAccessBuilder.withPermissionSet('PrC_FLP_App_Access')
            .withUserProfile('VAVET Base Profile')
            .withStandardData();
        pcTestFLPWithoutAccessBuilder.resultingUser.LastName = 'WithoutAccess';
        pcTestFLPWithoutAccessBuilder.build(true);
    }

    @isTest
    private static void funcFetchPrcUserByUserIdTestPositive() {
        // Test data setup
        PC_PrcUserRepo prcUserRepo = new PC_PrcUserRepo();
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];
        Schema.Location testLocation = [SELECT Id FROM Location LIMIT 1];
        insert new PC_User__c(OwnerId = runAsUser.Id, User_ID__c = runAsUser.Id, Current_Location__c = testLocation.Id);

        // Actual test
        Test.startTest();

        List<PC_User__c> result;
        System.runAs(runAsUser) {
            result = prcUserRepo.fetchPrcUserByUserId(UserInfo.getUserId());
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            result.size() > 0 && runAsUser.Id.equals(result[0].User_Id__c),
            'Current User\'s PrC User record not retrieved successfully.'
        );
    }

    @isTest
    private static void funcFetchPrcUserByUserIdTestNegative() {
        // Test data setup\
        PC_PrcUserRepo prcUserRepo = new PC_PrcUserRepo();
        User runAsUserNoAccess = [SELECT Id FROM User WHERE LastName = 'WithoutAccess'];
        Boolean hasFailure = false;

        // Actual test
        Test.startTest();

        System.runAs(runAsUserNoAccess) {
            try {
                prcUserRepo.fetchPrcUserByUserId(UserInfo.getUserId());
            } catch (QueryException e) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(hasFailure, 'SOQL query should fail if the user has no access to the PC_User object.');
    }

    @isTest
    private static void funcFetchPrcUserByUserIdWithSelectFieldsTestPositive() {
        // Test data setup
        PC_PrcUserRepo prcUserRepo = new PC_PrcUserRepo();

        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];
        //Mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            runAsUser.Division = 'VISN 1';
            update runAsUser;
        }

        Schema.Location testLocation = [SELECT Id FROM Location LIMIT 1];
        insert new PC_User__c(OwnerId = runAsUser.Id, User_ID__c = runAsUser.Id, Current_Location__c = testLocation.Id);

        // Actual test
        Test.startTest();

        List<PC_User__c> result;
        System.runAs(runAsUser) {
            result = prcUserRepo.fetchPrcUserByUserIdWithSelectFields(
                UserInfo.getUserId(),
                new Set<String>{ 'User_ID__c', 'User_ID__r.Division' }
            );
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            result.size() > 0 &&
                runAsUser.Id.equals(result[0].User_Id__c) &&
                result[0].isSet('User_ID__c') &&
                runAsUser.Division.equalsIgnoreCase(result[0].User_ID__r.Division),
            'Current User\'s PrC User record (with the specified fields) not retrieved successfully.'
        );
    }

    @isTest
    private static void funcUpsertNewPrcUserTestPositive() {
        // Test data setup
        PC_PrcUserRepo prcUserRepo = new PC_PrcUserRepo();
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];
        Schema.Location testLocation = [SELECT Id FROM Location LIMIT 1];
        PC_User__c newPrcUser = new PC_User__c(User_ID__c = runAsUser.Id, Current_Location__c = testLocation.Id);

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            prcUserRepo.upsertPrcUser(newPrcUser);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            [SELECT Id FROM PC_User__c WHERE User_ID__c = :runAsUser.Id LIMIT 1].size() > 0,
            'New PrC User record not upserted successfully.'
        );
    }

    @isTest
    private static void funcUpsertNewPrcUserTestNegative() {
        // Test data setup
        PC_PrcUserRepo prcUserRepo = new PC_PrcUserRepo();
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];
        PC_User__c newPrcUser = new PC_User__c(User_ID__c = runAsUser.Id, Current_Location__c = null);
        Boolean hasDmlFailure = false;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                prcUserRepo.upsertPrcUser(newPrcUser);
            } catch (DmlException e) {
                hasDmlFailure = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(hasDmlFailure, 'PrC User record without a Current Location should not upsert successfully.');
    }
}
