/**
 * @description VCC Consult Response Wrapper
 */
public inherited sharing class VCC_ConsultResponseWrp extends VCC_BaseResponseWrp {
    @AuraEnabled
    public VCC_ConsultModal consultModal { get; set; }
    @AuraEnabled
    public Boolean isMaxRecordsError { get; set; }
}
