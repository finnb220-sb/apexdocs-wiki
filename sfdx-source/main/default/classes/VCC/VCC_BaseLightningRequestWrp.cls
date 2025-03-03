global virtual inherited sharing class VCC_BaseLightningRequestWrp {
    @AuraEnabled
    public String recordId { get; set; }
    @AuraEnabled
    public String facility { get; set; }
    @AuraEnabled
    public String startDate { get; set; }
    @AuraEnabled
    public String endDate { get; set; }
}
