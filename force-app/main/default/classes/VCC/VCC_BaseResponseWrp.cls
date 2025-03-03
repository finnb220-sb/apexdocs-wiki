global virtual inherited sharing class VCC_BaseResponseWrp {
    @AuraEnabled
    public Integer statusCode { get; set; }
    @AuraEnabled
    public String errorMsg { get; set; }
    @AuraEnabled
    public Boolean status { get; set; }
    @AuraEnabled
    public String responseBody { get; set; }
    @AuraEnabled
    public Boolean isMaxRecordsError { get; set; }

    public VCC_BaseResponseWrp() {
        this.statusCode = 0;
        this.status = false;
        this.isMaxRecordsError = false;
    }
}
