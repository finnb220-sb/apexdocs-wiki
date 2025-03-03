/**
 * @description test class for PC_NDTHClinicalServicesRepo
 * @author      Booz Allen
 * @since       2024
 * @see         PC_NDTHClinicalServicesRepo
 */
@IsTest
private with sharing class PC_NDTHClinicalServicesRepoTest {
    private final static PC_NDTHClinicalServicesRepo REPO_TO_TEST;
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs(new User(Id = UserInfo.getUserId())) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);

            REPO_TO_TEST = new PC_NDTHClinicalServicesRepo();
        }
    }

    /**
     * @description test setup for re-usable data
     */
    @testSetup
    private static void testSetup() {
        //create NDTH data
        PC_NDTH__c ndth = (PC_NDTH__c) VATEST_SObjectFactory.createSObject(
            new PC_NDTH__c(NDTH_Name__c = 'Test Telehealth Hub', Type__c = 'TOS', Is_Active__c = true),
            true
        );
        VATEST_SObjectFactory.createSObject(
            new PC_NDTH_Clinical_Services__c(NDTH__c = ndth.Id, PC_Specialty__c = 'Cardiology', Is_Active__c = true),
            true
        );
    }

    /**
     * @description positive test of getClinicalServicesFromNDTHsandSkills method
     */
    @IsTest
    private static void funcGetClinicalServicesFromNDTHsandSkillsPositive() {
        // Test data setup
        Id ndthId = [SELECT Id FROM PC_NDTH__c WHERE NDTH_Name__c = 'Test Telehealth Hub' LIMIT 1].Id;

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new PC_NDTH__Share(
                ParentId = ndthId,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        List<PC_NDTH_Clinical_Services__c> results;
        System.runAs(runAsUser) {
            results = REPO_TO_TEST.getClinicalServicesFromNDTHsandSkills(new Set<Id>{ ndthId }, 'Cardiology');
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() > 0,
            'Expected Test Telehealth Hub\'s clinical services specialties to be retrieved succesfully, but they were not.'
        );
    }

    /**
     * @description positive test of getSpecialtiesForNDTHsWithEmptyResultHandling method (and incidentally also the getSpecialtiesForNDTHs method)
     */
    @IsTest
    private static void funcGetSpecialtiesForNDTHsPositive() {
        // Test data setup
        Id ndthId = [SELECT Id FROM PC_NDTH__c WHERE NDTH_Name__c = 'Test Telehealth Hub' LIMIT 1].Id;

        User runAsUser = FLP_USER;

        VATEST_SObjectFactory.createSObject(
            new PC_NDTH__Share(
                ParentId = ndthId,
                UserOrGroupId = runAsUser.Id,
                RowCause = 'Manual',
                AccessLevel = 'Read'
            ),
            true
        );

        // Actual test
        Test.startTest();

        Set<String> results;
        System.runAs(runAsUser) {
            results = REPO_TO_TEST.getSpecialtiesForNDTHsWithEmptyResultHandling(new Set<Id>{ ndthId });
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.size() > 0 && results.contains('Cardiology'),
            'Expected Test Telehealth Hub\'s clinical services specialties to be retrieved succesfully, but they were not.'
        );
    }

    /**
     * @description negative test of the getSpecialtiesForNDTHsWithEmptyResultHandling where no results should be returned by the query causing an exception to throw
     */
    @IsTest
    private static void funcGetSpecialtiesForNDTHsNegative() {
        // Test data setup
        User runAsUser = FLP_USER;

        Id ndthId = [SELECT Id FROM PC_NDTH__c WHERE NDTH_Name__c = 'Test Telehealth Hub' LIMIT 1].Id;

        //delete all existing clinical services junctions tied to our test NDTH
        delete [SELECT ID FROM PC_NDTH_Clinical_Services__c WHERE NDTH__c = :ndthId];

        Boolean threwError = false;

        // Actual test
        Test.startTest();

        System.runAs(runAsUser) {
            try {
                REPO_TO_TEST.getSpecialtiesForNDTHsWithEmptyResultHandling(new Set<Id>{ ndthId });
            } catch (Exception caughtException) {
                threwError = true;
            }
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            threwError,
            'Expected an exception to be thrown when no clinical services junctions are returned by query in getSpecialtiesForNDTHsWithEmptyResultHandling method, but no exception was thrown.'
        );
    }
}
