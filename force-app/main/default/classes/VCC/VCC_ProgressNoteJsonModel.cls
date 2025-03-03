public with sharing class VCC_ProgressNoteJsonModel {
    public class ProgressNoteSection {
        public String sectionName;
        public Boolean displaySectionName;
        public Boolean emphasizeSection;
        public List<ProgressNoteField> fields;

        public ProgressNoteSection() {
            this.fields = new List<ProgressNoteField>();
        }
    }

    public class ProgressNoteField {
        public String label;
        public String value;
        public String fieldName;
        public Boolean displayField;
        public Boolean displayValue;
    }
}
