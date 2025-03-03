global virtual class VCC_BaseWrp {
    @AuraEnabled
    global Boolean status { get; set; }
    @AuraEnabled
    global String errorMsg { get; set; }
}
