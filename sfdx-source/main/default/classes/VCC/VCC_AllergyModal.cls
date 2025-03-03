/**
 * @author Kumar Balan
 * @group API - Bridg - Allergy
 * @description Allergy model class.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class VCC_AllergyModal extends VCC_WrapperWithKeyword {
    /**
     * @description Constructor.
     */
    public class Author_Y {
        @AuraEnabled
        public Author practitioner;
        public String comment;
        //	@AuraEnabled
        //	public ObservationDateTime time;
    }

    /**
     * @description ClinicalData inner class.
     */
    public class ClinicalData {
        public String requestId;
        @AuraEnabled
        public List<Patient_Z> patient;
        public String templateId;
    }

    /**
     * @description Author_Z inner class.
     */
    public class Author_Z {
        @AuraEnabled
        public Author practitioner;
    }

    @AuraEnabled
    public ClinicalData clinicalData;

    /**
     * @description DrugClass inner class.
     */
    public class DrugClass {
        @AuraEnabled
        public Code code;
    }

    /**
     * @description Name inner class.
     */
    public class Name {
        @AuraEnabled
        public String given;
        @AuraEnabled
        public String family;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String displayName;
    }

    /**
     * @description CommentType inner class.
     */
    public class CommentType {
        @AuraEnabled
        public String displayText;
        public String code;
        public String codingSystem;
    }

    /**
     * @description Agent inner class.
     */
    public class Agent {
        @AuraEnabled
        public String code;
    }

    /**
     * @description IntoleranceConditions inner class.
     */
    public class IntoleranceConditions {
        @AuraEnabled
        public Agent agent;
        @AuraEnabled
        public List<Reaction> reaction;
        @AuraEnabled
        public CommentType informationSourceCategory;
        @AuraEnabled
        public Author_Y author;
        @AuraEnabled
        public AllergyType allergyType;
        @AuraEnabled
        public ObservationDateTime observationTime;
        @AuraEnabled
        public List<DrugClass> drugClass;
        @AuraEnabled
        public List<ChartMarker> chartMarker;
        @AuraEnabled
        public Verifier verifier;
        @AuraEnabled
        public FacilityIdentifier facilityIdentifier;
        @AuraEnabled
        public String status;

        @AuraEnabled
        public Mechanism mechanism;

        @AuraEnabled
        public List<CommentEvent> commentEvents;
    }

    /**
     * @description CommentType inner class.
     */
    public class CommentEvent {
        @AuraEnabled
        public String displayText;
        @AuraEnabled
        public List<string> comments;
    }

    /**
     * @description CommentType inner class.
     */
    public class Mechanism {
        @AuraEnabled
        public String displayText;
    }

    /**
     * @description CommentType inner class.
     */
    public class FacilityIdentifier {
        @AuraEnabled
        public String name;
    }

    /**
     * @description CommentType inner class.
     */
    public class Verifier {
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public DateTimeVar dateTimeVar;
        @AuraEnabled
        public Author practitioner;
    }

    /**
     * @description CommentType inner class.
     */
    public class DateTimeVar {
        @AuraEnabled
        public String literal;
    }

    /**
     * @description CommentType inner class.
     */
    public class AllergyType {
        @AuraEnabled
        public String displayText;
        public String code;
        public String codingSystem;
    }

    /**
     * @description CommentType inner class.
     */
    public class Reaction {
        @AuraEnabled
        public CommentType reaction;
        public Author_Z author;
        @AuraEnabled
        public ObservationDateTime observationTime;
    }

    /**
     * @description CommentType inner class.
     */
    public class Code {
        @AuraEnabled
        public String alternateDisplayText;
        @AuraEnabled
        public String displayText;
        @AuraEnabled
        public String alternateCodingSystem;
        @AuraEnabled
        public String code;
        @AuraEnabled
        public String codingSystem;
        @AuraEnabled
        public String alternateCode;
    }

    /**
     * @description ObservationDateTime inner class.
     */
    public class ObservationDateTime {
        /**
         * @description Overrides setter to format date/time.
         */
        @AuraEnabled
        public String literal {
            get;
            set {
                if (value != null) {
                    String timeValue = String.valueOf(value);
                    onsetDateStr = timeValue.substring(4, 6) + '/' + timeValue.substring(6, 8) + '/' + timeValue.substring(0, 4);
                    this.onsetDate = Date.newInstance(
                        Integer.valueOf(timeValue.substring(0, 4)),
                        Integer.valueOf(timeValue.substring(4, 6)),
                        Integer.valueOf(timeValue.substring(6, 8))
                    );

                    if (timeValue.length() >= 14) {
                        String hour = timeValue.substring(8, 10);
                        String minute = timeValue.substring(10, 12);
                        String seconds = timeValue.substring(12, 14);
                        String ampm = 'AM';
                        Integer hourCheck = Integer.valueOf(hour);

                        if (hourCheck > 12) {
                            ampm = 'PM';
                            hour = (hourCheck - 12) + '';
                        }
                        this.onsetTimeStr = String.valueOf(hour) + ':' + minute + ' ' + ampm;
                    }
                }
                literal = value;
            }
        }

        @AuraEnabled
        public Date onsetDate;
        @AuraEnabled
        public String onsetDateStr;

        @AuraEnabled
        public String onsetTimeStr;
    }

    /**
     * @description ChartMarker inner class.
     */
    public class ChartMarker {
        @AuraEnabled
        public Author practitioner;
        @AuraEnabled
        public ObservationDateTime timeVal;
        //@AuraEnabled
        //public string comment;
    }

    /**
     * @description Patient_Z inner class.
     */
    public class Patient_Z {
        @AuraEnabled
        public List<IntoleranceConditions> intoleranceConditions;
    }

    /**
     * @description Author inner class.
     */
    public class Author {
        @AuraEnabled
        public Name name;
    }

    /**
     * @description RecordIdentifier inner class.
     */
    public class RecordIdentifier {
        @AuraEnabled
        public String identity;
    }

    /**
     * @description Translates keywords.
     * @return Map<String, String>
     */
    public override Map<String, String> getKeywordTranslationMap() {
        return new Map<String, String>{ 'time' => 'timeVal' };
    }
}
