/**
 * @description method that extends VCC_DivaResponse for Cmop Log
 */
public class VCC_CmopLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<CmopLog> log;

    /**
     * @description method that generates Cmop class
     */
    public class CmopLog {
        @AuraEnabled
        public String ndcReceived;
        @AuraEnabled
        public String rxReference;
        @AuraEnabled
        public String sequenceNumber;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String transmissionNumber;
        @AuraEnabled
        public String dateTimeShipped;
        @AuraEnabled
        public String fdaMedGuide;
        @AuraEnabled
        public String transmissionNumberUrl;
    }

    /**
     * @param responseBody
     * @description method that parses incoming Copay
     * @return  VCC_CmopLogRS
     */
    public static VCC_CmopLogRS parse(String responseBody, VCC_PharmacyLogRQ pharmLogRQ) {
        VCC_CmopLogRS resp = (VCC_CmopLogRS) System.JSON.deserialize(responseBody, VCC_CmopLogRS.class);

        if (resp.success) {
            for (VCC_CmopLogRS.CmopLog log : resp?.log) {
                log.transmissionNumberUrl = String.format(Label.VCC_CMOP_Log_URL, new List<String>{ pharmLogRQ.facilityId, log.transmissionNumber });
            }
        }

        return resp;
    }
}
