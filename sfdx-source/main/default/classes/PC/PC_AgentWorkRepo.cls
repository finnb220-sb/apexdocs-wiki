/**
 * @description Repository class for the Agent Work object to hold its respective query and DML logic for Provider Connect.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_AgentWorkRepo extends VCR_AgentWorkRepo {
    /**
     * @description Constructor function for PC_AgentWorkRepo. Calls super constructor which sets this.sObjectType to 'AgentWork'
     */
    public PC_AgentWorkRepo() {
        super();
    }

    /**
     * @description    queries the aggregate result of the current capacity weight total of open cases for each agent (of a specific VISN (Division), if provided)
     * @param division allows the results to be limited by VISN of the running user (which then limits the aggregated agents by ones with the same VISN)
     * @return         `List<AggregateResult>` Aggregate result with capacity weight sum per user Id (agent)
     */
    public List<AggregateResult> getAgentWorkAggregate(String division) {
        Map<String, Object> bindParams = new Map<String, Object>();

        String additionalWhereClause;
        if (PC_PrcConfigSettingsUtility.visnRoutingEnabled && String.isNotBlank(division)) {
            additionalWhereClause = ' ' + 'AND User.Division = :division';
            bindParams.put('division', division);
        } else {
            additionalWhereClause = '';
        }

        String selectClause = 'SELECT SUM(CapacityWeight) TotalCapacity, UserId';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Status = \'Opened\'' + additionalWhereClause;
        string groupByClause = 'GROUP BY UserId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + groupByClause;
        return (List<AggregateResult>) this.fetch(query, bindParams);
    }

    /**
     * @description    Gets the aggregate result of the current capacity weight total of open cases for each agent
     * @param division allows the results to be limited by VISN of the running user (which then limits the aggregated agents by ones with the same VISN)
     * @return         `List<AgentWorkCapacityWrapper>` Aggregate result with capacity weight sum per user Id (agent)
     */
    public List<AgentWorkCapacityWrapper> getAgentWorkCapacity(String division) {
        List<AggregateResult> aggrWorkResults = getAgentWorkAggregate(division);

        List<AgentWorkCapacityWrapper> agentWorkCapacityList = new List<AgentWorkCapacityWrapper>();
        for (AggregateResult aggrWork : aggrWorkResults) {
            agentWorkCapacityList.add(
                new AgentWorkCapacityWrapper((Id) aggrWork.get('UserId'), (Decimal) aggrWork.get('TotalCapacity'))
            );
        }

        return agentWorkCapacityList;
    }

    /**
     * @description Gets the aggregate result of the current capacity weight total of open cases for each agent
     * @return      `List<AggregateResult>` Aggregate result with capacity weight sum per user Id (agent)
     */
    public List<AgentWorkCapacityWrapper> getAgentWorkCapacity() {
        return getAgentWorkCapacity('');
    }

    /**
     * @description  retrieves Agent Work record related to a specific case Id
     * @param caseId Id of the related Case
     * @return       `AgentWork` Agent Work record related to the provided case
     */
    public AgentWork getAgentWorkByCaseId(Id caseId) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'caseId' => caseId };

        String selectClause = 'SELECT Id, UserId, User.Email, User.Name, User.MediumPhotoUrl, WorkItemId';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE WorkItemId = :caseId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + 'LIMIT 1';
        List<AgentWork> queryResults = (List<AgentWork>) this.fetch(query, bindParams);

        return queryResults != null && !queryResults.isEmpty() ? queryResults[0] : null;
    }

    /**
     * @description wrapper class to hold agent work capacity aggregate result data
     */
    public class AgentWorkCapacityWrapper {
        /**
         * @description User Id of the specialist
         */
        public Id userId {
            /**
             * @description getter for userId
             */
            get;
            /**
             * @description setter for userId
             */
            private set;
        }

        /**
         * @description Sum of the weight of all work assigned to the specialist currently
         */
        public Decimal totalCapacity {
            /**
             * @description getter for userId
             */
            get;
            /**
             * @description setter for userId
             */
            private set;
        }

        /**
         * @description         constructor for agent work capacity wrapper
         * @param userId        user Id of the specialist
         * @param totalCapacity sum of the weight of all work assigned to the specialist currently
         */
        public AgentWorkCapacityWrapper(Id userId, Decimal totalCapacity) {
            this.userId = userId;
            this.totalCapacity = totalCapacity;
        }
    }
}
