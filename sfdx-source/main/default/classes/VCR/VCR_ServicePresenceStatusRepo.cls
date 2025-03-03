/**
 * @description Holds SOQL/DML logic for the Service Presence Status object
 * @author      Booz Allen Hamilton
 */
public inherited sharing class VCR_ServicePresenceStatusRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_ServicePresenceStatusRepo. Calls super constructor which sets this.sObjectType to 'ServicePresenceStatus'
     */
    public VCR_ServicePresenceStatusRepo() {
        super(ServicePresenceStatus.sObjectType);
    }

    /**
     * @description         fetches Service Presence Status with the given developer name
     * @param developerName the DeveloperName of the Service Presence Status
     * @return              `ServicePresenceStatu>` Service Presence Status with the given developer name
     */
    public ServicePresenceStatus fetchByDeveloperName(String developerName) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'developerName' => developerName };

        String selectClause = 'SELECT Id, DeveloperName';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE DeveloperName = :developerName';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';
        List<ServicePresenceStatus> fetchResults = (List<ServicePresenceStatus>) this.fetch(query, bindParams);
        return fetchResults != null && !fetchResults.isEmpty() ? fetchResults[0] : null;
    }
}
