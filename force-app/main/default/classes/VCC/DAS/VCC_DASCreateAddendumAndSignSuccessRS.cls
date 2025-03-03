/**
 * @author Booz Allen Hamilton
 * @description Allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignSuccessRS
 * @see VCC_DASCreateAddendumSignSuccessRSTest for test class
 */

public with sharing class VCC_DASCreateAddendumAndSignSuccessRS {
    public TextTO textTO;

    /**
     * @description Data structure for text-related information, including a note identifier.
     */
    public class TextTO {
        public String text;
        public String addendumIen;
    }

    /**
     * @description Constructor initializes the TextTO object.
     */
    public VCC_DASCreateAddendumAndSignSuccessRS() {
        this.textTO = new TextTO();
    }
}
