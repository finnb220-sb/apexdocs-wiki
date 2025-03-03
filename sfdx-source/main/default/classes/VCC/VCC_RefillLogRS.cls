/**
 * @description method that extends VCC_DivaResponse for Refill
 */
public class VCC_RefillLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<RefillLog> log;

    /**
     * @description method that generates Refill class
     */
    public class RefillLog {
        @AuraEnabled
        public String divisionNumber;
        @AuraEnabled
        public String divisionName;
        @AuraEnabled
        public String loginDate;
        @AuraEnabled
        public String refillDate;
        @AuraEnabled
        public String pharmacistName;
        @AuraEnabled
        public String releasedDateTime;
        @AuraEnabled
        public String routing;
        @AuraEnabled
        public String dispensedDate;
        @AuraEnabled
        public String quantity;
        @AuraEnabled
        public String ndc;
        @AuraEnabled
        public String lotNumber;
        @AuraEnabled
        public String personRequestingRefill;
    }

    /**
     * @param responseBody
     * @description method that parses incoming Copay
     * @return  VCC_RefillLogRS
     */
    public static VCC_RefillLogRS parse(String responseBody) {
        return (VCC_RefillLogRS) System.JSON.deserialize(responseBody, VCC_RefillLogRS.class);
    }
}
