/**
 * @description Tests the TUC_SupportedLocationByVISNMdtRepo class
 * @author Booz Allen
 *
 * @see TUC_SupportedLocationByVISNMdtRepo for class being tested
 *
 */
@isTest
public with sharing class TUC_SupportedLocationByVISNMdtRepoTest {
    /**
     * @description Test fetching TUC_Supported_Location_By_VISN__mdt metadata for positive result
     */
    @IsTest
    private static void unitTestgetEscalationStatusWithVisnAndQueueTypePositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(doctorUser) {
            TUC_SupportedLocationByVISNMdtRepo supportedLocationRepo = new TUC_SupportedLocationByVISNMdtRepo();
            List<TUC_Supported_Location_By_VISN__mdt> tucSupportedLocationByVISNS = new List<TUC_Supported_Location_By_VISN__mdt>();
            tucSupportedLocationByVISNS = supportedLocationRepo.getAllTUCSupportedLocationByVISNmdtRecords();

            Assert.isTrue(
                tucSupportedLocationByVISNS.size() > 0,
                'Expected records to successfully return but the returned list size was: ' +
                tucSupportedLocationByVISNS.size()
            );
        }
    }
}
