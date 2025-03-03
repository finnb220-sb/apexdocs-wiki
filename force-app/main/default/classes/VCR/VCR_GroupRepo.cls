/**
 * @description This repository is for Group Member Database Operations
 * @author Booz Allen Hamilton
 *
 * @see VTC_BaseRepo
 * @see VCR_GroupRepoTest
 */
public virtual inherited sharing class VCR_GroupRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_GroupRepo. Calls super constructor which sets this.sObjectType to 'Group'
     */
    public VCR_GroupRepo() {
        super(Group.SObjectType);
    }

    /**
     * @description Fetches record from the Group where the Developer Name of the group is provided
     * @param devName - A string that represents the Developer Name of a desired group
     * @return Group - A Group record returned from the query
     *                 Will return null if no group is found or if an improper input is provided
     */
    public Group fetchByDeveloperName(String devName) {
        List<Group> groupList = new List<Group>();
        if (String.isBlank(devName)) {
            return null;
        }
        String selectClause = 'SELECT Id, DeveloperName';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE DeveloperName =: devName';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';
        Map<String, Object> bindParams = new Map<String, Object>{ 'devName' => devName };
        groupList = (List<Group>) this.fetch(query, bindParams);
        Group groupRecord;
        if (groupList.size() > 0) {
            groupRecord = groupList[0];
        }

        return groupRecord;
    }

    /**
     * @description Fetches records from the Group where the Groups are being queried using a provided list of Group Ids.
     * @param groupIdList - List of Groups being queried
     * @return List<Group> - A list of Group records where the Groups are from a list of Group Ids
     *                       Will return an empty list if no groups are found, or from improper inputs
     */
    public List<Group> fetchByGroupIdList(List<Id> groupIdList) {
        List<Group> groupList = new List<Group>();
        if (groupIdList == null || groupIdList.isEmpty()) {
            return groupList;
        }
        String selectClause = 'SELECT DeveloperName';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id IN :groupIdList';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        Map<String, Object> bindParams = new Map<String, Object>{ 'groupIdList' => groupIdList };
        groupList = (List<Group>) this.fetch(query, bindParams);

        return groupList;
    }
}
