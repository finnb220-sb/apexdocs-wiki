/**
 * @description Repo class for the ResourceAbsence sObject.
 */
public inherited sharing class VCR_ResourceAbsenceRepo extends VTC_BaseRepo {
    /**
     * @description argless constructor that sets the Sobject type and adds default select fields.
     */
    public VCR_ResourceAbsenceRepo() {
        super(ResourceAbsence.SObjectType);
        this.defaultSelectFields.addAll(new Set<String>{ 'ResourceId', 'Start', 'End' });
    }

    /**
     * @description Gets Absences related to service resources within a date range.
     * @param serviceResourceIds `Set<Id>` Ids of the ServiceResources we care about.
     * @param range `VCC_DateRange` Range we are filtering by.
     *
     * @return `List<ResourceAbsence>` List of Resource absences.
     */
    public List<ResourceAbsence> getAbsencesInDateRangeForServiceResourcesInList(
        Set<Id> serviceResourceIds,
        VCC_DateRange range
    ) {
        //StartA <= EndB)  and  (EndA >= StartB) then it is overlapping.
        String whereClause = ' WHERE Start <= :endDateTime AND End >=: startDateTime AND ResourceId IN: serviceResourceIds ORDER BY ResourceId';
        String query =
            this.calculateSelectClause(this.defaultSelectFields) +
            ' ' +
            this.calculateFromClause() +
            ' ' +
            whereClause;
        Map<String, Object> binds = new Map<String, Object>{
            'startDateTime' => range.startDateTime,
            'endDateTime' => range.endDateTime,
            'serviceResourceIds' => serviceResourceIds
        };
        return this.fetch(query, binds);
    }
}
