/**
 * @description Repository class for the Service Resource Skill object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 * @justification PrC Specialists require deleting/inserting ServiceResourceSkill records for the three channel skills ('Chat', 'Phone', 'Teams') as part of their custom Channel Selection Omni-channel component.
 *                The Sharing rules for PrC ServiceResources only provide Specialists with Read Only access to those records, but Write access is required for creating/deleting related ServiceResourceSkills.
 *                We do not want to allow Specialists to edit/delete these Service Resources through normal means, so we are adding DML operations that run in System Mode for ServiceResourceSkill instead.
 */
public virtual inherited sharing class VCR_ServiceResourceSkillRepo extends VTC_BaseRepo {
    /**
     * @description default constructor function for VCR_ServiceResourceSkillRepo. Calls super constructor which sets this.sObjectType to 'ServiceResourceSkill'
     */
    public VCR_ServiceResourceSkillRepo() {
        super(ServiceResourceSkill.sObjectType);
    }
    /**
     * @description      Constructor function for VCR_ServiceResourceSkillRepo. Calls super constructor which sets this.sObjectType to 'ServiceResourceSkill' and allows setting value of allowUnsafe to TRUE/FALSE (see @justification above)
     * @param allowUnsafe allows for database operations to perform in System.Mode
     */
    public VCR_ServiceResourceSkillRepo(Boolean allowUnsafe) {
        super(ServiceResourceSkill.sObjectType, allowUnsafe);
    }

    /**
     * @description Performs unsafe Insert in System Mode (see @justification above).
     * @param recordList ServiceResourceSkill records to be inserted unsafely.
     */
    public void performCreateUnsafe(List<ServiceResourceSkill> recordList) {
        try {
            this.doCreateUnsafe(recordList);
        } catch (Exception caughtException) {
            Logger.error(
                'doCreateUnsafe failed to insert ServiceResourceSkill records: ' + JSON.serialize(recordList),
                caughtException
            );
            throw new PC_CustomException(caughtException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Performs unsafe Delete in System Mode (see @justification above).
     * @param recordList ServiceResourceSkill records to be deleted unsafely.
     */
    public void performDeleteUnsafe(List<ServiceResourceSkill> recordList) {
        try {
            this.doDeleteUnsafe(recordList);
        } catch (Exception caughtException) {
            Logger.error(
                'doDeleteUnsafe failed to delete ServiceResourceSkill records: ' + JSON.serialize(recordList),
                caughtException
            );
            throw new PC_CustomException(caughtException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description retrieves a list of Service Resource Skills with the provided specialty (Skill) where the parent Service Resource is a Provider Connect Specialist who is active in omni-channel and is located at one of the provided Host Locations
     * @param specialty                  Specialist (aka Skill) required by the Specialist
     * @param hostLocationIds            List of Locations, one of which is required by the Specialist
     * @param availableSpecialistUserIds List of Specialist User Ids available in omni-channel
     * @return                           `List<ServiceResourceSkill>` List of ServiceResourceSkill records that satisfy the above criteria. This query result is used to derive a list of Service Resources with the provided specialty (skill) that also satisfy the following criteria: is an Agent, is Active, is a PC_Resource, is located at one of the provided host Locations, and is currently online and available in omni-channel
     */
    public List<ServiceResourceSkill> getServiceResourceSkillsApplicableToNDTHRoutingCriteria(
        String specialty,
        Set<Id> hostLocationIds,
        Set<Id> availableSpecialistUserIds
    ) {
        Id pcResourceRecordTypeId = new VCR_ServiceResourceRepo()
            .recordTypeConstant.fromDeveloperName('PC_Resource')
            .Id;

        Map<String, Object> bindParams = new Map<String, Object>{
            'specialty' => specialty,
            'hostLocationIds' => hostLocationIds,
            'availableSpecialistUserIds' => availableSpecialistUserIds,
            'pcResourceRecordTypeId' => pcResourceRecordTypeId
        };

        String selectClause = 'SELECT ServiceResourceId, ServiceResource.RelatedRecordId, ServiceResource.PC_Location__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ServiceResource.ResourceType = \'A\' AND ServiceResource.IsActive = true AND ServiceResource.RecordTypeId = :pcResourceRecordTypeId AND Skill.MasterLabel = :specialty AND ServiceResource.PC_Location__c IN :hostLocationIds AND ServiceResource.RelatedRecordId IN :availableSpecialistUserIds';
        String orderByClause = 'ORDER BY ServiceResourceId DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return (List<ServiceResourceSkill>) this.fetch(query, bindParams);
    }
}
