public with sharing class VCC_CaseDomain {
    private static final String CASE_TYPE_PHARMACY = 'Pharmacy';
    private static final String CASE_SUB_TYPE_PHARMACY = 'Pharmacy';
    private static final String CASE_REASON_MED_REFILL = 'Medication Refill';
    private static final String NEW_LINE = '\n';
    private static final String EMPTY_STRING = '';
    private static final String HYPHEN = ' - ';

    public VCC_CaseDomain() {
        // System.debug(LoggingLevel.INFO, 'Default VCC_CaseDomain constructor.');
    }

    public Case createMedicationRefillCase(Account account, Integer numberOfRefills, Boolean allSuccessful) {
        Boolean hasMSACustomPermission = FeatureManagement.checkPermission('VCC_MSA');
        String caseOutcome;

        Case cse = new Case();
        cse.Origin = 'Inbound Call';
        cse.Subject = 'Refill Medication';
        cse.Priority = 'Low';
        caseOutcome = 'Processed Medication Refill';

        if (hasMSACustomPermission) {
            cse.RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Administrative').Id;
            cse.Type = 'Administrative';
            cse.VCC_Case_Type__c = 'Administrative';
            cse.VCC_Case_Sub_Type__c = 'Administrative and Scheduling';
            cse.VCC_Case_Reason_Multi__c = 'Medication Refill/Renewal';
            caseOutcome = 'Refilled Medication';
        } else {
            cse.RecordTypeId = new VCR_CaseRepo().recordTypeConstant.fromDeveloperName('VCC_Pharmacy').Id;
            cse.Type = CASE_TYPE_PHARMACY;
            cse.VCC_Case_Sub_Type__c = CASE_SUB_TYPE_PHARMACY;
            cse.VCC_Case_Reason_Multi__c = CASE_REASON_MED_REFILL;
        }

        if (allSuccessful) {
            cse.Status = 'Closed - Resolved';
            cse.VCC_Case_Outcome_Multi__c = caseOutcome;
        } else {
            cse.Status = 'Open';
        }

        if (numberOfRefills < 11) {
            cse.VCC_No_of_Refills__c = String.valueOf(numberOfRefills);
        } else {
            cse.VCC_No_of_Refills__c = '>10';
        }

        cse.AccountId = account.Id;
        cse.ContactId = account.PersonContactId;
        return cse;
    }

    public void setMedicationRefillDescription(
        Case cse,
        List<VCC_DivaClient.ResponseJSON> medRefillResults,
        List<VCC_MedsService.MedRefillRequest> medRefillRequests
    ) {
        //? sync up the medRefillResults & medRefillRequests
        List<RefillDescriptionLayout> medicationsWithMessages = new List<RefillDescriptionLayout>();
        for (VCC_DivaClient.ResponseJSON medRefillResult : medRefillResults) {
            for (VCC_MedsService.MedRefillRequest medRefillRequest : medRefillRequests) {
                if (medRefillResult.prescriptionId == medRefillRequest.prescriptionId) {
                    RefillDescriptionLayout rdl = new RefillDescriptionLayout();
                    rdl.prescriptionId = medRefillRequest.prescriptionId;
                    rdl.prescriptionName = medRefillRequest.prescriptionName;
                    rdl.success = medRefillResult.success;
                    rdl.successValue = medRefillResult.success ? 'Success' : 'Fail';
                    rdl.message = medRefillResult.message;
                    medicationsWithMessages.add(rdl);
                }
            }
        }

        //? build out the description from the medRefillResults & medRefillRequests
        List<String> medicationStrings = new List<String>();
        for (RefillDescriptionLayout med : medicationsWithMessages) {
            medicationStrings.add(
                med.prescriptionId +
                    HYPHEN +
                    med.prescriptionName +
                    HYPHEN +
                    med.successValue +
                    (med.success ? EMPTY_STRING : (HYPHEN + med.message) + NEW_LINE)
            );
        }

        if (cse.Description != null) {
            cse.Description += '\n' + String.join(medicationStrings, ' ').removeEnd('\n');
        } else {
            cse.Description = String.join(medicationStrings, ' ').removeEnd('\n');
        }
    }

    @TestVisible
    private class RefillDescriptionLayout {
        public String prescriptionId { get; set; }
        public String prescriptionName { get; set; }
        public Boolean success { get; set; }
        public String successValue { get; set; }
        public String message { get; set; }

        public RefillDescriptionLayout() {
            this.success = true;
        }
    }
}
