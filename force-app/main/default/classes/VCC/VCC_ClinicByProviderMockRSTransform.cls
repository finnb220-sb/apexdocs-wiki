/**
 * @description The purpose of this class is to act as a transformer for the mock sObject's VCC_Provider_Clinic_Assignment__c.
 *  This allows us to transform the shape of these objects into the actual shape of the api response. Working with the data in the shape of the api response will allow us to develop the lwc's to be data source
 * agnostic, and will reduce double work.
 * @author Booz Allen Hamilton
 * @since 4/23/2024
 */
public with sharing class VCC_ClinicByProviderMockRSTransform {
    @AuraEnabled
    public List<String> associatedClinicIEN = new List<String>();
    @AuraEnabled
    public List<String> associatedClinicName = new List<String>();
    @AuraEnabled
    public String providerName;
    @AuraEnabled
    public String providerIEN;
    @AuraEnabled
    public String pbspID;

    /**
     * @description  Constructor for VCC_ClinicByProviderMockRSTransform. Accepts a list of VCC_Provider_Clinic_Assignment__c records that will be used to parse into the appropriate shape that matches the API response
     * @param mockClinics Array of VCC_Provider_Clinic_Assignment__c records to parse into the appropriate shape that matches the API response
     */
    public VCC_ClinicByProviderMockRSTransform(List<VCC_Provider_Clinic_Assignment__c> mockClinics) {
        if (mockClinics == null || mockClinics.isEmpty()) {
            return;
        }
        this.providerName = mockClinics[0].VCC_Provider__r.Name;
        this.providerIEN = mockClinics[0].VCC_IEN__c;
        for (VCC_Provider_Clinic_Assignment__c mockClinic : mockClinics) {
            this.associatedClinicIEN.add(mockClinic.VCC_Clinic__r.VCC_IEN__c);
            this.associatedClinicName.add(mockClinic.VCC_Clinic__r.Name);
        }
    }
}
