/**
 * @description Vdif Select Patient RQ object definition
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifSelectPatientRQ extends VCC_VdifBaseRQ {
    //public String consumingAppPassword;
    //public String consumingAppToken;
    //public String requestingApp;
    //public String direction;
    //public String target;
    //public String maxRecords;
    public String providerLoginSiteCode;
    public String providerName;
    public String providerUserId;
    //public String patientName;
    public List<String> patientLocalPid;
    public String patientLocalSiteId;
    //public String authToken;

    public VCC_VdifSelectPatientRQ(VCC_VdifParameters vdifParameters) {
        //System.debug(LoggingLevel.ERROR, 'Placeholder/reminder to put complete this.');
        return;
    }

    public VCC_VdifSelectPatientRQ(
        String providerLoginSiteCode,
        String providerName,
        String providerUserId,
        String patientLocalPid,
        String patientLocalSiteId
    ) {
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerName = providerName;
        this.providerUserId = providerUserId;
        this.patientLocalPid = new List<String>{ patientLocalPid };
        this.patientLocalSiteId = patientLocalSiteId;
    }
    public VCC_VdifSelectPatientRQ(
        String providerLoginSiteCode,
        String providerName,
        String providerUserId,
        List<String> patientLocalPid,
        String patientLocalSiteId
    ) {
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerName = providerName;
        this.providerUserId = providerUserId;
        this.patientLocalPid = patientLocalPid;
        this.patientLocalSiteId = patientLocalSiteId;
    }

    public VCC_VdifSelectPatientRQ() {
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
        return;
    }

    public override Boolean isValid() {
        if (
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerName != null &&
            !String.isBlank(this.providerName) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId) &&
            this.patientLocalPid != null &&
            !this.patientLocalPid.isEmpty() &&
            this.patientLocalSiteId != null &&
            !String.isBlank(this.patientLocalSiteId)
        ) {
            return true;
        }

        return false;
    }
}
