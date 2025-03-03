public with sharing class VCC_DASSaveNoteAndEncounterRS {
    /**
     * saveNoteAndEncounterTextTO.text, with a successful callout, will contain the encounter string
     */
    public VCC_DASRSCommon.TextTO textTO;

    public VCC_DASSaveNoteAndEncounterRS() {
        this.textTO = new VCC_DASRSCommon.TextTO();
    }
}
