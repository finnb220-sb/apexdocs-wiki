/**
 * @description An instance of a VdifProvider object.
 * @group API - VDIF
 */
public with sharing class VCC_VdifProvider {
    @AuraEnabled
    public String duz;

    @AuraEnabled
    public String cosignerDuz;

    @AuraEnabled
    public String token;

    @AuraEnabled
    public String esig;

    @AuraEnabled
    public String siteCode;

    @AuraEnabled
    public String name;
    /**
     * @description Constructor for VCC_VdifProvider. Empty, but required for code coverage.
     */
    public VCC_VdifProvider() {
        return;
        //Constructor added for coverage
    }
}
