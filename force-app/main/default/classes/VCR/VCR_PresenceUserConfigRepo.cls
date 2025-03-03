/**
 * @description Repository class for the PresenceUserConfig object to hold its respective query and DML logic
 * @author Booz Allen
 * @since 2024
 */
public virtual inherited sharing class VCR_PresenceUserConfigRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_PresenceUserConfigRepo. Calls super constructor which sets this.sObjectType to 'PresenceUserConfig'
     */
    public VCR_PresenceUserConfigRepo() {
        super(PresenceUserConfig.sObjectType);
    }

    /**
     * @description  retrieves the Presence Configuration with the provided DeveloperName
     * @param presenceConfigDeveloperName API Developer name of the presence configuration
     * @return                            `PresenceUserConfig` The presence configuration with the provided developer name
     */
    public PresenceUserConfig fetchPresenceUserConfigByDeveloperName(String presenceConfigDeveloperName) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'presenceConfigDeveloperName' => presenceConfigDeveloperName
        };

        String selectClause = 'SELECT Capacity';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE DeveloperName = :presenceConfigDeveloperName';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';
        return ((List<PresenceUserConfig>) this.fetch(query, bindParams))?.get(0);
    }
}
