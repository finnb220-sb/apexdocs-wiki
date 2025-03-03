/**
 * @description Custom Apex exception to capture failure data from the new consolidated endpoints writeNoteAndSign and createAddendumAndSign.
 * @author Booz Allen Hamilton
 * @since 04/16/2024 - added in CCCM-31253
 * @see VCC_DASConsolidatedEndpointExceptionTest
 * @see VCC_DASCreateAddendumAndSignFailureRS
 * @see VCC_DASWriteNoteAndSignFailureRS
 */
public with sharing class VCC_DASConsolidatedEndpointException extends VCC_DASException {
    public DAS_Type type;
    public String noteOrAddendumIen;
    public String errorCode;
    public String errorMessage;
    public String errorDescription;

    public enum DAS_Type {
        NOTE,
        ADDENDUM
    }

    /**
     * @description Public constructor for this exception. Accepts a DAS consolidated endpoint FailureRS class
     * @param createAddendumAndSignFailureRs `VCC_DASCreateAddendumAndSignFailureRS` from which this exception will be constructed
     */
    public VCC_DASConsolidatedEndpointException(VCC_DASCreateAddendumAndSignFailureRS createAddendumAndSignFailureRs) {
        super(createAddendumAndSignFailureRs.description);
        this.type = DAS_Type.ADDENDUM;
        this.errorCode = createAddendumAndSignFailureRs.code;
        this.errorMessage = createAddendumAndSignFailureRs.message;
        this.errorDescription = createAddendumAndSignFailureRs.description;
        this.noteOrAddendumIen = createAddendumAndSignFailureRs.addendumIen;
    }

    /**
     * @description Public constructor for this exception. Accepts a DAS consolidated endpoint FailureRS class
     * @param writeNoteAndSignFailureRs `VCC_DASWriteNoteAndSignFailureRS` from which this exception will be constructed
     */
    public VCC_DASConsolidatedEndpointException(VCC_DASWriteNoteSignFailureRS writeNoteAndSignFailureRs) {
        super(writeNoteAndSignFailureRs.description);
        this.type = DAS_Type.NOTE;
        this.errorCode = writeNoteAndSignFailureRs.code;
        this.errorMessage = writeNoteAndSignFailureRs.message;
        this.errorDescription = writeNoteAndSignFailureRs.description;
        this.noteOrAddendumIen = writeNoteAndSignFailureRs.noteIen;
    }
}
