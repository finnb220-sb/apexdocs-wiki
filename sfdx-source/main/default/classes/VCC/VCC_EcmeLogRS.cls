public class VCC_EcmeLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<EcmeLog> log;

    public class EcmeLog {
        @AuraEnabled
        public String ecmeLogDateTime;
        @AuraEnabled
        public String initiatorOfActivity;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String rxReference;
        @AuraEnabled
        public String comment;
    }

    public static VCC_EcmeLogRS parse(String responseBody) {
        return (VCC_EcmeLogRS) System.JSON.deserialize(responseBody, VCC_EcmeLogRS.class);
    }
}
