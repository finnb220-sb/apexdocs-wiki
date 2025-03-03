/**
 * @description Parser, given a string, will replace characters specified in VCC_Progress_Note_Character_Replacements
 * and will remove all other non-ascii-printable characters not otherwise specified for replacement.
 */
public with sharing class VCC_NoteParser {
    //adding small change here so it gets deployed to stage3 - again

    public Map<String, SObjectField> fieldMap { get; set; }
    public Map<String, Object> sObjectMap { get; set; }
    public SObject inputSObject { get; set; }
    @TestVisible
    private Receiver receiver { get; set; }

    @TestVisible
    private VCC_NoteParser() {
        return;
    }

    public VCC_NoteParser(SObject noteSObject, Receiver receiver) {
        this.fieldMap = noteSObject.getSObjectType().getDescribe().fields.getMap();
        this.inputSObject = noteSObject;
        this.sObjectMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(this.inputSObject));
        this.receiver = receiver;
    }

    public void parse(List<Metadata.LayoutSection> layoutSectionList, List<VCC_Progress_Note_Custom_Section__mdt> customSectionList) {
        for (Metadata.LayoutSection section : layoutSectionList) {
            this.receiver.onSection(section);
            switch on String.valueOf(section.style) {
                when 'OneColumn' {
                    parseSectionOneColumn(section);
                }
                when 'TwoColumnsTopToBottom' {
                    parseSectionTwoColumnsTopToBottom(section);
                }
                when 'TwoColumnsLeftToRight' {
                    parseSectionTwoColumnsLeftToRight(section);
                }
            }
        }
        for (VCC_Progress_Note_Custom_Section__mdt customSection : customSectionList) {
            this.receiver.onSection(customSection);
        }
    }

    @TestVisible
    private void parseSectionOneColumn(Metadata.LayoutSection section) {
        if (section.layoutColumns == null) {
            return;
        }
        if (section.layoutColumns.size() != 1) {
            return;
        }
        Metadata.LayoutColumn column = section.layoutColumns[0];
        if (column.layoutItems == null) {
            return;
        }
        for (Metadata.LayoutItem layoutItem : column.layoutItems) {
            this.receiver.onLayoutItem(layoutItem);
        }
    }

    @TestVisible
    private void parseSectionTwoColumnsTopToBottom(Metadata.LayoutSection section) {
        if (section.layoutColumns == null) {
            return;
        }
        for (Metadata.LayoutColumn layoutColumn : section.layoutColumns) {
            if (layoutColumn.layoutItems == null) {
                continue;
            }
            for (Metadata.LayoutItem layoutItem : layoutColumn.layoutItems) {
                this.receiver.onLayoutItem(layoutItem);
            }
        }
    }

    @TestVisible
    private void parseSectionTwoColumnsLeftToRight(Metadata.LayoutSection section) {
        List<Metadata.LayoutColumn> columns = section.layoutColumns;
        Integer i = 0;
        do {
            if (columns[0].layoutItems != null && columns[0].layoutItems.size() > i) {
                Metadata.LayoutItem layoutItem = columns[0].layoutItems[i];
                this.receiver.onLayoutItem(layoutItem);
            }
            if (columns[1].layoutItems != null && columns[1].layoutItems.size() > i) {
                Metadata.LayoutItem layoutItem = columns[1].layoutItems[i];
                this.receiver.onLayoutItem(layoutItem);
            }
            i++;
        } while ((columns[0].layoutItems != null && columns[0].layoutItems.size() > i) || (columns[1].layoutItems != null && columns[1].layoutItems.size() > i));
    }

    public Object getValueFromSObject(DescribeFieldResult fieldDescribe) {
        String relationshipName = fieldDescribe.getRelationshipName();
        String fieldName = fieldDescribe.getName();
        if (!String.isBlank(relationshipName)) {
            try {
                Map<String, Object> relatedObject = (Map<String, Object>) this.sObjectMap.get(relationshipName);
                return relatedObject.get(VCC_AdapterUtils_Note.relationshipFieldPath.get(relationshipName));
            } catch (Exception e) {
                return null;
            }
        } else {
            return this.inputSObject.get(fieldName);
        }
    }

    /**
     * @description Main parsing function that parses through each character.
     * @param unparsedString `String` to parse.
     */
    public void parseString(String unparsedString) {
        StringParsingContext stringParsingContext = new StringParsingContext(unparsedString);
        for (; stringParsingContext.index < stringParsingContext.getLength(); stringParsingContext.index++) {
            this.receiver.onCharacter(stringParsingContext);
        }
    }

    public interface Receiver {
        void onCharacter(StringParsingContext stringParsingContext);
        void onSection(Object section);
        void onLayoutItem(Metadata.LayoutItem layoutItem);
    }

    public class StringParsingContext {
        //the string being parsed
        @TestVisible
        private String stringToParse { get; set; }

        /**
         * @description Represents the current index.
         */
        public Integer index { get; set; }

        /**
         * @description Constructor for `StringParsingContext`. It converts the provided `String` into character codes.
         * @param stringToParse The string to be parsed.
         */
        public StringParsingContext(String stringToParse) {
            this.index = 0;
            this.stringToParse = stringToParse;
        }

        /**
         * @description
         * @return Integer
         */
        public Integer getLength() {
            if (String.isBlank(this.stringToParse)) {
                return 0;
            }
            return this.stringToParse.length();
        }

        /**
         * @description
         * @return Integer
         */
        public Integer getCurrentCharacterCode() {
            return this.stringToParse.charAt(this.index);
        }

        public Integer getReplacementCharacterCode() {
            if (VCC_NoteParserService.characterReplacementMap.containsKey(this.getCurrentCharacterCode())) {
                VCC_NoteParserService.didReplaceCharacters = true;
                return VCC_NoteParserService.characterReplacementMap.get(this.getCurrentCharacterCode());
            } else if (this.getCurrentCharacterCode() > 31 && this.getCurrentCharacterCode() < 127) {
                return this.getCurrentCharacterCode();
            }
            VCC_NoteParserService.didReplaceCharacters = true;
            return null;
        }
    }
}
