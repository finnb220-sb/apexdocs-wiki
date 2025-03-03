/**
 * @description This repository is for VCC_Call_Tracking__c Database Operations
 * @author Booz Allen
 * @see VTC_BaseRepo
 */
public virtual inherited sharing class VCR_CallTrackingRepo extends VTC_BaseRepo {
    /**
     * @description Constructor for the Call Tracking Repository. Calls super constructor which sets this.sObjectType to 'VCC_Call_Tracking__c'
     * Adds additional defaultSelectFields
     */
    public VCR_CallTrackingRepo() {
        super(VCC_Call_Tracking__c.SObjectType);
        this.defaultSelectFields.addAll(new Set<String>{ 'VCC_Call_Date_Time__c', 'CreatedDate' });
    }

    // Other queries can be copy pasted here.
    /**
     * @description Retrieves VCC_Call_Tracking__c data that is associated with the record Id passed in.
     * @param recordId - record id
     * @return List<VCC_Call_Tracking__c> - list of Call Tracking Date/Times and Created Dates matching the record id
     */
    public List<VCC_Call_Tracking__c> fetchCallTrackingList(String recordId) {
        Map<String, Object> bindParams = new Map<String, Object>();
        bindParams.put('recordId', recordId);
        String selectClause = this.calculateSelectClause(new Set<String>{ 'VCC_Call_Date_Time__c', 'CreatedDate' });
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE VCC_Progress_Note__c = :recordId ';
        String orderByClause = 'ORDER BY VCC_Call_Date_Time__c ASC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + orderByClause;
        return this.fetch(query, bindParams);
    }
}
