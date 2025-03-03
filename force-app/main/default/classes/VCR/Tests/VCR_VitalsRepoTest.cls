/**
 * @description Tests the VCR_vitalsRepo class
 * @author Booz Allen
 *
 * @see VCR_VitalsRepo for class being tested
 */
@IsTest
private with sharing class VCR_VitalsRepoTest {
    @IsTest
    /**
     * @description functional test method to ensure initialization was successful
     */
    private static void funcEnsureCorrectDefaultInitialization() {
        User adminUser = createTestAdminUser();
        System.runAs(adminUser) {
            Test.startTest();
            VCR_VitalsRepo vitalsRepo = new VCR_VitalsRepo();
            Assert.isTrue(vitalsRepo != null, 'Expected class to be initialized.');
            Assert.isTrue(VCR_VitalsRepo.patientService != null, 'Expected patientService to be initialized.');
            Test.stopTest();
        }

    }

    @IsTest
    /**
     * @description unit test checking that data is returned with mock data
     */
    private static void unitGetVitalsReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_VitalsRepo.patientService = mockPatientServiceStub(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            //args is the arguments to pass to the provider, in this case the fake ICN
            VTC_DataModel vitalsDataModel = (VTC_DataModel) new VCR_VitalsRepo().fetchVitals(args);
            Assert.isTrue(vitalsDataModel != null, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }
    /**
     * @description method to build VTC_PatientService stub
     * @param args The arguments to pass to the provider
     * @param returnValue the object to be returned
     * @return `VTC_PatientService`
     */
    private static VTC_PatientService mockPatientServiceStub(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_vitals', args)
            .returning(returnValue)
            .defineStub();
    }
    /**
     * @description method to create a test user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
    /**
     * @description method to create a test admin user
     * @return `User` returns a user to be used for testing
     */
    private static User createTestAdminUser() {
        return new VATEST_UserBuilder().withUserProfile('System Administrator').withStandardData().build(true);
    }
}
