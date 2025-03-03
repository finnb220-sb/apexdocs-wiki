/**
 *
 * @group API - VDIF
 * @description Proxy class for VDIF callouts
 */
public with sharing class VCC_VdifProxy extends VCC_ApiProxy {
    private VCC_VdifClient vdifClient {
        get {
            return (VCC_VdifClient) this.client;
        }
    }
    /**
     * @param getAdditionalSignersRQ The request object for the VDIF getAdditionalSigners callout
     * @description Proxy method for routing to the getAdditionalSigners method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifGetAddtionalSignersRS
     */
    public VCC_VdifGetAdditionalSignersRS getAdditionalSigners(VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ) {
        return vdifClient.getAdditionalSigners(getAdditionalSignersRQ);
    }
    /**
     * @param createAddendumRQ The request object for the VDIF createAddendum callout
     * @description Proxy method for routing to the createAddendum method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifCreateAddendumRQ
     */
    public VCC_VdifCreateAddendumRS createAddendum(VCC_VdifCreateAddendumRQ createAddendumRQ) {
        return vdifClient.createAddendum(createAddendumRQ);
    }
    /**
     * @param isValidEsigRQ The request object for the VDIF isValidEsig callout
     * @description Proxy method for routing to the isValidEsig method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifIsValidEsigRQ
     */
    public VCC_VdifIsValidEsigRS isValidEsig(VCC_VdifIsValidEsigRQ isValidEsigRQ) {
        return vdifClient.isValidEsig(isValidEsigRQ);
    }
    /**
     * @param saveNoteAndEncounterRQ The request object for the VDIF save note and encounter callout
     * @description Proxy method for routing to the saveNoteAndEncounter method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifSaveNoteAndEncounterRS
     */
    public VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounter(VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ) {
        return vdifClient.saveNoteAndEncounter(saveNoteAndEncounterRQ);
    }
    /**
     * @param signNoteRQ The request object for the VDIF sign note callout
     * @description Proxy method for routhing to the signNote method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifSignNoteRS
     */
    public VCC_VdifSignNoteRS signNote(VCC_VdifSignNoteRQ signNoteRQ) {
        return vdifClient.signNote(signNoteRQ);
    }
    /**
     * @param writeNoteRQ The request object for writing a progress note to VDIF
     * @description Proxy method for routing to the writeNote method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifWriteNoteRQ object
     */
    public VCC_VdifWriteNoteRS writeNote(VCC_VdifWriteNoteRQ writeNoteRQ) {
        return vdifClient.writeNote(writeNoteRQ);
    }
    /**
     * @param selectPatientRQ The request object for VDIF select patient callout
     * @description Proxy method for routing to the selectPatient method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifSelectPatientRQ object
     */
    public VCC_VdifSelectPatientRS selectPatient(VCC_VdifSelectPatientRQ selectPatientRQ) {
        return vdifClient.selectPatient(selectPatientRQ);
    }
    /**
     * @param getProvidersBySiteRQ The request object for VDIF getProvidersBySite callout
     * @description Proxy method for routing to the getProvidersBySite method on VCC_VdifClient
     * @return Returns an instance of VCC_VdifGetProvidersBySiteRQ object
     */
    public VCC_VdifGetProvidersBySiteRS getProvidersBySite(VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ) {
        return vdifClient.getProvidersBySite(getProvidersBySiteRQ);
    }
    /**
     * @description Method for returning the VCC_VdifClient type
     * @return Returns an instance of System.Type for VCC_VdifClient.class
     */
    protected override System.Type getClientType() {
        return VCC_VdifClient.class;
    }
}
