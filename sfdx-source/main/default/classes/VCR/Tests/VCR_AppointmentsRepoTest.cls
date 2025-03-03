/**
 * @description Tests the VCR_AppointmentsRepo class
 * @author Booz Allen
 *
 * @see VCR_AppointmentsRepo for class being tested
 */
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveRunAs')
@IsTest
private with sharing class VCR_AppointmentsRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        Test.startTest();
        VCR_AppointmentsRepo appointmentsRepo = new VCR_AppointmentsRepo();
        Test.stopTest();

        Assert.isTrue(appointmentsRepo != null, 'Expected class to be initialized.');
        Assert.isTrue(VCR_AppointmentsRepo.patientService != null, 'Expected patientService to be initialized.');
    }

    @IsTest
    private static void unitGetAppointmentsReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_AppointmentsRepo.patientService = createPatientService(args, new VTC_DataModel());
        User vaVetUser = createTestUser();

        System.runAs(vaVetUser) {
            Test.startTest();
            VTC_DataModel appointmentsDataModel = (VTC_DataModel) new VCR_AppointmentsRepo().fetchAppointments(args);
            Assert.isTrue(appointmentsDataModel != null, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_appointments', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
