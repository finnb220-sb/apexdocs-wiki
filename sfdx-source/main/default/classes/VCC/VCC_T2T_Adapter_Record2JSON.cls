/**
 * Created by abaddon on 6/29/23.
 */

/**
 * @description         : Class used for mapping and parsing T2T data for several use cases, LWC, VDIF and T2T perpetuity
 * @author              : Christian J. Gonzalez
 * @group               : Team 2
 * @last modified on    : 08/01/2023
 * last modified by     : Christian J Gonzalez
 **/

@SuppressWarnings('PMD.ApexCrudViolation, PMD.ApexDoc')
public with sharing class VCC_T2T_Adapter_Record2JSON {
    public String value;
    public String label;
    public String fieldName;
    public Boolean displayValue;
    public Boolean displayField;

    /*
    JSON Methods
     */

    @SuppressWarnings('PMD.ApexDoc')
    public Object toJSON() {
        Map<String, Object> recordMap = new Map<String, Object>();
        recordMap.put('value', value);
        recordMap.put('label', label);
        recordMap.put('fieldName', fieldName);
        recordMap.put('displayValue', displayValue);
        recordMap.put('displayField', displayField);
        return recordMap;
    }

    @SuppressWarnings('PMD.ApexDoc')
    public void fromJSON(Object json) {
        Map<String, Object> recordMap = (Map<String, Object>) json;
        value = (String) recordMap.get('value');
        label = (String) recordMap.get('label');
        fieldName = (String) recordMap.get('fieldName');
        displayValue = (Boolean) recordMap.get('displayValue');
        displayField = (Boolean) recordMap.get('displayField');
    }

    @SuppressWarnings('PMD.ApexDoc')
    public static String T2TData(String recordId) {
        List<VCC_Progress_Note_Detail__c> Notes = [
            SELECT Id, Name, CreatedDate, LastModifiedDate, VCC_Progress_Note__c, VCC_T2T_Data__c, VCC_T2T_Labs__c
            FROM VCC_Progress_Note_Detail__c
            WHERE VCC_Progress_Note__c = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (Notes == null || Notes.isEmpty() || Notes[0].VCC_T2T_Data__c == null) {
            return null;
        }
        String rawT2TData = Notes.get(0).VCC_T2T_Data__c;
        List<VCC_T2T_Adapter_Record2JSON> records = VCC_T2T_Adapter_Record2JSON.parse(rawT2TData);
        String convertedJson = VCC_T2T_Adapter_Record2JSON.convertToJson(records);
        return convertedJson;
    }
    //default constructor
    @SuppressWarnings('PMD.ApexDoc')
    public VCC_T2T_Adapter_Record2JSON(String value, String label, String fieldName, Boolean displayValue, Boolean displayField) {
        this.value = value;
        this.label = label;
        this.fieldName = fieldName;
        this.displayValue = displayValue;
        this.displayField = displayField;
    }
    /*
    Convert into objects from Json string to map the corresponding fields into the existing format
     */
    @SuppressWarnings('PMD.ApexDoc')
    public static List<VCC_T2T_Adapter_Record2JSON> parse(String json) {
        List<VCC_T2T_Adapter_Record2JSON> records = new List<VCC_T2T_Adapter_Record2JSON>();
        List<Object> jsonList = (List<Object>) System.JSON.deserializeUntyped(json);
        for (Object obj : jsonList) {
            Map<String, Object> recordMap = (Map<String, Object>) obj;
            String fieldName = (String) recordMap.get('fieldName');
            String label = (String) recordMap.get('label');
            String value = (String) recordMap.get('response');

            VCC_T2T_Adapter_Record2JSON record = new VCC_T2T_Adapter_Record2JSON(value, label, fieldName, true, true);
            records.add(record);
        }
        return records;
    }
    /*
    Serialize T2T data into existing format to join into existing progress note string
     */
    @SuppressWarnings('PMD.ApexDoc')
    public static String convertToJson(List<VCC_T2T_Adapter_Record2JSON> records) {
        List<Map<String, Object>> sectionFields = new List<Map<String, Object>>();

        for (VCC_T2T_Adapter_Record2JSON record : records) {
            Map<String, Object> fieldMap = new Map<String, Object>();

            fieldMap.put('displayField', record.displayField);
            fieldMap.put('displayValue', record.displayValue);
            fieldMap.put('fieldName', record.fieldName);
            fieldMap.put('label', record.label);
            fieldMap.put('value', record.value);

            sectionFields.add(fieldMap);
        }
        Map<String, Object> sectionMap = new Map<String, Object>();
        sectionMap.put('displaySectionName', true);
        sectionMap.put('emphasizeSection', false);
        sectionMap.put('fields', sectionFields);
        sectionMap.put('sectionName', 'Test to Treat');

        List<Map<String, Object>> jsonList = new List<Map<String, Object>>();
        jsonList.add(sectionMap);

        return JSON.serialize(jsonList);
    }

    /*
    This method is used to prep the data stashed in VCC_Progress_Note_Detail__c for display once the T2T Assessment is completed
     */
    @SuppressWarnings('PMD.ApexDoc')
    @AuraEnabled(Cacheable=true)
    public static List<String> previewT2TData(String recordId) {
        List<String> results = new List<String>();

        List<VCC_Progress_Note_Detail__c> Notes = [
            SELECT Id, Name, CreatedDate, LastModifiedDate, VCC_Progress_Note__c, VCC_T2T_Data__c, VCC_T2T_Labs__c
            FROM VCC_Progress_Note_Detail__c
            WHERE VCC_Progress_Note__c = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (Notes == null || Notes.isEmpty()) {
            return null;
        }

        String rawT2TData = Notes.get(0).VCC_T2T_Data__c;
        List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(rawT2TData);
        for (Object obj : jsonList) {
            results.add(JSON.serialize(obj));
        }

        return results;
    }
    @SuppressWarnings('PMD.ApexDoc')
    public static String prepVDIFT2TData(String recordId) {
        List<String> t2tStrings = new List<String>();
        String jsonString = T2TData(recordId);

        if (jsonString == null) {
            return null;
        }

        List<Object> jsonObjects = (List<Object>) JSON.deserializeUntyped(jsonString);

        for (Object jsonObject : jsonObjects) {
            Map<String, Object> sectionMap = (Map<String, Object>) jsonObject;

            if (sectionMap.containsKey('sectionName')) {
                t2tStrings.add('|||COVID T2T Assessment|');
            }

            List<Object> fields = (List<Object>) sectionMap.get('fields');

            for (Object field : fields) {
                Map<String, Object> fieldMap = (Map<String, Object>) field;
                String label = sanitizeInput((String) fieldMap.get('label'));
                String value = sanitizeInput((String) fieldMap.get('value'));
                String fieldName = (String) fieldMap.get('fieldName');

                if (String.isNotBlank(label) && String.isNotBlank(value)) {
                    t2tStrings.add(label + ': ' + value + '|');
                } else if (String.isNotBlank(label)) {
                    t2tStrings.add(label + '|');
                } else if (fieldName != null) {
                    t2tStrings.add(value + '|');
                } else if (value != null) {
                    t2tStrings.add(value.startsWith(':') ? value.substring(1) + '|' : value + '|');
                }

                Logger.info(JSON.serialize(label));
            }
        }

        Logger.info('array' + JSON.serialize(t2tStrings));
        Logger.saveLog();

        return String.join(t2tStrings, '|');
    }

    private static String sanitizeInput(String input) {
        /*
        replaceAll is performance heavy and might need to look for an alternative on when and how to run this
         */
        if (input == null)
            return null;
        input = replaceCharacter(input);
        //This regex matches all characters that are not alphanumeric for the exception of
        // :|<>=-*(). and replaces
        return input.replaceAll('[^a-zA-Z0-9 :|<>=\\-*().]', '').replace('&nbsp', ' ');
    }
    private static String replaceCharacter(String input) {
        /*
        this will have to be done prior to sanitizing the input otherwise the formatting for paragraphs or bullet points will be lost
         */
        if (input == null)
            return null;
        return input.replace('\n', '|');
    }
}
