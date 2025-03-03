/**
 * @description This repository is for the E911 Metrics object database operations
 * @author Booz Allen
 * @date 04/2024
 */

public virtual inherited sharing class VCR_E911MetricsRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_E911MetricsRepo. Calls super constructor which sets this.sObjectType to 'VCC_e911_Metrics__c'
     *
     */
    public VCR_E911MetricsRepo() {
        super(VCC_e911_Metrics__c.sObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{
                'VCC_Street__c',
                'VCC_City__c',
                'VCC_State__c',
                'VCC_Country__c',
                'VCC_Zip_Code__c',
                'VCC_Call_Back_Number__c',
                'VCC_Temporary_e911_Number__c'
            }
        );
    }
    /**
     * @description Retrieves a list of E911 Metric records that share the same contact id
     * @param contactId - contact id
     * @return List<VCC_e911_Metrics__c> - list of E911 Metric records that match the contact id
     */
    public List<VCC_e911_Metrics__c> getE911MetricsByContactId(String contactId) {
        String selectClause = 'SELECT VCC_Street__c,VCC_City__c,VCC_State__c,VCC_Country__c,VCC_Zip_Code__c,VCC_Non_Address__c,VCC_Date_Activated__c,VCC_User_Name_Activated__c,VCC_User_VISN__c,VCC_Service__c,VCC_Temporary_e911_Number__c,VCC_Modality__c,VCC_e911_Case__c,VCC_Call_Back_Number__c,VCC_e911_Progress_Note__c,VCC_Patient_Account__c,VCC_Activated_From__c,VCC_Active__c ';
        String fromClause = 'FROM VCC_e911_Metrics__c ';
        String whereClause = 'WHERE VCC_Date_Activated__c = null AND VCC_Patient_Account__c = \'' + contactId + '\'';
        String limitClause = ' LIMIT 1';
        String query = selectClause + fromClause + whereClause + limitClause;
        return this.fetch(query);
    }
}
