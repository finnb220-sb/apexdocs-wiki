/**
 * @description VDif is Valid Esig RS Object definition
 *
 * @author Liberty
 * @since 01/07/2024
 */
public with sharing class VCC_VdifIsValidEsigRS extends VCC_BaseClient.BaseResponse {
    /**
     * textTO.text is expected to be "True" or "False" (not Boolean, but String) for the IsValidEsig Callout
     * textTO.fault contains fault information, should there be any.
     */
    public VCC_VdifRSCommon.TextTO isValidEsigTextTO;

    /**
     * @description default constructor method
     */
    public VCC_VdifIsValidEsigRS() {
        this.isValidEsigTextTO = new VCC_VdifRSCommon.TextTO();
    }

    /**
     * @description constructor method with baseResponse object as argument
     * @param baseResponse
     */
    public VCC_VdifIsValidEsigRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.isValidEsigTextTO = ((VCC_VdifIsValidEsigRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"textTO"', '"isValidEsigTextTO"'),
                    VCC_VdifIsValidEsigRS.class
                ))
                .isValidEsigTextTO;
        }
    }
}
