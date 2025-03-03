@SuppressWarnings('PMD.ApexDoc, PMD.ApexCrudViolation')
public with sharing class VCC_InterviewsByRecordController {
    @InvocableMethod(label='Get T2T Interviews')
    public static List<String> retrieveInterviews(List<String> recordId) {
        String thisRecord = recordId[0];
        String concat = '%';
        thisRecord = concat + thisRecord + concat;
        List<String> isInterview = new List<String>();
        for (FlowInterview flows : [
            SELECT InterviewLabel
            FROM FlowInterview
            WHERE InterviewLabel LIKE :thisRecord
            WITH SECURITY_ENFORCED
            LIMIT 1
        ])
            isInterview.add(flows.InterviewLabel);

        if (isInterview == null || isInterview.isEmpty()) {
            return null;
        }

        return isInterview;
    }

    @AuraEnabled
    public static String getPausedId(String recordId) {
        String thisRecord = '%' + recordId + '%';
        List<FlowInterview> interviews = [
            SELECT Id
            FROM FlowInterview
            WHERE InterviewLabel LIKE :thisRecord
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate ASC NULLS LAST
        ];
        if (interviews == null || interviews.isEmpty()) {
            return null;
        }
        return interviews.get(0).Id;
    }

    @AuraEnabled
    public static Boolean removeInterview(Id rowId) {
        List<FlowInterview> interviews = [
            SELECT Id
            FROM FlowInterview
            WHERE Id = :rowId
            WITH SECURITY_ENFORCED
            ORDER BY LastModifiedDate ASC NULLS LAST
        ];
        if (interviews == null || interviews.isEmpty()) {
            return false;
        }
        delete interviews;
        return true;
    }

    @AuraEnabled
    public static void resetT2TData(String recordId) {
        List<VCC_Progress_Note_Detail__c> dNotes = [
            SELECT Id, Name, VCC_Progress_Note__c, VCC_T2T_Data__c
            FROM VCC_Progress_Note_Detail__c
            WHERE VCC_Progress_Note__c = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!dNotes.isEmpty()) {
            VCC_Progress_Note_Detail__c dNote = dNotes[0];
            dNote.VCC_T2T_Data__c = null;
            update dNote;
        }

        List<VCC_Progress_Note__c> pNotes = [
            SELECT Id, Name, LastModifiedDate, VCC_Signed__c, VCC_Relative_Type__c, VCC_Caller_Name_Text__c, VCC_Caregiver_Name__c, VCC_T2T_Assessment_Completed__c
            FROM VCC_Progress_Note__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (!pNotes.isEmpty()) {
            VCC_Progress_Note__c pNote = pNotes[0];
            pNote.VCC_T2T_Assessment_Completed__c = false;
            update pNote;
        }
    }
    @AuraEnabled
    public static Boolean getFieldValue(Id recordId) {
        List<VCC_Progress_Note__c> record = [
            SELECT Id, VCC_T2T_Assessment_Completed__c
            FROM VCC_Progress_Note__c
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return record[0].VCC_T2T_Assessment_Completed__c;
    }
}
