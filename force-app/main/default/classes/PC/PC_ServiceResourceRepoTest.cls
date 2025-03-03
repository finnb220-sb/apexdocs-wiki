/**
 * @description test class for PC_ServiceResourceRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ServiceResourceRepo
 * @see         VCR_ServiceResourceRepo
 */
@IsTest
private class PC_ServiceResourceRepoTest {
    @testSetup
    private static void testSetup() {
        VATEST_SObjectFactory.createSObject(
            new Schema.Location(
                Name = 'Test Location1',
                RecordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName()
                    .get('VA Facility')
                    .getRecordTypeId(),
                VAF_Facility_Type__c = 'va_health_facility',
                LocationType = 'Site',
                VAF_Facility_ID__c = '100'
            ),
            true
        );
    }

    @IsTest
    private static void funcGetServiceResourceWithLocationTestPositive() {
        // Test data setup
        PC_ServiceResourceRepo testRepo = new PC_ServiceResourceRepo();

        Id locId = [SELECT Id FROM Location WHERE Name = 'Test Location1' LIMIT 1].Id;

        User runAsUser;
        User specialistUser;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsUser = generateUserWithAccess('PrC_FLP_Users');
            specialistUser = generateUserWithAccess('PrC_Specialist_Users');
        }

        ServiceResource specialistSR = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = ('Test Specialist ' + Datetime.now().getTime()).left(80),
                RelatedRecordId = specialistUser.Id,
                IsActive = true,
                ResourceType = 'A',
                RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
                    .get('PC_Resource')
                    .getRecordTypeId(),
                PC_Location__c = locId,
                PC_Assigned_Specialty__c = 'Cardiology'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = specialistSR.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResource> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceWithLocation(specialistUser.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Service resource for the given location not retrieved successfully.');
    }

    @IsTest
    private static void funcGetServiceResourceWithLocationTestNegative() {
        // Test data setup
        PC_ServiceResourceRepo testRepo = new PC_ServiceResourceRepo();

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Id userId = [SELECT Id FROM User WHERE LastName = 'last' LIMIT 1].Id;

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getServiceResourceWithLocation(userId);
            } catch (Exception exc) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            threwError,
            'Failed to honor user access rights for getServiceResourceWithLocation. Expected method to throw an exception but observed successful invocation.'
        );
    }

    @IsTest
    private static void funcGetServiceResourceWithSkillAndLocationTestPositive() {
        // Test data setup
        PC_ServiceResourceRepo testRepo = new PC_ServiceResourceRepo();
        Id locId = [SELECT Id FROM Location WHERE Name = 'Test Location1' LIMIT 1].Id;

        User runAsUser;
        User specialistUser;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsUser = generateUserWithAccess('PrC_FLP_Users');
            specialistUser = generateUserWithAccess('PrC_Specialist_Users');
        }

        ServiceResource specialistSR = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = ('Test Specialist ' + Datetime.now().getTime()).left(80),
                RelatedRecordId = specialistUser.Id,
                IsActive = true,
                ResourceType = 'A',
                RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
                    .get('PC_Resource')
                    .getRecordTypeId(),
                PC_Location__c = locId,
                PC_Assigned_Specialty__c = 'Cardiology'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = specialistSR.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResource> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceWithLocation(new Set<String>{ 'Cardiology' }, new Set<Id>{ locId });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() > 0,
            'Service resource for the given skill and location not retrieved successfully.'
        );
    }

    @IsTest
    private static void funcGetServiceResourceWithSkillAndLocationTestNegative() {
        // Test data setup
        PC_ServiceResourceRepo testRepo = new PC_ServiceResourceRepo();

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Id locId = [SELECT Id FROM Location LIMIT 1].Id;

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getServiceResourceWithLocation(new Set<String>{ 'Cardiology' }, new Set<Id>{ locId });
            } catch (Exception exc) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            threwError,
            'Failed to honor user access rights for getServiceResourceWithLocation method call with skill and location parameters. Expected method to throw an exception but observed successful invocation.'
        );
    }

    /**
     * @description positive test for getServiceResourcesRunningUser to ensure that the method returns a list of the running user's related service resource(s)
     */
    @IsTest
    private static void funcGetServiceResourcesRunningUserTestPositive() {
        // Test data setup
        PC_ServiceResourceRepo testRepo = new PC_ServiceResourceRepo();

        Id locId = [SELECT Id FROM Location WHERE Name = 'Test Location1' LIMIT 1].Id;

        User runAsUser;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            runAsUser = generateUserWithAccess('PrC_Specialist_Users');
        }

        ServiceResource specialistSR = (ServiceResource) VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = ('Test Specialist ' + Datetime.now().getTime()).left(80),
                RelatedRecordId = runAsUser.Id,
                IsActive = true,
                ResourceType = 'A',
                RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
                    .get('PC_Resource')
                    .getRecordTypeId(),
                PC_Location__c = locId,
                PC_Assigned_Specialty__c = 'Cardiology'
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = specialistSR.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResource> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourcesRunningUser();
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Service resource for the current user not retrieved successfully.');
    }

    /**
     * @description helper method to generate an test user with the specified permission set groupfor use in test methods
     * @param       permissionSetGroupName api name of the permission set group to give the user
     * @return      `User` FLP salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetGroupName) {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet(permissionSetGroupName)
            .build(true);
    }
}
