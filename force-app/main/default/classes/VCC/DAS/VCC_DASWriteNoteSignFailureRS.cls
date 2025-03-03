/**
 * @description Allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignFailureRS
 * @author Booz Allen Hamilton
 * @see VCC_DASWriteNoteSignFailureRSTest for test class
 */
public with sharing class VCC_DASWriteNoteSignFailureRS {
    public String message;
    public String description;
    public String code;
    public String noteIen;

    /**
     * @description Empty constructor for code coverage
     */
    public VCC_DASWriteNoteSignFailureRS() {
        return;
    }
}
