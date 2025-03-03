/**
 * @description Test class for VCR_ProgressNoteCustomSectionRepo.
 * Validates custom section retrieval and error handling based on configuration metadata.
 *
 * @author Booz Allen.
 *
 * @see VCR_ProgressNoteCustomSectionRepo
 *
 */

@IsTest
private class VCR_ProgressNoteCustomSectionRepoTest {
    private static final User RN_USER;
    private static final VCC_Progress_Note_Configuration__mdt PARENT_CONFIGURATION;

    static {
        RN_USER = new VATEST_UserBuilder()
            .withPermissionSets(
                new Set<String>{ 'VAHC_Write_Clinical_Triage_Progress_Note', 'VAHC_RN_User', 'VAHC_Standard_VCC_User' }
            )
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        PARENT_CONFIGURATION = [
            SELECT Id, MasterLabel, DeveloperName
            FROM VCC_Progress_Note_Configuration__mdt
            WHERE DeveloperName = 'Clinical_Triage_Config'
            LIMIT 1
        ];
    }

    /**
     * @description Positive test for fetchProgressNoteCustomSection.
     * Verifies that custom sections are retrieved when a valid configuration is provided.
     *
     * @justification Metadata objects cannot be mocked, so this functional test ensures
     * correct behavior with live metadata.
     */
    @IsTest
    static void funcFetchProgressNoteCustomSectionPositive() {
        List<VCC_Progress_Note_Custom_Section__mdt> progressNoteCustomSections = new List<VCC_Progress_Note_Custom_Section__mdt>();
        Test.startTest();
        System.runAs(RN_USER) {
            VCR_ProgressNoteCustomSectionRepo repo = new VCR_ProgressNoteCustomSectionRepo();
            progressNoteCustomSections = repo.fetchProgressNoteCustomSection(PARENT_CONFIGURATION);
        }
        Test.stopTest();
        Assert.isTrue(progressNoteCustomSections.size() > 0, 'Expected progressNoteCustomSections to have items');
        Assert.isNotNull(
            progressNoteCustomSections[0].VCC_Display_Section_Name__c,
            'Expected first item’s Display Section Name to not be null'
        );
    }

    /**
     * @description Negative test for fetchProgressNoteCustomSection.
     * Verifies that an exception is thrown when a null configuration is passed.
     *
     * @justification Ensures the repository handles null input correctly by throwing an exception,
     * which prevents unexpected errors and improves robustness.
     */
    @IsTest
    static void funcFetchProgressNoteCustomSectionNegative() {
        Test.startTest();
        try {
            System.runAs(RN_USER) {
                VCR_ProgressNoteCustomSectionRepo repo = new VCR_ProgressNoteCustomSectionRepo();
                repo.fetchProgressNoteCustomSection(null);
                Assert.fail('Expected an IllegalArgumentException');
            }
        } catch (IllegalArgumentException exc) {
            Assert.areEqual(
                exc.getMessage(),
                'Parent Configuration cannot be null',
                'Expected the exception message to be equal'
            );
        }
        Test.stopTest();
    }
}
