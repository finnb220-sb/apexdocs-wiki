/**
 * @description Location Repository class implementing the v pattern
 * Created by riadhmankai on 5/23/24.
 */

public inherited sharing class VCR_LocationRepo extends VTC_BaseRepo {
    /**
     * @description Default constructor
     */
    public VCR_LocationRepo() {
        super(Schema.Location.SObjectType);
    }

    /**
     * @description Fetch the locations that are located inside of the locationExternalIds for display later on
     * @param locationExternalIds External Facility (Location) IDs
     * @return Locations matching the external IDs passed in parameter
     */
    public List<Schema.Location> fetchLocationsByExternalId(Set<String> locationExternalIds) {
        return (List<Schema.Location>) fetch(
            'SELECT Id, Name, Common_Name__c, VAF_Facility_ID__c ' +
                'FROM Location ' +
                'WHERE VAF_Facility_ID__c IN :locationExternalIds',
            new Map<String, Object>{ 'locationExternalIds' => locationExternalIds }
        );
    }
}
