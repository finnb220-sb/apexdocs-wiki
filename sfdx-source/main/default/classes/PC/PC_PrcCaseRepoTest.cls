/**
 * @description Test class for PC_PrcCaseRepo.
 * @author      Booz Allen Hamilton
 * @since       2024
 * @see         PC_PrcCaseRepo
 */
@IsTest
private class PC_PrcCaseRepoTest {
    private final static User FLP_USER;
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .withPermissionSet('PC_PatientAccount_ReadWrite')
                .build(true);

            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .withPermissionSet('PC_PatientAccount_Read')
                .build(true);
        }
    }

    @testSetup
    private static void testSetup() {
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();
        System.runAs(FLP_USER) {
            VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = repo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Cardiology',
                    isRunningTest_DO_NOT_USE__c = true //this flag prevents the routing Flow from triggering
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = repo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Neurology',
                    isRunningTest_DO_NOT_USE__c = true //this flag prevents the routing Flow from triggering
                ),
                true
            );

            VATEST_SObjectFactory.createSObject(
                new PC_Case__c(
                    RecordTypeId = repo.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
                    Status__c = 'Open',
                    Channel__c = 'Chat',
                    Specialty__c = 'Gastroenterology',
                    isRunningTest_DO_NOT_USE__c = true //this flag prevents the routing Flow from triggering
                ),
                true
            );
        }
    }

    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        PC_PrcCaseRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_PrcCaseRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_PrcCaseRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=PC_Case__c'),
            'Expected the SObject type to be PrC Case'
        );
    }

    @IsTest
    private static void funcGetOpenPrcCasesOwnedByUserPositive() {
        // Test data setup
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();

        PC_Case__c pcCase = [SELECT Id, OwnerId FROM PC_Case__c LIMIT 1];
        pcCase.OwnerId = FLP_USER.Id;
        repo.doUpdate(pcCase);

        // Actual test
        Test.startTest();

        List<PC_Case__c> results;
        System.runAs(FLP_USER) {
            results = repo.getOpenPrcCasesOwnedByUser(FLP_USER.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            !results.isEmpty(),
            'getOpenPrcCasesOwnedByUser should have returned a PC Case owned by the FLP test user.'
        );
    }

    /**
     * @description Positive test for retrieval of Recently Closed Cases for a given User
     */
    @IsTest
    private static void funcGetRecentlyClosedCasesForUserPositive() {
        // Test data setup
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();

        PC_Case__c pcCase = [SELECT Id, OwnerId, Closed_Date__c, Status__c, closed__c FROM PC_Case__c LIMIT 1];

        //Setting Owner here to avoid Closed Case Validation Rule, subsequent update will fulfill intent of the test class
        pcCase.OwnerId = FLP_USER.Id;
        repo.doUpdate(pcCase);

        pcCase.Closed_Date__c = Date.today();
        repo.doUpdate(pcCase);

        // Actual test
        Test.startTest();

        List<PC_Case__c> results;
        System.runAs(FLP_USER) {
            results = repo.getRecentlyClosedCasesForUser(FLP_USER.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.isFalse(
            results.isEmpty(),
            'getRecentlyClosedCasesForUser should have returned a Closed PC Case owned by the FLP test user.'
        );
    }

    /**
     * @description Positive test for retrieval of Recently Closed Cases that do not include Training Cases for a given User
     */
    @IsTest
    private static void funcGetRecentlyClosedCasesForUserWithoutTrainingCasesPositive() {
        // Test data setup
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();

        PC_Case__c pcCase = [SELECT Id, OwnerId, Closed_Date__c, Status__c, closed__c FROM PC_Case__c LIMIT 1];

        // Adding training case
        pcCase.OwnerId = FLP_USER.Id;
        pcCase.Training_Case__c = true;
        update pcCase;

        // Actual test
        Test.startTest();

        List<PC_Case__c> results;
        System.runAs(FLP_USER) {
            results = repo.getRecentlyClosedCasesForUser(FLP_USER.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.isTrue(
            results.isEmpty(),
            'Expected the results to return empty when executing getRecentlyClosedCasesForUser because this is a training case and observed this is true.'
        );
    }

    /**
     * @description Positive test for retrieval of the oldest open PC Case for a given User
     */
    @IsTest
    private static void funcGetOldestOpenPrcCaseOwnedByUserPositive() {
        // Test data setup
        PC_PrcCaseRepo repo = new PC_PrcCaseRepo();

        List<PC_Case__c> pcCaseList = [
            SELECT Id, OwnerId, Specialty__c, CreatedDate
            FROM PC_Case__c
            WHERE Specialty__c = 'Neurology' OR Specialty__c = 'Gastroenterology'
            LIMIT 2
        ];

        for (PC_Case__c pcCase : pcCaseList) {
            Test.setCreatedDate(pcCase.Id, Date.today().addDays(-1));
            if (pcCase.Specialty__c == 'Gastroenterology') {
                pcCase.OwnerId = SPECIALIST_USER.Id;
            }
        }
        update pcCaseList;

        // Actual test
        Test.startTest();

        List<PC_Case__c> results;
        System.runAs(SPECIALIST_USER) {
            results = repo.getOldestOpenPrcCaseOwnedByUser(SPECIALIST_USER.Id);
        }

        Test.stopTest();

        // Asserts
        Assert.areEqual(results.size(), 1, 'Expected only oldest PrC Case');
        Assert.areEqual(results[0].Specialty__c, 'Gastroenterology', 'Expected pcCase');
    }
}
