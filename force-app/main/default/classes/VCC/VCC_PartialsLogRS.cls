/**
 * @description method that extends VCC_DivaResponse for Partial Logs
 */
public class VCC_PartialsLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<PartialLog> log;

    /**
     * @description method that generates PartialLog class
     */
    public class PartialLog {
        @AuraEnabled
        public String divisionNumber;
        @AuraEnabled
        public String divisionName;
        @AuraEnabled
        public String loginDateTime;
        @AuraEnabled
        public String partialDate;
        @AuraEnabled
        public String pharmacistName;
        @AuraEnabled
        public String quantity;
        @AuraEnabled
        public String releasedDateTime;
        @AuraEnabled
        public String ndc;
        @AuraEnabled
        public String dispensedDate;
        @AuraEnabled
        public String routing;
        @AuraEnabled
        public String lotNumber;
    }

    /**
     * @param responseBody
     * @description method that parses incoming Copay
     * @return  VCC_PartialsLogRS
     */
    public static VCC_PartialsLogRS parse(String responseBody) {
        return (VCC_PartialsLogRS) System.JSON.deserialize(responseBody, VCC_PartialsLogRS.class);
    }
}
