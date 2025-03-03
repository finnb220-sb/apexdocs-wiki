/**
 * @description Vdif Note Parser for translating data to note format
 *
 * @author Liberty
 * @since 01/08/2024
 * @group VAHC
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifNoteParser implements VCC_NoteParser.Receiver {
    private static final Integer MAX_LINES_PER_PAGE = 300;
    private static final Integer MAX_CHARS_PER_LINE = 79;
    private static final Integer MAX_TEXT_SIZE_IN_BYTES = 300000;
    private static final Integer SPACE_CHAR_CODE = 32; //char code for ' '
    private static final Integer NEW_LINE_CHAR_CODE = 10;
    private static final String FIELD_TEMPLATE = '{0}: {1}';

    //List of pages
    @TestVisible
    private List<VCC_NotePage> pages = new List<VCC_NotePage>{ new VCC_NotePage() };

    //The current page
    @TestVisible
    private VCC_NotePage currentPage {
        get {
            return this.pages.get(this.pages.size() - 1);
        }
    }

    //The current line
    private VCC_NoteLine currentLine {
        get {
            return this.currentPage.currentLine;
        }
    }

    //Boolean flag indicating to this parser that empty layout items are to be interpreted as new lines
    private Boolean includeSpaces { get; set; }

    //Custom type holding state info about the current section (layout section or custom section)
    private VCC_SectionState sectionState { get; set; }

    @TestVisible
    private VCC_VdifNoteParser() {
        return;
    }

    /**
     * @description constructor with Note object as argument
     * @param noteSObject
     */
    public VCC_VdifNoteParser(SObject noteSObject) {
        this.noteParser = new VCC_NoteParser(noteSObject, this);
    }

    //Base note parser
    private VCC_NoteParser noteParser { get; set; }

    /**
     * @description Method that starts the parsing process.
     * @param layoutSectionList List of Metadata.LayoutSection
     * @param customSectionList List of VCC_Progress_Note_Custom_Section__mdt
     * @return String
     */
    public String parse(List<Metadata.LayoutSection> layoutSectionList, List<VCC_Progress_Note_Custom_Section__mdt> customSectionList) {
        return parse(layoutSectionList, customSectionList, false);
    }

    /**
     * @description Overloaded method with added parameter.
     * @param layoutSectionList List of Metadata.LayoutSection
     * @param customSectionList List of VCC_Progress_Note_Custom_Section__mdt
     * @param includeSpaces Boolean flag indicating to this parser that empty layout items are to be interpreted as new lines
     * @return String
     */
    public String parse(List<Metadata.LayoutSection> layoutSectionList, List<VCC_Progress_Note_Custom_Section__mdt> customSectionList, Boolean includeSpaces) {
        this.includeSpaces = (includeSpaces == null) ? false : includeSpaces;
        this.noteParser.parse(layoutSectionList, customSectionList);
        return this.getText();
    }

    /**
     * @description Required by the VCC_NoteParser.Receiver interface. This is called every time a `Metadata.LayoutSection` or `VCC_Progress_Note_Custom_Section__mdt` is 'parsed'.
     * @param section a `Metadata.LayoutSection` or `VCC_Progress_Note_Custom_Section__mdt`
     */
    public void onSection(Object section) {
        if (section instanceof Metadata.LayoutSection) {
            Metadata.LayoutSection layoutSection = (Metadata.LayoutSection) section;
            this.sectionState = new VCC_SectionState(layoutSection);
            return;
        }

        if (section instanceof VCC_Progress_Note_Custom_Section__mdt) {
            VCC_Progress_Note_Custom_Section__mdt customSection = (VCC_Progress_Note_Custom_Section__mdt) section;
            this.sectionState = new VCC_SectionState(customSection);
            this.parseCustomSection(customSection);
            return;
        }

        throw new VCC_VdifNoteParserException('Parser encountered unknown section type.');
    }

    /**
     * @description Parses custom section.
     * @param customSection The custom section to parse.
     */
    private void parseCustomSection(VCC_Progress_Note_Custom_Section__mdt customSection) {
        for (String fieldName : VCC_String_Utilities.splitUnique(customSection.VCC_Fields__c, ',')) {
            String stringToParse = this.getFieldString(fieldName);
            if (String.isBlank(stringToParse)) {
                continue;
            }
            if (this.sectionState.shouldPrintName == true && this.sectionState.hasPrintedName == false) {
                this.noteParser.parseString('\n' + this.sectionState.sectionName + '\n');
                this.sectionState.hasPrintedName = true;
            }
            this.noteParser.parseString('\n' + stringToParse);
        }
    }

    /**
     * @description Required by the VCC_NoteParser. Called for each LayoutItem in a Metadata.LayoutSection in tab order.
     * @param layoutItem a `Metadata.LayoutItem`
     */
    public void onLayoutItem(Metadata.LayoutItem layoutItem) {
        if ((layoutItem.emptySpace != null) && layoutItem.emptySpace && (this.includeSpaces)) {
            if (this.currentPage.hasMaximumLines()) {
                this.newPage();
            }
            this.currentPage.newLine();
            return;
        }

        String generatedString = getFieldString(layoutItem.field);

        if (generatedString == null || String.isBlank(generatedString)) {
            return;
        }

        if (this.sectionState.shouldPrintName == true && this.sectionState.hasPrintedName == false) {
            this.noteParser.parseString('\n' + this.sectionState.sectionName + '\n');
            this.sectionState.hasPrintedName = true;
        }

        this.noteParser.parseString(generatedString + '\n');
    }

    /**
     * @description Required by the VCC_NoteParser. Called for each character that is read through the parser.
     * @param stringParsingContext a `VCC_NoteParser.StringParsingContext`
     */
    public void onCharacter(VCC_NoteParser.StringParsingContext stringParsingContext) {
        Integer characterCode = stringParsingContext.getCurrentCharacterCode();

        if (characterCode == NEW_LINE_CHAR_CODE) {
            // if new line is added successfully, stop here
            if (this.currentPage.newLine()) {
                return;
            }
            //otherwise create a new page (which is constructed w/ a new line) and stop
            this.newPage();
            return;
        }

        Integer replacementCharacterCode = stringParsingContext.getReplacementCharacterCode();
        //if replacement character code is null, stop and dont add any character
        if (replacementCharacterCode == null) {
            return;
        }
        //if successfully added character, stop here
        if (this.currentLine.addCharacterCode(replacementCharacterCode)) {
            return;
        }

        //checking whether or not to break mid-word to the next line
        if (this.currentLine.doBreakWord()) {
            //try to add a new line, if failed create new page
            if (!this.currentPage.newLine()) {
                this.newPage();
            }
            this.currentLine.addCharacterCode(replacementCharacterCode);
            return;
        }

        //remove partial word from current line
        List<Integer> partialWordCharacterCodeList = this.currentLine.removePartialWord();

        //create new line and add partial word and new character
        if (!this.currentPage.newLine()) {
            this.newPage();
        }

        //if no partial word is removed (ie. a space is the last character in the line), add character and return
        if (partialWordCharacterCodeList == null || partialWordCharacterCodeList.size() == 0) {
            this.currentLine.addCharacterCode(replacementCharacterCode);
            return;
        }

        for (Integer partialWordCharacterCode : partialWordCharacterCodeList) {
            this.currentLine.addCharacterCode(partialWordCharacterCode);
        }

        this.currentLine.addCharacterCode(replacementCharacterCode);
    }

    /**
     * @description Holds information about the current section.
     */
    @TestVisible
    private class VCC_SectionState {
        /**
         * @description getter and setter
         */
        public Boolean hasPrintedName { get; set; }
        /**
         * @description getter and setter
         */
        public Boolean shouldPrintName { get; set; }
        /**
         * @description getter and setter
         */
        public String sectionName { get; set; }

        /**
         * @description Constructor for Metadata.LayoutSection
         * @param layoutSection the layout section
         */
        public VCC_SectionState(Metadata.LayoutSection layoutSection) {
            this.hasPrintedName = false;
            this.shouldPrintName = layoutSection.detailHeading;
            this.sectionName = layoutSection.label;
        }

        /**
         * @description Constructor for VCC_Progress_Note_Custom_Section__mdt
         * @param customSection the custom section
         */
        public VCC_SectionState(VCC_Progress_Note_Custom_Section__mdt customSection) {
            this.hasPrintedName = false;
            this.shouldPrintName = customSection.VCC_Display_Section_Name__c;
            this.sectionName = customSection.MasterLabel;
        }
    }

    /**
     * @description creates a new page
     * @return the new page
     */
    @TestVisible
    private VCC_NotePage newPage() {
        VCC_NotePage notePage = new VCC_NotePage();
        this.pages.add(notePage);
        return notePage;
    }

    /**
     * @description converts NotePages and NoteLines into text for Vdif/VistA
     * @return  `string`
     */
    @TestVisible
    private string getText() {
        String returnString = '';
        for (Integer counter = 0; counter < this.pages.size(); counter++) {
            if (counter == 0) {
                returnString += this.pages[counter].toString();
            } else {
                returnString += '|' + this.pages[counter].toString();
            }
        }
        return returnString;
    }

    /**
     * @description Given a field name, pulls the value from sobject and places it into a string to parse.
     * @param fieldName name of the field
     * @return returns the string for parsing
     */
    private String getFieldString(String fieldName) {
        if (String.isBlank(fieldName)) {
            return null;
        }
        DescribeFieldResult fieldDescribe = this.noteParser.fieldMap.get(fieldName).getDescribe();
        String generatedString = generateFieldString(fieldDescribe, this.noteParser.getValueFromSObject(fieldDescribe));
        return generatedString;
    }

    /**
     * @description generateFieldString uses String.format to generate a string with field name and value
     * @param fieldDescribe the DescribeFieldResult for the desired field
     * @param value the value to be printed with the field name
     * @return String
     */
    private String generateFieldString(DescribeFieldResult fieldDescribe, Object value) {
        if (value == null) {
            return null;
        }
        String label = fieldDescribe.getLabel();
        String name = fieldDescribe.getName();

        if (value instanceof Boolean) {
            if ((Boolean) value == true) {
                if (VCC_NoteParserService.helpTextMap.containsKey(name)) {
                    value = VCC_NoteParserService.helpTextMap.get(name);
                } else {
                    return label;
                }
            } else {
                return '';
            }
        }

        return String.format(FIELD_TEMPLATE, new List<String>{ label, String.valueOf(value) });
    }

    @TestVisible
    /**
     * @description Represents a progress note page, contains logic for adding a line to the page.
     */
    private class VCC_NotePage {
        @TestVisible
        private List<VCC_NoteLine> lines = new List<VCC_NoteLine>{ new VCC_NoteLine() };

        /**
         * @description get current line
         */
        public VCC_NoteLine currentLine {
            get {
                return this.lines[this.lines.size() - 1];
            }
        }

        /**
         * @description does this page have the max number of lines
         * @return `true` if the page has max number of lines, `false` otherwise
         */
        public Boolean hasMaximumLines() {
            if (this.lines.size() < MAX_LINES_PER_PAGE) {
                return false;
            }
            return true;
        }

        /**
         * @description adds new line to page
         * @return returns `true` if successful, false otherwise
         */
        public Boolean newLine() {
            if (this.hasMaximumLines()) {
                return false;
            }
            this.lines.add(new VCC_NoteLine());
            return true;
        }

        /**
         * @description overridden toString method
         * @return this page and it's line but as a `String`
         */
        public override String toString() {
            String returnOfTheString = '';
            for (Integer counter = 0; counter < lines.size(); counter++) {
                if (counter > 0) {
                    returnOfTheString += '|' + lines[counter];
                } else {
                    returnOfTheString += lines[counter];
                }
            }
            return returnOfTheString;
        }
    }

    /**
     * @description Represents a line in a progress note page. Contains logic for adding characters to the line.
     */
    @TestVisible
    private class VCC_NoteLine {
        @TestVisible
        private List<Integer> characterCodeList = new List<Integer>();

        /**
         * List of locations of space characters in charCodeList
         */
        private List<Integer> spaceIndicies = new List<Integer>();

        /**
         * @description Adds character to characterCodeList if the maximum line length has not been reached.
         * @param characterCode integer representation of character code
         * @return Returns `true` if character was successfully added. `false` otherwise.
         */
        public Boolean addCharacterCode(Integer characterCode) {
            if (this.isMaximumLength()) {
                return false;
            }
            if (characterCode == SPACE_CHAR_CODE) {
                this.spaceIndicies.add(this.characterCodeList.size()); //not doing size - 1 because the character isn't added yet
            }
            this.characterCodeList.add(characterCode);
            return true;
        }

        /**
         * @description Is this line maximum length?
         * @return Returns `true` if the line is max length and `false` otherwise.
         */
        private Boolean isMaximumLength() {
            if (this.characterCodeList.size() < MAX_CHARS_PER_LINE) {
                return false;
            }
            return true;
        }

        /**
         * @description Does this line contain spaces?
         * @return Returns `true` if the line contains a space and `false` otherwise.
         */
        private Boolean containsSpaces() {
            if (this.spaceIndicies.size() > 0) {
                return true;
            }
            return false;
        }

        /**
         * @description indicates if a word should be broken
         * @return `Boolean` true if yes, `Boolean` false if no
         */
        public Boolean doBreakWord() {
            if (!this.containsSpaces() && this.isMaximumLength()) {
                return true;
            }
            return false;
        }

        /**
         * @description Removes the character at the end of the line until a space character is reached.
         * @return List<Integer> containing the partial word character codes
         */
        public List<Integer> removePartialWord() {
            if (this.spaceIndicies.size() == 0) {
                return null;
            }
            Integer lastSpaceIndex = this.spaceIndicies.remove(this.spaceIndicies.size() - 1);
            Integer numberToRemove = (this.characterCodeList.size() - 1) - (lastSpaceIndex);
            if (numberToRemove <= 0) {
                return null;
            }
            List<Integer> removedCharacterCodes = new List<Integer>(numberToRemove);
            for (Integer counter = 1; counter <= numberToRemove; counter++) {
                Integer characterCode = this.characterCodeList.remove((this.characterCodeList.size() - 1));
                removedCharacterCodes[(numberToRemove - counter)] = characterCode;
                if (characterCode == SPACE_CHAR_CODE) {
                    break;
                }
            }
            return removedCharacterCodes;
        }

        /**
         * @description overridden toString method
         * @return this line but a `String`
         */
        public override String toString() {
            return String.fromCharArray(this.characterCodeList);
        }
    }

    /**
     * @description An exception class
     */
    private class VCC_VdifNoteParserException extends Exception {
    }
}
