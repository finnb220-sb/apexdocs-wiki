/**
 * @description Repository class for the Service Resource Skill object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_ServiceResourceSkillRepo extends VCR_ServiceResourceSkillRepo {
    private final Id pcResourceRecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
        .get('PC_Resource')
        .getRecordTypeId();

    private final Set<String> channelAvailabilitySkills = new Set<String>{ 'Chat', 'Teams', 'Phone' };

    /**
     * @description default Constructor function for PC_ServiceResourceSkillRepo. Calls super constructor which sets this.sObjectType to 'ServiceResourceSkill'
     */
    public PC_ServiceResourceSkillRepo() {
        super();
    }

    /**
     * @description       Overloaded Constructor function for PC_ServiceResourceSkillRepo. Calls super constructor which sets this.sObjectType to 'ServiceResourceSkill' and sends in a value of allowUnsafe property to do system mode operations
     * @param allowUnsafe Allows for database operations to perform in System.Mode
     */
    public PC_ServiceResourceSkillRepo(Boolean allowUnsafe) {
        super(allowUnsafe);
    }

    /**
     * @description       Retrieves a list of service resource skill junctions with criteria based on the active routing configuration
     * @param division    VISN to match service resource's VISN (division) - used for VISN Routing
     * @param skillNames  Skills to match - used for NDTH Agreement routing
     * @param locationIds Locations to match to service resource's location - used for NDTH Agreement routing
     * @return            `List<ServiceResourceSkill>` list of junctions returned by query
     */
    public List<ServiceResourceSkill> getServiceResourceSkills(
        String routingType,
        String division,
        Set<String> skillNames,
        Set<Id> locationIds
    ) {
        Boolean isNDTHRouting = 'NDTH'.equalsIgnoreCase(routingType);
        Boolean isVISNRouting = 'VISN'.equalsIgnoreCase(routingType);

        Map<String, Object> bindParams = new Map<String, Object>{
            'pcResourceRecordTypeId' => this.pcResourceRecordTypeId
        };

        String additionalWhereClause;
        if (isNDTHRouting) {
            //Add the channel availability skills (Chat/Teams/Phone) so they can be picked up as well for conditional disabling/enabling of buttons
            skillNames.addAll(channelAvailabilitySkills);
            additionalWhereClause =
                ' ' + 'AND Skill.MasterLabel IN: skillNames AND ServiceResource.PC_Location__c IN :locationIds';
            bindParams.put('skillNames', skillNames);
            bindParams.put('locationIds', locationIds);
        } else if (isVISNRouting) {
            additionalWhereClause = ' ' + 'AND ServiceResource.RelatedRecord.Division = :division';
            bindParams.put('division', division);
        } else {
            additionalWhereClause = '';
        }

        String selectClause = 'SELECT SkillLevel, SkillId, Skill.MasterLabel, ServiceResourceId, ServiceResource.RelatedRecordId, ServiceResource.PC_Location__c';
        String fromClause = this.calculateFromClause();
        String whereClause =
            'WHERE ServiceResource.ResourceType = \'A\' AND ServiceResource.IsActive = TRUE AND ServiceResource.RecordTypeId = :pcResourceRecordTypeId' +
            additionalWhereClause;
        String orderByClause = 'ORDER BY Skill.MasterLabel ASC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return (List<ServiceResourceSkill>) this.fetch(query, bindParams);
    }

    /**
     * @description Retrieves a list of service resource skill junctions for active PC agents
     * @return      `List<ServiceResourceSkill>` list of service resource skills of active PC agents
     */
    public List<ServiceResourceSkill> getServiceResourceSkills() {
        return getServiceResourceSkills(null, null, null, null);
    }

    /**
     * @description    (VISN ROUTING ONLY) retrieves a list of service resource skill junctions for active PC agents with the provided VISN (division)
     * @param division VISN to match service resource's VISN (division)
     * @return         `List<ServiceResourceSkill>` list of junctions returned by query
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsVISNRouting(String division) {
        return getServiceResourceSkills('VISN', division, null, null);
    }

    /**
     * @description       (NDTH AGREEMENT ROUTING ONLY) retrieves a list of service resource skill junctions for active PC agents from one of the provided locations with one of the provided skills
     * @param skillNames  Skills to match
     * @param locationIds Locations to match to service resource's location
     * @return            `List<ServiceResourceSkill>` list of junctions returned by query
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsNDTHRouting(Set<String> skillNames, Set<Id> locationIds) {
        return getServiceResourceSkills('NDTH', null, skillNames, locationIds);
    }

    /**
     * @description              Gets a list of service resource skills related to the current user except for skills with the provided developer names
     * @param excludedSkillNames List of developer names for the skills to exclude in the query result
     * @return                   `List<ServiceResourceSkill>` list of service resource skill junctions related to the current user except for junctions related to skills with the provided names
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsExcluding(List<String> excludedSkillNames) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'userId' => UserInfo.getUserId(),
            'excludedSkillNames' => excludedSkillNames
        };
        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ServiceResource.RelatedRecordId = :userId AND Skill.DeveloperName NOT IN :excludedSkillNames';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<ServiceResourceSkill>) this.fetch(query, bindParams);
    }

    /**
     * @description               Gets a list of service resource skills related to the current user with a skill in the provided list of skill developer names
     * @param includedSkillNames  List of skill developer names used for an inclusive query result
     * @return                   `List<ServiceResourceSkill>` list of service resource skills related to the current user with a skill in the provided list of skill developer names
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsIncluding(List<String> includedSkillNames) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'userId' => UserInfo.getUserId(),
            'includedSkillNames' => includedSkillNames
        };
        String selectClause = 'SELECT Id, Skill.DeveloperName';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ServiceResource.RelatedRecordId = :userId AND Skill.DeveloperName IN :includedSkillNames';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<ServiceResourceSkill>) this.fetch(query, bindParams);
    }

    /**
     * @description      Gets a list of service resource skills related to the running user with the provided skill label
     * @param skillLabel Master label of the skill
     * @return           `List<ServiceResourceSkill>` list of service resource skills for the running user related to a skill with the provided label
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsByLabel(String skillLabel) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'userId' => UserInfo.getUserId(),
            'skillLabel' => skillLabel
        };
        String selectClause = 'SELECT Id';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ServiceResource.RelatedRecordId = :userId AND Skill.MasterLabel = :skillLabel';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<ServiceResourceSkill>) this.fetch(query, bindParams);
    }
}
