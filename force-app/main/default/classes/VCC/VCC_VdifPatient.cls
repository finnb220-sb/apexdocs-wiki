/**
 *
 * @description Describes an instance of a VdifPatient. Included in VCC_Vdif_Parameters
 * @group API - VDIF
 */
public with sharing class VCC_VdifPatient {
    /**
     * @description Retreived by external system. Identifies their patient record in CPRS/VistA.
     */
    @AuraEnabled
    public String pid;

    @AuraEnabled
    public String siteCode;

    @AuraEnabled
    public String name;
    /**
     *
     * @description Constructor for VCC_VdifPatient. Empty, but required for code coverage
     */
    public VCC_VdifPatient() {
        return;
        //Constructor added for coverage
    }
}
