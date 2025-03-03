/**
 * @description This Trigger Action checks that no text field is maxed out. Effectively making their max length one less than specified on the field itself.
 * This is to give a warning to users that they have reached the text limit and to ensure they have not lost any data.
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_ProgressNote_TextFieldSizeCheck_BU implements TriggerAction.BeforeUpdate {
    @TestVisible
    private VCC_ProgressNoteDomain progressNoteDomain = new VCC_ProgressNoteDomain();

    /**
     * @description Implementation of TriggerAction.BeforeUpdate, calls VCC_ProgressNoteDomain.charLimitError
     * @param newList `List<VCC_Progress_Note__c>` records and their new values to be committed to the database
     * @param oldList `List<VCC_Progress_Note__c>` records in their previous/original form
     */
    public void beforeUpdate(List<VCC_Progress_Note__c> newList, List<VCC_Progress_Note__c> oldList) {
        if (newList == null || oldList == null) {
            return;
        }
        if (newList.isEmpty() || oldList.isEmpty()) {
            return;
        }
        progressNoteDomain.charLimitError(newList, new Map<Id, SObject>(oldList));
    }
}
