/**
 * @description  Controller for the pcCaseListComponent LWC component - displays a Specialist's Open Case details
 * @author       Booz Allen Hamilton
 * @see          PC_PrcCaseRepo
 * @see          PC_PrcCaseRepoTest
 * @see          PC_CaseListControllerTest
 **/
public with sharing class PC_CaseListController {
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
     * @description get a list of the oldest open PC Cases and return the oldest one.
     * @return      `PC_Case__c`
     */
    @AuraEnabled(cacheable=true)
    public static PC_Case__c getOpenPcCase() {
        List<PC_Case__c> lstOpenCases;

        try {
            lstOpenCases = prcCaseRepo.getOldestOpenPrcCaseOwnedByUser((Id) UserInfo.getUserId());
        } catch (Exception caughtException) {
            Logger.error('Failed to retrieve the oldest PC Case via getOpenPcCase method', caughtException);
            Logger.saveLog();
            throw VCC_ExceptionUtils.createAuraHandledException(caughtException.getMessage());
        }
        return lstOpenCases?.isEmpty() ? null : lstOpenCases?.get(0);
    }
}
