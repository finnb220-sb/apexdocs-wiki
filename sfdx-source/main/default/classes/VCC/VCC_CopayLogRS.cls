/**
 * @description method that extends VCC_DivaResponse for CopayLog
 */
public class VCC_CopayLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<CopayLog> log;

    /**
     * @description method that generates Copay class
     */
    public class CopayLog {
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String rxReference;
        @AuraEnabled
        public String copayActivityLogDate;
        @AuraEnabled
        public String initiatorOfActivity;
    }

    /**
     * @param responseBody
     * @description method that parses incoming Copay
     * @return  VCC_CopayLogRS
     */
    public static VCC_CopayLogRS parse(String responseBody) {
        return (VCC_CopayLogRS) System.JSON.deserialize(responseBody, VCC_CopayLogRS.class);
    }
}
