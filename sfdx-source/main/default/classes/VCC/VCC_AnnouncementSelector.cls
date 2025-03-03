/**
 * @author VAHC Liberty IT
 * @since 8/5/2023
 * @description Selector for Announcements.
 */

@SuppressWarnings('PMD.ApexSOQLInjection, sf:SOQLInjection')
public without sharing class VCC_AnnouncementSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        Announcement__c.Id,
        Announcement__c.Name,
        Announcement__c.Active__c,
        Announcement__c.End_Date__c,
        Announcement__c.Start_Date__c,
        Announcement__c.Order__c,
        Announcement__c.RecordTypeId,
        Announcement__c.Message__c
    };
    /**
     * @description return SObject
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Announcement__c.SObjectType;
    }
    /**
     * @description return the SObjectField
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }
    /**
     * @description add SObjectFields to query
     * @param List<Schema.SObjectField> sObjectFields
     */
    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    /**
     * @description set the order
     * @return String
     */
    public override String getOrderBy() {
        return 'Order__c ASC';
    }
    /**
     * @description to get active announcements
     * @return List<Announcement__c>
     */
    public List<Announcement__c> selectActiveAnnouncement() {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition(
            'Active__c = true ' +
                'AND ( ' +
                ' (Start_Date__c = null AND End_Date__c != null AND  End_Date__c >= TODAY ) ' +
                ' OR (End_Date__c = null AND Start_Date__c != null AND  Start_Date__c <= TODAY ) ' +
                ' OR (End_Date__c = null AND Start_Date__c = null) ' +
                ' OR (End_Date__c != null AND Start_Date__c != null AND Start_Date__c <= TODAY AND End_Date__c >=TODAY  ) ' +
                ')'
        );

        List<Announcement__c> announcementList = (List<Announcement__c>) Database.query(query.toSOQL());
        return announcementList;
    }
}
