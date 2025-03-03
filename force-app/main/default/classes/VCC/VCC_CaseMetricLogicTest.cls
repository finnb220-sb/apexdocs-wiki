/**
 * @description this is the test class for VCC_CaseMetricLogic
 * @author Booz-Allen
 * @see VCC_CaseMetricLogic
 */
@IsTest
public with sharing class VCC_CaseMetricLogicTest {
    //test reference constants
    private static final String VCC_REPORTING = 'VCC_Reporting';
    private static final String DEVELOPER_NAME_ID = VCC_Case_Metrics__c.SObjectType.getDescribe(
            SObjectDescribeOptions.DEFERRED
        )
        .getRecordTypeInfosByDeveloperName()
        .get(VCC_REPORTING)
        .getRecordTypeId();
    private static final Set<String> PERMISSION_SETS = new Set<String>{
        'VAHC_Standard_VCC_User',
        'VCC_DisableCaseMetricTrigger'
    };
    private static final List<String> DEVELOPER_NAMES = new List<String>{
        'VCC_Administrative',
        'VCC_Clinical_Triage',
        'VCC_Vitrual_Clinic_Visit'
    };
    private static final User ADMIN_USER;

    @TestVisible
    private static final Group testGroup {
        get {
            return testGroup = testGroup ??
                (Group) VATEST_SObjectFactory.createSObject(
                    new Group(DeveloperName = 'Fluffy_Bunny', Name = 'Fluffy_Bunny', Type = 'Queue'),
                    true
                );
        }
    }

    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSION_SETS)
            .withStandardData()
            .build(true);
        ADMIN_USER.Division = '914';
        update ADMIN_USER;
    }
    private static List<Case> testCases {
        get {
            return testCases = testCases ??
                [
                    SELECT
                        Id,
                        OwnerId,
                        Subject,
                        TYPEOF Owner
                            WHEN User THEN Name, Division
                            WHEN Group THEN DeveloperName
                        END
                    FROM Case
                    WHERE Subject = 'testCases'
                    LIMIT 5
                ];
        }
        private set;
    }
    private static Case groupTestCase {
        get {
            return groupTestCase = groupTestCase ??
                [
                    SELECT
                        Id,
                        OwnerId,
                        Subject,
                        TYPEOF Owner
                            WHEN User THEN Name, Division
                            WHEN Group THEN DeveloperName
                        END
                    FROM Case
                    WHERE Subject = 'testGroupCase'
                    LIMIT 1
                ];
        }
        private set;
    }
    private static User testProvider {
        get {
            return testProvider = testProvider ??
                [
                    SELECT Id, Name, LastName, Username, Email, Division
                    FROM User
                    WHERE LastName = 'last'
                    LIMIT 1
                ];
        }
        private set;
    }

    private static Case userTestCase {
        get {
            return userTestCase = userTestCase ??
                [
                    SELECT
                        Id,
                        OwnerId,
                        Subject,
                        TYPEOF Owner
                            WHEN User THEN Name, Division
                            WHEN Group THEN DeveloperName
                        END
                    FROM Case
                    WHERE Subject = 'testUserCase'
                    LIMIT 1
                ];
        }
        private set;
    }
    /**
     * @description Setup method to create the necessary data for the test class
     */
    @TestSetup
    private static void createTestData() {
        VATEST_SObjectFactory.createSObject(new QueueSobject(QueueId = testGroup.Id, SobjectType = 'Case'), true);
        User testProvider;
        User runningUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        System.runAs(runningUser) {
            testProvider = createTestUser();
        }
        System.runAs(ADMIN_USER) {
            Id vccAdministrativeCaseRecordTypeId = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Case' AND DeveloperName = 'VCC_Administrative'
            ]
            .Id;
            //unit test data for getRecordVISNName
            groupTestCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    OwnerId = testGroup.Id,
                    Subject = 'testGroupCase',
                    RecordTypeId = vccAdministrativeCaseRecordTypeId
                ),
                true
            );
            userTestCase = (Case) VATEST_SObjectFactory.createSObject(
                new Case(
                    OwnerId = testProvider.Id,
                    Subject = 'testUserCase',
                    RecordTypeId = vccAdministrativeCaseRecordTypeId
                ),
                true
            );
            testCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(
                    OwnerId = testProvider.Id,
                    Subject = 'testCases',
                    RecordTypeId = vccAdministrativeCaseRecordTypeId
                ),
                5,
                true
            );
        }
    }
    private static User createTestUser() {
        System.runAs(ADMIN_USER) {
            testProvider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            testProvider.Division = 'testDiv';
            update testProvider;
        }
        return testProvider;
    }
    /**
     * @description this test method tests the constructor of VCR_CaseMetricRepo
     * Positive test case
     * @see VCR_CaseMetricRepo
     */
    @IsTest
    static void unitTestVCRCaseMetricRepoPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseMetricRepo caseRepo;
            Test.startTest();
            caseRepo = new VCR_CaseMetricRepo();
            Test.stopTest();
            Assert.isNotNull(caseRepo, 'VCC_CaseMetricLogic instance is null, expected not null');
        }
    }
    /**
     * @description this test method tests the constructor of VCR_CaseRepo
     * Positive test case
     * @see VCR_CaseRepo
     */
    @IsTest
    static void unitTestVCRCaseRepoPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseMetricRepo metricRepo;
            Test.startTest();
            metricRepo = new VCR_CaseMetricRepo();
            Test.stopTest();
            Assert.isNotNull(metricRepo, 'VCC_CaseMetricLogic instance is null, expected not null');
        }
    }
    /**
     * @description this test method tests the constructor of VCC_CaseMetricLogic
     * Positive test case
     * @see VCC_CaseMetricLogic
     */
    @IsTest
    static void unitTestVCCCaseMetricLogicConstructorPositive() {
        System.runAs(ADMIN_USER) {
            VCC_CaseMetricLogic vccCaseMetricLogic;
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            Test.stopTest();
            Assert.isNotNull(vccCaseMetricLogic, 'VCC_CaseMetricLogic instance is null, expected not null');
        }
    }
    /**
     * @description test method for getBindVariables
     * Positive test case
     * @see VCC_CaseMetricLogic.getBindVariables
     */
    @IsTest
    static void unitTestGetBindVariablesPositive() {
        System.runAs(ADMIN_USER) {
            Map<String, Object> expected = new Map<String, Object>{ 'developerNames' => DEVELOPER_NAMES };
            Map<String, Object> result;
            VCC_CaseMetricLogic vccCaseMetricLogic;
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            result = vccCaseMetricLogic.getBindVariables();
            Test.stopTest();
            Assert.areEqual(
                expected,
                result,
                'Expected the getBindVariables method to return a non-null map that matches the expected map'
            );
        }
    }
    /**
     * @description test method for getRecordTypeId
     * Positive test case
     * @see VCC_CaseMetricLogic.getRecordTypeId
     */
    @IsTest
    static void unitTestGetRecordTypeIdPositive() {
        System.runAs(ADMIN_USER) {
            VCC_CaseMetricLogic vccCaseMetricLogic;
            String result;
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            result = VCC_CaseMetricLogic.getRecordTypeId();
            Test.stopTest();
            Assert.areEqual(DEVELOPER_NAME_ID, result, 'Expected the record type id to be VCC_Administrative');
        }
    }
    /**
     * @description test method for getRecordVISNName
     * Positive test case
     * @see VCC_CaseMetricLogic.getRecordVISNName
     * User is the owner
     */
    @IsTest
    static void unitTestGetRecordVISNNameUserPositive() {
        System.runAs(ADMIN_USER) {
            VCC_CaseMetricLogic vccCaseMetricLogic;
            String result;
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            result = vccCaseMetricLogic.getRecordVISNName(userTestCase);
            Test.stopTest();
            Assert.areEqual('testDiv', result, 'Expected the record VISN name to be the division of the owner');
        }
    }
    /**
     * @description test method for getRecordVISNName
     * Positive test case
     * @see VCC_CaseMetricLogic.getRecordVISNName
     * Group is the owner
     */
    @IsTest
    static void unitTestGetRecordVISNNameGroupPositive() {
        System.runAs(ADMIN_USER) {
            VCC_CaseMetricLogic vccCaseMetricLogic;
            String result;
            VCC_Queue_Mapping__mdt overridenQueueMapping = new VCC_Queue_Mapping__mdt(
                DeveloperName = 'Fluffy_Bunny',
                VCC_VISN_Name__c = 'VISN 8'
            );
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            vccCaseMetricLogic.devNameToQueueMapping = new Map<String, VCC_Queue_Mapping__mdt>{
                'Fluffy_Bunny' => overridenQueueMapping
            };
            result = vccCaseMetricLogic.getRecordVISNName(groupTestCase);
            Test.stopTest();
            Assert.areEqual('VISN 8', result, 'Expected the record VISN name to be the division of the owner');
        }
    }
    /**
     * @description test method for getRecordVISNName
     * Negative test case
     * @see VCC_CaseMetricLogic.getRecordVISNName
     * Case is null
     */
    @IsTest
    static void unitTestGetRecordVISNNameNegative() {
        System.runAs(ADMIN_USER) {
            Boolean isExceptionThrown = false;
            VCC_CaseMetricLogic vccCaseMetricLogic;
            String result;
            Test.startTest();
            try {
                vccCaseMetricLogic = new VCC_CaseMetricLogic();
                result = vccCaseMetricLogic.getRecordVISNName(null);
            } catch (NullPointerException nullPointerException) {
                //Exception is expected
                isExceptionThrown = true;
            }

            Test.stopTest();
            Assert.isTrue(isExceptionThrown, 'Expected an exception to be thrown when the case is null');
        }
    }
    /**
     * @description this test method tests the generateCaseMetrics method of VCC_CaseMetricLogic
     * Positive test case
     * @see VCC_CaseMetricLogic.generateCaseMetrics
     */
    @IsTest
    static void unitTestGenerateCaseMetricsPositive() {
        System.runAs(ADMIN_USER) {
            VCC_Case_Metrics__c caseMetricResult;
            VCC_CaseMetricLogic vccCaseMetricLogic;
            Test.startTest();
            vccCaseMetricLogic = new VCC_CaseMetricLogic();
            caseMetricResult = vccCaseMetricLogic.generateCaseMetrics(userTestCase);
            Test.stopTest();
            Assert.areEqual(
                caseMetricResult.VCC_Case__c,
                userTestCase.Id,
                'Expected the case metric to have the same case id as the case'
            );
        }
    }
    /**
     * @description this test method tests the generateCaseMetrics method of VCC_CaseMetricLogic
     * Negative test case
     * @see VCC_CaseMetricLogic.generateCaseMetrics
     */
    @IsTest
    static void unitTestGenerateCaseMetricsNegative() {
        System.runAs(ADMIN_USER) {
            Boolean isExceptionThrown = false;
            VCC_CaseMetricLogic vccCaseMetricLogic;
            VCC_Case_Metrics__c caseMetricResult;
            Test.startTest();
            try {
                vccCaseMetricLogic = new VCC_CaseMetricLogic();
                caseMetricResult = vccCaseMetricLogic.generateCaseMetrics(null);
            } catch (NullPointerException nullPointerException) {
                //Exception is expected
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isTrue(isExceptionThrown, 'Expected an exception to be thrown when the case is null');
        }
    }
    /**
     * @description this test method tests the getQueryLocator method of VCC_CaseMetricLogic
     * Positive test case
     * @see VCC_CaseMetricLogic.getQueryLocator
     */
    @IsTest
    static void funcTestGetQueryLocatorPositive() {
        System.runAs(ADMIN_USER) {
            Database.QueryLocator result;
            Test.startTest();
            VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
            result = vccCaseMetricLogic.getQueryLocator(vccCaseMetricLogic.getQueryLocatorString());
            Test.stopTest();
            Assert.isNotNull(result, 'the query locator is null, expected not null');
        }
    }
    /**
     * @description this test method tests the getQueryLocator method of VCC_CaseMetricLogic
     * Negative test case
     * @see VCC_CaseMetricLogic.getQueryLocator
     */
    @IsTest
    static void funcTestGetQueryLocatorNegativeNullQuery() {
        System.runAs(ADMIN_USER) {
            Database.QueryLocator result;
            Test.startTest();
            try {
                VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
                result = vccCaseMetricLogic.getQueryLocator(null);
            } catch (Exception exc) {
                //Exception is not expected
                Assert.fail('Expected no exception to be thrown when the query is null');
            }
            Test.stopTest();
            Assert.isNull(result, 'the query locator is not null, expected null');
        }
    }
    /**
     * @description this test method tests the execute method of VCC_CaseMetricLogic
     * Positive test case
     * Should produce a case metric record for each case
     * @see VCC_CaseMetricLogic.execute
     */
    @IsTest
    static void funcTestExecutePositive() {
        System.runAs(ADMIN_USER) {
            String adminRecordId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Administrative')
                .getRecordTypeId();
            String clinicalRecordId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            List<Case> parentCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(RecordTypeId = adminRecordId),
                5,
                true
            );
            List<Case> cases = new List<Case>();
            for (Case parentCase : parentCases) {
                cases.add(
                    (Case) VATEST_SObjectFactory.createSObject(
                        new Case(ParentId = parentCase.Id, OwnerId = provider.Id, RecordTypeId = clinicalRecordId),
                        true
                    )
                );
            }
            List<Case> scope = [
                SELECT
                    CreatedDate,
                    Id,
                    ParentId,
                    RecordTypeId,
                    OwnerId,
                    TYPEOF Owner
                        WHEN User THEN Name, Division
                        WHEN Group THEN DeveloperName
                    END,
                    (
                        SELECT
                            CreatedDate,
                            Id,
                            ParentId,
                            RecordTypeId,
                            OwnerId,
                            TYPEOF Owner
                                WHEN User THEN Name, Division
                                WHEN Group THEN DeveloperName
                            END
                        FROM Cases
                    ),
                    (
                        SELECT
                            Id,
                            VCC_Case__c,
                            VCC_VISN__c,
                            VCC_Child_Case__c,
                            RecordTypeId,
                            VCC_Child_Case_Record_Type__c
                        FROM Case_Metrics__r
                    )
                FROM Case
                WHERE
                    RecordType.DeveloperName = 'VCC_Administrative'
                    OR RecordType.DeveloperName = 'VCC_Clinical_Triage'
                ORDER BY CreatedDate ASC
            ];
            Test.startTest();
            VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
            vccCaseMetricLogic.execute(scope);
            Test.stopTest();
            List<VCC_Case_Metrics__c> caseMetrics = [
                SELECT Id, VCC_Case__c
                FROM VCC_Case_Metrics__c
                WHERE VCC_Case__c IN :cases
            ];
            for (Integer count = 0; count < cases.size(); count++) {
                Assert.areEqual(
                    cases[count].Id,
                    caseMetrics[count].VCC_Case__c,
                    'Expected the cases that were inserted to have a corresponding case metric record'
                );
            }
        }
    }

    ///////////////// APEX TESTS DEFINED BY QA TEAM /////////////////

    /**
     * @description this is 'common core' test data setup for the QA Team Tests
     * @return `List<Case>` Returns a list of Scheduling cases that were generated.
     */
    private static List<Case> generate5SchedulingCases() {
        List<Case> resultingCases;
        System.runAs(ADMIN_USER) {
            Id schedulingRecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Administrative')
                .getRecordTypeId();

            resultingCases = VATEST_SObjectFactory.createSObjects(
                new Case(
                    RecordTypeId = schedulingRecordTypeId,
                    Subject = 'scheduling case',
                    VCC_Follow_Up_Appt_Needed__c = 'Within 8 hours'
                ),
                5,
                true
            );
        }

        resultingCases = [
            SELECT
                Id,
                OwnerId,
                TYPEOF Owner
                    WHEN User THEN Name, Division
                    WHEN Group THEN DeveloperName
                END
            FROM Case
            WHERE Id IN :resultingCases
        ];
        return resultingCases;
    }

    /**
     * @description This test incorporates part of CCCCM-33707
     */
    @IsTest
    static void funcPreconditionsAreMetPositive() {
        generate5SchedulingCases();
        System.runAs(ADMIN_USER) {
            List<Case> preExistingCases = [
                SELECT Id
                FROM Case
                WHERE Subject = 'scheduling case'
            ];
            Assert.areEqual(5, preExistingCases.size(), 'Expected 5 cases to be created');
        }
    }

    /**
     * @description This test is CCCM-33707
     */
    @IsTest
    static void funcBatchGenerationOfCaseMetricObjectsPositive() {
        // given 12 scheduling cases. 5 created next and 7 created in the test setup.
        generate5SchedulingCases();
        // the baseline count of historical cases is 5.
        // when the one time batch job is called to generate case metric objects
        List<VCC_Case_Metrics__c> caseMetrics;
        System.runAs(ADMIN_USER) {
            Test.startTest();
            Map<String, VCC_Queue_Mapping__mdt> devNameToQueueMapping = new Map<String, VCC_Queue_Mapping__mdt>{
                'Fluffy_Bunny' => new VCC_Queue_Mapping__mdt(
                    DeveloperName = 'Fluffy_Bunny',
                    VCC_VISN_Name__c = 'VISN 8'
                )
            };
            VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
            vccCaseMetricLogic.devNameToQueueMapping = devNameToQueueMapping;
            Database.executeBatch(new VCC_GenericBatch((ABS_BatchExecutioner) vccCaseMetricLogic));
            Test.stopTest();
            caseMetrics = [
                SELECT
                    Id,
                    VCC_Case__c,
                    VCC_VISN__c,
                    VCC_Child_Case_Record_Type__c,
                    VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c,
                    RecordTypeId
                FROM VCC_Case_Metrics__c
            ];
        }
        // then, the count of the case metric objects should be 5.
        Assert.areEqual(12, caseMetrics.size(), 'Expected 12 case metrics to be created');
        // Assert fields are populated on the case_metric object
        for (VCC_Case_Metrics__c currentCaseMetric : caseMetrics) {
            Assert.isNotNull(currentCaseMetric.VCC_VISN__c, 'Expected the VISN field to be populated');
            Assert.isNotNull(currentCaseMetric.VCC_Case__c, 'Expected the Case field to be populated');
            Assert.isNotNull(
                currentCaseMetric.VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c,
                'Expected the follow up appointment needed hr field to be populated'
            );
            Assert.isNotNull(currentCaseMetric.RecordTypeId, 'Expected the record type id field to be populated');
        }
    }

    /**
     * @description Given 5 scheduling cases that we then run the batch job multiple times on....
     * Assert that there are only ever 5 metric cases created no matter the number of times the batch job runs.
     * Assert that the VCC_VISN__c field is populated on all case metrics generated by the batch job.
     * Assert that the VCC_Case__c field is populated on all case metrics generated by the batch job.
     * Assert that the VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c field is populated on all case metrics generated by the batch job.
     * Assert that the RecordType is set on all case metrics generated by the batch job.
     */
    @IsTest
    static void funcBatchIsIdempotentPositive() {
        VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
        Database.QueryLocator queryLoc = vccCaseMetricLogic.getQueryLocator(vccCaseMetricLogic.getQueryLocatorString());
        System.runAs(ADMIN_USER) {
            vccCaseMetricLogic.execute(
                Database.queryWithBinds(
                    queryLoc.getQuery(),
                    new Map<String, Object>{ 'developerNames' => DEVELOPER_NAMES },
                    AccessLevel.USER_MODE
                )
            );
        }

        vccCaseMetricLogic = new VCC_CaseMetricLogic();
        // the baseline count of historical cases is 7. This is because test setup is creating 5 cases.
        // when the one time batch job is called a second time, the count of case metric objects should remain 5.
        List<VCC_Case_Metrics__c> caseMetrics;
        System.runAs(ADMIN_USER) {
            Test.startTest();
            Map<String, VCC_Queue_Mapping__mdt> devNameToQueueMapping = new Map<String, VCC_Queue_Mapping__mdt>{
                'Fluffy_Bunny' => new VCC_Queue_Mapping__mdt(
                    DeveloperName = 'Fluffy_Bunny',
                    VCC_VISN_Name__c = 'VISN 8'
                )
            };
            VCC_CaseMetricLogic vccCaseMetricLogic2 = new VCC_CaseMetricLogic();
            vccCaseMetricLogic2.devNameToQueueMapping = devNameToQueueMapping;
            Database.executeBatch(new VCC_GenericBatch((ABS_BatchExecutioner) vccCaseMetricLogic2));
            Test.stopTest();
            caseMetrics = [
                SELECT
                    Id,
                    VCC_Case__c,
                    VCC_VISN__c,
                    VCC_Child_Case_Record_Type__c,
                    VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c,
                    RecordTypeId
                FROM VCC_Case_Metrics__c
            ];
        }
        // then, the count of the case metric objects should be 7.
        Assert.areEqual(7, caseMetrics.size(), 'Expected 7 case metrics to be created');
        commonAssertionsAgainstGroupOfCaseMetrics(caseMetrics);
    }

    private static void commonAssertionsAgainstGroupOfCaseMetrics(List<VCC_Case_Metrics__c> caseMetrics) {
        for (VCC_Case_Metrics__c currentCaseMetric : caseMetrics) {
            Assert.isNotNull(currentCaseMetric.VCC_VISN__c, 'Expected the VISN field to be populated');
            Assert.isNotNull(currentCaseMetric.VCC_Case__c, 'Expected the Case field to be populated');
            Assert.isNotNull(
                currentCaseMetric.VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c,
                'Expected the follow up appt needed hr field to be populated'
            );
            Assert.isNotNull(currentCaseMetric.RecordTypeId, 'Expected the record type id field to be populated');
        }
    }

    /**
     * @description This test is cccm-33709
     */
    @IsTest
    static void funcMultipleExecutionsOfBatchJobOnlyEnrichDataPositive() {
        // given 7 scheduling cases
        // given that we've already created the caseMetric records
        VCC_CaseMetricLogic vccCaseMetricLogic = new VCC_CaseMetricLogic();
        Database.QueryLocator queryLoc = vccCaseMetricLogic.getQueryLocator(vccCaseMetricLogic.getQueryLocatorString());
        System.runAs(ADMIN_USER) {
            vccCaseMetricLogic.execute(
                Database.queryWithBinds(
                    queryLoc.getQuery(),
                    new Map<String, Object>{ 'developerNames' => DEVELOPER_NAMES },
                    AccessLevel.USER_MODE
                )
            );
        }
        vccCaseMetricLogic = new VCC_CaseMetricLogic();
        // Intentionally ruin the data, by stripping the VISN field off.
        List<VCC_Case_Metrics__c> updatableMetrics = new List<VCC_Case_Metrics__c>();
        for (VCC_Case_Metrics__c caseMetric : [
            SELECT Id, RecordTypeId
            FROM VCC_Case_Metrics__c
        ]) {
            caseMetric.VCC_VISN__c = null;
            updatableMetrics.add(caseMetric);
        }

        // the baseline count of historical cases is 5.
        // when the one time batch job is called a second time, the count of case metric objects should remain 5.
        List<VCC_Case_Metrics__c> caseMetrics;
        System.runAs(ADMIN_USER) {
            update updatableMetrics;
            for (VCC_Case_Metrics__c caseMetric : updatableMetrics) {
                Assert.isNull(caseMetric.VCC_VISN__c, 'Expected the VISN field to be null');
            }
            Map<String, VCC_Queue_Mapping__mdt> devNameToQueueMapping = new Map<String, VCC_Queue_Mapping__mdt>{
                'Fluffy_Bunny' => new VCC_Queue_Mapping__mdt(
                    DeveloperName = 'Fluffy_Bunny',
                    VCC_VISN_Name__c = 'VISN 8'
                )
            };
            VCC_CaseMetricLogic vccCaseMetricLogic2 = new VCC_CaseMetricLogic();
            vccCaseMetricLogic2.devNameToQueueMapping = devNameToQueueMapping;
            Test.startTest();
            Database.executeBatch(new VCC_GenericBatch((ABS_BatchExecutioner) vccCaseMetricLogic2));
            Test.stopTest();
        }
        caseMetrics = [
            SELECT
                Id,
                VCC_Case__c,
                VCC_VISN__c,
                VCC_Child_Case_Record_Type__c,
                VCC_Parent_Case_Follow_Up_Appt_Needed_Hr__c,
                RecordTypeId
            FROM VCC_Case_Metrics__c
        ];
        // then, the count of the case metric objects should be 7.
        Assert.areEqual(7, caseMetrics.size(), 'Expected 7 case metrics to be created');
        commonAssertionsAgainstGroupOfCaseMetrics(caseMetrics);
    }
}
