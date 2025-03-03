@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_DASSelectPatientRQ extends VCC_DASBaseRQ {
    public String providerLoginSiteCode {
        get {
            return propertyGetter(providerLoginSiteCode);
        }
        set;
    }
    public String providerName {
        get {
            return propertyGetter(providerName);
        }
        set;
    }
    public String providerUserId {
        get {
            return propertyGetter(providerUserId);
        }
        set;
    }
    public List<String> patientLocalPid;
    public String patientLocalSiteId {
        get {
            return propertyGetter(patientLocalSiteId);
        }
        set;
    }

    public VCC_DASSelectPatientRQ() {
        return;
    }

    public VCC_DASSelectPatientRQ(
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

    public VCC_DASSelectPatientRQ(
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
