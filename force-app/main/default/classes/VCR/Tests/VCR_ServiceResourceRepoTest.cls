/**
 * @author Booz Allen Hamilton
 * @since 5/9/24
 * @description Unit tests for VCR_ServiceResourceRepo.
 * @see VCR_ServiceResourceRepo
 */

@IsTest
private class VCR_ServiceResourceRepoTest {
    final static User VAVET_ADMIN_USER;
    static {
        VAVET_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
    }

    @TestSetup
    static void buildData() {
        List<String> lastNames = new List<String>{ 'Active MP', 'Inactive MP', 'Active PC' };
        List<User> providers = new List<User>();
        for (Integer idx = 0; idx < 3; idx++) {
            User provider = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .build(false);
            provider.LastName = lastNames[idx];
            providers.add(provider);
        }
        insert providers;
        Integer idx = 0;
        // create Active MP ServiceResource
        VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = 'Active MP Service Resource',
                RelatedRecordId = providers[idx++].Id,
                RecordTypeId = ServiceResource.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Medical_Provider')
                    .getRecordTypeId(),
                IsActive = true
            ),
            true
        );

        // create Inactive MP ServiceResource
        VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = 'Inactive Service Resource',
                RelatedRecordId = providers[idx++].Id,
                RecordTypeId = ServiceResource.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Medical_Provider')
                    .getRecordTypeId(),
                IsActive = false
            ),
            true
        );

        // create Active PC ServiceResource
        VATEST_SObjectFactory.createSObject(
            new ServiceResource(
                Name = 'PC Service Resource',
                RelatedRecordId = providers[idx++].Id,
                RecordTypeId = ServiceResource.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PC_Resource')
                    .getRecordTypeId(),
                IsActive = true
            ),
            true
        );
    }

    /**
     * @description Happy path for constructor
     */
    @IsTest
    static void funcItConstructsInstancePositive() {
        Test.startTest();
        VCR_ServiceResourceRepo testRepo;
        System.runAs(VAVET_ADMIN_USER) {
            testRepo = new VCR_ServiceResourceRepo();
        }
        Test.stopTest();
        Assert.isInstanceOfType(
            testRepo,
            VTC_BaseRepo.class,
            'Expected valid repository to be constructed & returned.'
        );
    }

    /**
     * @description Happy path for get ServiceResources for given UserIds
     */
    @IsTest
    static void funcFetchServiceResourcesByUserIdPositive() {
        VCR_ServiceResourceRepo testRepo = new VCR_ServiceResourceRepo();
        List<ServiceResource> expProviders;
        System.runAs(VAVET_ADMIN_USER) {
            expProviders = [
                SELECT Id, IsActive, RelatedRecordId, RecordTypeId
                FROM ServiceResource
                WHERE Name = 'Active MP Service Resource'
            ];
        }
        List<Id> providerUserIds = new List<Id>();
        providerUserIds.add(expProviders.get(0).RelatedRecordId);
        Test.startTest();
        List<ServiceResource> foundProviders;
        System.runAs(VAVET_ADMIN_USER) {
            foundProviders = testRepo.fetchServiceResourcesForMPsByUserId(providerUserIds);
        }
        Test.stopTest();
        Assert.areEqual(
            expProviders.size(),
            foundProviders.size(),
            'Expected 1 ServiceResource (provider) to be returned from fetchServiceResourcesForMPsByUserId given related valid UserId.'
        );
    }

    /**
     * @description Unhappy path for get ServiceResources for empty list of Users
     *  Unhappy path
     */
    @IsTest
    static void funcFetchServiceResourcesByUserIdNegative() {
        VCR_ServiceResourceRepo testRepo = new VCR_ServiceResourceRepo();
        Test.startTest();
        List<ServiceResource> foundProviders;
        System.runAs(VAVET_ADMIN_USER) {
            foundProviders = testRepo.fetchServiceResourcesForMPsByUserId(new List<Id>());
        }
        Test.stopTest();
        Assert.areEqual(
            0,
            foundProviders.size(),
            'Expected fetchServiceResourcesForMPsByUserId to return empty list, not null, for empty list of Providers.'
        );
    }

    /**
     * @description Happy path for get ServiceResources for valid User Id but with no ServiceResources
     *  Unhappy path
     */
    @IsTest
    static void funcFetchServiceResourcesByUserIdWhenNoMatchesNegative() {
        // re-assign ServiceResource to other User as we cannot delete these records
        List<ServiceResource> expProviders;
        List<Id> providerUserIds = new List<Id>();
        System.runAs(VAVET_ADMIN_USER) {
            expProviders = [SELECT Id, RelatedRecordId FROM ServiceResource];
            providerUserIds.add(expProviders.get(0).RelatedRecordId);
            expProviders.get(0).RelatedRecordId = UserInfo.getUserId();
            update expProviders;
        }
        VCR_ServiceResourceRepo testRepo = new VCR_ServiceResourceRepo();
        Test.startTest();
        List<ServiceResource> foundProviders;
        System.runAs(VAVET_ADMIN_USER) {
            foundProviders = testRepo.fetchServiceResourcesForMPsByUserId(providerUserIds);
        }
        Test.stopTest();
        Assert.areEqual(
            0,
            foundProviders.size(),
            'Expected fetchServiceResourcesForMPsByUserId to return empty list, not null, when no matching ServiceResources found.'
        );
    }
}
