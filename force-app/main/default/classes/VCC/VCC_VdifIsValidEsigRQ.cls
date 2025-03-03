/**
 * @description Vdif is Valid Esig RQ object definition
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class VCC_VdifIsValidEsigRQ extends VCC_VdifBaseRQ {
    public String providerLoginSiteCode;
    public String providerName;
    public String providerUserId;
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String criteria;
    public String authToken;

    /**
     * @description constructor mehod given vdifProvider object as argument
     *
     * @param vdifProvider
     */
    public VCC_VdifIsValidEsigRQ(VCC_VdifProvider vdifProvider) {
        this.providerLoginSiteCode = vdifProvider.siteCode;
        this.providerName = vdifProvider.name;
        this.providerUserId = vdifProvider.token;
        this.criteria = vdifProvider.esig;
    }

    /**
     * @description constructor mehod given vdifParameters object as argument
     *
     * @param vdifParameters
     */
    public VCC_VdifIsValidEsigRQ(VCC_VdifParameters vdifParameters) {
        this(vdifParameters.vdifProvider);
        this.recordId = vdifParameters.recordId;
    }

    /**
     * @description constructor mehod given arguments
     *
     * @param providerLoginSiteCode
     * @param providerName
     * @param providerUserId
     * @param criteria
     */
    public VCC_VdifIsValidEsigRQ(
        String providerLoginSiteCode,
        String providerName,
        String providerUserId,
        String criteria
    ) {
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerName = providerName;
        this.providerUserId = providerUserId;
        this.criteria = criteria;
    }

    /**
     * @description default constructor method
     */
    public VCC_VdifIsValidEsigRQ() {
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
        return;
    }

    /**
     * @description Checks for validity based on if fields are null/blank
     * @return  `Boolean`
     */
    public override Boolean isValid() {
        if (
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerName != null &&
            !String.isBlank(this.providerName) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId) &&
            this.criteria != null &&
            !String.isBlank(this.criteria)
        ) {
            return true;
        }

        return false;
    }
}
