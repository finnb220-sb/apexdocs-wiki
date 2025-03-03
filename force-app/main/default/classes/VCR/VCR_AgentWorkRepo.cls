/**
 * @description Repository class for the Agent Work object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public virtual inherited sharing class VCR_AgentWorkRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_AgentWorkRepo. Calls super constructor which sets this.sObjectType to 'AgentWork'
     */
    public VCR_AgentWorkRepo() {
        super(AgentWork.sObjectType);
    }
}
