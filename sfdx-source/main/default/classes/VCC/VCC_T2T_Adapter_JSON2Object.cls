/**
 * Created by abaddon on 7/12/23.
 */

public with sharing class VCC_T2T_Adapter_JSON2Object {
    public class CustomObject {
        public Integer index { get; set; }
        public String fieldName { get; set; }
        public String id { get; set; }
        public String label { get; set; }
        public String response { get; set; }
        public String review { get; set; }

        public CustomObject(Integer Index, String fieldName, String id, String label, String response, String review) {
            this.index = Index;
            this.fieldName = fieldName;
            this.id = id;
            this.label = label;
            this.response = response;
            this.review = review;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static List<CustomObject> translateStrings(String recordId) {
        List<CustomObject> results = convertToObjects(VCC_T2T_Adapter_Record2JSON.previewT2TData(recordId));
        //Add a check to verify if the progress note is signed and if it is exit the process
        return results;
    }

    public static List<CustomObject> convertToObjects(List<String> jsonStringList) {
        if (jsonStringList == null) {
            return null;
        }
        List<CustomObject> objectList = new List<CustomObject>();
        for (String jsonString : jsonStringList) {
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            CustomObject obj = new CustomObject(
                (Integer) jsonMap.get('Index'),
                (String) jsonMap.get('fieldName'),
                (String) jsonMap.get('id'),
                (String) jsonMap.get('label'),
                (String) jsonMap.get('response'),
                (String) jsonMap.get('review')
            );
            objectList.add(obj);
        }
        return objectList;
    }
    @AuraEnabled(Cacheable=true)
    public static List<String> getStringList(String recordId) {
        List<String> stringList = new List<String>();
        List<CustomObject> customObjects = translateStrings(recordId);
        if (customObjects == null) {
            return null;
        }

        for (CustomObject obj : customObjects) {
            String objString = JSON.serialize(obj);
            stringList.add(objString);
        }

        return stringList;
    }
}
