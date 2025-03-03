/**
 * @description       : This Class contains the invocable method to get current TeleEcStatusEscalation objects for flows
 * @author            : Booz Allen
 **/
public with sharing class TUC_GetCurrentVISNStatusInvocable {
    /**
     * @description This method takes in an input for the getCurrentStatusRecord call in an invocable fashion. It then returns a string from the record retrieved, using the inputs.
     * @param escalationInputs - This is a list of a custom class that contains the necessary inputs for the calls to function. This is used in flows that make use of this invocable. We expect there to only be a single record being passed in.
     * @return List<String> - Returns a String list that contains the current status from the related escalation status record.
     */
    @InvocableMethod(label='Get TeleEc Status for VISN and Queue')
    public static List<String> getCurrentEscalationStatusInvocable(List<EscalationStatusRequest> escalationInputs) {
        List<String> escalationStatusList = new List<String>();
        if (escalationInputs != null && escalationInputs.size() > 0) {
            EscalationStatusRequest escalationRequest = escalationInputs[0];
            Tele_EC_Escalation_Status__c currentStatusRecord = TUC_EscalatePauseButtonController.getCurrentStatusRecord(
                escalationRequest.providedVISN,
                escalationRequest.queueType
            );
            if (currentStatusRecord != null) {
                escalationStatusList.add(currentStatusRecord.TUC_Status_Type__c);
            }
        }
        return escalationStatusList;
    }

    /**
     * @description - Custom class that contains input parameters that pertain the desired inputs for the get current status call.
     */
    public class EscalationStatusRequest {
        /**
         * @description - String that pertains to the desired VISN to achieve the status update for.
         */
        @InvocableVariable
        public String providedVISN;
        /**
         * @description - String that pertains to the desired Queue to achieve the status update for.
         */
        @InvocableVariable
        public String queueType;
    }
}
