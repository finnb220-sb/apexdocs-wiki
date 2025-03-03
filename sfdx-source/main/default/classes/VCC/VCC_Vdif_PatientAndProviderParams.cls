/**
 * @description Apex-defined type for use in flows.
 * @author Patrick Skamarak
 * @since 8/10/2021
 * @group API - VDIF
 * @see VCC_ProgressNoteController
 */
public with sharing class VCC_Vdif_PatientAndProviderParams {
    @AuraEnabled
    public String providerUserId;

    @AuraEnabled
    public String providerName;

    //add patient name parameter for DAS
    @AuraEnabled
    public String patientName;

    @AuraEnabled
    public Long patientLocalPid;

    @AuraEnabled
    public String patientLocalSiteId;

    @AuraEnabled
    public String providerLoginSiteCode;

    @AuraEnabled
    public String eSig;

    @AuraEnabled
    public String authorDUZ;

    public VCC_Vdif_PatientAndProviderParams() {
        return; //adding empty constructor so we see 100% test coverage
    }
}
