/**
 * @description Repository class for the PrC NDTH Host Location object to hold its respective query and DML logic.
 * @author      Booz Allen
 * @since       2024
 */
public inherited sharing class PC_NDTHHostLocationRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_NDTHHostLocationRepo. Calls super constructor which sets this.sObjectType to 'PC_NDTH_Host_Locations__c'
     */
    public PC_NDTHHostLocationRepo() {
        super(PC_NDTH_Host_Locations__c.sObjectType);
        this.defaultSelectFields = new Set<String>{ 'Id', 'Location__c' };
    }

    /**
     * @description     query returning NDTH Host Locations related to the provided NDTHs
     * @param ndthIdSet set of NDTH IDs
     * @return          `List<PC_NDTH_Host_Locations__c>` list of retrieved NDTH Host Location junctions related to the provided NDTHs
     */
    public List<PC_NDTH_Host_Locations__c> getHostLocationsFromNDTHs(Set<Id> ndthIdSet) {
        String selectClause = this.calculateSelectClause(this.defaultSelectFields);
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE NDTH__c IN :ndthIdSet AND Is_Active__c = TRUE AND NDTH__r.Is_Active__c = TRUE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_NDTH_Host_Locations__c>) this.fetch(query, new Map<String, Object>{ 'ndthIdSet' => ndthIdSet });
    }

    /**
     * @description     Generates a set of Ids for Locations of which the provided NDTH agreements are related as host locations
     * @param ndthIdSet Set of Ids for NDTHs for which we need to grab a set of the covered host locations
     * @return          `Set<Id>` set of Location record Ids for the host locations under the NDTH agreement
     */
    public Set<Id> getSpecialistLocationIdsForNDTHs(Set<Id> ndthIdSet) {
        Set<Id> hostLocationIds = new Set<Id>();
        for (PC_NDTH_Host_Locations__c ndthHostLocation : this.getHostLocationsFromNDTHs(ndthIdSet)) {
            hostLocationIds.add(ndthHostLocation.Location__c);
        }
        return hostLocationIds;
    }

    /**
     * @description     Generates a set of Ids for Locations of which the provided NDTH agreements are related as host locations
     *                  Throws exception if no Specialists are available under the NDTH Agreements
     * @param ndthIdSet Set of Ids for NDTHs for which we need to grab a set of the covered host locations
     * @return          `Set<Id>` set of Location record Ids for the host locations under the NDTH agreement
     */
    public Set<Id> getSpecialistLocationIdsForNDTHsWithEmptyResultHandling(Set<Id> ndthIdSet) {
        Set<Id> hostLocationIds = this.getSpecialistLocationIdsForNDTHs(ndthIdSet);

        if ((hostLocationIds == null || hostLocationIds.isEmpty())) {
            throw new PC_CustomException(System.Label.No_Specialists_Available);
        } else {
            return hostLocationIds;
        }
    }
}
