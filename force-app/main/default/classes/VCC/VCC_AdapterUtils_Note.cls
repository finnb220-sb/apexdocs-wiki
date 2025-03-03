/**
 * @description       : Utility methods for working with Progress Note object
 * @author            : Unknown
 * @group             :
 * @last modified on  : 05-10-2023
 * @last modified by  : WagnerJ@BAH
 **/
@SuppressWarnings('PMD.ApexSOQLInjection, sf:SOQLInjection')
public with sharing class VCC_AdapterUtils_Note {
    public static Map<Object, Object> booleanValueReplacements = new Map<Object, Object>{ true => 'Yes', false => 'No' };

    public static Map<String, String> relationshipFieldPath = new Map<String, String>{
        'VCC_Procedure_Code__r' => 'Name',
        'VCC_Primary_Diagnosis_Code__r' => 'Name',
        'VCC_Secondary_Diagnosis_Code__r' => 'Name',
        'VCC_Clinic_Location__r' => 'Name',
        'VCC_Case__r' => 'CaseNumber'
    };

    /**
     * @description
     * @author Unknown
     * @param note
     * @param requiredFields
     * @return SObject
     **/
    public static SObject prepNote(SObject note, Set<String> requiredFields) {
        if (!(note instanceof VCC_Addendum__c) && !(note instanceof VCC_Progress_Note__c)) {
            return null;
        }

        SObject newNote = Database.query(generateQueryString(note, requiredFields));

        return mergeNotes(note, newNote, requiredFields);
    }

    /**
     * @description
     * @author Unknown
     * @param note
     * @param requiredFields
     * @return string
     **/
    public static string generateQueryString(SObject note, Set<String> requiredFields) {
        //set of populated fields
        Set<String> populatedFields = note.getPopulatedFieldsAsMap().keySet();

        Map<String, SObjectField> fieldMap = note.getSObjectType().getDescribe().fields.getMap();

        Map<String, String> requiredRelationshipFields = getRelationshipFieldNames(requiredFields, note.getSObjectType());

        Set<String> fieldSetForQuerySelect = new Set<String>();

        for (String fieldName : requiredFields) {
            String relationshipName = requiredRelationshipFields.get(fieldName);

            if (!String.isBlank(relationshipName)) {
                fieldSetForQuerySelect.add(relationshipName + '.' + relationshipFieldPath.get(relationshipName));
            }

            if (String.isBlank(relationshipName)) {
                if (!populatedFields.contains(fieldName) || fieldMap.get(fieldName).getDescribe().isCalculated() || !fieldMap.get(fieldName).getDescribe().isUpdateable()) {
                    fieldSetForQuerySelect.add(fieldName);
                }
            }
        }
        return 'SELECT ' +
            String.escapeSingleQuotes(String.join(new List<String>(fieldSetForQuerySelect), ',')) +
            ' ' +
            'FROM ' +
            note.getSObjectType() +
            ' ' +
            'WHERE Id = \'' +
            String.escapeSingleQuotes(String.valueOf(note.get('Id'))) +
            '\' ' +
            'WITH USER_MODE';
    }

    /**
     * @description
     * @author Unknown
     * @param originalNote
     * @param newNote
     * @param requiredFields
     * @return SObject
     **/
    public static SObject mergeNotes(SObject originalNote, SObject newNote, Set<String> requiredFields) {
        if (originalNote.getSObjectType() != newNote.getSObjectType()) {
            return originalNote;
        }
        //Map<String, String> requiredRelationshipFields = getRelationshipFieldNames(requiredFields, originalNote.getSObjectType());
        Map<String, Object> populatedFields = originalNote.getPopulatedFieldsAsMap();

        for (String fieldName : populatedFields.keySet()) {
            try {
                newNote.put(fieldName, populatedFields.get(fieldName));
            } catch (Exception e) {
                continue;
            }
        }

        return newNote;
    }

    /**
     * @description
     * @author Unknown
     * @param noteSObjectType
     * @param progressNoteConfig
     * @return VCC_LayoutService.LayoutInfo
     **/
    public static VCC_LayoutService.LayoutInfo getLayoutInfo(SObjectType noteSObjectType, VCC_Progress_Note_Configuration__mdt progressNoteConfig) {
        if (noteSObjectType != VCC_Progress_Note__c.SObjectType && noteSObjectType != VCC_Addendum__c.SObjectType) {
            return null;
        }
        return VCC_LayoutService.getLayoutInfo(
            VCC_LayoutService.getPageLayout(String.valueOf(noteSObjectType), progressNoteConfig.VCC_Page_Layout_Name__c),
            VCC_String_Utilities.splitUnique(progressNoteConfig.VCC_Excluded_Page_Layout_Sections__c, ',')
        );
    }

    /**
     * @description
     * @author Unknown
     * @param layoutInfo
     * @param customSections
     * @return Set<String>
     **/
    public static Set<String> getAllFieldNames(VCC_LayoutService.LayoutInfo layoutInfo, List<VCC_Progress_Note_Custom_Section__mdt> customSections) {
        Set<String> allFields = new Set<String>();

        allFields.addAll(layoutInfo.fieldSet);

        allFields.addAll(getCustomSectionFieldNames(customSections));

        return allFields;
    }

    /**
     * @description
     * @author Unknown
     * @param allFieldNames
     * @param sobjectType
     * @return Map<String, String>
     **/
    public static Map<String, String> getRelationshipFieldNames(Set<String> allFieldNames, SObjectType sobjectType) {
        @SuppressWarnings('PMD.EagerlyLoadedDescribeSObjectResult')
        Map<String, SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap();

        Map<String, String> fieldNameToRelationshipNameMap = new Map<String, String>();

        for (String fieldName : allFieldNames) {
            String relationshipName = fieldMap.get(fieldName).getDescribe().getRelationshipName();
            if (!String.isBlank(relationshipName)) {
                fieldNameToRelationshipNameMap.put(fieldName, relationshipName);
            }
        }

        return fieldNameToRelationshipNameMap;
    }

    /**
     * @description
     * @author Unknown
     * @param customSections
     * @return Set<String>
     **/
    public static Set<String> getCustomSectionFieldNames(List<VCC_Progress_Note_Custom_Section__mdt> customSections) {
        Set<String> customSectionFields = new Set<String>();

        for (VCC_Progress_Note_Custom_Section__mdt customSection : customSections) {
            customSectionFields.addAll(VCC_String_Utilities.splitUnique(customSection.VCC_Fields__c, ','));
        }

        return customSectionFields;
    }
}
