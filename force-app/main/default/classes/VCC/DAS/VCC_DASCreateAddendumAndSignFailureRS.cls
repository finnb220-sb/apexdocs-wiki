/**
 * @author Booz Allen Hamilton
 * @description Allows for the deserialization of the JSON HTTP response body of VCC_DASCreateAddendumAndSignFailureRS
 * @see VCC_DASCreateAddendumSignFailureRSTest for test class
 */
public with sharing class VCC_DASCreateAddendumAndSignFailureRS {
    public String message;
    public String description;
    public String code;
    public String addendumIen;

    /**
     * @description empty constructor for test coverage
     */
    public VCC_DASCreateAddendumAndSignFailureRS() {
        return;
    }
}
