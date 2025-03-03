/**
 * @description Dummy apex class in order to force a commit transaction within the VCC DAS Sign & Integrate VCC_Progress_Note__c Flow
 * @author BAH
 * @see VCC_DAS_Sign_Integrate_VCC_Progress_Note__c
 *
 */

public with sharing class VCC_CommitFlowTransaction {
    @InvocableMethod(label='Dummy Action')
    /**
     * @description Dummy Apex method to perform a commit within the VCC DAS Sign & Integrate VCC_Progress_Note__c Flow.
     * @justification All of the DAS logic was being done in one transaction within the DAS flows. Adding a Screen within the flow will commit a transaction, but we can't add
     * any more screens to the Sign Note flow. It needs to look the same to the end user even with all the new DAS logic.
     * If the sign note process failed for any reason, the flow was giving us an error saying “you have uncommitted work pending” instead of the true error that caused the failure.
     * Adding this class allows us to force the DML operations to occur so we don't get that error.
     * Also we need to be able to access the value of the DAS last error code field within the flows so forcing that commit allows that value to be available.
     */
    public static void performDummyAction() {
    }
}
