/**
 * @description Controller class for the pcSpecialistOmniStatus aura component
 * @author      Booz Allen Hamilton
 */
public with sharing class PC_SpecialistOmniStatusController {
    /**
     * @description repository for ServicePresenceStatus object
     */
    @TestVisible
    private static VCR_ServicePresenceStatusRepo servicePresenceStatusRepo {
        get {
            return servicePresenceStatusRepo = servicePresenceStatusRepo ?? new VCR_ServicePresenceStatusRepo();
        }
        set;
    }

    /**
     * @description gets the 15 character Id of the PC_Available_Provider_Connect service presence status for use by the specialistOmniStatus component
     *              the omni-channel API library does not play well with the 18 character ID for Service Presence Statuses
     * @return      `String` 15 character Id of the PC_Available_Provider_Connect service presence status
     */
    @AuraEnabled
    public static String getPcServicePresenceStatusId() {
        try {
            ServicePresenceStatus pcServicePresenceStatus = servicePresenceStatusRepo.fetchByDeveloperName(
                'PC_Available_Provider_Connect'
            );
            return pcServicePresenceStatus != null ? pcServicePresenceStatus.Id.to15() : null;
        } catch (QueryException caughtException) {
            Logger.error(caughtException.getMessage(), caughtException);
            AuraHandledException auraExceptionToThrow = new AuraHandledException(caughtException.getMessage());
            //This is required if you want anything other than Script-thrown exception.
            auraExceptionToThrow.setMessage(caughtException.getMessage());
            throw auraExceptionToThrow;
        }
    }
}
