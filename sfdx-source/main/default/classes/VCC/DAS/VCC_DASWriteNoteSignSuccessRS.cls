/**
 * @description Allows for the deserialization of the JSON HTTP response body of VCC_DASWriteNoteSignSuccessRS
 * @author Booz Allen Hamilton
 * @see VCC_DASWriteNoteSignSuccessRSTest for test class
 * @see VCC_DASRSCommon
 */

public with sharing class VCC_DASWriteNoteSignSuccessRS {
    public TextTO textTO;

    /**
     * @description Data structure for text-related information, including a note identifier and fault information.
     */

    public class TextTO {
        public String text;
        public String noteIen;
    }

    /**
     * @description Constructor initializes the TextTO object.
     */
    public VCC_DASWriteNoteSignSuccessRS() {
        this.textTO = new TextTO();
    }
}
