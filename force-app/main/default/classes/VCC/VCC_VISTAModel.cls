/**
 * @description Vista Model object
 *
 * @author
 * @since
 */
public with sharing class VCC_VISTAModel {
    @AuraEnabled
    public String facilityId;
    @AuraEnabled
    public VCC_BridgDemographicsRS.PatientAddress address;

    /**
     * @description constructor with bridge demographics and bridge request as arguments
     *
     * @param rs
     * @param rq
     */
    public VCC_VISTAModel(VCC_BridgDemographicsRS rs, VCC_BridgRequest rq) {
        this.address = rs?.sites[0]?.results?.demographics?.patient[0]?.address;
        this.facilityId = rq.assigningFacility.length() > 3 ? rq.assigningFacility.substring(0, 3) : rq.assigningFacility;
    }
}
