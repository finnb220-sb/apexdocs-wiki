/**
 * @description Repository class for the Address object to hold its respective query and DML logic
 * @author Booz Allen
 * @since   2024
 */
public inherited sharing class VCR_AddressRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AddressRepo. Calls super constructor which sets this.sObjectType to 'User'
     */
    public VCR_AddressRepo() {
        super(Schema.Address.sObjectType);
    }

    /**
     * @description             retrieves a list of Address records based on address id
     * @param addressId         the Id of the Address object
     * @return                  `List<Schema.Address>` List of Address Informations
     */
    public List<Schema.Address> fetchAddressById(Id addressId) {
        String selectClause = 'Select Id,ParentId,VAF_Longitude__c, VAF_Latitude__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id = :addressId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<Schema.Address>) this.fetch(query, new Map<String, Object>{ 'addressId' => addressId });
    }

    /**
     * @description             retrieves a list of Address records based on Location Id List
     * @param locationIdList    the list of Id of the Location object
     * @return                  `List<Schema.Address>` List of Address Informations
     */
    public List<Schema.Address> getAddressListFromLocId(Set<Id> locationIdList) {
        String selectClause = 'Select Id, VAF_Longitude__c, VAF_Latitude__c, ParentId, CreatedDate';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VAF_Is_Decommissioned__c = False AND AddressType= \'Physical\' AND ParentId IN :locationIdList';
        String orderByClause = 'ORDER BY CreatedDate DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return (List<Schema.Address>) this.fetch(query, new Map<String, Object>{ 'locationIdList' => locationIdList });
    }

    /**
     * @description        This method is to prepare a map of location Id with Address object. Location Latitude and Longitude information is present on Address object
     * @param locationList Set of service resource location Id
     * @return             `Map<Id, Schema.Address>` map of location Id with Address record will be returned.
     */
    public Map<Id, Schema.Address> getMapOfLocIdToAddress(Set<Id> locationList) {
        List<Schema.Address> listAddress = getAddressListFromLocId(locationList);

        Map<Id, Schema.Address> locationIdToAddress = new Map<Id, Schema.Address>();
        for (Schema.Address address : listAddress) {
            locationIdToAddress.put(address.ParentId, address);
        }

        return locationIdToAddress;
    }
}
