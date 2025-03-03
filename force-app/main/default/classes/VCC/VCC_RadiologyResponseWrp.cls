/**
 * @description VCC Radiology Response Wrapper
 */
public inherited sharing class VCC_RadiologyResponseWrp extends VCC_BaseResponseWrp {
    //@AuraEnabled public VCC_RadiologyModal radiologyModal{get;set;}
    /**
     * @description Used for Radiology Request
     */
    public VCC_RadiologyResponseWrp() {
        system.debug('ctor');
    }
    /**
     * @description sed for Radiology Request
     * @param responseBody
     */
    public VCC_RadiologyResponseWrp(String responseBody) {
        this.responseBody = responseBody;
    }
}
