/**
 * @description This repository is for the VAHC e911 Custom Settings records
 * @author Booz Allen
 * @since 05/2024
 */
public virtual inherited sharing class VCR_VAHCe911CustomSettingRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_VAHCe911CustomSettingRepo. Calls super constructor which sets this.sObjectType to
     * VAHC_E911_Settings__c
     */
    public VCR_VAHCe911CustomSettingRepo() {
        super(VAHC_E911_Settings__c.sObjectType);
    }

    /**
     * @description retrieves the custom setting with e911 Enabled bool field
     * @return `List<VAHC_E911_Settings__c>` - list of the e911 custom setting data
     *
     * There should only be a single (org wide default) VAHC_E911_Settings__c that exists. We do not expect additional users or profiles to have records or different settings all together
     */
    public List<VAHC_E911_Settings__c> getAlle911CustomSettingsRecords() {
        String selectClause = 'SELECT e911_Enabled__c ';
        String fromClause = 'FROM VAHC_E911_Settings__c';
        String query = selectClause + fromClause;

        return this.fetch(query);
    }
}
