/**
 * @description Response class for createAddendum DAS call
 * @author      Booz Allen
 * @see         VCC_DASRSCommon
 */
public with sharing class VCC_DASCreateAddendumRS {
    public VCC_DASRSCommon.TextTO textTO;

    public VCC_DASCreateAddendumRS() {
        this.textTO = new VCC_DASRSCommon.TextTO();
    }
}
