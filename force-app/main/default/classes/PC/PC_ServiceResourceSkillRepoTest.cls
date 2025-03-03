/**
 * @description test class for PC_ServiceResourceSkillRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ServiceResourceSkillRepo
 * @see         VCR_ServiceResourceSkillRepo
 */
@IsTest
private class PC_ServiceResourceSkillRepoTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    @testSetup
    private static void testSetup() {
        VATEST_UserBuilder pcTestSpecialistWithAccessBuilder = new VATEST_UserBuilder();
        pcTestSpecialistWithAccessBuilder.withPermissionSet('PrC_Specialist_Users')
            .withUserProfile('VAVET Base Profile')
            .withStandardData();
        pcTestSpecialistWithAccessBuilder.resultingUser.Division = 'VISN 1';
        pcTestSpecialistWithAccessBuilder.build(true);

        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Schema.Location location1 = (Schema.Location) VATEST_SObjectFactory.createSObject(
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

            ServiceResource serviceResource = (ServiceResource) VATEST_SObjectFactory.createSObject(
                new ServiceResource(
                    Name = ('Test Specialist ' + Datetime.now().getTime()).left(80),
                    RelatedRecordId = pcTestSpecialistWithAccessBuilder.resultingUser.Id,
                    IsActive = true,
                    ResourceType = 'A',
                    RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
                        .get('PC_Resource')
                        .getRecordTypeId(),
                    PC_Location__c = location1.Id
                ),
                true
            );

            //Skills cannot be inserted in test classes
            Skill testSkillCardio = [SELECT Id FROM Skill WHERE DeveloperName = 'PC_Cardiology' LIMIT 1];
            VATEST_SObjectFactory.createSObject(
                new ServiceResourceSkill(
                    ServiceResourceId = serviceResource.Id,
                    SkillId = testSkillCardio.Id,
                    SkillLevel = 1,
                    EffectiveStartDate = Datetime.now().addDays(-1)
                ),
                true
            );

            Skill testSkillChatChannel = [SELECT Id FROM Skill WHERE DeveloperName = 'PC_Chat' LIMIT 1];
            VATEST_SObjectFactory.createSObject(
                new ServiceResourceSkill(
                    ServiceResourceId = serviceResource.Id,
                    SkillId = testSkillChatChannel.Id,
                    SkillLevel = 1,
                    EffectiveStartDate = Datetime.now().addDays(-1)
                ),
                true
            );
        }
    }

    /**
     * @description positive test of constructor with allowUnsafe parameter set to true
     */
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        PC_ServiceResourceSkillRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_ServiceResourceSkillRepo(true);
        }
        Test.stopTest();

        Assert.isNotNull(
            repo,
            'Expected constructor to properly instantiate a PC_ServiceResourceSkillRepo class object'
        );
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=ServiceResourceSkill'),
            'Expected the SObject type to be ServiceResourceSkill'
        );
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.allowUnsafe=true'),
            'Expected the Repository\'s allowUnsafe property to be true'
        );
    }

    /**
     * @description positive test of getServiceResourceSkills that returns the service resource skills created in test setup
     */
    @IsTest
    private static void funcGetServiceResourceSkillsPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = [SELECT Id FROM ServiceResource LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkills();
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() > 0,
            'Failed to retrieve service resource skills for default skill based routing.'
        );
    }

    /**
     * @description negative test of getServiceResourceSkills that throws an exception due to the running user not having appropriate access
     */
    @IsTest
    private static void funcGetServiceResourceSkillsNegative() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getServiceResourceSkills();
            } catch (Exception forcedException) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(threwError, 'Failed to throw error during test getServiceResourceSkills method call.');
    }

    /**
     * @description positive test of getServiceResourceSkillsVISNRouting for a provided 'VISN 1' that should return only service resource skills related to that VISN
     */
    @IsTest
    private static void funcGetServiceResourceSkillsVISNRoutingPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = [SELECT Id FROM ServiceResource LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkillsVISNRouting('VISN 1');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Failed to retrieve service resource skills for VISN routing.');
    }

    /**
     * @description negative test of getServiceResourceSkillsVISNRouting that should throw an error when a null value is provided for the VISN string parameter
     */
    @IsTest
    private static void funcGetServiceResourceSkillsVISNRoutingNegative() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getServiceResourceSkillsVISNRouting(null);
            } catch (Exception forcedException) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(threwError, 'Failed to throw error during test getServiceResourceSkillsVISNRouting method call.');
    }

    /**
     * @description positive test of getServiceResourceSkillsNDTHRouting for the test location set up in test setup Cardiology as the specialty
     */
    @IsTest
    private static void funcGetServiceResourceSkillsNDTHRoutingPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        Id locId = [SELECT Id FROM Location WHERE Name = 'Test Location1' LIMIT 1].Id;

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = [SELECT Id FROM ServiceResource LIMIT 1]
                .Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkillsNDTHRouting(
                new Set<String>{ 'Cardiology' },
                new Set<Id>{ locId }
            );
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Failed to retrieve service resource skills for VISN routing.');
    }

    /**
     * @description negative test of getServiceResourceSkillsNDTHRouting that should throw an error due to null values provided as parameters
     */
    @IsTest
    private static void funcGetServiceResourceSkillsNDTHRoutingNegative() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        //user with basic access - No access to NDTH
        VATEST_UserBuilder pcTestWithoutAccessBuilder = new VATEST_UserBuilder();
        pcTestWithoutAccessBuilder.withUserProfile('VAVET Base Profile').withStandardData().build(true);

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(pcTestWithoutAccessBuilder.resultingUser) {
            try {
                testRepo.getServiceResourceSkillsNDTHRouting(null, null);
            } catch (Exception forcedException) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(threwError, 'Failed to throw error during test getServiceResourceSkillsNDTHRouting method call.');
    }

    /**
     * @description positive test running as the specialist user to ensure the getServiceResourceSkillsExcluding only returns the junction for the Cardiology skill and not the skill with the provided name, Chat
     */
    @IsTest
    private static void funcGetServiceResourceSkillsExcludingPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        ServiceResource specialistSR = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        User runAsUser = [SELECT Id FROM User WHERE ID = :specialistSR.RelatedRecordId LIMIT 1];

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

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkillsExcluding(new List<String>{ 'PC_Chat' });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() == 1, 'Failed to retrieve only specialty skills (without PC_Chat channel skill).');
    }

    /**
     * @description positive test running as the specialist user to ensure the getServiceResourceSkillsIncluding only returns the junction for the PC_Chat skill and not any other skill
     */
    @IsTest
    private static void funcGetServiceResourceSkillsIncludingPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        ServiceResource specialistSR = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        User runAsUser = [SELECT Id FROM User WHERE ID = :specialistSR.RelatedRecordId LIMIT 1];

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

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkillsIncluding(new List<String>{ 'PC_Chat' });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() == 1,
            'Failed to retrieve only channel skills (without PC_Cardiology specialty skill).'
        );
    }

    /**
     * @description positive test of getServiceResourceSkillsByLabel that should return ServiceResourceSkill created in setup related to the Cardiology skill
     */
    @IsTest
    private static void funcGetServiceResourceSkillsByLabelPositive() {
        // Test data setup
        PC_ServiceResourceSkillRepo testRepo = new PC_ServiceResourceSkillRepo();

        ServiceResource specialistSR = [SELECT Id, RelatedRecordId FROM ServiceResource LIMIT 1];
        User runAsUser = [SELECT Id FROM User WHERE ID = :specialistSR.RelatedRecordId LIMIT 1];

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

        List<ServiceResourceSkill> results;
        System.runAs(runAsUser) {
            results = testRepo.getServiceResourceSkillsByLabel('Cardiology');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(results.size() > 0, 'Failed to retrieve Cardiology specialty skill for running user.');
    }
}
