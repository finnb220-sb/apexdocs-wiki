/**
 * @author Booz Allen Hamilton
 * @description The expected structure of the response from DAS getAdditionalSigners
 */
public with sharing class VCC_DASGetAdditionalSignersRS {
    /**
     * taggedTextArray.results.taggedText is a `List<VCC_DASRSCommon.TaggedText>` containing info on the signers added.
     * taggedText[i].text is the DUZ of the signer
     * taggedText[i].tag is the Site Code
     * See VCC_DASRSCommon for more information.
     */
    public VCC_DASRSCommon.TaggedTextArray taggedTextArray;

    public VCC_DASGetAdditionalSignersRS() {
        this.taggedTextArray = new VCC_DASRSCommon.TaggedTextArray();
    }
}
