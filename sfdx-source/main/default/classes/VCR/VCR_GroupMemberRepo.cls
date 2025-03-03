/**
 * @description This repository is for Group Member Database Operations
 * @author Booz Allen Hamilton
 *
 * @see VTC_BaseRepo
 * @see VCR_GroupMemberRepoTest
 */
public virtual inherited sharing class VCR_GroupMemberRepo extends VTC_BaseRepo {
    /**
     * @description - Constructor function for VCR_GroupMemberRepo. Calls super constructor which sets this.sObjectType to 'GroupMember'
     */
    public VCR_GroupMemberRepo() {
        super(GroupMember.SObjectType);
    }

    /**
     * @description - Fetches records from the GroupMember where the provided Id matches any UserOrGroupId. The GroupId is used in further queries.
     * @param userOrGroupId - User being queried
     * @return - A list of GroupMember records where the Id provided is the UserOrGroupId
     */
    public List<GroupMember> fetchByUserOrGroupId(Id userOrGroupId) {
        List<GroupMember> memberList = new List<GroupMember>();
        String selectClause = 'SELECT GroupId,UserOrGroupId';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE UserOrGroupId = :userOrGroupId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        Map<String, Object> bindParams = new Map<String, Object>{ 'userOrGroupId' => userOrGroupId };
        memberList = (List<GroupMember>) this.fetch(query, bindParams);

        return memberList;
    }
}
