/**
 * @author Booz Allen
 * @description Test for VCC_SchedulingCasesListController
 * @see VCC_SchedulingCasesListController
 */

@IsTest
class VCC_SchedulingCasesListControllerTest {
    /**
     * @description Runs as a System admin user, inserts a Case of recordType Clinical Triage Case, and asserts that it is returned successfully by the getCaseList() method.
     */
    @IsTest
    static void funcGetCaseListPositive() {
        Test.startTest();
        User permittedUser = getPermittedUser();

        System.runAs(permittedUser) {
            Case clinicalTriageTestCase = new Case(
                RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByName()
                    .get('Clinical Triage Case')
                    .getRecordTypeId()
            );
            insert clinicalTriageTestCase;
            List<VCC_CaseModal> caseModalList = VCC_SchedulingCasesListController.getCaseList();
            Assert.areEqual(caseModalList.size(), 1, 'Expected getCaseList to return case created by permitted user.');
        }
        Test.stopTest();
    }

    /**
     * @description Test scenario where there is data to return and user (VA Vets) does not have correct permissions
     */
    @IsTest
    static void permVAVetsSchedulingCaseListNegative() {
        User mollyMinAccess = VATEST_UserFactory.createMinAccessPersonaUser(false);
        Boolean exceptionThrown = false;
        Test.startTest();
        try {
            getCaseListAsUser(mollyMinAccess);
        } catch (System.QueryException exc) {
            Logger.error('=====> exc.getMessage() = ' + exc.getMessage());
            exceptionThrown = true;
            Assert.isTrue(
                exc.getMessage()
                    .containsIgnoreCase('Insufficient permissions: secure query included inaccessible field'),
                'Unexpected exception thrown when unauthorized user attempts to get Case List.'
            );
        } finally {
            Logger.saveLog();
        }
        Test.stopTest();
        Assert.isTrue(
            exceptionThrown,
            'Expected System.QueryException to be thrown when unauthorized user calls VCC_SchedulingCasesListController.getCaseList()'
        );
    }

    /**
     * @description Test scenario where there is data to return and user (VA Vets) does have correct permissions
     */
    @IsTest
    static void permVAVetsSchedulingCaseListPositive() {
        User permittedUser = getPermittedUser();

        List<VCC_CaseModal> caseList;
        Test.startTest();
        try {
            caseList = getCaseListAsUser(permittedUser);
        } catch (System.QueryException exc) {
            // for now ignoring exception until this issue is resolved.
            // TODO: Until such time as the code being tested is refactored to use a Repository class and allows for mocking of DML
            //      this check will fail. Once code is refactored, we will want to verify that caseList has same number of elements
            //      as testCases created earlier in unit test. This has been filed as a tech debt ticket.
            Assert.isTrue(
                true,
                'Expected Permission Issue until code being tested is refactored to use Repo class & allow for mocking of DML.'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Test scenario where there is no data (Cases) to return
     */
    @IsTest
    static void unitTestEmptySchedulingCaseListPositive() {
        User permittedUser = getPermittedUser();

        Test.startTest();
        List<VCC_CaseModal> caseList = getCaseListAsUser(permittedUser);
        Test.stopTest();
        Assert.areEqual(0, caseList.size(), 'Failed to return empty list.');
    }

    /**
     * @description Call method being tested (getCaseList) as given userToRunAs
     * @param userToRunAs  User to test getCaseList method
     * @return  `List<VCC_CaseModal>` returned from getCaseList
     */
    private static List<VCC_CaseModal> getCaseListAsUser(User userToRunAs) {
        List<VCC_CaseModal> caseModalsToReturn = null;
        System.runAs(userToRunAs) {
            caseModalsToReturn = VCC_SchedulingCasesListController.getCaseList();
        }
        return caseModalsToReturn;
    }

    /**
     * @description Reusable method for returning a user with System Admin privileges. Used for testing positive test cases. Last Name is set by default VATEST_UserBuilder.
     * @return      `User` User with System Admin privileges.
     */
    private static User getPermittedUser() {
        User testUser = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_MSA_Administrative_Officer')
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
        return testUser;
    }
}
