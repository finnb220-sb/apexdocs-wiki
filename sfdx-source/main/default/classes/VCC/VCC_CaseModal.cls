public with sharing class VCC_CaseModal {
    @AuraEnabled
    public String caseId { get; set; }
    @AuraEnabled
    public String caseNumber { get; set; }
    @AuraEnabled
    public String caseURL { get; set; }
    @AuraEnabled
    public String contactId { get; set; }
    @AuraEnabled
    public String contactName { get; set; }
    @AuraEnabled
    public String contactURL { get; set; }
    @AuraEnabled
    public String recordType { get; set; }
    @AuraEnabled
    public String caseType { get; set; }
    @AuraEnabled
    public String caseSubType { get; set; }
    @AuraEnabled
    public String subject { get; set; }
    @AuraEnabled
    public String subjectURL { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public DateTime dateTimeOpened { get; set; }
    @AuraEnabled
    public String dateTimeOpenedStr { get; set; }
    @AuraEnabled
    public String caseOwnerAlias { get; set; }
    @AuraEnabled
    public String followUpAppt { get; set; }
    @AuraEnabled
    public Decimal followUpApptHours { get; set; }
}
