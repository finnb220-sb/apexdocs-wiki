/**
 * @description Class is responsible for providing data to multiple LWC components and Apex classes for Provider Connect.
 * @author      Booz Allen Hamilton
 * @see         pcCancelCase Lighting Web Component
 **/

public with sharing class PC_CancelCaseController {
    @TestVisible
    private static final String CASE_ID_BLANK_ERROR_MESSAGE = System.Label.CASE_ID_BLANK_ERROR_MESSAGE;
    @TestVisible
    private static final String CASE_ALREADY_CLOSED_STATUS = System.Label.CASE_ALREADY_CLOSED_STATUS;
    @TestVisible
    private static final String CASE_CANCELED_STATUS = System.Label.CASE_CANCELED_STATUS;
    private static final String CLOSED_CASE = 'Closed__c';

    /**
     * @description repository for custom PC Case object
     */
    @TestVisible
    private static PC_PrcCaseRepo prcCaseRepo {
        get {
            return prcCaseRepo = prcCaseRepo ?? new PC_PrcCaseRepo();
        }
        set;
    }

    /**
     * @description Method to cancel the specified case
     * @param caseId - String value of the ProviderConnect Case Id
     * @return       `PC_Case__c` Closed case
     **/
    @AuraEnabled
    public static PC_Case__c cancelCase(String caseId) {
        if (String.isBlank(caseId)) {
            throw new PC_CustomException(CASE_ID_BLANK_ERROR_MESSAGE);
        }

        try {
            PC_Case__c caseToCancel = (PC_Case__c) prcCaseRepo.fetchById(caseId, new Set<String>{ CLOSED_CASE });

            if (caseToCancel.Closed__c) {
                throw new PC_CustomException(CASE_ALREADY_CLOSED_STATUS);
            }
            caseToCancel.Status__c = CASE_CANCELED_STATUS;
            prcCaseRepo.doUpdate(caseToCancel);

            return caseToCancel;
        } catch (Exception caughtException) {
            throw PC_ExceptionUtils.logAndCreateAuraHandledException(caughtException.getMessage(), caughtException);
        }
    }
}
