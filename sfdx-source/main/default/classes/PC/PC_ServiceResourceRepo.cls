/**
 * @description Repository class for the Service Resource object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_ServiceResourceRepo extends VCR_ServiceResourceRepo {
    /**
     * @description Constructor function for PC_ServiceResourceRepo - calls base class to set SObjectType
     */
    public PC_ServiceResourceRepo() {
        super();
    }

    /**
     * @description get list of service resource records related to the current running user
     * @return      `List<ServiceResource>` list of service resource records related to the current user
     */
    public List<ServiceResource> getServiceResourcesRunningUser() {
        Map<String, Object> bindParams = new Map<String, Object>{ 'userId' => UserInfo.getUserId() };
        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE RelatedRecordId = :userId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<ServiceResource>) this.fetch(query, bindParams);
    }
}
