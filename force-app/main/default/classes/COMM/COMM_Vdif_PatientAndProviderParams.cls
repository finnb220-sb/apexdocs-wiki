public with sharing class COMM_Vdif_PatientAndProviderParams {
    @AuraEnabled
    public String providerUserId;

    @AuraEnabled
    public String providerName;

    @AuraEnabled
    public Integer patientLocalPid;

    @AuraEnabled
    public String patientLocalSiteId;

    @AuraEnabled
    public String providerLoginSiteCode;

    @AuraEnabled
    public String eSig;

    @AuraEnabled
    public String authorDUZ;
}
