/*
 * @description Test class for VCC_ScheduleAppointmentHelper
 * @author Booz Allen Hamilton
 * @see VCC_ScheduleAppointmentHelper
 */
@IsTest
public class VCC_ScheduleAppointmentHelperTest {
    private static final String TESTIEN = '4';
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    /**
     * @description Test method that confirms that the generateCreateAppointmentParameters method will populate a map successfully.
     */
    @IsTest
    static void unitGenerateCreateAppointmentParametersPositive() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.clinicIEN = TESTIEN;
        apptParams.start = String.valueOf(DateTime.now());
        apptParams.xEnd = String.valueOf(DateTime.now().addHours(1));
        apptParams.apptType = 'Regular';
        apptParams.apptRequestId = 'R9848920';
        apptParams.facilityStationId = '984';
        apptParams.facilityStationName = 'DAYTSHR TEST LAB';
        apptParams.clinicName = 'DAYTSHR Clinic';
        apptParams.patientDFN = '550063856';
        apptParams.patientICN = '1015777398V425985';
        apptParams.providerIEN = '34117';
        apptParams.note = 'Test Note';
        apptParams.eligibilityOfVisit = 'Service Connected 50%';
        apptParams.timeZone = 'EASTERN';
        apptParams.duration = 60;
        Map<String, Object> createAppointmentParams;

        System.runAs(MSA_USER) {
            Test.startTest();
            createAppointmentParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(apptParams);
            Test.stopTest();
        }

        Assert.isNotNull(createAppointmentParams, 'Expected a map generated');
        Assert.areEqual('Regular', createAppointmentParams.get('apptType'), 'Expected a value for apptType');
        Assert.areEqual('984', createAppointmentParams.get('vistaSiteId'), 'Expected a value for vistaSiteId');
    }

    /**
     * @description Test method that confirms that the generateCreateAppointmentParameters method will not fully populate a map.
     */
    @IsTest
    static void unitGenerateCreateAppointmentParametersNegative() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        Map<String, Object> createAppointmentParams;

        System.runAs(MSA_USER) {
            Test.startTest();
            createAppointmentParams = VCC_ScheduleAppointmentHelper.generateAppointmentParameters(apptParams);
            Test.stopTest();
        }

        Assert.isNotNull(createAppointmentParams, 'Expected a map generated');
        Assert.areEqual(null, createAppointmentParams.get('apptType'), 'Expected a null for apptType');
    }

    /**
     * @description Test method that confirms that the generateScheduledAppointmentParameters method will populate a map successfully.
     */
    @IsTest
    static void unitGenerateScheduledAppointmentParametersPositive() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        apptParams.clinicIEN = TESTIEN;
        apptParams.start = String.valueOf(DateTime.now());
        apptParams.xEnd = String.valueOf(DateTime.now().addHours(1));
        apptParams.patientICN = '1015698358V644983';
        apptParams.patientDFN = '550063856';
        Map<String, Object> createAppointmentParams;

        System.runAs(MSA_USER) {
            Test.startTest();
            createAppointmentParams = VCC_ScheduleAppointmentHelper.generateScheduledAppointmentParameters(apptParams);
            Test.stopTest();
        }

        Assert.isNotNull(createAppointmentParams, 'Expected a map generated');
        Assert.areEqual(TESTIEN, createAppointmentParams.get('clinicIen'), 'Expected a value for clinicIen');
        Assert.areEqual(
            '1015698358V644983',
            createAppointmentParams.get('patientIcn'),
            'Expected a value for vistaSiteId'
        );
    }

    /**
     * @description Test method that confirms that the generateScheduledAppointmentParameters method will not fully populate a map.
     */
    @IsTest
    static void unitGenerateScheduledAppointmentParametersNegative() {
        VCC_ScheduleAppointmentController.AppointmentParams apptParams = new VCC_ScheduleAppointmentController.AppointmentParams();
        Map<String, Object> createAppointmentParams;

        System.runAs(MSA_USER) {
            Test.startTest();
            createAppointmentParams = VCC_ScheduleAppointmentHelper.generateScheduledAppointmentParameters(apptParams);
            Test.stopTest();
        }

        Assert.isNotNull(createAppointmentParams, 'Expected a map generated');
        Assert.areEqual(null, createAppointmentParams.get('clinicIen'), 'Did not expect a value for clinicIen');
    }
}
