/**
 * @description Handles the get additional signers response
 * @author Liberty
 * @since 01/07/2024
 */
public with sharing class VCC_VdifGetAdditionalSignersRS extends VCC_BaseClient.BaseResponse {
    /**
     * taggedTextArray.results.taggedText is a `List<VCC_VdifRSCommon.TaggedText>` containing info on the signers added.
     * taggedText[i].text is the DUZ of the signer
     * taggedText[i].tag is the Site Code
     * See VCC_VdifCommon for more information.
     */
    public VCC_VdifRSCommon.TaggedTextArray taggedTextArray;

    /**
     * @description contructor method
     */
    public VCC_VdifGetAdditionalSignersRS() {
        this.taggedTextArray = new VCC_VdifRSCommon.TaggedTextArray();
    }

    /**
     * @description constructor method with baseResponse argument passed in
     *
     * @param baseResponse
     */
    public VCC_VdifGetAdditionalSignersRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.taggedTextArray = ((VCC_VdifGetAdditionalSignersRS) JSON.deserialize(baseResponse.httpResponse.getBody(), VCC_VdifGetAdditionalSignersRS.class)).taggedTextArray;
        }
    }
}
