public with sharing class VCC_VdifTestRun_Encounter implements VCC_VdifQueueableCallback.Strategy {
    public VCC_VdifTestRun_Encounter(VCC_Test_Configuration_Data__c testPatientMetadata) {
        this.testPatientMetadata = testPatientMetadata;
    }

    @TestVisible
    private VCC_VdifTestRun_Encounter() {
        return;
    }

    @TestVisible
    private VCC_Test_Configuration_Data__C testPatientMetadata { get; set; }

    public void onQueueableStart(VCC_VdifQueueableCallback vdifQueueableCallback) {
        VCC_VdifNote vdifNote = vdifQueueableCallback.getVdifParameters().vdifNote;
        VCC_VdifEncounter vdifEncounter = vdifQueueableCallback.getVdifParameters().vdifEncounter;
        VCC_VdifProvider vdifProvider = vdifQueueableCallback.getVdifParameters().vdifProvider;
        switch on (vdifQueueableCallback.getStage()) {
            when ADD_SIGNERS {
                vdifNote.additionalSigners = new List<String>{ testPatientMetadata.VCC_Additional_Signer_IEN__c };
            }
            when WRITE_NOTE {
                vdifNote.text = this.testPatientMetadata.VCC_Note_Text__c;
                vdifNote.noteTitleIen = this.testPatientMetadata.VCC_Note_Title_IEN_For_Encounter__c;
            }
            when CREATE_ENCOUNTER {
                vdifEncounter.locationIen = (String.isNotBlank(this.testPatientMetadata.VCC_Location_IEN__c)) ? this.testPatientMetadata.VCC_Location_IEN__c : null;
                vdifEncounter.noteTitleIen = this.testPatientMetadata.VCC_Note_Title_IEN_For_Encounter__c;
                vdifEncounter.serviceCategory = 'T';
                vdifEncounter.visitRelatedTos = (String.isNotBlank(this.testPatientMetadata?.VCC_Visit_Related_Tos__c)) ? this.testPatientMetadata.VCC_Visit_Related_Tos__c : null;
                vdifEncounter.procedures = (String.isNotBlank(this.testPatientMetadata?.VCC_Procedure_Codes__c))
                    ? this.testPatientMetadata.VCC_Procedure_Codes__c + '^^^^' + vdifProvider.duz
                    : null;

                if (String.isNotBlank(this.testPatientMetadata?.VCC_Diagnosis_Codes__c)) {
                    if (this.testPatientMetadata.VCC_Diagnosis_Codes__c.contains(',')) {
                        Set<String> diagnosisCodes = VCC_String_Utilities.splitUnique(this.testPatientMetadata.VCC_Diagnosis_Codes__c, ',');
                        List<String> diagnosisCodesList = new List<String>(diagnosisCodes);
                        vdifEncounter.diagnoses = diagnosisCodesList[0] + '^^1^^' + diagnosisCodesList[1] + '^^^^';
                    } else {
                        vdifEncounter.diagnoses = this.testPatientMetadata.VCC_Diagnosis_Codes__c + '^^1^^';
                    }
                }
            }
        }
    }

    public void onException(Exception e, VCC_VdifQueueableCallback vdifQueueableCallback) {
        return;
    }

    public void onCalloutResponse(Object response, VCC_VdifQueueableCallback vdifQueueableCallback) {
        switch on (vdifQueueableCallback.getStage()) {
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
            when CREATE_ENCOUNTER {
                VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounterRS = ((VCC_VdifSaveNoteAndEncounterRS) response);
                String encounterString = VCC_EncounterService.findEncounterString(saveNoteAndEncounterRS?.saveNoteAndEncounterTextTO?.text);
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(encounterString), 'Expected to find an encounter string in the response, but did not.');
                vdifQueueableCallback.getVdifParameters().vdifNote.encounterString = encounterString;
            }
            when SIGN_NOTE {
                String text = ((VCC_VdifSignNoteRS) response)?.signNoteTextTO?.text;
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(text) && text == 'OK', 'Expected "OK", but found a null/blank value.');
            }
            when WRITE_NOTE {
                String itemId = ((VCC_VdifWriteNoteRS) response)?.noteResultTO?.Id;
                VCC_IntegrationTestUtilityService.instance.assert(String.isNotBlank(itemId), 'Expected an item id, but found a null/blank value.');
                vdifQueueableCallback.getVdifParameters().vdifNote.itemId = itemId;
            }
        }
    }

    public void onQueueableEnd(VCC_VdifQueueableCallback vdifQueueableCallback) {
        switch on (vdifQueueableCallback.getStage()) {
            when ADD_SIGNERS {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.SIGN_NOTE);
            }
            when VALIDATE_ESIG {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.CREATE_ENCOUNTER);
            }
            when CREATE_ENCOUNTER {
                vdifQueueableCallback.enqueueStage(VCC_VdifQueueableCallback.Stage.WRITE_NOTE);
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
