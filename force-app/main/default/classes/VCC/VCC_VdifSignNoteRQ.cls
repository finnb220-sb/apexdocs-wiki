/**
 * @description Vdif Sign Note RQ object definition
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifSignNoteRQ extends VCC_VdifBaseRQ {
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String esig;
    public String providerLoginSiteCode;
    public String providerName;
    public String providerUserId;
    public String authToken;
    public String noteIEN;
    public String userDUZ;

    public VCC_VdifSignNoteRQ(VCC_VdifProvider vdifProvider, VCC_VdifNote vdifNote) {
        this.esig = vdifProvider.esig;
        this.providerLoginSiteCode = vdifProvider.siteCode;
        this.providerName = vdifProvider.name;
        this.providerUserId = vdifProvider.token;
        this.noteIEN = vdifNote.itemId;
        this.userDUZ = vdifProvider.duz;
    }

    public VCC_VdifSignNoteRQ(VCC_VdifParameters vdifParameters) {
        this(vdifParameters.vdifProvider, vdifParameters.vdifNote);
        this.recordId = vdifParameters.recordId;
    }

    public VCC_VdifSignNoteRQ(
        String esig,
        String providerLoginSiteCode,
        String providerName,
        String providerUserId,
        String noteIEN,
        String userDUZ
    ) {
        this.esig = esig;
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerName = providerName;
        this.providerUserId = providerUserId;
        this.noteIEN = noteIEN;
        this.userDUZ = userDUZ;
    }

    public VCC_VdifSignNoteRQ() {
        return;
        //System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public override Boolean isValid() {
        if (
            this.esig != null &&
            !String.isBlank(esig) &&
            this.providerLoginSiteCode != null &&
            !String.isBlank(providerLoginSiteCode) &&
            this.providerName != null &&
            !String.isBlank(providerName) &&
            this.providerUserId != null &&
            !String.isBlank(providerUserId) &&
            this.noteIEN != null &&
            !String.isBlank(noteIEN) &&
            this.userDUZ != null &&
            !String.isBlank(userDUZ)
        ) {
            return true;
        }

        return false;
    }
}
