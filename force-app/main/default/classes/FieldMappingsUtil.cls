/**
 * Created by: DC Solutions
 * Created on: 2019-11-06
 *
 * Description: Utility class to parse out and use Field Mapping metadata to copy fields from
 *      one object (source) to another (target)
 *
 * @See FieldMapping custom metadata type
 */
public class FieldMappingsUtil {
    // map keyed off target object of map of source field->mapping records
    public Map<String, Map<String,Field_Mapping__mdt>> mappingsByTargetObj  = new Map<String, Map<String,Field_Mapping__mdt>>();
    private String objectAPIName;
    @TestVisible private static List<Field_Mapping__mdt> testMappings;

    /*
     * Get all Field Mappings for the given process name for use later in building
     *  queries and mapping values from configured source object to target object(s)
     */
    public FieldMappingsUtil(String processName) {
        this.objectAPIName = objectAPIName;
        List<Field_Mapping__mdt> mappings;
        if (Test.isRunningTest() && testMappings != null) {
            mappings = testMappings;
        } else {
            mappings =[SELECT Process_Name__c,
                    Source_Object_Name__c, Source_Field_Name__c,
                    Target_Object_Name__c, Target_Field_Name__c,
                    Is_Static_Value__c, Is_Active__c, Is_Read_Only__c
                    FROM Field_Mapping__mdt
                    WHERE Is_Active__c=true
                    AND Process_Name__c=:processName];
        }
        for (Field_Mapping__mdt mapping : mappings) {
            if (mappingsByTargetObj.get(mapping.Target_Object_Name__c) == null) {
                mappingsByTargetObj.put(mapping.Target_Object_Name__c, new Map<String, Field_Mapping__mdt>());
            }
            mappingsByTargetObj.get(mapping.Target_Object_Name__c).put(mapping.Source_Field_Name__c, mapping);
        }
        System.debug('=====> Processing mapping ' + JSON.serializePretty(mappingsByTargetObj));
    }

    /**
     * Build and return a SOQL query from configured field names for our process. targetObjectName
     *  indicates the target object for which mappings are being returned.
     *
     * @param targetObjectName API Name of target object
     * @param blnSourceFields true if building soql for source object, false if building it for
     *  targetObjectName.
     *
     * @return comma-separated list of fields to be retrieved suitable for a soql query
     */
    public String buildSoqlQuery(String targetObjectName, Boolean blnSourceFields) {
        String soqlQueryString = '';
        if ( mappingsByTargetObj.get(targetObjectName) == null) {
            System.debug('======> returning empty soql query as there are no mappings for target object ' +
                targetObjectName);
            return ''; // no mappings for given target object name
        }
        Set<String> fieldNames = new Set<String>();
        for (String srcField : mappingsByTargetObj.get(targetObjectName).keyset()) {
            Field_Mapping__mdt mapping = mappingsByTargetObj.get(targetObjectName).get(srcField);
            String fieldName = mapping.Source_Field_Name__c;
            if (!blnSourceFields) {
                fieldName = mapping.Target_Field_Name__c;
            }

            if(String.isNotBlank(fieldName)) {
                 //skip static values when building soql query
                 if (mapping.Is_Static_Value__c) {
                     continue;
                 }
                fieldNames.add(fieldName);
            }
        }
        List<String> fieldsToQuery = new List<String>();
        fieldsToQuery.addAll(fieldNames);
        soqlQueryString += String.join(fieldsToQuery, ',');
        System.debug('====> returning soqlQueryString = ' + soqlQueryString);
        return soqlQueryString;
    }

    /**
     * Return the set of source fields for the given target object mappings.
     *
     * @param targetObjectName API name of target object mappings
     *
     * @return set of source fields for targetObjectName mappings
     */
    public Set<String> getSrcFields(String targetObjectName) {
        return mappingsByTargetObj.get(targetObjectName).keyset();
    }

    /**
     * Map values from the source record (fromObject) to the target record (toObject)
     *  using our configured mappings
     *
     * @param toObject instance of configured source object
     * @param fromObject instance of configured target object to copy values to
     */
    public void mapValues(SObject toObject, SObject fromObject) {
        String targetObjectName = toObject.getSObjectType().getDescribe().getName();
        // get our mappings for this target
        for (Field_Mapping__mdt mapping : mappingsByTargetObj.get(targetObjectName).values()) {
            System.debug('=====> mapping values using mapping : ' + JSON.serializePretty(mapping));
            if (mapping.Is_Read_Only__c) {
                continue; // this field is only for retrieval, not mapping
            }
            if (mapping.Is_Static_Value__c) {
                if (isValidField(toObject.getSObjectType().getDescribe().getName(), mapping.Target_Field_Name__c)) {
                    toObject.put(mapping.Target_Field_Name__c, mapping.Source_Field_Name__c);
                }
                else {
                    System.debug('SYNC ERROR - invalid target field name for mapping ' + JSON.serializePretty(mapping));
            }
            } else {
                mapValues(mapping, toObject, fromObject);
            }
        }
    }

    /**
     * Internal method to map individual value for prop on fromObject to toField
     *  on toObject.
     *
     * @param mapping Configuration details for the field currently being mapped from
     *      fromObject to toObject
     * @param toField target field name to copy value to
     * @param toObject instance of configured source object
     * @param fromObject instance of configured target object to copy values to
     */
    private void mapValues(Field_Mapping__mdt mapping, SObject toObject, SObject fromObject) {
        Object fromValue;
        SObject sourceObj = fromObject;

        //used to iterate up the parent child relationship
        if(mapping.Source_Field_Name__c.contains('.')) {
            List<String> fields = mapping.Source_Field_Name__c.split('\\.');
            for(String field : fields) {
                try {
                    sourceObj = (SObject)sourceObj.getSObject(field);
                } catch (Exception ex) {
                    try {
                        fromValue = sourceObj.get(field);
                    } catch (Exception e) {
                        System.debug('SYNC ERROR ' + e);
                        continue;
                    }
                }
            }
        } else if (sourceObj.get(mapping.Source_Field_Name__c) != null) {
            fromValue = sourceObj.get(mapping.Source_Field_Name__c);
        }

        System.debug('====> copying value ' + fromValue + ' to ' + mapping.Target_Field_Name__c  + ' on class ' +
                toObject.getSObjectType().getDescribe().getName());
        if(isValidField(toObject.getSObjectType().getDescribe().getName(), mapping.Target_Field_Name__c )) {
            try {
                if (toObject.getSObjectType().getDescribe().fields.getMap().get(mapping.Target_Field_Name__c).getDescribe().getType() ==
                        Schema.DisplayType.CURRENCY) {
                    // need to convert string to currency field
                    toObject.put(mapping.Target_Field_Name__c, Decimal.valueOf(String.valueOf(fromValue)));
                } else {
                    toObject.put(mapping.Target_Field_Name__c , fromValue);
                }

            } catch (Exception e) {
                System.debug('SYNC ERROR - to Field:' + mapping.Target_Field_Name__c + ' From Field: ' + mapping.Source_Field_Name__c +
                        ' To Object: ' + toObject + '. Exception:' + e);
            }
        } else {
            System.debug('SYNC ERROR - invalid to Field: ' + mapping.Target_Field_Name__c  +
            '   From Field ' + mapping.Source_Field_Name__c + ' To Object ' + toObject.getSObjectType().getDescribe().getName());
        }
        System.debug(toObject);
    }

    /**
     * Return schema information for all objects in org
     */
    public static Map<String, Schema.sObjectType> globalDescribe {
        get {
            if(globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }


    /**
     * Return true or false to indicate if objName is a valid object
     *
     * @param objName API Name of object to verify
     * @return true if objName is a valid API Object Name
     */
    public static boolean isValidObjectName(String objName) {
		if(globalDescribe.get(objName) == null) {
			return false;
		} else {
			return true;
		}
	}


    /**
     * Return true or false to indicate if fieldName is a valid field on object named objName
     *
     * @param objName API Name of object to verify
     * @param fieldName API Name of field to check objName for validity
     * @return true if fieldName on objName is valid
     */
	public static boolean isValidField(String objName, String fieldName) {
		if(!isValidObjectName(objName)) {
			return false;
		}
		return globalDescribe.get(objName).getDescribe().fields.getMap().containsKey(fieldName);
	}
}