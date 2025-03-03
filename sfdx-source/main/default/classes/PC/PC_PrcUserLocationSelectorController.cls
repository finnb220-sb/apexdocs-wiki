/**
 * @description Controller for the pcPrcUserLocationSelector LWC
 * @author      Booz Allen
 * @since       2024
 */
public with sharing class PC_PrcUserLocationSelectorController {
    @TestVisible
    private static PC_PrcUserRepo visiblePrcUserRepo;

    private static PC_PrcUserRepo prcUserRepo {
        get {
            if (visiblePrcUserRepo == null) {
                visiblePrcUserRepo = new PC_PrcUserRepo();
            }
            return visiblePrcUserRepo;
        }
    }

    /**
     * @description  fetches PC_User__c based on the supplied userId
     * @param userId the running user's Id
     * @return       `PC_User__c` running user's respective PC_User record
     * @exception    QueryException
     */
    @AuraEnabled(cacheable=true)
    public static PC_User__c getPrcUser(Id userId) {
        try {
            List<PC_User__c> fetchResultList = prcUserRepo.fetchPrcUserByUserId(userId);
            return fetchResultList.size() > 0 ? fetchResultList[0] : null;
        } catch (Exception e) {
            log_LogService.log(
                'PC_PrcUserLocationSelectorController.getPrcUser Exception',
                log_LogService.LogType.ERROR,
                e
            );
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description   upserts the PC_User__c record (currently, only net new or update with changes to the Current_Location__c field)
     * @param prcUser current running user's PC_User__c record (matched via User_ID__c field)
     * @return        `PC_User__c` upserted record
     * @exception     DmlException
     */
    @AuraEnabled
    public static PC_User__c savePrcUser(PC_User__c prcUser) {
        try {
            return prcUserRepo.upsertPrcUser(prcUser);
        } catch (Exception e) {
            log_LogService.log(
                'PC_PrcUserLocationSelectorController.savePrcUser Exception',
                log_LogService.LogType.ERROR,
                e
            );
            log_LogService.publish();
            throw new AuraHandledException(e.getMessage());
        }
    }
}
