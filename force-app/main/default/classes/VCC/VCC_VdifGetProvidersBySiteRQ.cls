/**
 * @description  Vdif Get Providers By Site RQ object definition
 * @author Booz Allen
 */
public with sharing class VCC_VdifGetProvidersBySiteRQ extends VCC_VdifBaseRQ {
    public String providerLoginSiteCode;
    public String providerName;
    public String providerUserId;
    public String direction;
    public String target;
    public String maxRecords;
    public String requestingApp;
    public String consumingAppPassword;
    public String consumingAppToken;
    public String authToken;

    /**
     * @description contructor method with arguments
     *
     * @param providerLoginSiteCode
     * @param providerName
     * @param providerUserId
     */
    public VCC_VdifGetProvidersBySiteRQ(String providerLoginSiteCode, String providerName, String providerUserId) {
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerName = providerName;
        this.providerUserId = providerUserId;
    }

    /**
     * @description contructor method with vdifParameters object as argument
     * @param vdifParameters
     */
    public VCC_VdifGetProvidersBySiteRQ(VCC_VdifParameters vdifParameters) {
        return;
        //System.debug(LoggingLevel.ERROR, 'Placeholder/reminder to put complete this.');
    }

    /**
     * @description default constructor method
     */
    public VCC_VdifGetProvidersBySiteRQ() {
        return;
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    /**
     * @description Check validity based on if fields are empty
     * @return  `Boolean`
     */
    public override Boolean isValid() {
        if (
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerName != null &&
            !String.isBlank(this.providerName) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId)
        ) {
            return true;
        }

        return false;
    }
}
