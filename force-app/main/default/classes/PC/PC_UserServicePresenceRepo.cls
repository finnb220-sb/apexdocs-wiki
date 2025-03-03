/**
 * @description Repository class for the User Service Presence object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_UserServicePresenceRepo extends VCR_UserServicePresenceRepo {
    private final String pcAvailableStatus = 'PC_Available_Provider_Connect';
    private final String pcWrapUpStatus = 'PC_Wrap_Up';

    /**
     * @description Constructor function for PC_UserServicePresenceRepo. Calls super constructor which sets this.sObjectType to 'UserServicePresence'
     */
    public PC_UserServicePresenceRepo() {
        super();
    }

    /**
     * @description    gets a list of OmniChannel users' service presences currently active with the provided criteria depending on the enabled routing type
     * @param division The VISN of the running user (and of the possible agents we can route to) used if VISN Routing is enabled
     * @return         `List<UserServicePresence>` list of users signed in and active with the default status and with the same VISN (division) as the specified parameter
     */
    public List<UserServicePresence> getCurrentUserServicePresence(String division) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'presenceStatus' => this.pcAvailableStatus };

        String additionalWhereClause;
        if (PC_PrcConfigSettingsUtility.visnRoutingEnabled && String.isNotBlank(division)) {
            additionalWhereClause = ' ' + 'AND User.Division = :division';
            bindParams.put('division', division);
        } else {
            additionalWhereClause = '';
        }

        String selectClause = 'SELECT UserId';
        String fromClause = this.calculateFromClause();
        String whereClause =
            'WHERE ServicePresenceStatus.DeveloperName = :presenceStatus AND StatusStartDate >= TODAY AND IsCurrentState = true' +
            additionalWhereClause;
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<UserServicePresence>) this.fetch(query, bindParams);
    }

    /**
     * @description  overridden getCurrentUserServicePresence() with no division provided (for cases of VISN Routing disabled)
     * @return       `List<UserServicePresence>` list of users signed in and active with the default status
     */
    public List<UserServicePresence> getCurrentUserServicePresence() {
        return getCurrentUserServicePresence('');
    }

    /**
     * @description   get the List of service resource with presence status as active by list of user id
     * @param userIdList  get Service resource presence status based on userIdList
     * @return       `List<UserServicePresence>` list of users signed in and active with the default status
     */
    public List<UserServicePresence> getCurrentUserServicePresencebyUserId(List<Id> userIdList) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'presenceStatus' => this.pcAvailableStatus,
            'userIdList' => userIdList
        };
        String selectClause = 'SELECT UserId';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ServicePresenceStatus.DeveloperName = :presenceStatus AND StatusStartDate >= TODAY AND IsCurrentState = true AND UserId IN :userIdList';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<UserServicePresence>) this.fetch(query, bindParams);
    }

    /**
     * @description  gets a list of all current user service presences tied to the provided user to determine if they are currently signed into Omni-channel
     * @param userId SF User Id
     * @return       `List<UserServicePresence>` list of user service presence records for the provided user
     */
    public List<UserServicePresence> getCurrentUserServicePresenceForUser(Id userId) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'userId' => userId };
        String selectClause = 'SELECT UserId, ServicePresenceStatus.DeveloperName';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsCurrentState = TRUE AND UserId = :userId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';
        return (List<UserServicePresence>) this.fetch(query, bindParams);
    }

    /**
     * @description gets a list of all current user service presences tied to the running user to determine if they are currently signed into Omni-channel
     * @return      `List<UserServicePresence>` list of user service presence records for the running user
     */
    public List<UserServicePresence> getCurrentUserServicePresenceForRunningUser() {
        return getCurrentUserServicePresenceForUser((Id) UserInfo.getUserId());
    }
}
