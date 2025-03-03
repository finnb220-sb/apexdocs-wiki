/**
 * @description method that extends VCC_DivaResponse for Cmop Lot/Expiration Logs
 */
public class VCC_CmopLotExpLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<CmopLotExpLog> log;

    /**
     * @description method that generates LotExp class
     */

    public class CmopLotExpLog {
        @AuraEnabled
        public String lotExp;
        @AuraEnabled
        public String rxIndicator;
        @AuraEnabled
        public String expirationDate;
    }

    /**
     * @param responseBody
     * @description method that parses incoming LotExp
     * @return  VCC_CmopLotExpLogRS
     */

    public static VCC_CmopLotExpLogRS parse(String responseBody) {
        return (VCC_CmopLotExpLogRS) System.JSON.deserialize(responseBody, VCC_CmopLotExpLogRS.class);
    }
}
