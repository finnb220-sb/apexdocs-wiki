/**
 * @description Repository class for the PrC NDTH Clinical Services object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since  2024
 */
public inherited sharing class PC_NDTHClinicalServicesRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_NDTHClinicalServicesRepo. Calls super constructor which sets this.sObjectType to 'PC_NDTH_Clinical_Services__c'
     */
    public PC_NDTHClinicalServicesRepo() {
        super(PC_NDTH_Clinical_Services__c.sObjectType);
    }

    /**
     * @description     Gets a list of Clinical Services junctions related to the provided NDTH agreements
     * @param ndthIdSet NDTH agreement ids
     * @return          `List<PC_NDTH_Clinical_Services__c>` list of Clinical Service Junctions (with a selected Speciality) related to the NDTH agreements
     */
    public List<PC_NDTH_Clinical_Services__c> getClinicalServicesFromNDTHs(Set<Id> ndthIdSet) {
        String selectClause = 'SELECT PC_Specialty__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE NDTH__c IN :ndthIdSet AND PC_Specialty__c != NULL AND Is_Active__c = TRUE AND NDTH__r.Is_Active__c = TRUE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_NDTH_Clinical_Services__c>) this.fetch(
            query,
            new Map<String, Object>{ 'ndthIdSet' => ndthIdSet }
        );
    }

    /**
     * @description     Gets a list of Clinical Services junctions related to the provided NDTH agreements and skill (specialty)
     * @param ndthIdSet NDTH agreement ids
     * @param skillName resource skill name (specialty)
     * @return          `List<PC_NDTH_Clinical_Services__c>` list of Clinical Service Junctions (with a selected Speciality) related to the NDTH agreements and skill
     */
    public List<PC_NDTH_Clinical_Services__c> getClinicalServicesFromNDTHsandSkills(
        Set<Id> ndthIdSet,
        String skillName
    ) {
        String selectClause = 'SELECT Id, PC_Specialty__c, NDTH__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE NDTH__c IN :ndthIdSet AND PC_Specialty__c = :skillName AND Is_Active__c = TRUE AND NDTH__r.Is_Active__c = TRUE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_NDTH_Clinical_Services__c>) this.fetch(
            query,
            new Map<String, Object>{ 'ndthIdSet' => ndthIdSet, 'skillName' => skillName }
        );
    }

    /**
     * @description     Gets a list of names for Specialties (Skills) provided by NDTH agreements (via a Clinical Service junction)
     * @param ndthIdSet set of NDTH agreement ids
     * @return          `Set<String>` list of Specialty names
     */
    public Set<String> getSpecialtiesForNDTHs(Set<Id> ndthIdSet) {
        Set<String> specialtiesSet = new Set<String>();
        for (PC_NDTH_Clinical_Services__c ndthClinicalService : this.getClinicalServicesFromNDTHs(ndthIdSet)) {
            specialtiesSet.add(ndthClinicalService.PC_Specialty__c);
        }
        return specialtiesSet;
    }

    /**
     * @description     Gets a list of names for Specialties (Skills) provided by NDTH agreements (via a Clinical Service junction)
     * @throw           throws exception if no Specialties available under the NDTH Agreements servicing your current location
     * @param ndthIdSet set of NDTH agreement ids
     * @return          `Set<String>` list of Specialty names
     */
    public Set<String> getSpecialtiesForNDTHsWithEmptyResultHandling(Set<Id> ndthIdSet) {
        Set<String> specialtiesSet = this.getSpecialtiesForNDTHs(ndthIdSet);

        if ((specialtiesSet == null || specialtiesSet.isEmpty())) {
            throw new PC_CustomException(System.Label.PC_No_Specialties_Available);
        } else {
            return specialtiesSet;
        }
    }
}
