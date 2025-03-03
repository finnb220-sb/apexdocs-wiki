/**
 * @description       : Controller class for the Tele Ec Escalation and Pause functionality. Called by tucAssignFromQueue.lwc
 * @author            : Booz Allen Hamilton
 **/
public with sharing class TUC_EscalatePauseButtonController {
    @TestVisible
    /**
     * @description - Static instantiation of the TUC_TeleEcEscalationStatusRepo for test memoization.
     */
    private static TUC_TeleEcEscalationStatusRepo memoizedEscalationRepo;
    @TestVisible
    /**
     * @description - Static instantiation of the TUC_TeleEcEscalationStatusRepo.
     */
    private static TUC_TeleEcEscalationStatusRepo escalationRepo {
        get {
            if (memoizedEscalationRepo == null) {
                memoizedEscalationRepo = new TUC_TeleEcEscalationStatusRepo();
            }
            return memoizedEscalationRepo;
        }
    }

    /**
     * @description - returns a user's visn data
     * @return String - a String pertaining to the user's assigned VISN from the Division field
     */
    @AuraEnabled
    public static String getVISNData() {
        return tucCommonUtils.getUserDivisionVISN(); //this reference will be updated later, still currently does what is needed
    }

    /**
     * @description - takes in a JSON of field data, then passes a deserialized map to the creation method
     * @param fieldsJSON - the JSON containing field data passed from LWC
     * @return String - a status string returned to LWC
     */
    @AuraEnabled
    public static String createTeleEcStatusRecord(String fieldsJSON) {
        //logic might be moved to a new TUC_CommonUtils, but only this class uses the logic right now
        Map<String, String> fieldsMap = deserializeJSONIntoMap(fieldsJSON);
        return createTeleEcStatusRecordMap(fieldsMap);
    }

    /**
     * @description - takes in a map of fields, then creates a new Tele Ec Escalation Status record to replace the current status of a VISN/Queue combo
     * @param fieldsMap - the fields provided from the LWC to be parsed and built into a new status record
     * @return String - a status string returned to LWC
     */
    @AuraEnabled
    public static String createTeleEcStatusRecordMap(Map<String, String> fieldsMap) {
        Tele_EC_Escalation_Status__c currentStatusRecord = getCurrentStatusRecord(
            fieldsMap.get('providedVISN'),
            fieldsMap.get('queueType')
        );
        String currentStatus;
        if (currentStatusRecord != null) {
            currentStatus = currentStatusRecord.TUC_Status_Type__c;
            currentStatusRecord.TUC_Is_Current_Status__c = false;
            currentStatusRecord.TUC_Queue_Type__c = fieldsMap.get('queueType');
            escalationRepo.doUpdate(currentStatusRecord);
        }

        Tele_EC_Escalation_Status__c statusRecord = new Tele_EC_Escalation_Status__c();
        DateTime sys = System.now();
        statusRecord.TUC_Status_Datetime__c = DateTime.newInstance(
            sys.year(),
            sys.month(),
            sys.day(),
            sys.hour(),
            sys.minute(),
            0
        );
        statusRecord.TUC_VISN__c = fieldsMap.get('providedVISN');
        statusRecord.TUC_Is_Current_Status__c = true;
        statusRecord.TUC_Queue_Type__c = fieldsMap.get('queueType');
        statusRecord.TUC_Pause_Reason__c = fieldsMap.get('pauseReason');

        if (currentStatus == 'Paused') {
            statusRecord.TUC_Original_Pause_Record__c = currentStatusRecord.Id; //if currently paused, add the original pause to the next status
        }

        /* //this is only needed if we add more status types besides paused and resumed. Add parent field to the soql query in getCurrentStatusRecord if implementing later.
        if(currentStatusRecord.TUC_Original_Pause_Record__c != null) {
            statusRecord.TUC_Original_Pause_Record__c = currentStatusRecord.TUC_Original_Pause_Record__c; //if currentStatus has a parent, add it to the new status as well
        }
        */

        if (currentStatus == 'Resumed' || currentStatus == null) {
            statusRecord.TUC_Status_Type__c = 'Paused';
        } else {
            statusRecord.TUC_Status_Type__c = 'Resumed';
        }

        escalationRepo.doCreate(statusRecord);

        return 'Success';
    }

    /**
     * @description - provides a VISN and queue, then queries the custom repo for the current statuses matching those input and returns the record
     * @param providedVISN - the VISN a status record is being requested for
     * @param queueType - the Type of Queue a status record is being requested for
     * @return Tele_EC_Escalation_Status__c - the current status record for the provided data
     */
    @AuraEnabled
    public static Tele_EC_Escalation_Status__c getCurrentStatusRecord(String providedVISN, String queueType) {
        //logic might be moved to a new TUC_CommonUtils, but only this class uses the logic right now
        List<Tele_EC_Escalation_Status__c> currentStatusList = (List<Tele_EC_Escalation_Status__c>) escalationRepo.getEscalationStatusWithVisnAndQueueType(
            providedVISN,
            queueType
        );
        Tele_EC_Escalation_Status__c currentStatusRecord;
        if (currentStatusList.size() > 0) {
            currentStatusRecord = currentStatusList[0];
        }

        return currentStatusRecord;
    }

    /**
     * @description - takes in a JSON string, deserializes the string, then returns the result map
     * @param fieldsJSON - a JSON string that roughly translates into a map of Fields API names and values to set into them
     * @return Map<String, String> - A result map of Fields API names and values
     */
    private static Map<String, String> deserializeJSONIntoMap(String fieldsJSON) {
        Map<String, String> fieldsMap = new Map<String, String>();
        try {
            fieldsMap = (Map<String, String>) JSON.deserialize(fieldsJSON, Map<String, String>.class);
            return fieldsMap;
        } catch (JSONException jsonException) {
            String errorMessage = 'JSON is malformed. Message: ' + jsonException.getMessage();
            Logger.error(errorMessage, jsonException);
            Logger.saveLog();
            AuraHandledException auraException = new AuraHandledException(errorMessage);
            auraException.setMessage(errorMessage);
            throw auraException;
        }
    }
}
