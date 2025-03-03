/**
 * @description This trigger action prevents deletion of a Task record when its RecordType is VCC_Calls or VCC_VCV_Follow_Up.
 * The error message stored in CustomLabel VCC_Prevent_Delete_Task_Message is added to the record when it's found to be have one of these RecordTypes.
 */
public with sharing class VCC_TaskPreventDeleteBD implements TriggerAction.BeforeDelete {
    @TestVisible
    private static final String PREVENT_DELETE_ERROR_MESSAGE = System.Label.VCC_Prevent_Delete_Task_Message;
    private static final String PREVENT_DELETE_ERROR_MESSAGE_GENERIC = System.Label.VCC_Prevent_Delete_Generic_Task_Message;
    /**
     * @description Prevent delete Task on VCC_Calls, VCC_VCV_Follow_Up and VCC_Verify_Caller record types.
     * @param oldList List of Tasks slated for deletion
     */
    public void beforeDelete(List<Task> oldList) {
        if (oldList == null || oldList.isEmpty()) {
            return;
        }
        String callsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get('VCC_Calls')
            .getRecordTypeId();
        String followupRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get('VCC_VCV_Follow_Up')
            .getRecordTypeId();
        String vahcVerifyCallerRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
            .get('VCC_Verify_Caller')
            .getRecordTypeId();
        Boolean isMP = FeatureManagement.checkPermission('VCC_Medical_Provider');
        for (Task rec : oldList) {
            if (
                (rec.RecordTypeId == followupRecTypeId && isMP) ||
                rec.RecordTypeId == callsRecTypeId ||
                rec.RecordTypeId == vahcVerifyCallerRecTypeId
            ) {
                rec.adderror(
                    rec.RecordTypeId == followupRecTypeId
                        ? PREVENT_DELETE_ERROR_MESSAGE
                        : System.Label.VCC_Prevent_Delete_Generic_Task_Message
                );
            }
        }
    }
}
