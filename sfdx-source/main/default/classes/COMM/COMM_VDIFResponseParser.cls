public with sharing class COMM_VDIFResponseParser {
    public TextTO textTO;
    public NoteResultTO noteResultTO;
    public Boolean exceptionOccurred;
    public String exceptionMessage;
    public TaggedTextArray taggedTextArray;

    //vdifSaveNoteAndEncouter
    public class TextTO {
        public String text;
        public Fault fault;
    }

    public class TaggedTextArray {
        public Long count;
        public String tag;
        public ArrayOftaggedTextTaggedText results;
        public Boolean textOnly;
    }

    public class ArrayOftaggedTextTaggedText {
        List<TaggedText> taggedText;
    }

    public class TaggedText {
        public Fault fault;
        public String tag;
        public String text;
    }

    //vdifWriteNote
    public class NoteResultTO {
        public Fault fault;
        public String id;
        public Integer totalPages;
        public Integer lastPageRecd;
        public String explanation;
    }

    public class Fault {
        public String innerMessage;
        public String innerStackTrace;
        public String innerType;
        public String message;
        public String stackTrace;
        public String suggestion;
        public String type;
    }
}
