/**
 * @description Tests the TUC_KanbanConfigMdtRepo class
 * @author Booz Allen Hamilton
 *
 * @see TUC_KanbanConfigMdtRepo for class being tested
 *
 */
@isTest
private with sharing class TUC_KanbanConfigMdtRepoTest {
    private static final String CONTROLLING_METADATA_DEVELOPER_NAME = 'Available_Cases_By_VISN';
    private static final String DOCTOR_PERM_SET_NAME = 'TED_Medical_Provider_Group';
    private static final String VAVET_BASE_PROFILE_NAME = 'VAVET Base Profile';

    /**
     * @description - Private instantiation of the TUC_KanbanConfigMdtRepo
     */
    private static final TUC_KanbanConfigMdtRepo kanbanRepo {
        get {
            return kanbanRepo ?? new TUC_KanbanConfigMdtRepo();
        }
    }

    /**
     * @description Test fetching TUC_Supported_Location_By_VISN__mdt metadata for positive result
     */
    @IsTest
    private static void unitFetchControllingMetadataRecordPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_Kanban_Config__mdt defaultMetadata = TUC_Kanban_Config__mdt.getInstance(
                CONTROLLING_METADATA_DEVELOPER_NAME
            );
            TUC_Kanban_Config__mdt retrievedMetadata = kanbanRepo.fetchControllingMetadataRecord(
                CONTROLLING_METADATA_DEVELOPER_NAME
            );
            Assert.areEqual(defaultMetadata.Id, retrievedMetadata.Id, 'Expected Config metadata to match');
        }
    }

    /**
     * @description Test fetch for nonexistant-input negative result
     */
    @IsTest
    private static void unitFetchControllingMetadataRecordWrongNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_Kanban_Config__mdt retrievedMetadata = kanbanRepo.fetchControllingMetadataRecord('Nonexistant_Entry');
            Assert.isNull(retrievedMetadata, 'Expected a null return from a non-existant input');
        }
    }

    /**
     * @description Test fetch for empty-input negative result
     */
    @IsTest
    private static void unitFetchControllingMetadataRecordEmptyNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_Kanban_Config__mdt retrievedMetadata = kanbanRepo.fetchControllingMetadataRecord('');
            Assert.isNull(retrievedMetadata, 'Expected a null return from an empty input');
        }
    }

    /**
     * @description Test fetch for null-input negative result
     */
    @IsTest
    private static void unitFetchControllingMetadataRecordNullNegative() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User doctorUser = builder.withPermissionSet(DOCTOR_PERM_SET_NAME)
            .withUserProfile(VAVET_BASE_PROFILE_NAME)
            .withStandardData()
            .build(true);
        System.runAs(doctorUser) {
            TUC_Kanban_Config__mdt retrievedMetadata = kanbanRepo.fetchControllingMetadataRecord(null);
            Assert.isNull(retrievedMetadata, 'Expected a null return from a null input');
        }
    }
}
