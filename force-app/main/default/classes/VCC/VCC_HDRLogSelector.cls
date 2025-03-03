/**
 * VCC_HDRLogSelector
 * @description Common selector for VCC_HDR_Log__c.
 * @author Kumar
 * @date 18/5/2022
 */
public with sharing class VCC_HDRLogSelector extends fflib_SObjectSelector {
    public static String HDRDownLogType = 'HDR Down';
    public static String MPIDownLogType = 'MPI Down';
    public static String MPIDownLogType2 = 'MPI Down 2';
    public static Integer MPIDownLogMaxLimit = 1;

    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        VCC_HDR_Log__c.Id,
        VCC_HDR_Log__c.Name,
        VCC_HDR_Log__c.VCC_Type__c,
        VCC_HDR_Log__c.VCC_Exception_Message__c,
        VCC_HDR_Log__c.VCC_Send_Email__c,
        VCC_HDR_Log__c.CreatedDate
    };

    public Schema.SObjectType getSObjectType() {
        return VCC_HDR_Log__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    public List<VCC_HDR_Log__c> selectById(Set<Id> ids) {
        return (List<VCC_HDR_Log__c>) selectSObjectsById(ids);
    }

    public List<VCC_HDR_Log__c> getTodayHDRDownLog() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('CreatedDate = TODAY AND VCC_Type__c=:HDRDownLogType');
        query.addOrdering(new fflib_QueryFactory.Ordering('VCC_HDR_Log__c', 'CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING));

        List<VCC_HDR_Log__c> HDRLogList = (List<VCC_HDR_Log__c>) Database.query(query.toSOQL());
        return HDRLogList;
    }

    public List<VCC_HDR_Log__c> getTodayMPIDownLog() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('CreatedDate = TODAY AND (VCC_Type__c=:MPIDownLogType OR VCC_Type__c=:MPIDownLogType2)');
        query.addOrdering(new fflib_QueryFactory.Ordering('VCC_HDR_Log__c', 'CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING));

        List<VCC_HDR_Log__c> HDRLogList = (List<VCC_HDR_Log__c>) Database.query(query.toSOQL());
        return HDRLogList;
    }
}
