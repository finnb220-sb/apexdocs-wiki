/**
 * @description VCC Discharge Summary Response Wrapper
 */
public inherited sharing class VCC_DischargeSummaryResponseWrp extends VCC_BaseResponseWrp {
    @AuraEnabled
    public VCC_DischargeSummaryModal dischargeSummaryModal { get; set; }
    @AuraEnabled
    public Boolean isMaxRecordsError { get; set; }
}
