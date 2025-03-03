/**
 * @description Repository class for the VCC_Provider_Clinic_Assignment__c object
 * @author  Booz Allen Hamilton
 * @since  4/2/2024
 */
public inherited sharing class VCR_ProviderClinicAssignmentRepo extends VTC_BaseRepo {
    /**
     * @description Constructor for VCR_ProviderClinicAssignmentRepo
     */
    public VCR_ProviderClinicAssignmentRepo() {
        super(VCC_Provider_Clinic_Assignment__c.sObjectType);
    }
    /**
     * @description Returns a list of Provider Clinic Assignments based on provider SEC ID, and available Facility Codes
     * @return List<VCC_Provider_Clinic_Assignment__c> returns a list of VCC_Provider_Clinic_Assignment__c records
     * @param providerIEN    String of Provider IEN for identifying the Provider
     * @param facilityCode       Facility Code for filtering which Clinics are under Facility
     */
    public List<VCC_Provider_Clinic_Assignment__c> getProviderClinicsInternal(String providerIEN, String facilityCode) {
        //Get Clinic IENs where Provider works at:
        Map<String, Object> binds = new Map<String, Object>{
            'providerIEN' => providerIEN,
            'facilityCode' => facilityCode
        };
        String selectClause = 'SELECT VCC_Clinic__r.VCC_IEN__c, VCC_Clinic__r.Name, VCC_Clinic__r.VCC_Station_Id__c, VCC_Provider__r.Name, VCC_IEN__c ';
        String fromClause = this.calculateFromClause();
        String whereClause = ' WHERE VCC_Provider__r.VCC_IEN__c = :providerIEN AND VCC_Clinic__r.VCC_Station_Id__c = :facilityCode';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return this.fetch(query, binds);
    }
    /**
     * @description Returns a list of Provider Clinic Assignments based on the clinic's IEN
     * @return List<VCC_Provider_Clinic_Assignment__c> returns a list of VCC_Provider_Clinic_Assignment__c records
     * @param clinicIEN    String of Clinic IEN for identifying the Provider
     */
    public List<VCC_Provider_Clinic_Assignment__c> getProvidersInternal(String clinicIEN) {
        //Get Providers where Provider works at:
        Map<String, Object> binds = new Map<String, Object>{ 'clinicIEN' => clinicIEN };
        String selectClause = 'SELECT VCC_Provider__r.Name, VCC_IEN__c, VCC_Clinic__r.VCC_IEN__c ';
        String fromClause = this.calculateFromClause();
        String whereClause = ' WHERE VCC_Clinic__r.VCC_IEN__c = :clinicIEN';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return this.fetch(query, binds);
    }
}
