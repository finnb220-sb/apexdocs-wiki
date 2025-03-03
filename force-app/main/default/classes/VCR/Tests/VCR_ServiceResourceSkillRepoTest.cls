/**
 * @description Test class for VCR_ServiceResourceSkillRepo
 *              NOTE: Forced to create Edit Access ServiceResource Share record for test SPECIALIST_USER as the performCreateUnsafe and performDeleteUnsafe methods would fail with just Read Access.
 *                    It appears that there is a Salesforce bug surrounding inherited sharing - when calling the VCR_ServiceSkillRepo class directly from a test method, the class does not inherit sharing
 *                    The current assumption is that this is causing the repo class to instead default to "with sharing", which makes the DML operations to still consider sharing rules and the unsafe operations fail
 * @author      Booz Allen
 * @see         VCR_ServiceResourceSkillRepo
 */
@IsTest
private with sharing class VCR_ServiceResourceSkillRepoTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    private final static User PRC_MANAGER_USER;
    private final static VCR_ServiceResourceSkillRepo REPO_BEING_TESTED;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);

            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);

            PRC_MANAGER_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Manager_Users')
                .build(true);

            REPO_BEING_TESTED = new VCR_ServiceResourceSkillRepo();
        }
    }

    @TestSetup
    private static void testSetup() {
        System.runAs(PRC_MANAGER_USER) {
            Schema.Location hostLocation = (Schema.Location) VATEST_SObjectFactory.createSObject(
                new Schema.Location(
                    Name = 'Hogwarts',
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
                    RelatedRecordId = SPECIALIST_USER.Id,
                    IsActive = true,
                    ResourceType = 'A',
                    RecordTypeId = new VCR_ServiceResourceRepo().recordTypeConstant.fromDeveloperName('PC_Resource').Id,
                    PC_Location__c = hostLocation.Id
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new ServiceResourceSkill(
                    ServiceResourceId = serviceResource.Id,
                    SkillId = [SELECT Id FROM Skill WHERE DeveloperName = 'PC_Chat' LIMIT 1]
                    .Id,
                    SkillLevel = 1,
                    EffectiveStartDate = Datetime.now()
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new ServiceResourceSkill(
                    ServiceResourceId = serviceResource.Id,
                    SkillId = [SELECT Id FROM Skill WHERE DeveloperName = 'PC_Cardiology' LIMIT 1]
                    .Id,
                    SkillLevel = 1,
                    EffectiveStartDate = Datetime.now()
                ),
                true
            );
        }
    }

    /**
     * @description positive test of constructor with allowUnsafe parameter defaulted to false
     */
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        VCR_ServiceResourceSkillRepo repo;
        System.runAs(SPECIALIST_USER) {
            repo = new VCR_ServiceResourceSkillRepo();
        }
        Test.stopTest();

        Assert.isNotNull(
            repo,
            'Expected constructor to properly instantiate a VCR_ServiceResourceSkillRepo class object'
        );
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=ServiceResourceSkill'),
            'Expected the SObject type to be ServiceResourceSkill'
        );
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.allowUnsafe=false'),
            'Expected the Repository\'s allowUnsafe property to be false'
        );
    }

    /**
     * @description positively test performCreateUnsafe with successful insert
     */
    @IsTest
    private static void funcPerformCreateUnsafePositive() {
        // Test data setup
        VCR_ServiceResourceSkillRepo repo = new VCR_ServiceResourceSkillRepo(true);

        //Skills cannot be inserted in test classes
        Skill skillToAdd = [SELECT Id FROM Skill WHERE DeveloperName = 'PC_Phone' LIMIT 1];

        ServiceResource serviceResource = [SELECT Id FROM ServiceResource LIMIT 1];

        //NOTE: forced to give AccessLevel of Edit instead of Read, because the VCR_ServiceResourceSkillRepo is inheriting "with sharing" even when the test class is specified as "without sharing"
        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = serviceResource.Id,
                UserOrGroupId = SPECIALIST_USER.Id,
                RowCause = 'Manual',
                AccessLevel = 'Edit'
            ),
            true
        );

        //create ServiceResourceSkill for unsafe doCreate
        ServiceResourceSkill srsToInsert = new ServiceResourceSkill(
            ServiceResourceId = serviceResource.Id,
            SkillId = skillToAdd.Id,
            SkillLevel = 1,
            EffectiveStartDate = Datetime.now()
        );

        // Actual test
        Test.startTest();

        System.runAs(SPECIALIST_USER) {
            repo.performCreateUnsafe(new List<ServiceResourceSkill>{ srsToInsert });
        }

        Test.stopTest();

        // Asserts
        Assert.isFalse(
            [
                    SELECT Id
                    FROM ServiceResourceSkill
                    WHERE ServiceResourceId = :serviceResource.Id AND SkillId = :skillToAdd.Id
                    LIMIT 1
                ]
                .isEmpty(),
            'Expected a ServiceResourceSkill record to be created.'
        );
    }

    /**
     * @description negatively test performCreateUnsafe with failing insert due to missing required fields
     */
    @IsTest
    private static void funcPerformCreateUnsafeNegative() {
        // Test data setup
        VCR_ServiceResourceSkillRepo repo = new VCR_ServiceResourceSkillRepo(true);

        //create ServiceResourceSkill for unsafe doCreate
        ServiceResourceSkill srsToInsert = new ServiceResourceSkill(
            ServiceResourceId = null,
            SkillId = null,
            SkillLevel = null,
            EffectiveStartDate = null
        );

        // Actual test
        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            try {
                repo.performCreateUnsafe(new List<ServiceResourceSkill>{ srsToInsert });
                Assert.fail('Expected an exception to be thrown due to missing required fields.');
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            caughtExceptionMessage.containsIgnoreCase('REQUIRED_FIELD_MISSING'),
            'Expected an exception to be caught due to missing required fields.'
        );
    }

    /**
     * @description positively test performDeleteUnsafe with successful delete
     */
    @IsTest
    private static void funcPerformDeleteUnsafePositive() {
        // Test data setup
        VCR_ServiceResourceSkillRepo repo = new VCR_ServiceResourceSkillRepo(true);

        ServiceResourceSkill serviceResourceToDelete = [
            SELECT Id, ServiceResourceId
            FROM ServiceResourceSkill
            WHERE Skill.DeveloperName = 'PC_Chat'
        ];

        //NOTE: forced to give AccessLevel of Edit instead of Read, because the VCR_ServiceResourceSkillRepo is inheriting "with sharing" even when the test class is specified as "without sharing"
        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = serviceResourceToDelete.ServiceResourceId,
                UserOrGroupId = SPECIALIST_USER.Id,
                RowCause = 'Manual',
                AccessLevel = 'Edit'
            ),
            true
        );

        // Actual test
        Test.startTest();

        System.runAs(SPECIALIST_USER) {
            repo.performDeleteUnsafe(new List<ServiceResourceSkill>{ serviceResourceToDelete });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            [SELECT Id FROM ServiceResourceSkill WHERE Skill.DeveloperName = 'PC_Chat'].isEmpty(),
            'Expected the ServiceResourceSkill for PC_Chat to be deleted.'
        );
    }

    /**
     * @description negatively test performDeleteUnsafe with failing delete due to the ServiceResourceSkill not having a real Id
     */
    @IsTest
    private static void funcPerformDeleteUnsafeNegative() {
        // Test data setup
        VCR_ServiceResourceSkillRepo repo = new VCR_ServiceResourceSkillRepo(true);

        //create ServiceResourceSkill without a real Id for attempted deletion
        ServiceResourceSkill srsToDelete = new ServiceResourceSkill(
            Id = VATEST_IdFactory.get(Schema.ServiceResourceSkill.getSObjectType())
        );

        // Actual test
        Test.startTest();

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            try {
                repo.performDeleteUnsafe(new List<ServiceResourceSkill>{ srsToDelete });
                Assert.fail(
                    'Expected an exception to be thrown due to the ServiceResourceSkill record not having a real salesforce Id'
                );
            } catch (PC_CustomException caughtException) {
                caughtExceptionMessage = caughtException.getMessage();
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            caughtExceptionMessage.containsIgnoreCase('INVALID_CROSS_REFERENCE_KEY'),
            'Expected an exception to be caught due to the ServiceResourceSkill record not having a real salesforce Id'
        );
    }

    /**
     * @description positive test of getServiceResourceSkillsApplicableToNDTHRoutingCriteria method that should return the Cardiologist's service resource skill junction
     */
    @IsTest
    private static void funcGetServiceResourceSkillsApplicableToNDTHRoutingCriteriaPositive() {
        // Test data setup
        Schema.Location hogwarts = [SELECT Id FROM Location WHERE Name = 'Hogwarts' LIMIT 1][0];
        ServiceResource testSpecialist = [
            SELECT Id, RelatedRecordId
            FROM ServiceResource
            WHERE PC_Location__c = :hogwarts.Id
            LIMIT 1
        ];

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new ServiceResourceShare(
                ParentId = testSpecialist.Id,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<ServiceResourceSkill> resultList;
        System.runAs(runAsUser) {
            resultList = REPO_BEING_TESTED.getServiceResourceSkillsApplicableToNDTHRoutingCriteria(
                'Cardiology',
                new Set<Id>{ hogwarts.Id },
                new Set<Id>{ testSpecialist.RelatedRecordId }
            );
        }
        Test.stopTest();

        // Asserts
        Assert.areEqual(resultList.size(), 1, 'Expected 1 Service Resource Skill record to be returned.');
        Assert.areEqual(
            resultList[0].ServiceResourceId,
            testSpecialist.Id,
            'Expected the Test Cardiology Specialist service resource skill junction record to be returned.'
        );
    }
}
