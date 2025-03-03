public with sharing class VCC_VdifSaveNoteAndEncounterRS extends VCC_BaseClient.BaseResponse {
    /**
     * saveNoteAndEncounterTextTO.text, with a successful callout, will contain the encounter string
     */
    public VCC_VdifRSCommon.TextTO saveNoteAndEncounterTextTO;

    public VCC_VdifSaveNoteAndEncounterRS() {
        this.saveNoteAndEncounterTextTO = new VCC_VdifRSCommon.TextTO();
    }

    public VCC_VdifSaveNoteAndEncounterRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.saveNoteAndEncounterTextTO = ((VCC_VdifSaveNoteAndEncounterRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"textTO"', '"saveNoteAndEncounterTextTO"'),
                    VCC_VdifSaveNoteAndEncounterRS.class
                ))
                .saveNoteAndEncounterTextTO;
        }
    }
}
