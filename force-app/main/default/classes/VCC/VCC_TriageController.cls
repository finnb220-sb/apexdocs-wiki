public with sharing class VCC_TriageController {
    @AuraEnabled
    public static List<VCC_Progress_Note__c> getVitals(Id recordId) {
        VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();
        progressNoteSelector.addSObjectFields(
            new List<Schema.SObjectField>{
                VCC_Progress_Note__c.VCC_Gender__c,
                VCC_Progress_Note__c.VCC_Date_of_Birth__c,
                VCC_Progress_Note__c.VCC_Height__c,
                VCC_Progress_Note__c.VCC_Weight__c,
                VCC_Progress_Note__c.VCC_Systolic_Blood_Pressure__c,
                VCC_Progress_Note__c.VCC_Diastolic_Blood_Pressure__c,
                VCC_Progress_Note__c.VCC_Temperature__c,
                VCC_Progress_Note__c.VCC_Serum_Glucose__c,
                VCC_Progress_Note__c.VCC_Respiratory_Rate__c,
                VCC_Progress_Note__c.VCC_Pulse_Oximetry__c,
                VCC_Progress_Note__c.VCC_Pulse__c,
                VCC_Progress_Note__c.VCC_Triage_Complete__c,
                VCC_Progress_Note__c.VCC_Triage_Note__c,
                VCC_Progress_Note__c.VCC_Chief_Complaint__c,
                VCC_Progress_Note__c.VCC_Logistical_Recommendation_WHEN__c,
                VCC_Progress_Note__c.VCC_Logistical_Recommendation_WHERE__c,
                VCC_Progress_Note__c.VCC_System_RFI__c,
                VCC_Progress_Note__c.VCC_System_RFL__c
            }
        );
        return progressNoteSelector.selectByIds(new Set<Id>{ recordId });
    }

    @AuraEnabled
    public static TriageStatus getTriageStatus(Id recordId) {
        return new TriageStatus(recordId);
    }

    @TestVisible
    private class TriageStatus {
        @AuraEnabled
        public Boolean isStartable = false;

        @AuraEnabled
        public String isNotStartableReason = 'VCC_TriageController.cls: Unhandled Exception';

        private VCC_Progress_Note__c getProgressNote(Id recordId) {
            VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();
            progressNoteSelector.addSObjectFields(
                new List<Schema.SObjectField>{
                    VCC_Progress_Note__c.VCC_Triage_Complete__c,
                    VCC_Progress_Note__c.CreatedById,
                    VCC_Progress_Note__c.VCC_Signed__c,
                    VCC_Progress_Note__c.VCC_Date_of_Birth__c
                }
            );
            List<VCC_Progress_Note__c> progressNoteList = progressNoteSelector.selectByIds(new Set<Id>{ recordId });
            return (progressNoteList.size() > 0) ? progressNoteList[0] : null;
        }

        private void doIsStartableConditions(VCC_Progress_Note__c progressNoteRecord) {
            if (progressNoteRecord.CreatedById != UserInfo.getUserId()) {
                this.isNotStartableReason = System.Label.VCC_TriageController_isNotStartableReason_must_be_creator;
                return;
            }
            if (progressNoteRecord.VCC_Triage_Complete__c == true) {
                this.isNotStartableReason = System.Label.VCC_TriageController_isNotStartableReason_triage_complete;
                return;
            }
            if (progressNoteRecord.VCC_Signed__c == true) {
                this.isNotStartableReason = System.Label.VCC_TriageController_isNotStartableReason_progress_note_signed;
                return;
            }
            if (String.isBlank(String.valueOf(progressNoteRecord.VCC_Date_of_Birth__c))) {
                this.isNotStartableReason = System.Label.VCC_TriageController_isNotStartableReason_no_dob;
                return;
            }
            this.isNotStartableReason = '';
            this.isStartable = true;
        }

        public TriageStatus(Id recordId) {
            try {
                VCC_Progress_Note__c progressNoteRecord = this.getProgressNote(recordId);
                this.doIsStartableConditions(progressNoteRecord);
            } catch (Exception e) {
                this.isNotStartableReason = 'VCC_TriageController.cls: ' + e.getMessage();
            }
        }
    }
}
