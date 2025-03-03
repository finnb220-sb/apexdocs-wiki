/**
 * @description Shape/structure of the JSON HTTP response body of das/signNote
 */
public with sharing class VCC_DASSignNoteRS {
    public VCC_DASRSCommon.TextTO textTO;

    public VCC_DASSignNoteRS() {
        this.textTO = new VCC_DASRSCommon.TextTO();
    }
}
