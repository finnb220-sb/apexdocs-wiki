/**
 * @author Kumar Balan
 * @group API - Bridg - Allergy
 * @description Wrapper class for Allergy Response.
 */
public inherited sharing class VCC_AllergyResponseWrp extends VCC_BaseResponseWrp {
    /**
     * @description VCC_AllergyModel
     */
    @AuraEnabled
    public VCC_AllergyModal allergyModal { get; set; }
}
