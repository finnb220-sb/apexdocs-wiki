public with sharing class VCC_JsonNoteParser implements VCC_NoteParser.Receiver {
    //adding this comment so that a change registers in source control and this file is deployed
    @TestVisible
    private VCC_JsonNoteParser() {
        return;
    }

    public VCC_JsonNoteParser(SObject noteSObject, VCC_Progress_Note_Configuration__mdt progressNoteConfig) {
        this.noteParser = new VCC_NoteParser(noteSObject, this);
        this.progressNoteConfig = progressNoteConfig;
    }

    @TestVisible
    private VCC_NoteParser noteParser { get; set; }

    @TestVisible
    private VCC_Progress_Note_Configuration__mdt progressNoteConfig { get; set; }

    @TestVisible
    private List<VCC_ProgressNoteJsonModel.ProgressNoteSection> jsonSectionList = new List<VCC_ProgressNoteJsonModel.ProgressNoteSection>{};

    private VCC_ProgressNoteJsonModel.ProgressNoteSection currentJsonSection {
        get {
            if (this.jsonSectionList == null || this.jsonSectionList.size() == 0) {
                return null;
            }
            return jsonSectionList[jsonSectionList.size() - 1];
        }
    }

    /**
     * @description
     * @author Unknown
     * @param allFieldNames
     * @param sobjectType
     * @return Map<String, String>
     **/
    public String parse(List<Metadata.LayoutSection> layoutSectionList, List<VCC_Progress_Note_Custom_Section__mdt> customSectionList) {
        this.noteParser.parse(layoutSectionList, customSectionList);
        return JSON.serialize(this.jsonSectionList);
    }

    public void onSection(Object section) {
        if (section instanceof Metadata.LayoutSection) {
            Metadata.LayoutSection layoutSection = (Metadata.LayoutSection) section;
            this.jsonSectionList.add(this.initializeSection(layoutSection));
            return;
        }

        if (section instanceof VCC_Progress_Note_Custom_Section__mdt) {
            VCC_Progress_Note_Custom_Section__mdt customSection = (VCC_Progress_Note_Custom_Section__mdt) section;
            this.jsonSectionList.add(this.initializeSection(customSection));
            this.parseCustomSection(customSection);
            return;
        }
    }

    public void parseCustomSection(VCC_Progress_Note_Custom_Section__mdt customSection) {
        Set<String> fields = VCC_String_Utilities.splitUnique(customSection.VCC_Fields__c, ',');
        if (fields == null || fields.isEmpty()) {
            return;
        }
        for (String fieldName : new List<String>(fields)) {
            VCC_ProgressNoteJsonModel.ProgressNoteField jsonField = this.createJsonField(this.noteParser.fieldMap.get(fieldName).getDescribe());
            if (jsonField == null) {
                continue;
            }
            this.currentJsonSection.fields.add(jsonField);
            String tempString = jsonField.value;
            jsonField.value = '';
            this.noteParser.parseString(tempString);
        }
    }

    public void onLayoutItem(Metadata.LayoutItem layoutItem) {
        if (layoutItem.emptySpace == true) {
            return;
        }
        String fieldName = layoutItem.field;
        if (String.isBlank(fieldName)) {
            return;
        }
        VCC_ProgressNoteJsonModel.ProgressNoteField jsonField = this.createJsonField(this.noteParser.fieldMap.get(fieldName).getDescribe());
        if (jsonField == null) {
            return;
        }
        this.currentJsonSection.fields.add(jsonField);
        String tempString = jsonField.value;
        jsonField.value = '';
        this.noteParser.parseString(tempString);
    }

    public void onCharacter(VCC_NoteParser.StringParsingContext stringParsingContext) {
        VCC_ProgressNoteJsonModel.ProgressNoteField currentJsonField = this.currentJsonSection.fields[this.currentJsonSection.fields.size() - 1];
        Integer currentCharacterCode = stringParsingContext.getCurrentCharacterCode();
        if (currentCharacterCode == 10) {
            currentJsonField.value += '\n';
            return;
        }
        Integer replacementCharacter = stringParsingContext.getReplacementCharacterCode();
        if (replacementCharacter == null) {
            return;
        }
        currentJsonField.value += String.fromCharArray(new List<Integer>{ replacementCharacter });
    }

    private VCC_ProgressNoteJsonModel.ProgressNoteField filterSensitiveFields(VCC_ProgressNoteJsonModel.ProgressNoteField jsonField) {
        if (jsonField.fieldName.contains('SSN')) {
            jsonField.displayField = false;
            jsonField.displayValue = false;
        }

        return jsonField;
    }

    /**
     * @description
     * @author Unknown
     * @param allFieldNames
     * @param sobjectType
     * @return Map<String, String>
     **/
    public VCC_ProgressNoteJsonModel.ProgressNoteField createJsonField(DescribeFieldResult fieldDescribe) {
        Object value;
        VCC_ProgressNoteJsonModel.ProgressNoteField jsonField;
        String relationshipName = fieldDescribe.getRelationshipName();

        if (!String.isBlank(relationshipName)) {
            try {
                Map<String, Object> relatedObject = (Map<String, Object>) this.noteParser.sObjectMap.get(relationshipName);
                value = relatedObject.get(VCC_AdapterUtils_Note.relationshipFieldPath.get(relationshipName));
            } catch (Exception e) {
                value = null;
            }
        } else {
            value = this.noteParser?.sObjectMap?.get(fieldDescribe.getName());
        }

        if (value == null) {
            return null;
        }
        jsonField = new VCC_ProgressNoteJsonModel.ProgressNoteField();
        jsonField.fieldName = fieldDescribe.getName();
        jsonField.label = fieldDescribe.getLabel();

        if (value == true) {
            if (VCC_NoteParserService.helpTextMap.containsKey(jsonField.fieldName)) {
                jsonField.value = String.valueOf(VCC_NoteParserService.helpTextMap.get(jsonField.fieldName));
            } else {
                jsonField.value = String.valueOf(value);
            }
        } else {
            jsonField.value = String.valueOf(value);
        }

        jsonField.displayField = !(jsonField.value == 'false');
        jsonField.displayValue = !(jsonField.value == 'true');

        jsonField = filterSensitiveFields(jsonField);

        return jsonField;
    }

    /**
     * @description
     * @author Unknown
     * @param allFieldNames
     * @param sobjectType
     * @return Map<String, String>
     **/
    public VCC_ProgressNoteJsonModel.ProgressNoteSection initializeSection(VCC_Progress_Note_Custom_Section__mdt customSection) {
        VCC_ProgressNoteJsonModel.ProgressNoteSection jsonSection = new VCC_ProgressNoteJsonModel.ProgressNoteSection();
        Set<String> emphasizedSections = VCC_String_Utilities.splitUnique(this.progressNoteConfig.VCC_Emphasized_Sections__c, ',');

        jsonSection.displaySectionName = customSection.VCC_Display_Section_Name__c;
        jsonSection.sectionName = customSection.MasterLabel;
        jsonSection.emphasizeSection = emphasizedSections.contains(customSection.MasterLabel);

        return jsonSection;
    }

    /**
     * @description
     * @author Unknown
     * @param allFieldNames
     * @param sobjectType
     * @return Map<String, String>
     **/
    public VCC_ProgressNoteJsonModel.ProgressNoteSection initializeSection(Metadata.LayoutSection section) {
        VCC_ProgressNoteJsonModel.ProgressNoteSection jsonSection = new VCC_ProgressNoteJsonModel.ProgressNoteSection();
        Set<String> emphasizedSections = VCC_String_Utilities.splitUnique(this.progressNoteConfig.VCC_Emphasized_Sections__c, ',');

        jsonSection.displaySectionName = section.detailHeading;
        jsonSection.sectionName = section.label;
        jsonSection.emphasizeSection = emphasizedSections.contains(section.label);

        return jsonSection;
    }
}
