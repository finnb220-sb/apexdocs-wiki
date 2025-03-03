public with sharing class VCC_VdifRSCommon {
    public class TextTO {
        public String text;
        public FaultTO fault;

        public TextTO() {
            this.fault = new FaultTO();
        }
    }

    public class TaggedText {
        public FaultTO fault;
        public String tag;
        public String text;

        public TaggedText() {
            this.fault = new FaultTO();
        }
    }

    public class TaggedTextArray {
        public FaultTO fault;
        public Long count;
        public String tag;
        public Boolean textOnly;
        public ArrayOfTaggedText results;

        public TaggedTextArray() {
            this.results = new ArrayOfTaggedText();
        }
    }

    public class ArrayOfTaggedText {
        public List<TaggedText> taggedText;

        public ArrayOfTaggedText() {
            this.taggedText = new List<TaggedText>();
        }
    }

    public class FaultTO {
        public String innerMessage;
        public String innerStackTrace;
        public String innerType;
        public String message;
        public String stackTrace;
        public String suggestion;
        public String type;
    }
}
