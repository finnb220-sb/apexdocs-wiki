/**
 * @description Tests the VCR_DirectivesRepo class
 * @author Booz Allen
 *
 * @see VCR_DirectivesRepo for class being tested
 */
@IsTest
/**
 * @description Test Successfully initializing VTC Patient service and Directives Repo
 */
private with sharing class VCR_DirectivesRepoTest {
    @IsTest
    private static void unitInitializeRepoPositive() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCR_DirectivesRepo directivesRepo = new VCR_DirectivesRepo();
            Test.stopTest();
            Assert.isNotNull(directivesRepo, 'Expected class to be initialized.');
            Assert.isNotNull(VCR_DirectivesRepo.patientService, 'Expected patientService to be initialized.');
        }
    }

    @IsTest
    /**
     * @description Test Successfully creating a patient service and getting VTC Directives
     */
    private static void unitGetDirectivesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'testICN' };
        VCR_DirectivesRepo.patientService = createPatientService(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            VTC_DataModel directivesDataModel = (VTC_DataModel) new VCR_DirectivesRepo().getDirectives(args);
            Assert.isTrue(directivesDataModel != null, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    /**
     * @description Creates test patient service for mock callout
     * @param args `Map<String, Object>` arguments that we expect our callout to receive.
     * @param returnValue `Object` The model we are telling our mock to return.
     * @return returns a mocked instance of the VTC_Patient service.
     */
    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_notes', args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Creates a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
