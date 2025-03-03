/**
 * @description Test class for PC_PrcUserLocationSelectorController unit tests
 * @author      Booz Allen
 * @since       2024
 */
@isTest
private class PC_PrcUserLocationSelectorControllerTest {
    @testSetup
    private static void testSetup() {
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
    private static void unitFetchPrcUserByUserIdTestPositive() {
        // Test data setup
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];

        //Create the fakes PC User in memory
        PC_User__c expected = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(
                OwnerId = runAsUser.Id,
                User_ID__c = runAsUser.Id,
                Current_Location__c = VATEST_IdFactory.get(Type.forName('Schema.Location'))
            )
        );

        PC_PrcUserRepo stubbedRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(expected.User_ID__c)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ expected })
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_PrcUserLocationSelectorController.visiblePrcUserRepo = stubbedRepo;

        // Actual test
        Test.startTest();

        PC_User__c result;
        System.runAs(runAsUser) {
            result = PC_PrcUserLocationSelectorController.getPrcUser(UserInfo.getUserId());
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(expected == result, 'Expected PC_PrcUserLocationSelectorController to call getPrcUser');
    }

    @isTest
    private static void unitFetchPrcUserByUserIdTestNegative() {
        // Test data setup
        User runAsUserNoAccess = [SELECT Id FROM User WHERE LastName = 'WithoutAccess'];
        Boolean hasFailure = false;

        //Create the fakes PC User in memory that will not be returned due to a forced exception
        PC_User__c notExpected = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(
                OwnerId = runAsUserNoAccess.Id,
                User_ID__c = runAsUserNoAccess.Id,
                Current_Location__c = VATEST_IdFactory.get(Type.forName('Schema.Location'))
            )
        );

        PC_PrcUserRepo stubbedRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(notExpected.User_ID__c)
            //Tell the stub builder to throw an exception
            .throwingException()
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_PrcUserLocationSelectorController.visiblePrcUserRepo = stubbedRepo;

        // Actual test
        Test.startTest();

        PC_User__c result;
        System.runAs(runAsUserNoAccess) {
            try {
                result = PC_PrcUserLocationSelectorController.getPrcUser(UserInfo.getUserId());
            } catch (AuraHandledException e) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            hasFailure,
            'Expected PC_PrcUserLocationSelectorController to call getPrcUser and throw Exception'
        );
    }

    @isTest
    private static void unitUpsertNewPrcUserTestPositive() {
        // Test data setup
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];

        //Create the fakes PC User in memory
        Id fakeLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));
        PC_User__c expected = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(User_ID__c = runAsUser.Id, Current_Location__c = fakeLocationId)
        );

        PC_User__c prcUserForUpsert = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(User_ID__c = runAsUser.Id, Current_Location__c = fakeLocationId)
        );
        prcUserForUpsert.Id = null;

        PC_PrcUserRepo stubbedRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //add mock for fetchPrcUserByUserId since upsertPrcUser calls it as well
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(expected.User_ID__c)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ expected })
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('upsertPrcUser', Type.forName('PC_User__c'))
            .withParameterValues(prcUserForUpsert)
            .returning(expected)
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_PrcUserLocationSelectorController.visiblePrcUserRepo = stubbedRepo;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            //should update the Id field with the 'new' Id value after upsert
            prcUserForUpsert = PC_PrcUserLocationSelectorController.savePrcUser(prcUserForUpsert);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            expected.Id == prcUserForUpsert.Id,
            'Expected PC_PrcUserLocationSelectorController to call upsertPrcUser'
        );
    }

    @isTest
    private static void unitUpsertNewPrcUserTestNegative() {
        // Test data setup
        User runAsUser = [SELECT Id FROM User WHERE LastName = 'WithAccess'];
        Boolean hasFailure = false;

        //Create the fakes PC User in memory that will not be returned due to a force exception
        Id fakeLocationId = VATEST_IdFactory.get(Type.forName('Schema.Location'));
        PC_User__c notExpected = (PC_User__c) VATEST_SObjectFactory.createSObject(
            new PC_User__c(OwnerId = runAsUser.Id, User_ID__c = runAsUser.Id, Current_Location__c = fakeLocationId)
        );

        PC_PrcUserRepo stubbedRepo = (PC_PrcUserRepo) new VATEST_StubBuilder(PC_PrcUserRepo.class)
            //add mock for fetchPrcUserByUserId since upsertPrcUser calls it as well
            .mockingMethodCall('fetchPrcUserByUserId', Id.class)
            .withParameterValues(notExpected.User_ID__c)
            //Tell the stub builder what to return
            .returning(new List<PC_User__c>{ notExpected })
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('upsertPrcUser', PC_User__c.class)
            .withParameterValues(notExpected)
            //Tell the stub builder to throw an exception
            .throwingException()
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_PrcUserLocationSelectorController.visiblePrcUserRepo = stubbedRepo;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                PC_PrcUserLocationSelectorController.savePrcUser(notExpected);
            } catch (AuraHandledException e) {
                hasFailure = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            hasFailure,
            'Expected PC_PrcUserLocationSelectorController to call upsertPrcUser and throw a DmlException'
        );
    }
}
