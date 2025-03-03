/**
 * @author Kumar Balan
 * @group API - Bridg - inpatient
 * @description VCC inpatient Wrp.
 */

public class VCC_InpatientResWrp {
    @AuraEnabled
    public String resBody { get; set; }
    @AuraEnabled
    public Boolean isShowInPatientPopup { get; set; }
}
