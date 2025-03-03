/**
 * @description Repository class for the Skill object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class VCR_SkillRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_SkillRepo - calls base class to set SObjectType
     */
    public VCR_SkillRepo() {
        super(Skill.SObjectType);
    }

    /**
     * @description      gets a Skill with the provided master label
     * @param skillLabel master label of the Skill record
     * @return           `Skill` skill with the provided label
     */
    public Skill getSkillByLabel(String skillLabel) {
        Map<String, Object> bindParams = new Map<String, Object>{ 'skillLabel' => skillLabel };
        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE MasterLabel = :skillLabel';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ORDER BY CreatedDate DESC LIMIT 1';
        return (Skill) this.fetch(query, bindParams)[0];
    }
}
