/**
 * @description VCC Patient Lab Service
 */

public with sharing class VCC_PatientLabService {
    @TestVisible
    private static final String RECENT_SUD_LABS_ERROR = System.Label.VCC_Recent_SUD_Labs_Error;

    @TestVisible
    private static final String RECENT_SUD_LABS_NONE = System.Label.VCC_Recent_SUD_Labs_No_Results;

    /**
     * @description Adds Recent SUD Labs to VCC_Progress_Note__c field VCC_Recent_SUD_Labs__c
     * @param progressNoteId Id of
     */
    public static void updateProgressNoteWithSUDInformation(Id progressNoteId) {
        try {
            // Step 1: Get the Progress Note from database
            String icn = [
                SELECT Id, VCC_Patient_ICN__c
                FROM VCC_Progress_Note__c
                WHERE Id = :progressNoteId
                WITH USER_MODE
                LIMIT 1
            ]
            .VCC_Patient_ICN__c;

            // Step 2: Get the data from the remote site
            VCC_BridgLabsRS bridgLabsRS = new VCC_BridgClient(new Set<VCC_BaseClient.ClientOption>{}).labs(new VCC_BridgLabsRQ(icn, 'USVHA')); //TODO: move 'USVHA' to custom metadata

            if (bridgLabsRS.statusCode != 200) {
                Logger.debug(bridgLabsRS.httpResponse.getBody());
                throw new VCC_RemoteServiceException(RECENT_SUD_LABS_ERROR);
            }

            // Step 3: Format, transform, etc
            List<VCC_LabModal.Lab> formattedLabs = new VCC_LabDomain()
                .flattenSites((VCC_LabModal) JSON.deserialize(JSON.serialize(new Map<String, Object>{ 'sites' => bridgLabsRS.sites }), VCC_LabModal.class));

            String sudLabsString;
            try {
                sudLabsString = new VCC_SudService(formattedLabs).toSudString();
            } catch (VCC_InternalException internalException) {
                Logger.error('No recend SUD Labs', internalException);
            }

            // Step 4: Update the progress note
            if (String.isBlank(sudLabsString)) {
                Database.update(new VCC_Progress_Note__c(Id = progressNoteId, VCC_Recent_SUD_Labs__c = RECENT_SUD_LABS_NONE), AccessLevel.USER_MODE);
            } else {
                Database.update(new VCC_Progress_Note__c(Id = progressNoteId, VCC_Recent_SUD_Labs__c = sudLabsString), AccessLevel.USER_MODE);
            }
        } catch (Exception e) {
            Logger.error('SUD Lab Exception', e);
            Logger.saveLog(Logger.SaveMethod.SYNCHRONOUS_DML);
            Database.update(new VCC_Progress_Note__c(Id = progressNoteId, VCC_Recent_SUD_Labs__c = RECENT_SUD_LABS_ERROR), AccessLevel.USER_MODE);
        }
    }
}
