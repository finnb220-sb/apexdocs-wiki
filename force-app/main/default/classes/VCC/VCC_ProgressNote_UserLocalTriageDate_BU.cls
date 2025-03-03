/**
 * @description This trigger action populates the text field VCC_Triage_Date_User_Timezone_Adjusted__c with a String representation of
 * the Datetime value in VCC_Triage_Date__c but in the timezone of the running user. This must be done because, when the progress note
 * is converted to text (preparing to send to VistA, to be placed into the patients electronic health record), the VCC_Triage_Date__c field
 * is printed in GMT (or UTC, cant remember).
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_ProgressNote_UserLocalTriageDate_BU implements TriggerAction.BeforeUpdate {
    @TestVisible
    private static final String TRIAGE_DATE_FORMAT_STRING = System.Label.VCC_Triage_Date_Format_String;

    /**
     * @description Implementation of `TriggerAction.BeforeUpdate`, which is called from the trigger action framework.
     * @param newList
     * @param oldList
     */
    public void beforeUpdate(List<VCC_Progress_Note__c> newList, List<VCC_Progress_Note__c> oldList) {
        if (oldList == null || oldList.isEmpty()) {
            return;
        }
        if (newList == null || newList.isEmpty()) {
            return;
        }
        for (Integer listIndex = 0; listIndex < oldList.size(); listIndex++) {
            setTriageDateUserTimezoneAdjusted(newList.get(listIndex), oldList.get(listIndex));
        }
    }

    /**
     * @description See class description
     *
     * @param newProgressNote progress note with new values
     * @param oldProgressNote progress note with old values
     */
    @TestVisible
    private void setTriageDateUserTimezoneAdjusted(VCC_Progress_Note__c newProgressNote, VCC_Progress_Note__c oldProgressNote) {
        if (oldProgressNote == null || newProgressNote == null) {
            return;
        }
        if (newProgressNote.VCC_Triage_Date__c == oldProgressNote.VCC_Triage_Date__c) {
            // nothing is changing between old and new, exiting
            return;
        }
        if (newProgressNote.VCC_Triage_Date__c == null) {
            // clear the value in VCC_Triage_Date_User_Timezone_Adjusted__c to stay in lock step with VCC_Triage_Date__c and exit
            newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c = null;
            return;
        }
        // either the triage date is changing, or it is updating from null to non-null. Either way we want to update the formatted date.
        newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c = newProgressNote.VCC_Triage_Date__c.format(TRIAGE_DATE_FORMAT_STRING, UserInfo.getTimeZone().toString());
    }
}
