/**
 * @description Repository class for retrieving custom sections of progress notes and addenda
 *              from custom metadata. This class provides methods to query and fetch custom
 *              sections based on the configuration settings defined in `VCC_Progress_Note_Configuration__mdt`.
 *
 * @author Booz Allen.
 */

public with sharing class VCR_ProgressNoteCustomSectionRepo {
    /**
     * @description Gets progress note (and addendum) custom sections from metadata.
     *
     * @param parentConfiguration `VCC_Progress_Note_Configuration__mdt` parent to the custom sections
     *
     * @return `List<VCC_Progress_Note_Custom_Section__mdt>` This metadata controls the sort of the sections
     * such as TXXC, VCC_CTNoteDisclaimer, VCC_MSANoteDisclaimer, etc.
     */
    public List<VCC_Progress_Note_Custom_Section__mdt> fetchProgressNoteCustomSection(
        VCC_Progress_Note_Configuration__mdt parentConfiguration
    ) {
        if (parentConfiguration == null) {
            throw new IllegalArgumentException('Parent Configuration cannot be null');
        }
        return [
            SELECT
                Id,
                MasterLabel,
                VCC_Display_Section_Name__c,
                VCC_Fields__c,
                VCC_Progress_Note_Configuration__c,
                VCC_Sort_Order__c
            FROM VCC_Progress_Note_Custom_Section__mdt
            WHERE VCC_Progress_Note_Configuration__c = :parentConfiguration.Id
            WITH USER_MODE
            ORDER BY VCC_Sort_Order__c ASC
        ];
    }
}
