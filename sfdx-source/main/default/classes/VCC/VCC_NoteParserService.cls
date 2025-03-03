public with sharing class VCC_NoteParserService {
    //adding small change here so it gets deployed to stage3 - again

    // added for CCCM-20147 / LEAF-299
    public static Boolean didReplaceCharacters = false;

    public static Map<Integer, Integer> characterReplacementMap = getReplacementCharacterCodeMap();
    public static Map<String, String> helpTextMap = getHelpTextsMap();

    private static Map<Integer, Integer> getReplacementCharacterCodeMap() {
        Map<Integer, Integer> replacementMap = new Map<Integer, Integer>();
        for (VCC_Progress_Note_Character_Replacement__mdt replacementRecord : [
            //NOPMD using 'WITH USER_MODE' enforces FLS
            SELECT Invalid_Character_Code__c, Replacement_Character_Code__c
            FROM VCC_Progress_Note_Character_Replacement__mdt
            WITH USER_MODE
            LIMIT 1000
        ]) {
            if (replacementRecord.Invalid_Character_Code__c == null || replacementRecord.Replacement_Character_Code__c == null) {
                continue;
            }
            replacementMap.put(Integer.valueOf(replacementRecord.Invalid_Character_Code__c), Integer.valueOf(replacementRecord.Replacement_Character_Code__c));
        }
        return replacementMap;
    }

    /**
     * @description generate map of field names to their Help Text value stored in custom metadata type
     * @author Unknown
     * @return Map<String, String>
     **/
    public static Map<String, String> getHelpTextsMap() {
        Map<String, String> helpTextsMap = new Map<String, String>();

        //CCCM-20931 switched retrieval of custom metadata type records to SOQL query as only the first 255 characters of Long text area fields are returned via the OOB getAll() and getInstance() methods (see https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_custom_metadata_types.htm#apex_System_CustomMetadataType_getall)
        List<VCC_Progress_Note_Field_Help_Text__mdt> helpTexts = [
            //NOPMD WITH USER_MODE checks FLS
            SELECT Field__c, Help_Text__c
            FROM VCC_Progress_Note_Field_Help_Text__mdt
            WITH USER_MODE
            LIMIT 1000
        ];

        for (VCC_Progress_Note_Field_Help_Text__mdt helpL : helpTexts) {
            helpTextsMap.put(helpL.Field__c, helpL.Help_Text__c);
        }
        return helpTextsMap;
    }
}
