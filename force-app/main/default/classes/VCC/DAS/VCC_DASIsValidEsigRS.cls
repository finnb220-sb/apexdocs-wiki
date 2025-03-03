/**
 * @description Shape/structure of the JSON HTTP response body of das/isValidEsig
 */
public with sharing class VCC_DASIsValidEsigRS {
    /**
     * textTO.text is expected to be "True" or "False" (not Boolean, but String) for the IsValidEsig Callout
     * textTO.fault contains fault information, should there be any.
     */
    public VCC_DASRSCommon.TextTO textTO;

    public VCC_DASIsValidEsigRS() {
        this.textTO = new VCC_DASRSCommon.TextTO();
    }
}
