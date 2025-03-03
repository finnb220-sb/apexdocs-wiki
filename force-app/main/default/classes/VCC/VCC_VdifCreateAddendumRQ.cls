/**
 * @description Vdif Create Addendum RQ object
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifCreateAddendumRQ extends VCC_VdifBaseRQ {
    public String itemId;
    public String type;
    public String criteria;
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String providerName;
    public String providerLoginSiteCode;
    public String providerUserId;
    public String authToken;

    /**
     * @description constructor with vdif parameters as arguement
     * @param vdifParameters
     */
    public VCC_VdifCreateAddendumRQ(VCC_VdifParameters vdifParameters) {
        this.recordId = vdifParameters.recordId;
        this.itemId = vdifParameters.vdifNote.itemId;
        this.type = vdifParameters.vdifNote.noteTitleIen;
        this.criteria = vdifParameters.vdifNote.text;
        this.providerLoginSiteCode = vdifParameters.vdifProvider.siteCode;
        this.providerUserId = vdifParameters.vdifProvider.token;
    }

    /**
     * @description constructor with params as arguments
     *
     * @param itemId
     * @param type
     * @param criteria
     * @param providerLoginSiteCode
     * @param providerUserId
     */
    public VCC_VdifCreateAddendumRQ(
        String itemId,
        String type,
        String criteria,
        String providerLoginSiteCode,
        String providerUserId
    ) {
        this.itemId = itemId;
        this.type = type;
        this.criteria = criteria;
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerUserId = providerUserId;
    }

    /**
     * @description default constructor
     */
    public VCC_VdifCreateAddendumRQ() {
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
        return;
    }

    /**
     * @description check if valid based on if fields are empty/blank
     * @return  `Boolean`
     */
    public override Boolean isValid() {
        if (
            this.itemId != null &&
            !String.isBlank(this.itemId) &&
            this.type != null &&
            !String.isBlank(this.type) &&
            this.criteria != null &&
            !String.isBlank(this.criteria) &&
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId)
        ) {
            return true;
        }

        return false;
    }
}
