/**
 * @author Booz Allen Hamilton
 * @description VCC_Adapter_NoteToVdif wrapper.
 */
public with sharing class VCC_DASServiceParser {
    @TestVisible
    //'dumb' stubbing of VCC_Adapter_NoteToVdif
    private Boolean stubParser = true;

    /**
     * @description Repository for accessing custom sections in progress notes.
     * @type VCR_ProgressNoteCustomSectionRepo
     */
    @TestVisible
    private static VCR_ProgressNoteCustomSectionRepo progressNoteCustomSectionRepo {
        get {
            if (progressNoteCustomSectionRepo == null) {
                progressNoteCustomSectionRepo = new VCR_ProgressNoteCustomSectionRepo();
            }
            return progressNoteCustomSectionRepo;
        }
        set;
    }

    /**
     * @description Parses a progress note salesforce record into a string for transmission to VistA.
     * @param noteSObject A `VCC_Progress_Note__c` or `VCC_Addendum__c`
     * @return String
     */
    public String parse(SObject noteSObject) {
        try {
            VCC_Progress_Note_Configuration__mdt config = VCC_DAS.SERVICES.METADATA.getConfiguration(
                VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(noteSObject)
            );

            if (Test.isRunningTest() == true && stubParser == true) {
                return 'test';
            }

            return VCC_Adapter_NoteToVdif.parse(
                noteSObject,
                config,
                progressNoteCustomSectionRepo.fetchProgressNoteCustomSection(config)
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ParseException(e);
        }
    }

    public class ParseException extends VCC_DASException {
    }
}
