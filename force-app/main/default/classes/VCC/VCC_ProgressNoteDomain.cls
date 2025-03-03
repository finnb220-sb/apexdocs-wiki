public with sharing class VCC_ProgressNoteDomain extends fflib_SObjectDomain {
    // Constructors.
    public VCC_ProgressNoteDomain() {
        super(new List<VCC_Progress_Note__c>());
    }

    public VCC_ProgressNoteDomain(List<VCC_Progress_Note__c> records) {
        super(records);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> records) {
            return new VCC_ProgressNoteDomain(records);
        }
    }

    // Trigger Handling
    /**
     * @description           fflib trigger on before updates
     * @param existingRecords trigger new map of records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Logger.info('Progress Note onBeforeUpdate called. Validating SObject prior to save.');
    }

    public override void onValidate(Map<Id, SObject> previousMap) {
        charLimitError(this.Records, previousMap);
    }

    // Methods

    /**
     * @description       throw custom validation rule when text or text area fields character limit is maxed out, to prevent accidental truncation of field value risk.
     * @param recs        new list of Progress Note records from trigger
     * @param previousMap old list of Progress Note records from trigger
     */
    public void charLimitError(List<VCC_Progress_Note__c> recs, Map<Id, SObject> previousMap) {
        Map<String, SObjectField> objFieldsMap = Schema.SObjectType.VCC_Progress_Note__c.fields.getMap();
        Map<String, Integer> fieldName2FieldLengthMap = new Map<String, Integer>();
        Map<String, String> fieldName2LabelMap = new Map<String, String>();
        List<String> charLimitErrorFields = new List<String>();

        for (String fieldName : objFieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = objFieldsMap.get(fieldName).getDescribe();

            if (fieldDesc.getType() == Schema.DisplayType.String || fieldDesc.getType() == Schema.DisplayType.TextArea) {
                fieldName2FieldLengthMap.put(fieldName, fieldDesc.getLength());
                fieldName2LabelMap.put(fieldName, fieldDesc.getLabel());
            }
        }

        for (VCC_Progress_Note__c progNote : recs) {
            for (String fld : fieldName2FieldLengthMap.keySet()) {
                String fieldValue = String.valueOf(progNote.get(fld));
                if (fieldValue != null && fieldValue.length() >= fieldName2FieldLengthMap.get(fld) && fieldValue != String.valueOf(previousMap.get(progNote.Id).get((fld)))) {
                    String fieldLabel = fieldName2LabelMap.get(fld);
                    charLimitErrorFields.add(fieldLabel);
                    progNote.addError(fld, 'Character limit for ' + fieldLabel + ' has been reached.  Please review entry and remove character(s) to save.');
                }
            }

            if (!charLimitErrorFields.isEmpty()) {
                String errMsg =
                    'Character limit for ' +
                    String.join(charLimitErrorFields, ', ') +
                    ' has been reached.  Please review entry, validate that entry was not truncated, and remove character(s) to save.';
                progNote.addError(errMsg);
            }
        }
    }

    /**
     * @description         instantiate Progress Note, assign field values, and return it. Need to address excessive params warning in future.
     * @param pnString      assign value to requested medication field
     * @param controlled    assign value to controlled medication field
     * @param nonControlled assign value to non controlled medication field
     * @param cse           assign value to case field
     * @param pnRecTypeId   assign value to record type field
     * @param facilityName assign value to facility field
     * @return              `VCC_Progress_Note__c`
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_Progress_Note__c newProgressNote(String pnString, Boolean controlled, Boolean nonControlled, Case cse, Id pnRecTypeId, String facilityName) {
        VCC_Progress_Note__c progNote = new VCC_Progress_Note__c();
        progNote.VCC_Requested_Medication__c = pnString;
        progNote.VCC_Medication_Fill_Renewal__c = true;
        progNote.VCC_Controlled_medication__c = controlled;
        progNote.VCC_Non_controlled_medication__c = nonControlled;
        progNote.RecordTypeId = pnRecTypeId;
        progNote.VCC_Case__c = cse.Id;
        progNote.VCC_Relative_Type__c = cse.VCC_Caller_Relation__c; //? same as case
        progNote.VCC_If_Other_Describe_Relation_Patient__c = cse.VCC_Relation_Type_Other__c; //? relation type (if Other)
        progNote.VCC_Caller_Name_Text__c = cse.VCC_Caller_Name__c;
        progNote.VCC_Facility__c = facilityName;

        return progNote;
    }
}
