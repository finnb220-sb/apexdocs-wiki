/**
 * @description Vdif Save Note And Encounter RQ object definition
 * @author Booz Allen
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.TooManyFields, PMD.ExcessivePublicCount, PMD.CyclomaticComplexity')
public with sharing class VCC_VdifSaveNoteAndEncounterRQ extends VCC_VdifBaseRQ {
    public String recordSiteCode;
    public String itemId;
    public List<String> supplementalParameters;
    public String consumingAppPassword;
    public String consumingAppToken;
    public String requestingApp;
    public String providerName;
    public String providerLoginSiteCode;
    public String providerUserId;
    public String patientName;
    public String patientLocalPid;
    public String patientLocalSiteId;
    public String noteAndEncounterLocationIen;
    public String noteAndEncounterNoteTitleIen;
    public String noteAndEncounterConsultIen;
    public String noteAndEncounterServiceCategory;
    public String noteAndEncounterProviders;
    public String noteAndEncounterProcedures;
    public String noteAndEncounterDiagnoses;
    public String noteAndEncounterImmunizations;
    public String noteAndEncounterHealthFactors;
    public String noteAndEncounterVisitRelatedTos;
    public String noteAndEncounterEncounterComments;
    public String authToken;

    public VCC_VdifSaveNoteAndEncounterRQ(VCC_VdifParameters vdifParameters) {
        this();
        this.recordId = vdifParameters.recordId;
        this.providerLoginSiteCode = vdifParameters.vdifProvider.siteCode;
        this.providerUserId = vdifParameters.vdifProvider.token;
        this.patientLocalPid = vdifParameters.vdifPatient.pid;
        this.patientLocalSiteId = vdifParameters.vdifPatient.siteCode;
        this.noteAndEncounterLocationIen = vdifParameters.vdifEncounter.locationIen;
        this.noteAndEncounterNoteTitleIen = vdifParameters.vdifEncounter.noteTitleIen;
        this.noteAndEncounterServiceCategory = vdifParameters.vdifEncounter.serviceCategory;
        this.noteAndEncounterProcedures = vdifParameters.vdifEncounter.procedures;
        this.noteAndEncounterDiagnoses = vdifParameters.vdifEncounter.diagnoses;
    }

    public VCC_VdifSaveNoteAndEncounterRQ(
        String providerLoginSiteCode,
        String providerUserId,
        String patientLocalPid,
        String patientLocalSiteId,
        String noteAndEncounterLocationIen,
        String noteAndEncounterNoteTitleIen,
        String noteAndEncounterServiceCategory,
        String noteAndEncounterProcedures,
        String noteAndEncounterDiagnoses
    ) {
        this.supplementalParameters = new List<String>{ 'saveNoteAndEncounter' };
        this.providerLoginSiteCode = providerLoginSiteCode;
        this.providerUserId = providerUserId;
        this.patientLocalPid = patientLocalPid;
        this.patientLocalSiteId = patientLocalSiteId;
        this.noteAndEncounterLocationIen = noteAndEncounterLocationIen;
        this.noteAndEncounterNoteTitleIen = noteAndEncounterNoteTitleIen;
        this.noteAndEncounterServiceCategory = noteAndEncounterServiceCategory;
        this.noteAndEncounterProcedures = noteAndEncounterProcedures;
        this.noteAndEncounterDiagnoses = noteAndEncounterDiagnoses;
    }

    public VCC_VdifSaveNoteAndEncounterRQ() {
        this.supplementalParameters = new List<String>{ 'saveNoteAndEncounter' };
    }

    public override Boolean isValid() {
        if (
            this.providerLoginSiteCode != null &&
            !String.isBlank(this.providerLoginSiteCode) &&
            this.providerUserId != null &&
            !String.isBlank(this.providerUserId) &&
            this.patientLocalPid != null &&
            !String.isBlank(this.patientLocalPid) &&
            this.patientLocalSiteId != null &&
            !String.isBlank(this.patientLocalSiteId) &&
            this.noteAndEncounterLocationIen != null &&
            !String.isBlank(this.noteAndEncounterLocationIen) &&
            this.noteAndEncounterNoteTitleIen != null &&
            !String.isBlank(this.noteAndEncounterNoteTitleIen) &&
            this.noteAndEncounterServiceCategory != null &&
            !String.isBlank(this.noteAndEncounterServiceCategory) //&&
        ) {
            // this.noteAndEncounterProcedures != null && !String.isBlank(this.noteAndEncounterProcedures) &&
            // this.noteAndEncounterDiagnoses != null && !String.isBlank(this.noteAndEncounterDiagnoses)
            return true;
        }

        return false;
    }
}
