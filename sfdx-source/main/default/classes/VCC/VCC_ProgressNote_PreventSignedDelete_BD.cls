/**
 * @description This trigger action prevents deletetion of a VCC_Progress_Note__c record when its VCC_Signed__c field is set to `true`.
 * The error message stored in CustomLabel VCC_Prevent_Delete_Signed_Progress_Note is added to the record when it's found to be signed.
 */
@SuppressWarnings('PMD.ClassNamingConventions') // following the naming convention shown on the apex-trigger-actions-framework github
public with sharing class VCC_ProgressNote_PreventSignedDelete_BD implements TriggerAction.BeforeDelete {
    @TestVisible
    private static final String PREVENT_DELETE_ERROR_MESSAGE = System.Label.VCC_Prevent_Delete_Signed_Progress_Note;

    /**
     * @description Prevent delete of of signed progress note
     * @param oldList List of progress notes slated for deletion
     */
    public void beforeDelete(List<VCC_Progress_Note__c> oldList) {
        if (oldList == null || oldList.isEmpty()) {
            return;
        }
        for (VCC_Progress_Note__c progressNote : oldList) {
            // if Progress Note Signed checkbox = true, throw prevent delete error
            if (progressNote.VCC_Signed__c) {
                // add error to prevent delete. Display custom label message.
                progressNote.addError(PREVENT_DELETE_ERROR_MESSAGE);
            }
        }
    }
}
