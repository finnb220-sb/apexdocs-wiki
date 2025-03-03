/**
 * @description       :
 * @author            : UNKNOWN
 * @group             :
 * @last modified on  : 05-12-2023
 * @last modified by  : Ronald Stewart
 **/
public with sharing class VCC_TaskController {
    /**
     * @description  This prevents Task delete if Task RecordType VCC_Calls or VCC_VCV_Follow_Up
     * @author UNKNOWN | 05-12-2023
     * @param oldRecs
     **/
    public static void preventTaskDelete(List<Task> oldRecs) {
        hasDisableTriggersFlag();

        // task recordtype VCC_Calls id
        string callsRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCC_Calls').getRecordTypeId();
        string followupRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('VCC_VCV_Follow_Up').getRecordTypeId();
        Boolean isMP = FeatureManagement.checkPermission('VCC_Medical_Provider');
        for (Task rec : oldRecs) {
            // if task recordtype = VCC_Calls or VCC_FollowUp
            if ((rec.RecordTypeId == followupRecTypeId && isMP) || rec.RecordTypeId == callsRecTypeId) {
                // add error to prevent delete. Display custom label message.
                rec.adderror(rec.RecordTypeId == followupRecTypeId ? System.Label.VCC_Prevent_Delete_Task_Message : System.Label.VCC_Prevent_Delete_Generic_Task_Message);
            }
        }
    }

    /**
     * @description Exit the preventTaskDelete method if the user has the DisableTriggersFlag custom permission set
     * @author Ronald Stewart | 05-12-2023
     **/
    private static void hasDisableTriggersFlag() {
        if (FeatureManagement.checkPermission('DisableTriggersFlag')) {
            return;
        }
    }
}
