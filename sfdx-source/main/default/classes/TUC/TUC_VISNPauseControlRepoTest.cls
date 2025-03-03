/**
 * @description Tests the TUC_VISNPauseControlRepo class
 * @author Booz Allen Hamilton
 *
 * @see TUC_VISNPauseControlRepo for class being tested
 *
 * NOTE: The repo being tested is a metadata repo that, while extending the VTC_BaseRepo, cannot be
 *       fully stubbed in this test class until such a time that the base repository can mock
 *       custom metadata. Functional tests are required for test coverage.
 *       This test REQUIRES TUC_VISN_Pause_Control__mdt metadata to EXIST in test orgs.
 */
@IsTest
private with sharing class TUC_VISNPauseControlRepoTest {
    /**
     * @description Test fetching TUC_VISN_Pause_Control__mdt metadata - Happy Path, getting all current metadata
     */
    @IsTest
    private static void funcGetEscalationStatusWithVisnAndQueueTypePositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(doctorUser) {
            TUC_VISNPauseControlRepo visnPauseRepo = new TUC_VISNPauseControlRepo();
            List<TUC_VISN_Pause_Control__mdt> tucVisnPauseControlRecords = new List<TUC_VISN_Pause_Control__mdt>();
            tucVisnPauseControlRecords = visnPauseRepo.getAllActiveTucVisnPauseControlRecords();

            Assert.isFalse(
                tucVisnPauseControlRecords.isEmpty(),
                'Expected records to successfully return but the returned list was empty.'
            );
        }
    }
}
