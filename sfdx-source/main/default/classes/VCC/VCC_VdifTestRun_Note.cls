public with sharing class VCC_VdifTestRun_Note implements VCC_VdifQueueableCallback.Strategy {
    public VCC_VdifTestRun_Note(VCC_Test_Configuration_Data__c testPatientMetadata) {
        this.testPatientMetadata = testPatientMetadata;
    }

    @TestVisible
    private VCC_VdifTestRun_Note() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    @TestVisible
    private VCC_Test_Configuration_Data__c testPatientMetadata { get; set; }

    public void onQueueableStart(VCC_VdifQueueableCallback vdifQueueableCallback) {
        VCC_VdifNote vdifNote = vdifQueueableCallback.getVdifParameters().vdifNote;
        switch on vdifQueueableCallback.getStage() {
            when ADD_SIGNERS {
                vdifNote.additionalSigners = new List<String>{ testPatientMetadata.VCC_Additional_Signer_IEN__c };
            }
            when CREATE_ADDENDUM {
                vdifNote.noteTitleIen = this.testPatientMetadata.VCC_Addendum_IEN__c;
            }
            when WRITE_NOTE {
                vdifNote.encounterString = VCC_EncounterService.generateEncounterString(Integer.valueOf(this.testPatientMetadata.VCC_Location_IEN__c));
                vdifNote.text = this.testPatientMetadata.VCC_Note_Text__c;
                vdifNote.noteTitleIen = this.testPatientMetadata.VCC_Note_Title_IEN__c;
            }
        }
    }

    public void onException(Exception e, VCC_VdifQueueableCallback vdifQueueableCallback) {
        return;
    }

    public void onCalloutResponse(Object response, VCC_VdifQueueableCallback vdifQueueableCallback) {
        switch on vdifQueueableCallback.getStage() {
            when ADD_SIGNERS {
                VCC_VdifGetAdditionalSignersRS additionalSignersRS = ((VCC_VdifGetAdditionalSignersRS) response);

                VCC_IntegrationTestUtilityService.instance.assert(
                    additionalSignersRS.taggedTextArray.count == 1,
                    'Expected additionalSignersRS.taggedTextArray.count to be 1, but is not.'
                );

                VCC_IntegrationTestUtilityService.instance.assert(
                    additionalSignersRS.taggedTextArray.results.taggedText[0].text == testPatientMetadata.VCC_Additional_Signer_IEN__c,
                    'Expected added signer duz to match configuration, but it did not.'
                );
            }
            when SIGN_NOTE {
                String text = ((VCC_VdifSignNoteRS) response)?.signNoteTextTO?.text;
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(text) && text == 'OK', 'Expected "OK", but found a null/blank value.');
            }
            when CREATE_ADDENDUM {
                String itemId = ((VCC_VdifCreateAddendumRS) response)?.createAddendumTextTO?.text;
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(itemId), 'Expected an item id, but found a null/blank value.');
                vdifQueueableCallback.getVdifParameters().vdifNote.itemId = itemId;
            }
            when WRITE_NOTE {
                String itemId = ((VCC_VdifWriteNoteRS) response)?.noteResultTO?.Id;
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(itemId), 'Expected an item id, but found a null/blank value.');
                vdifQueueableCallback.getVdifParameters().vdifNote.itemId = itemId;
            }
        }
    }

    public void onQueueableEnd(VCC_VdifQueueableCallback vdifQueueableCallback) {
        switch on vdifQueueableCallback.getStage() {
            when ADD_SIGNERS {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
            }
            when VALIDATE_ESIG {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
            }
            when CREATE_ADDENDUM {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
            }
            when SIGN_NOTE {
                if (
                    vdifQueueableCallback.getPreviousStage() == VCC_VdifQueueableCallback.Stage.WRITE_NOTE ||
                    vdifQueueableCallback.getPreviousStage() == VCC_VdifQueueableCallback.Stage.ADD_SIGNERS
                ) {
                    vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.CREATE_ADDENDUM);
                }
            }
            when WRITE_NOTE {
                if (String.isNotBlank(this.testPatientMetadata.VCC_Additional_Signer_IEN__c)) {
                    vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.ADD_SIGNERS);
                } else {
                    vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
                }
            }
        }
    }
}
