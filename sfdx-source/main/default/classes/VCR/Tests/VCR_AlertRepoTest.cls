/**
 * @description Tests the VCR_AlertRepo class
 * @author Booz Allen Hamilton
 *
 * @see VCR_AlertRepo for class being tested
 */
@IsTest
private with sharing class VCR_AlertRepoTest {
    @IsTest
    private static void ensureCorrectDefaultInitialization() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            Assert.isNotNull(VCR_AlertRepo.patientService, 'Expected patientService to be initialized.');
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitGetAlertReturnsValidDataWhenMockedPositive() {
        Map<String, Object> args = new Map<String, Object>{
            'application' => 'VAHC',
            'facilityId' => new List<String>{ '982' },
            'ssoToken' => 'ZYsE6NTYP5GPMo8E6tgJoQzU0ezSRptRfXzcEcPg',
            'parseAlert' => true
        };

        VCR_AlertRepo.patientService = createPatientService(args, new VTC_RecordModel());
        System.runAs(createTestUser()) {
            Test.startTest();
            VTC_RecordModel alertDataModel = new VCR_AlertRepo().fetchAlerts(args);
            Assert.isNotNull(alertDataModel, 'Expected valid non-null model to be returned.');
            Test.stopTest();
        }
    }

    private static VTC_PatientService createPatientService(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('get_alerts', args)
            .returning(returnValue)
            .defineStub();
    }

    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
