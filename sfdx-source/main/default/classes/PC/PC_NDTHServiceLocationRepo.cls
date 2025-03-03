/**
 * @description Repository class for the PrC NDTH Service Locations object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_NDTHServiceLocationRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_NDTHServiceLocationRepo. Calls super constructor which sets this.sObjectType to 'PC_NDTH_Service_Locations__c'
     */
    public PC_NDTHServiceLocationRepo() {
        super(PC_NDTH_Service_Locations__c.sObjectType);
        this.defaultSelectFields = new Set<String>{ 'Id', 'NDTH__c' };
    }

    /**
     * @description             retrieves a list of NDTH Service Location junctions that are related to a given Location
     * @param serviceLocationId the Id of the Location
     * @return                  `List<PC_NDTH_Service_Locations__c>` List of NDTH Service Location junctions related to the given Location
     */
    public List<PC_NDTH_Service_Locations__c> getNDTHServiceLocsFromLocId(Id serviceLocationId) {
        String selectClause = this.calculateSelectClause(this.defaultSelectFields);
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Location__c = :serviceLocationId AND Is_Active__c = TRUE AND NDTH__r.Is_Active__c = TRUE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_NDTH_Service_Locations__c>) this.fetch(
            query,
            new Map<String, Object>{ 'serviceLocationId' => serviceLocationId }
        );
    }

    /**
     * @description             gets a Set of IDs for NDTH agreements that are available for a given Location
     * @param serviceLocationId the Id of the Location
     * @return                  `Set<Id>` set of NDTH Ids
     */
    public Set<Id> getNDTHsIdSetFromLocation(Id serviceLocationId) {
        Set<Id> ndthIdSet = new Set<Id>();
        for (PC_NDTH_Service_Locations__c ndthServiceLocation : this.getNDTHServiceLocsFromLocId(serviceLocationId)) {
            ndthIdSet.add(ndthServiceLocation.NDTH__c);
        }
        return ndthIdSet;
    }

    /**
     * @description             gets a Set of IDs for NDTH agreements that are available for a given Location
     *                          throws an exception if there are no NDTH Agreements servicing your current location
     * @param serviceLocationId the Id of the Location
     * @return                  `Set<Id>` set of NDTH Ids
     */
    public Set<Id> getNDTHsIdSetFromLocationWithEmptyResultHandling(Id serviceLocationId) {
        Set<Id> ndthIdSet = this.getNDTHsIdSetFromLocation(serviceLocationId);

        if ((ndthIdSet == null || ndthIdSet.isEmpty())) {
            throw new PC_CustomException(System.Label.PC_No_NDTH_Agreements);
        } else {
            return ndthIdSet;
        }
    }
}
