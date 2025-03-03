/**
 * @description       : Controller class for the tucCustomCasePath LWC
 * @author            : Booz Allen
 */
public with sharing class TUC_CustomCasePathController {
    @TestVisible
    private static VCR_CaseRepo memoizedCaseRepo;
    @TestVisible
    private static VCR_CaseRepo caseRepo {
        get {
            if (memoizedCaseRepo == null) {
                memoizedCaseRepo = new VCR_CaseRepo();
            }
            return memoizedCaseRepo;
        }
    }

    /**
     * @description gets a Case record and checks that the list returned from the repo has value
     * @param caseId id of the case to be retrieved
     * @return Case returns the case that was retrieved after pulling it from the repo list
     */
    @AuraEnabled
    public static SObject getCaseData(String caseId) {
        if (String.isBlank(caseId)) {
            throw new AuraHandledException('A proper Case Id is required');
        }
        Set<String> additionalFields = new Set<String>{ 'Status' };
        SObject caseRec = caseRepo.fetchById(caseId, additionalFields);
        return caseRec;
    }

    /**
     * @description takes in a list of Case Statuses, checks if they are valid, and returns a wrapped list back for iteration purposes
     * @param providedValues a list of strings which translates into a list of Case Statuses
     * @return List<TUC_PathWrapper> returns a list of TUC_PathWrapper
     */
    @AuraEnabled
    public static List<TUC_PathWrapper> getPickListLabels(List<String> providedValues) {
        if (providedValues == null || providedValues.isEmpty()) {
            throw new AuraHandledException('The list of Provided Values is malformed.');
        }
        List<TUC_PathWrapper> wrapperList = new List<TUC_PathWrapper>();
        Schema.DescribeFieldResult fieldResult = Case.Status.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (providedValues.contains(pickListVal.getValue())) {
                TUC_PathWrapper wrapper = new TUC_PathWrapper();
                wrapper.label = pickListVal.getLabel();
                wrapper.value = pickListVal.getValue();
                wrapperList.add(wrapper);
            }
        }
        return wrapperList;
    }

    /**
     * @description takes in a record Id and JSON string, deserializes the string, then returns a status string from the update method
     * @param recordId id of the record to be updated
     * @param fieldsJSON a JSON string that roughly translates into a map of Fields API names and values to set into them
     * @return String returns a result string
     */
    @AuraEnabled
    public static String updateCaseWithJSONString(String recordId, String fieldsJSON) {
        if (String.isBlank(recordId) || String.isBlank(fieldsJSON)) {
            throw new AuraHandledException('Record Id and Fields JSON are required');
        }
        return updateRecordWithJSONString(recordId, fieldsJSON);
    }

    /**
     * @description takes in a record Id and JSON string, deserializes the string, then returns a status string from the update method
     * @param recordId id of the record to be updated
     * @param fieldsJSON a JSON string that roughly translates into a map of Fields API names and values to set into them
     * @return String returns a result string
     */
    private static String updateRecordWithJSONString(String recordId, String fieldsJSON) {
        Map<String, String> fieldsMap = deserializeJSONIntoMap(fieldsJSON);
        SObject sObjectToUpdate = parseMapIntoSObject(recordId, fieldsMap);
        try {
            caseRepo.doUpdate(sObjectToUpdate);
        } catch (DmlException dmlException) {
            String errorMessage = 'The attempt to update the record failed. Message: ' + dmlException.getMessage();
            Logger.error(errorMessage, dmlException);
            Logger.saveLog();
            throw new AuraHandledException(errorMessage);
        }
        return 'true';
    }

    /**
     * @description takes in a JSON string, deserializes the string, then returns the result map
     * @param fieldsJSON a JSON string that roughly translates into a map of Fields API names and values to set into them
     * @return Map<String, String> A result map of Fields API names and values
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
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description takes in a Map of values, parses them into an SObject to update, then returns the SObject
     * @param recordId id of the record to be updated
     * @param fieldsMap a Map of field API to field Values for updating the record
     * @return SObject returns a result SObject containing updated values
     */
    private static SObject parseMapIntoSObject(String recordId, Map<String, String> fieldsMap) {
        try {
            SobjectType objType = Id.valueOf(recordId).getSObjectType();
            SObject sObjectToUpdate = objType.newSObject();
            sObjectToUpdate.Id = recordId;
            for (String currentKey : fieldsMap.keySet()) {
                sObjectToUpdate.put(currentKey, (String) fieldsMap.get(currentKey));
            }
            return sObjectToUpdate;
        } catch (SObjectException sObjectException) {
            String errorMessage =
                'A bad field was found in the data package. Message: ' + sObjectException.getMessage();
            Logger.error(errorMessage, sObjectException);
            Logger.saveLog();
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description A Wrapper class that holds the label and value of Statuses for the Path list
     */
    public class TUC_PathWrapper {
        /**
         * @description Label of the value
         */
        @AuraEnabled
        public String label { get; set; }
        /**
         * @description Value of the data entry
         */
        @AuraEnabled
        public String value { get; set; }
    }
}
