/**
 * @description Repository class for the VAF_Address__c object to hold its respective query and DML logic
 * @author Booz Allen
 * @since   2024
 */
public inherited sharing class VCR_VAFAddressRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_VAFAddressRepo. Calls super constructor which sets this.sObjectType to 'VAF_Address__c'
     */
    public VCR_VAFAddressRepo() {
        super(VAF_Address__c.sObjectType);
    }

    /**
     * @description             retrieves a list of VAF_Address__c records based on Location Id List
     * @param locationIdList    the list of Ids of the Locations
     * @return                  `List<VAF_Address__c>` List of VAF Addresses
     */
    public List<VAF_Address__c> getAddressListFromLocId(Set<Id> locationIdList) {
        List<VAF_Address__c> vafAddressList = new List<VAF_Address__c>();
        String selectClause = 'Select Id, VAF_Longitude__c, VAF_Latitude__c, VAF_Facility__c, CreatedDate';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VAF_Is_Decommissioned__c = False AND VAF_Type__c= \'Physical\' AND VAF_Facility__c IN :locationIdList';
        String orderByClause = 'ORDER BY CreatedDate DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return vafAddressList = (List<VAF_Address__c>) this.fetch(
            query,
            new Map<String, Object>{ 'locationIdList' => locationIdList }
        );
    }

    /**
     * @description        This method queries for VAF Address and then creates a map of locationIds with VAF Address. Location latitude and longitude information is present at VAF Address Object
     * @param locationList Set of locationIds
     * @return             `Map<Id, VAF_Address__c>` map of locationIds with their respective VAF Address record will be returned
     */
    public Map<Id, VAF_Address__c> getMapOfLocIdToVafAddress(Set<Id> locationList) {
        List<VAF_Address__c> listVAFAddress = this.getAddressListFromLocId(locationList);

        Map<Id, VAF_Address__c> locationIdToVAFAddress = new Map<Id, VAF_Address__c>();
        for (VAF_Address__c vafAddress : listVAFAddress) {
            locationIdToVAFAddress.put(vafAddress.VAF_Facility__c, vafAddress);
        }
        return locationIdToVAFAddress;
    }
}
