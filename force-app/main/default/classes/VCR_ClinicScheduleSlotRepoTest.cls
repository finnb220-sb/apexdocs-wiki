/**
 * @description Test class for VCR_ClinicScheduleSlotRepo
 * @author Booz Allen Hamilton
 * @see VCR_ClinicScheduleSlotRepo
 */
@isTest
private class VCR_ClinicScheduleSlotRepoTest {
    final static User MSA_USER;
    final static User ADMIN;
    final static Date STARTDATE = Date.today().addMonths(-1);
    final static Date STOPDATE = Date.today().addMonths(1);
    static {
        MSA_USER = new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VAHC_Scheduling_User')
            .withPermissionSet('VTC_CHRO')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test method that confirms the VCR_ClinicScheduleSlotRepo instantiates successfully.
     */
    @IsTest
    static void unitConstructorPositive() {
        Test.startTest();
        VCR_ClinicScheduleSlotRepo repo;
        System.runAs(MSA_USER) {
            repo = new VCR_ClinicScheduleSlotRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ClinicScheduleSlotRepo');
    }
    /**
     * @description Test method that confirms that the VTC fetchTimeslots method returns an expected slot.
     */
    @IsTest
    static void funcSearchClinicSlotsPositive() {
        VTC_RecordModel stubModel = new VTC_RecordModel();
        VTC_Timeslot timeSlot = new VTC_Timeslot();
        stubModel.records.add((VTC_Record) timeSlot);
        System.runAs(MSA_USER) {
            Map<String, Object> args = new Map<String, Object>{
                'application' => 'VAHC',
                'siteId' => '958',
                'clinicIEN' => '6112',
                'includeOriginal' => true,
                'startDate' => '2024-03-01',
                'endDate' => '2024-03-01'
            };
            Test.startTest();
            VCR_ClinicScheduleSlotRepo repo = new VCR_ClinicScheduleSlotRepo();
            VCR_ClinicScheduleSlotRepo.patientService = createPatientService('get_timeslots', args, stubModel);
            stubModel = (VTC_RecordModel) repo.fetchTimeslots(args);
            Test.stopTest();
        }
        Assert.isNotNull(stubModel, 'Assertion Failed; expected stubModel to be not null');
        Assert.isNotNull(stubModel.records, 'Assertion Failed; expected records to be not null');
        Assert.isFalse(
            stubModel.records.isEmpty(),
            'Assertion failed; expected a record inside the stubModel records array'
        );
        Assert.isNotNull(stubModel.records[0].vtcId, 'Assertion failed; expected a vtcId property');
    }
    /**
     * @description       This method is used to stub the VTC_PatientService
     * @param action      The vtc endpoint to target by referencing action Name
     * @param args        The arguments for the call
     * @param returnValue The model to return
     * @return            `VTC_PatientService`
     */
    private static VTC_PatientService createPatientService(
        String action,
        Map<String, Object> args,
        Object returnValue
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(action, args)
            .returning(returnValue)
            .defineStub();
    }
}
