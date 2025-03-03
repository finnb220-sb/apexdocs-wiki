/**
 * @description VCC_ClinicByNameMockRSTransformer is used to transform a list of VCC_Clinic__c mock object records into a shape that matches the corresponding API reponse. This is useful to enable lwc development for the Scheduling
 * feature before the API endpoints are available.
 * @author Booz Allen Hamilton
 * @since 4/8/2024
 */
//Suppressing these warnings due to the shape of this class matching the shape of the API response
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields, PMD.FieldNamingConventions, PMD.ClassNamingConventions')
public with sharing class VCC_ClinicByNameMockRSTransformer {
    @AuraEnabled
    public List<ClinicSearchResult> data = new List<ClinicSearchResult>();

    /**
     * @description ClinicSearchResult represents the Clinic Information returned by the API.
     */
    private class ClinicSearchResult {
        @AuraEnabled
        public String ien;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String patientFriendlyName;
        @AuraEnabled
        public String primaryStopCode;
        @AuraEnabled
        public String secondaryStopCode;
        @AuraEnabled
        public Boolean nonCount;
        @AuraEnabled
        public Boolean active;
        @AuraEnabled
        public String abbreviation;

        /**
         * @description Constructor for ClinicSearchResult. It accepts a VCC_Clinic__c record for transforming into the API response
         * @param mockClinic The VCC_Clinic__c record to transform
         */
        public ClinicSearchResult(VCC_Clinic__c mockClinic) {
            this.ien = mockClinic?.VCC_IEN__c;
            this.name = mockClinic?.Name;
            this.patientFriendlyName = null;
            this.primaryStopCode = null;
            this.secondaryStopCode = null;
            this.nonCount = null;
            this.active = mockClinic?.VCC_Active_Flag__c;
            this.abbreviation = null;
        }
    }
    /**
     * @description  Constructor for VCC_ClinicByNameMockRSTransformer. Accepts a list of VCC_Clinic__c records that will be used to parse into the appropriate shape that matches the API response
     * @param mockClinics VCC_Clinic__c records to parse into the appropriate shape that matches the API response
     */
    public VCC_ClinicByNameMockRSTransformer(List<VCC_Clinic__c> mockClinics) {
        if (mockClinics == null || mockClinics.isEmpty()) {
            return;
        }
        for (VCC_Clinic__c mockClinic : mockClinics) {
            this.data.add(new ClinicSearchResult(mockClinic));
        }
    }
}
