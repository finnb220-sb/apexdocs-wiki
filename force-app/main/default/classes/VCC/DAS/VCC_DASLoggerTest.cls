/**
 * @description test class for VCC_DASLogger
 * @author Booz Allen Hamilton
 * @since 06/22/24
 * @see `VCC_DASLogger`
 */
@IsTest
private class VCC_DASLoggerTest {
    /**
     * @description Creating an Admin test user
     * @return `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .build(true);
    }

    @IsTest
    static void unitConstructorPositive() {
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            VCC_DASLogger dasLogger = new VCC_DASLogger();
            Assert.isTrue(dasLogger.tags.contains(VCC_DASLogger.DAS_LOGGER_TAG), 'Expected tags to contain DAS tag');
            Test.stopTest();
        }
    }
}
