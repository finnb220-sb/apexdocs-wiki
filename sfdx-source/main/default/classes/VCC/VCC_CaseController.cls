/**
 * @description Controller class for Case UX.
 */
public with sharing class VCC_CaseController {
    @AuraEnabled
    public static CaseInfo getCaseInfo(Id recordId) {
        SObjectType typeForId = recordId.getSobjectType();
        if (typeForId === Case.SObjectType) {
            return whenCaseGetCaseInfo(recordId);
        } else if (typeForId === VCC_Progress_Note__c.SObjectType) {
            return getCaseInfo(whenProgressNoteGetCaseInfo(recordId));
        } else {
            throw new AuraHandledException('VCC_CaseController.getCaseInfo is not configured for the provided SObjectType.');
        }
    }

    private static Id whenProgressNoteGetCaseInfo(Id recordId) {
        VCC_ProgressNoteSelector progressNoteSelector = new VCC_ProgressNoteSelector();
        progressNoteSelector.addSObjectFields(new List<Schema.SObjectField>{ VCC_Progress_Note__c.VCC_Case__c });
        List<VCC_Progress_Note__c> progressNoteList = progressNoteSelector.selectSObjectsById(new Set<Id>{ recordId });
        return (progressNoteList.size() == 1) ? progressNoteList[0].VCC_Case__c : null;
    }

    private static CaseInfo whenCaseGetCaseInfo(Id recordId) {
        VCC_CaseSelector caseSelector = new VCC_CaseSelector();
        caseSelector.addSObjectFields(new List<Schema.SObjectField>{ Case.RecordTypeId, Case.Subject });
        List<Case> caseList = caseSelector.selectById(new Set<Id>{ recordId });
        if (caseList.size() == 1) {
            return new CaseInfo(caseList[0]);
        }
        return null;
    }

    // This bypasses the callMethod method and is called directly as imperative Apex method (per Salesforce's documentation) from the vccCloseCaseV2 LWC
    @AuraEnabled
    public static String getCaseInfoWrapper(Id recordId) {
        //VCC_CaseController caseController = new VCC_CaseController();
        return JSON.Serialize(VCC_CaseController.getCaseInfo(recordId));
    }

    @TestVisible
    private class CaseInfo {
        public CaseInfo(Case caseRecord) {
            this.id = caseRecord.Id;
            this.recordTypeId = caseRecord.RecordTypeId;
            this.subject = caseRecord.Subject;
            this.recordTypeDeveloperName = Case.getSObjectType().getDescribe().getRecordTypeInfosById().get(this.recordTypeId).getDeveloperName();
        }

        @AuraEnabled
        public Id id;

        @AuraEnabled
        public Id recordTypeId;

        @AuraEnabled
        public String recordTypeDeveloperName;

        @AuraEnabled
        public String subject;
    }
}
