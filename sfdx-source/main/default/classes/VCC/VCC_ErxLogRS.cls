/**
 * @description : It extends VCC_DivaResponse and provides information about ErxLog.
 */
public class VCC_ErxLogRS extends VCC_DivaResponse {
    /**
     * @description A flag that determines whether the operation was successful.
     */
    @AuraEnabled
    public Boolean success;

    /**
     * @description A message associated with the operation.
     */
    @AuraEnabled
    public String message;

    /**
     * @description A list of ErxLog objects.
     */
    @AuraEnabled
    public List<ErxLog> log;

    /**
     * @description : A class to provide more insight related to the ErxLog.
     */
    public class ErxLog {
        /**
         * @description DateTime of the Activity log
         */
        @AuraEnabled
        public String erxLogDateTime;

        /**
         * @description Comments in the Activity Log.
         */
        @AuraEnabled
        public String comment;

        /**
         * @description The initiator of this specific activity.
         */
        @AuraEnabled
        public String initiatorOfActivity;

        /**
         * @description Reason associated with the Activity log.
         */
        @AuraEnabled
        public String reason;

        /**
         * @description Rx Reference associated with the Activity log.
         */
        @AuraEnabled
        public String rxReference;
    }

    /**
     * @description A method to parse the JSON response.
     * @param responseBody The JSON response as a String.
     * @return VCC_ErxLogRS the deserialized response.
     */
    public static VCC_ErxLogRS parse(String responseBody) {
        return (VCC_ErxLogRS) System.JSON.deserialize(responseBody, VCC_ErxLogRS.class);
    }
}
