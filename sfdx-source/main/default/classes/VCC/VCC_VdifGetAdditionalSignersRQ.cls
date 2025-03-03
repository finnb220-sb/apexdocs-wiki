/**
 * @description Vdif Get Additional Signers RQ object
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifGetAdditionalSignersRQ extends VCC_VdifBaseRQ {
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String providerName;
    public String providerUserId;
    public String providerLoginSiteCode;
    public String itemId;
    public List<String> supplementalParameters;
    public String authToken;

    /**
     * @description constructor method
     */
    public VCC_VdifGetAdditionalSignersRQ() {
        this.supplementalParameters = new List<String>();
    }

    /**
     * @description Constructor with vdifParameters object argument
     *
     * @param vdifParameters
     */
    public VCC_VdifGetAdditionalSignersRQ(VCC_VdifParameters vdifParameters) {
        this.recordId = vdifParameters.recordId;
        this.providerName = vdifParameters.vdifProvider.name;
        this.providerUserId = vdifParameters.vdifProvider.token;
        this.providerLoginSiteCode = vdifParameters.vdifProvider.siteCode;
        this.itemId = vdifParameters.vdifNote.itemId;
        this.supplementalParameters = vdifParameters.vdifNote.additionalSigners;
    }

    /**
     * @description Constructor with arguments
     *
     * @param providername
     * @param providerUserId
     * @param providerLoginSiteCode
     * @param itemId
     * @param supplementalParameters
     */
    public VCC_VdifGetAdditionalSignersRQ(
        String providername,
        String providerUserId,
        String providerLoginSiteCode,
        String itemId,
        List<String> supplementalParameters
    ) {
        this.providerName = providerName;
        this.providerUserId = providerUserId;
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.itemId = itemId;
        this.supplementalParameters = supplementalParameters;
    }

    /**
     * @description Ensures validity by checking for any blank fields
     *
     * @return  `Boolean`
     */
    public override Boolean isValid() {
        if (
            this.providerName != null &&
            !String.isBlank(this.providerName) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId) &&
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.itemId != null &&
            !String.isBlank(this.itemId) &&
            this.supplementalParameters != null
        ) {
            if (this.supplementalParameters.size() > 0) {
                return true;
            }
        }
        return false;
    }
}
