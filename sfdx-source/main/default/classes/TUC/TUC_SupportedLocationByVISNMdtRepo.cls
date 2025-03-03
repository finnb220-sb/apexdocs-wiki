/**
 * @description This repository is for the TUC_Supported_Location_By_VISN__mdt Metadata. Meant to be used in test classes that retrieve and compare to make sure all VISNs have data
 * @author Booz Allen
 */
public virtual with sharing class TUC_SupportedLocationByVISNMdtRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for TUC_SupportedLocationByVISNMdtRepo. Calls super constructor which sets this.sObjectType to
     * TUC_Supported_Location_By_VISN__mdt
     */
    public TUC_SupportedLocationByVISNMdtRepo() {
        super(TUC_Supported_Location_By_VISN__mdt.sObjectType);
    }

    /**
     * @description retrieves all metadata in the org
     * @return `List<TUC_Supported_Location_By_VISN__mdt>` - list of the Tuc Supported Location metadata
     */
    public List<TUC_Supported_Location_By_VISN__mdt> getAllTUCSupportedLocationByVISNmdtRecords() {
        String selectClause = 'SELECT Id, MPI_Facility_ID__c, Salesforce_Facility_ID__c, VISN__c ';
        String fromClause = 'FROM TUC_Supported_Location_By_VISN__mdt';
        String query = selectClause + fromClause;

        return this.fetch(query);
    }
}
