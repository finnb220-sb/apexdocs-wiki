/**
 * Author:Jaren Yach
 *  Created Date 05/09/2022
 *  Purpose: This class is used to delete custom setting records
 *  in a sandbox to prevent production values from being used
 *
 *  Without sharing is used because this needs to run in a system context.
 */
public without sharing class DeleteCustomSettingsBatch implements Database.Batchable<String> {
    public Iterable<String> start(Database.BatchableContext context) {
        List<String> objList = new List<String>();
        //Get the custom setting objects that need their records deleted.
        DTCSandboxRefreshClearSettingSelector settingSelector = (DTCSandboxRefreshClearSettingSelector) Injector.getInjector().instantiate('DTCSandboxRefreshClearSettingSelector');

        for (DTC_Sandbox_Refresh_Clear_Custom_Setting__mdt rec : settingSelector.getAllRecords()) {
            try {
                SObjectType objType = ((SObject) Type.forName(rec.Api_Object_Name__c).newInstance()).getSObjectType();
                objList.add(objType.getDescribe().getName());
            } catch (Exception ex) {
                //just debug the failure because we want to process the next record
                System.debug(rec.Api_Object_Name__c + ' does not exist');
            }
        }
        return objList;
    }

    public void execute(Database.BatchableContext context, List<String> objList) {
        Map<Id, SObject> recordMap = new Map<Id, SObject>();
        for (String sobj : objList) {
            //Yes, this is doing a soql in a for loop, but the scope should be limited since the
            //values are group by sobject type and there should never be 100 different custom setting object
            //records to delete.
            String template = 'SELECT Id FROM {0}';
            List<String> vars = new List<String>();
            vars.add(sobj);
            String soql = String.format(template, vars);
            List<SObject> customSettingRecs = Database.query(soql);
            recordMap.putAll(customSettingRecs);
        }

        if (recordMap.size() > 0) {
            Database.delete(recordMap.values(), false);
        }
    }

    public void finish(Database.BatchableContext context) {
        DTCUtils.sendCompletedBatchJobEmail(context.getJobId());
    }

    /**
     * Easy way to run this batch job
     */
    public static String run() {
        return Database.executeBatch(new DeleteCustomSettingsBatch());
    }
}
