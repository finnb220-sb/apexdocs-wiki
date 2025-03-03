/**
 * @author Booz Allen Hamilton
 * @group API - Bridg - Flags
 */
public inherited sharing class VCC_FlagResponseWrp extends VCC_BaseResponseWrp {
    @AuraEnabled
    public VCC_FlagModal flagModal { get; set; }

    /**
     * @deprecated use VCC_AccountPopupController.getPopupFlags
     * @see `VCC_AccountPopupController`
     */
    @AuraEnabled
    public boolean isShowFlagPopup { get; set; }

    @AuraEnabled
    public String womenHealthResponseBody { get; set; }
}
