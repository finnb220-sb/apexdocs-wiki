/**
 * @description Test class for VCR_CaseMetricRepo
 * @see VCR_CaseMetricRepo
 * @author BAH
 */
@IsTest
public with sharing class VCR_CaseMetricRepoTest {
    private static final Set<String> DEFAULT_FIELDS = new Set<String>{
        'CreatedById',
        'CreatedDate',
        'Id',
        'IsDeleted',
        'LastModifiedById',
        'LastModifiedDate',
        'Name',
        'RecordTypeId',
        'VCC_Case__c',
        'VCC_Child_Case__c',
        'VCC_VISN__c'
    };
    private static final User ADMIN_USER;
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withPermissionSet('VAHC_Case_Read_Only')
            .withStandardData()
            .build(true);
    }
    /**
     * @description Test method testing the initialization of the VCR_CaseMetricRepo.
     * Positive test case.
     * @see VCR_CaseMetricRepo
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseMetricRepo repo;
            Test.startTest();
            repo = new VCR_CaseMetricRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'VCR_CaseMetricRepo instance is null');
        }
    }

    /**
     * @description function test for getSelectClause
     * Positive test case.
     * @see VCR_CaseMetricRepo.getSelectClause
     */
    @IsTest
    static void unitTestGetCalculateSelectClausePositive() {
        System.runAs(ADMIN_USER) {
            String expectedSelectClause = 'SELECT ' + String.join(DEFAULT_FIELDS, ', ');
            String selectClause;
            Test.startTest();
            VCR_CaseMetricRepo repo = new VCR_CaseMetricRepo();
            selectClause = repo.getSelectClause();
            Test.stopTest();
            Assert.isNotNull(selectClause, 'Select clause is null');
            Assert.isTrue(selectClause == expectedSelectClause, 'The select clause is not as expected');
        }
    }

    /**
     * @description function test for fetchCaseMetricById
     * Test case that (inserts case metrics) for setup and fetches them by Id.
     * Expected to return a list of case metrics based on the unique identifier passed.
     * Positive test case.
     * @see VCR_CaseMetricRepo.fetchCaseMetricById
     */
    @IsTest
    static void funcTestFetchCaseMetricByIdPositive() {
        System.runAs(ADMIN_USER) {
            List<Case> cases = (List<Case>) VATEST_SObjectFactory.createSObjects(new Case(), 5, true);
            List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();
            List<String> uniqueIdentifier = new List<String>();
            for (Integer count = 0; count < cases.size(); count++) {
                VCC_Case_Metrics__c cmMetrics = (VCC_Case_Metrics__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Case_Metrics__c(VCC_Case__c = cases[count].Id),
                    true
                );
                caseMetrics.add(cmMetrics);
                uniqueIdentifier.add(cmMetrics.Id);
            }
            Test.startTest();
            VCR_CaseMetricRepo repo = new VCR_CaseMetricRepo();
            for (Integer count = 0; count < caseMetrics.size(); count++) {
                VCC_Case_Metrics__c cmCase = repo.fetchCaseMetricById(uniqueIdentifier[count]);
                Assert.isNotNull(cmCase, 'Case Metric is null');
            }
            Test.stopTest();
            Assert.isTrue(caseMetrics.size() == 5, 'fetchByCaseMetricId should have fetched 5 records');
        }
    }

    /**
     * @description function test for fetchCaseMetricByCaseId
     * Test case that (inserts case metrics) for setup and fetches them by Case Id.
     * Expected to return a list of case metrics based on the Case Id passed.
     * Positive test case.
     * @see VCR_CaseMetricRepo.fetchCaseMetricByCaseId
     */
    @IsTest
    static void funcFetchCaseMetricsByCaseIdPositive() {
        System.runAs(ADMIN_USER) {
            List<Case> cases = (List<Case>) VATEST_SObjectFactory.createSObjects(new Case(), 5, true);
            List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();
            Set<Id> caseIds = new Set<Id>();
            for (Integer count = 0; count < cases.size(); count++) {
                VCC_Case_Metrics__c cmMetrics = (VCC_Case_Metrics__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Case_Metrics__c(VCC_Case__c = cases[count].Id),
                    true
                );
                caseMetrics.add(cmMetrics);
                caseIds.add(cmMetrics.VCC_Case__c);
            }
            Test.startTest();
            VCR_CaseMetricRepo repo = new VCR_CaseMetricRepo();
            List<VCC_Case_Metrics__c> fetchedCaseMetrics = repo.fetchCaseMetricByCaseId(caseIds);
            Test.stopTest();
            Assert.areEqual(
                caseMetrics.size(),
                fetchedCaseMetrics.size(),
                'fetchByCaseId should have fetched 5 records'
            );
        }
    }

    /**
     * @description function test for upsertCaseMetrics
     * Positive test case.
     * @see VCR_CaseMetricRepo.upsertCaseMetrics
     */
    @IsTest
    static void funcTestUpsertCaseMetricsPositive() {
        System.runAs(ADMIN_USER) {
            Integer count = 0;
            List<VCC_Case_Metrics__c> results;
            List<Case> cases = (List<Case>) VATEST_SObjectFactory.createSObjects(new Case(), 5, true);
            List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();
            for (count = 0; count < cases.size(); count++) {
                VATEST_SObjectFactory.createSObject(new VCC_Case_Metrics__c(VCC_Case__c = cases[count].Id), false);
            }
            Test.startTest();
            VCR_CaseMetricRepo repo = new VCR_CaseMetricRepo();
            repo.upsertCaseMetrics(caseMetrics);
            results = [
                SELECT Id, VCC_Case__c
                FROM VCC_Case_Metrics__c
                WHERE VCC_Case__c IN :cases
            ];
            Test.stopTest();
            count = 0;
            for (VCC_Case_Metrics__c cmMetrics : results) {
                Assert.isTrue(cmMetrics.VCC_Case__c == cases[count].Id, 'Case Metric Id is null');
                count++;
            }
        }
    }
    /**
     * @description function test for getScheduleCaseMetrics
     * Positive test case.
     * @see VCR_CaseMetricRepo.getScheduleCaseMetrics
     */
    @IsTest
    static void funcTestGetScheduleCaseMetricsPositive() {
        System.runAs(ADMIN_USER) {
            List<Case> cases = (List<Case>) VATEST_SObjectFactory.createSObjects(new Case(), 5, true);
            List<VCC_Case_Metrics__c> caseMetrics = new List<VCC_Case_Metrics__c>();
            List<Id> caseIds = new List<Id>();
            for (Integer count = 0; count < cases.size(); count++) {
                VCC_Case_Metrics__c cmMetrics = (VCC_Case_Metrics__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Case_Metrics__c(VCC_Case__c = cases[count].Id),
                    true
                );
                caseMetrics.add(cmMetrics);
                caseIds.add(cases[count].Id);
            }
            List<VCC_Case_Metrics__c> cmCase = new List<VCC_Case_Metrics__c>();
            Test.startTest();
            VCR_CaseMetricRepo repo = new VCR_CaseMetricRepo();
            cmCase = repo.getScheduleCaseMetrics(caseIds);
            Test.stopTest();
            Assert.isTrue(cmCase.size() == 5, 'getScheduleCaseMetrics should have fetched 5 records');
        }
    }
}
