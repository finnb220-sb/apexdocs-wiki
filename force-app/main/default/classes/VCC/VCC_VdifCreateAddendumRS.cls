/**
 * @description Vdif reate Addendum RS object
 *
 * @author Liberty
 * @since 01/08/2024
 */
public with sharing class VCC_VdifCreateAddendumRS extends VCC_BaseClient.BaseResponse {
    public VCC_VdifRSCommon.TextTO createAddendumTextTO;

    /**
     * @description default constructor
     */
    public VCC_VdifCreateAddendumRS() {
        this.createAddendumTextTo = new VCC_VdifRSCommon.TextTO();
    }

    /**
     * @description constructor with base response object as argument
     * @param baseResponse
     */
    public VCC_VdifCreateAddendumRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.createAddendumTextTO = ((VCC_VdifCreateAddendumRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"textTO"', '"createAddendumTextTO"'),
                    VCC_VdifCreateAddendumRS.class
                ))
                .createAddendumTextTO;
        }
    }
}
