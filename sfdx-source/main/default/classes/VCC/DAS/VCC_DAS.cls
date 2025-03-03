/**
 * @description Entry-point for DAS integration that connects to VistA
 * @author      Booz Allen
 */
public with sharing class VCC_DAS {
    public enum Endpoint {
        IS_VALID_ESIG,
        SELECT_PATIENT,
        WRITE_NOTE,
        SIGN_NOTE,
        GET_ADDITIONAL_SIGNERS,
        CREATE_ADDENDUM,
        SAVE_NOTE_AND_ENCOUNTER,
        WRITE_NOTE_AND_SIGN,
        CREATE_ADDENDUM_AND_SIGN
    }

    @TestVisible
    private State state;

    public static final String VERSION = System.Label.VCC_DAS_Version_Number;

    static {
        SERVICES.LOGGER.debug('DAS Integration v' + VERSION);
        SERVICES.LOGGER.debug(String.valueOf(Datetime.now()));
    }

    /**
     * @description Service property
     */
    public static final VCC_DASServices SERVICES { //NOPMD
        get {
            if (SERVICES == null) {
                SERVICES = new VCC_DASServices();
            }
            return SERVICES;
        }
        set;
    }

    /**
     * @description Variables needed for initialization
     */
    public class State {
        public VCC_SiteId siteId;
        public String callingAppName;
        public Id recordId;
        public VCC_DAS.Endpoint endpoint;

        /**
         * @description Constructor
         * @param siteId `VCC_SiteId` facility site id
         * @param callingAppName `String` vahc app name
         * @param recordId `Id` progress note or addendum record id
         */
        public State(VCC_SiteId siteId, String callingAppName, Id recordId) {
            this.siteId = siteId;
            this.callingAppName = callingAppName;
            this.recordId = recordId;
        }
    }

    /**
     * @description Needs workshopping
     * @param state `State`
     */
    public VCC_DAS(State state) {
        this.state = state;
    }

    /**
     * @description empty constructor for testing purposes
     */
    @TestVisible
    private VCC_DAS() {
        return;
    }

    /** All DAS Callouts Below */

    /**
     * @description Used to send DAS getAdditionalSigners API requests
     * @param getAdditionalSignersRq `VCC_DASGetAdditionalSignersRQ` - DTO object encapsulating the request information needed for the getAdditionalSigners DAS call
     * @return `VCC_DASGetAdditionalSignersRS`
     */
    public VCC_DASGetAdditionalSignersRS getAdditionalSigners(VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq) {
        this.state.endpoint = VCC_DAS.Endpoint.GET_ADDITIONAL_SIGNERS;
        return SERVICES.API.getAdditionalSigners(getAdditionalSignersRq, this.state);
    }

    /**
     * @description Used to send DAS createAddendum API requests
     * @param createAddendumRq `VCC_DASCreateAddendumRQ` - DTO object encapsulating the request information needed for the createAddendum DAS call
     * @return `VCC_DASCreateAddendumRS`
     */
    public VCC_DASCreateAddendumRS createAddendum(VCC_DASCreateAddendumRQ createAddendumRq) {
        this.state.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM;
        return SERVICES.API.createAddendum(createAddendumRq, this.state);
    }

    /**
     * @description Used to send DAS isValidEsig API requests
     * @param isValidEsigRq `VCC_DASIsValidEsigRQ` - DTO object encapsulating the request information needed for the isValidEsig DAS call
     * @return `VCC_DASIsValidEsigRS`
     */
    public VCC_DASIsValidEsigRS isValidEsig(VCC_DASIsValidEsigRQ isValidEsigRq) {
        this.state.endpoint = VCC_DAS.Endpoint.IS_VALID_ESIG;
        return SERVICES.API.isValidEsig(isValidEsigRq, this.state);
    }

    /**
     * @description Used to send DAS saveNoteAndEncounter API requests
     * @param saveNoteAndEncounterRq `VCC_DASSaveNoteAndEncounterRQ` - DTO object encapsulating the request information needed for the saveNoteAndEncounter DAS call
     * @return `VCC_DASSaveNoteAndEncounterRS`
     */
    public VCC_DASSaveNoteAndEncounterRS saveNoteAndEncounter(VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq) {
        this.state.endpoint = VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER;
        return SERVICES.API.saveNoteAndEncounter(saveNoteAndEncounterRq, this.state);
    }

    /**
     * @description Used to send DAS signNote API requests
     * @param signNoteRq `VCC_DASSignNoteRQ` - DTO object encapsulating the request information needed for the signNote DAS call
     * @return `VCC_DASSignNoteRS`
     */
    public VCC_DASSignNoteRS signNote(VCC_DASSignNoteRQ signNoteRq) {
        this.state.endpoint = VCC_DAS.Endpoint.SIGN_NOTE;
        return SERVICES.API.signNote(signNoteRq, this.state);
    }

    /**
     * @description Used to send DAS writeNote API requests
     * @param writeNoteRq `VCC_DASWriteNoteRQ` - DTO object encapsulating the request information needed for the writeNote DAS call
     * @return `VCC_DASWriteNoteRS`
     */
    public VCC_DASWriteNoteRS writeNote(VCC_DASWriteNoteRQ writeNoteRq) {
        this.state.endpoint = VCC_DAS.Endpoint.WRITE_NOTE;
        return SERVICES.API.writeNote(writeNoteRq, this.state);
    }

    /**
     * @description Used to send DAS selectPatient API requests
     * @param selectPatientRq `VCC_DASSelectPatientRQ` - DTO object encapsulating the request information needed for the selectPatient DAS call
     * @return `VCC_DASSelectPatientRS`
     */
    public List<VCC_DASSelectPatientRS> selectPatient(VCC_DASSelectPatientRQ selectPatientRq) {
        this.state.endpoint = VCC_DAS.Endpoint.SELECT_PATIENT;
        return SERVICES.API.selectPatient(selectPatientRq, this.state);
    }

    /**
     * @description Used to send DAS writeNoteAndSign API requests
     * @param writeNoteAndSignRQ `VCC_DASWriteNoteAndSignRQ` - DTO object encapsulating the request information needed for the writeNoteAndSign DAS call
     * @return `VCC_DASWriteNoteSignSuccessRS`
     */
    public VCC_DASWriteNoteSignSuccessRS writeNoteAndSign(VCC_DASWriteNoteAndSignRQ writeNoteAndSignRQ) {
        this.state.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;
        return SERVICES.API.writeNoteAndSign(writeNoteAndSignRQ, this.state);
    }

    /**
     * @description Used to send DAS createAddendumAndSign API requests
     * @param createAddendumAndSignRq `VCC_DASCreateAddendumAndSignRQ` - DTO object encapsulating the request information needed for the createAddendumAndSign DAS call
     * @return `VCC_DASCreateAddendumAndSignSuccessRS`
     */
    public VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSign(
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq
    ) {
        this.state.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN;
        return SERVICES.API.createAddendumAndSign(createAddendumAndSignRq, this.state);
    }
}
