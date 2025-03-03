/**
 * @author Booz Allen Hamilton
 * @since 5/22/24
 * @description Unit tests for VCR_AppointmentSlotConfigRepo
 * @see VCR_AppointmentSlotConfigRepo
 */
@IsTest
private class VCR_AppointmentSlotConfigRepoTest {
    private static final User VAVET_BASE_USER;
    private static final String TEST_VISN_NAME_1 = 'TEST VISN 1';
    private static final String TEST_VISN_NAME_2 = 'TEST VISN 2';
    private static final String DEFAULT_VISN_CONFIG = 'DEFAULT VISN CONFIG';

    static {
        VAVET_BASE_USER = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
    /**
     * @description Verify that we can fetch config records by VISN name correctly
     *  NOTE: This needs to be a functional test as we cannot create Custom Metadata records
     *      in Apex and we do not want to mock out the Repository as we are testing it.
     *      Mocking out the base class is not possible. Until such time as a base repository
     *      is created for mocking custom metadata, this will suffice to get code coverage.
     *      THIS REQUIRES CMTD RECORDS TO EXIST IN TEST ORG
     */
    @IsTest
    static void funcFetchRecordsPositive() {
        Test.startTest();
        VCR_AppointmentSlotConfigRepo repoInstance = new VCR_AppointmentSlotConfigRepo();
        Map<String, VCC_Appointment_Slot_Config__mdt> slotDurationsByVisnNames;
        VCC_Appointment_Slot_Config__mdt globalDefaultRecord = null;
        System.runAs(VAVET_BASE_USER) {
            slotDurationsByVisnNames = repoInstance.fetchAppointmentSlotConfigs();
            for (VCC_Appointment_Slot_Config__mdt config : slotDurationsByVisnNames.values()) {
                if (config.Is_Global_Default__c) {
                    globalDefaultRecord = config;
                    break;
                }
            }
        }
        Test.stopTest();
        Assert.isTrue(slotDurationsByVisnNames.size() >= 1, 'Expected at least one entry in resultant map');
        Assert.isNotNull(globalDefaultRecord, 'Expected a Global Default record to exist.');
        Assert.isNotNull(
            globalDefaultRecord.Appointment_Slot_Duration_in_minutes__c,
            'Expected Global Default record Slot Duration to have a non-null value.'
        );
    }
}
