/**
 * @description Vdif Write Note RQ object definition
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifWriteNoteRQ extends VCC_VdifBaseRQ {
    public String encounterString;
    public String text;
    public String providerName;
    public String providerLoginSiteCode;
    public String providerUserId;
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String patientLocalPid;
    public String patientName;
    public String patientLocalSiteId;
    public String authToken;
    public String titleIEN;
    public String authorDUZ;
    public String cosignerDUZ;
    public String consultIEN;
    public String prfIEN;

    public VCC_VdifWriteNoteRQ(VCC_VdifParameters vdifParameters) {
        this.recordId = vdifParameters.recordId;
        this.encounterString = vdifParameters.vdifNote.encounterString;
        this.text = vdifParameters.vdifNote.text;
        this.providerName = vdifParameters.vdifProvider.name;
        this.providerLoginSiteCode = vdifParameters.vdifProvider.siteCode;
        this.providerUserId = vdifParameters.vdifProvider.token;
        this.patientLocalPid = vdifParameters.vdifPatient.pid;
        this.titleIEN = vdifParameters.vdifNote.noteTitleIen;
    }

    public VCC_VdifWriteNoteRQ(
        String encounterString,
        String text,
        String providerName,
        String providerLoginSiteCode,
        String providerUserId,
        String patientLocalPid,
        String titleIEN
    ) {
        this.encounterString = encounterString;
        this.text = text;
        this.providerName = providerName;
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerUserId = providerUserId;
        this.patientLocalPid = patientLocalPid;
        this.titleIEN = titleIEN;
    }

    public VCC_VdifWriteNoteRQ() {
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
        return;
    }

    public override Boolean isValid() {
        if (
            this.encounterString != null &&
            !String.isBlank(this.encounterString) &&
            this.text != null &&
            !String.isBlank(this.text) &&
            this.providerName != null &&
            !String.isBlank(this.providerName) &&
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId) &&
            this.patientLocalPid != null &&
            !String.isBlank(this.patientLocalPid) &&
            this.titleIEN != null &&
            !String.isBlank(this.titleIEN)
        ) {
            return true;
        }

        return false;
    }
}
