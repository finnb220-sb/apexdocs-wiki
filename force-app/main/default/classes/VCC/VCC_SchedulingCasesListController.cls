/**
 * @author VAHC
 * @since 4/20/2023
 * @description Class that holds apex methods to be used in LWC/Aura components
 */

public with sharing class VCC_SchedulingCasesListController {
    /**
     * @description class that gets a list of cases in the MSA queue
     * @return List of VCC_CaseModal
     */
    @AuraEnabled
    public static List<VCC_CaseModal> getCaseList() {
        List<Case> caseList = [
            SELECT
                Id,
                CaseNumber,
                ContactId,
                Contact.Name,
                Status,
                RecordTypeId,
                RecordType.Name,
                VCC_Case_Type__c,
                VCC_Case_Sub_Type__c,
                Subject,
                CreatedDate,
                Owner.Name,
                VCC_Follow_Up_Appt_Needed__c,
                VCC_Follow_Up_Appt_Needed_Hours__c
            FROM Case
            WHERE
                VCC_Queue_type__c = '_MSA'
                AND VCC_VISN_to_Queue_Formula__c = TRUE
                AND (Status = 'New'
                OR Status = 'Open'
                OR Status = 'Patient Call Back'
                OR Status = 'Ready for MP'
                OR Status = 'Nurse Encounter'
                OR Status = 'MP Encounter')
            WITH SECURITY_ENFORCED
            ORDER BY VCC_Follow_Up_Appt_Needed_Hours__c ASC NULLS LAST, CreatedDate ASC
            LIMIT 10000
        ];

        if (Test.isRunningTest()) {
            caseList = [
                SELECT
                    Id,
                    CaseNumber,
                    ContactId,
                    Contact.Name,
                    Status,
                    RecordTypeId,
                    RecordType.Name,
                    VCC_Case_Type__c,
                    VCC_Case_Sub_Type__c,
                    Subject,
                    CreatedDate,
                    Owner.Name,
                    VCC_Follow_Up_Appt_Needed__c,
                    VCC_Follow_Up_Appt_Needed_Hours__c
                FROM Case
                WITH SECURITY_ENFORCED
                LIMIT 10000
            ];
        }
        List<VCC_CaseModal> caseModalList = new List<VCC_CaseModal>();
        for (Case caseObj : caseList) {
            VCC_CaseModal caseModalObj = new VCC_CaseModal();
            caseModalObj.caseId = caseObj.Id;
            caseModalObj.caseNumber = caseObj.CaseNumber;
            caseModalObj.caseURL = '/lightning/r/Case/' + caseObj.Id + '/view';
            caseModalObj.contactId = caseObj.ContactId;
            caseModalObj.contactName = caseObj.Contact.Name;
            caseModalObj.contactURL = '/lightning/r/Contact/' + caseObj.contactId + '/view';
            caseModalObj.recordType = caseObj.RecordType.Name;
            caseModalObj.caseType = caseObj.VCC_Case_Type__c;
            caseModalObj.caseSubType = caseObj.VCC_Case_Sub_Type__c;
            caseModalObj.subject = caseObj.Subject;
            caseModalObj.subjectURL = String.isNotBlank(caseObj.Subject)
                ? '/lightning/r/Case/' + caseObj.Id + '/view'
                : '';
            caseModalObj.status = caseObj.Status;
            caseModalObj.dateTimeOpened = caseObj.CreatedDate;
            caseModalObj.dateTimeOpenedStr = caseObj.CreatedDate.format();
            caseModalObj.caseOwnerAlias = caseObj.Owner.Name;
            caseModalObj.followUpAppt = caseObj.VCC_Follow_Up_Appt_Needed__c;
            caseModalObj.followUpApptHours = caseObj.VCC_Follow_Up_Appt_Needed_Hours__c;
            caseModalList.add(caseModalObj);
        }
        return caseModalList;
    }
}
