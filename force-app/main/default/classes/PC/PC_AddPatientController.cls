/**
 * @description Contains logic associated to the PC Add Patient lwc component
 * @author Booz Allen
 * @since 2024
 */

public without sharing class PC_AddPatientController {
    /**
     * @description repository for custom PC Case object
     */
    @TestVisible
    private static PC_PrcCaseRepo prcCaseRepo {
        get {
            return prcCaseRepo ?? new PC_PrcCaseRepo();
        }
        set;
    }

    /**
     * @description         Retrieves the PC Case (current page) and assigns the selected Account to Case.Patient_Account
     * @param prcCaseId     Id of the PC Case
     * @param selectedAccId Id of the Account to be associated
     * @return              `PC_Case__c` the updated PC Case
     * @exception           DMLException error during PC Case update
     */
    @AuraEnabled
    public static PC_Case__c associateAccount(Id prcCaseId, Id selectedAccId) {
        Set<String> fields = new Set<String>{ 'Patient_Account__c' };

        PC_Case__c caseToUpdate = (PC_Case__c) prcCaseRepo.fetchById(prcCaseId, fields);

        if (caseToUpdate != null) {
            caseToUpdate.Patient_Account__c = selectedAccId;
        }

        try {
            prcCaseRepo.doUpdate(caseToUpdate);
            return caseToUpdate;
        } catch (DmlException dexc) {
            if (!Test.isRunningTest()) {
                for (Integer count = 0; count < dexc.getNumDml(); count++) {
                    Logger.error(dexc.getDmlMessage(count));
                }
            } else {
                Logger.error(dexc.getMessage());
            }
            Logger.error(dexc.getStackTraceString());
            throw new AuraHandledException(dexc.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
