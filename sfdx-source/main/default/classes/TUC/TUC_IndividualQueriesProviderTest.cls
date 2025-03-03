/**
 * @description       : Test class for TUC_IndividualQueriesProvider
 * @author            : Booz Allen Hamilton
 *
 * @see TUC_GetKanbanStrategyInterface
 * @see TUC_IndividualQueriesProvider
 **/
@IsTest
private with sharing class TUC_IndividualQueriesProviderTest {
    private static final Integer COUNT_OF_CASES_PER_STATUS = 1;
    private static final Decimal VISN_DECIMAL = 8;
    private static final User DOCTOR_USER;
    static {
        DOCTOR_USER = new VATEST_UserBuilder()
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .setFields(User.Division, 'VISN 0')
            .setFields(User.LastName, 'TheTestUser')
            .withUserProfile('VAVET Base Profile')
            .build(true);
    }

    /**
     * @description - Private instantiation of the TUC_CaseRepo
     **/
    private static final TUC_CaseRepo caseRepo {
        get {
            return caseRepo ?? new TUC_CaseRepo();
        }
    }

    /**
     * @description - Functional Test for the fetch cases method
     * @see TUC_IndividualQueriesProvider.fetchCasesForKanbanForVisns(List<Decimal> visnIds, TUC_CaseRepo repo)
     **/
    @IsTest
    private static void funcFetchCasesForKanbanForVisnsPositive() {
        System.runAs(DOCTOR_USER) {
            Map<String, List<Case>> sortedCases;

            Test.startTest();
            TUC_IndividualQueriesProvider individualStrategy = new TUC_IndividualQueriesProvider();
            individualStrategy.setConfig(caseRepo.kanbanConfig);
            sortedCases = individualStrategy.fetchCasesForKanbanForVisns(new List<Decimal>{ VISN_DECIMAL }, caseRepo);
            Test.stopTest();
            Assert.isFalse(sortedCases.isEmpty(), 'Expected the returned list to have data.');
        }
    }

    /**
     * @description - Unit testing utilizing stubbed methods
     * @see TUC_IndividualQueriesProvider.fetchCasesForKanbanForVisns(List<Decimal> visnIds, TUC_CaseRepo repo)
     **/
    @IsTest
    private static void unitFetchCasesForKanbanForVisnsStubbedPositive() {
        TUC_CaseRepo stubRepo = getFetchStubRepo();
        stubRepo.kanbanConfig = caseRepo.kanbanConfig;

        System.runAs(DOCTOR_USER) {
            Map<String, List<Case>> sortedCases;

            Test.startTest();
            TUC_IndividualQueriesProvider individualStrategy = new TUC_IndividualQueriesProvider();
            individualStrategy.setConfig(stubRepo.kanbanConfig);
            sortedCases = individualStrategy.fetchCasesForKanbanForVisns(new List<Decimal>{ VISN_DECIMAL }, stubRepo);
            Test.stopTest();
            Assert.isFalse(sortedCases.isEmpty(), 'Expected the returned map to have data.');
        }
    }

    /**
     * @description - Returns the stubRepo for unitFetchCasesForKanbanForVisnsStubbedPositive().
     * 				  This repo stub/mocking required so many different stub calls it made sense to break out
     * 				  into its own method for readability.
     * @return TUC_CaseRepo - Stubbed TUC_CaseRepo for the unit test to use.
     **/
    private static TUC_CaseRepo getFetchStubRepo() {
        List<Case> caseList = new List<Case>();
        return (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('fetchCasesSortedByWaitTime')
            .withParameterTypes(String.class)
            .withParameterValues('New')
            .returning(caseList)
            .mockingMethodCall('fetchCasesSortedByWaitTime')
            .withParameterTypes(String.class)
            .withParameterValues('Patient Call Back')
            .returning(caseList)
            .mockingMethodCall('fetchClosedCases')
            .withParameterTypes(String.class)
            .withParameterValues('Closed')
            .returning(caseList)
            .mockingMethodCall('fetchCasesByStatus')
            .withParameterTypes(String.class)
            .withParameterValues('TED Nurse Encounter')
            .returning(caseList)
            .mockingMethodCall('fetchCasesByStatus')
            .withParameterTypes(String.class)
            .withParameterValues('Ready for MP')
            .returning(caseList)
            .mockingMethodCall('fetchCasesByStatus')
            .withParameterTypes(String.class)
            .withParameterValues('TED MP Encounter')
            .returning(caseList)
            .defineStub();
    }

    /**
     * @description - Tests that the fetch method handles a null decimal input as expected
     **/
    @IsTest
    private static void unitFetchCasesForKanbanForVisnsNullNegative() {
        System.runAs(DOCTOR_USER) {
            Map<String, List<Case>> sortedCases;

            Test.startTest();
            TUC_IndividualQueriesProvider individualStrategy = new TUC_IndividualQueriesProvider();
            sortedCases = individualStrategy.fetchCasesForKanbanForVisns(null, caseRepo);
            Test.stopTest();
            Assert.areEqual(0, sortedCases.size(), 'Expected a returned list size of 0 but was ' + sortedCases.size());
        }
    }

    /**
     * @description - Tests that the fetch method handles an empty decimal input as expected
     **/
    @IsTest
    private static void unitFetchCasesForKanbanForVisnsEmptyNegative() {
        System.runAs(DOCTOR_USER) {
            Map<String, List<Case>> sortedCases;

            Test.startTest();
            TUC_IndividualQueriesProvider individualStrategy = new TUC_IndividualQueriesProvider();
            sortedCases = individualStrategy.fetchCasesForKanbanForVisns(new List<Decimal>(), caseRepo);
            Test.stopTest();
            Assert.areEqual(0, sortedCases.size(), 'Expected a returned list size of 0 but was ' + sortedCases.size());
        }
    }
}
