public class VCC_LabelLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<LabelLog> log;

    public class LabelLog {
        @AuraEnabled
        public String labelComment;
        @AuraEnabled
        public String labelDateTime;
        @AuraEnabled
        public String printedBy;
        @AuraEnabled
        public String rxReference;
        @AuraEnabled
        public String fdaMedGuide;
    }

    public static VCC_LabelLogRS parse(String responseBody) {
        return (VCC_LabelLogRS) System.JSON.deserialize(responseBody, VCC_LabelLogRS.class);
    }
}
