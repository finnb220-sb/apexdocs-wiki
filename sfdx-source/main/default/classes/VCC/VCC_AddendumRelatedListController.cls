public with sharing class VCC_AddendumRelatedListController {
    @AuraEnabled
    public static List<VCC_Addendum__c> getRelatedAddendums(Id incomingId) {
        List<VCC_Addendum__c> results = new List<VCC_Addendum__c>();
        results = [
            SELECT
                Id,
                Name,
                VCC_Electronic_Signature__c,
                VCC_Signed__c,
                VCC_Related_Note__c,
                VCC_Related_Note__r.Name,
                VCC_Related_Note__r.VCC_Case__r.Id,
                VCC_Related_Note__r.VCC_Case__r.CaseNumber,
                CreatedBy.Name,
                CreatedDate,
                VCC_Addendum__c
            FROM VCC_Addendum__c
            WHERE VCC_Related_Note__r.VCC_Case__r.Id = :incomingId
            WITH SECURITY_ENFORCED
        ];
        return results;
    }
}
