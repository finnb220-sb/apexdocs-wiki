public with sharing class VCC_DASSaveNoteAndEncounterRQ extends VCC_DASBaseRQ {
    public List<String> supplementalParameters;
    public String providerUserId {
        get {
            return propertyGetter(providerUserId);
        }
        set;
    }
    public String patientName {
        get {
            return propertyGetter(patientName);
        }
        set;
    }
    public String patientLocalPid {
        get {
            return propertyGetter(patientLocalPid);
        }
        set;
    }
    public String patientLocalSiteId {
        get {
            return propertyGetter(patientLocalSiteId);
        }
        set;
    }
    public String noteAndEncounterLocationIen {
        get {
            return propertyGetter(noteAndEncounterLocationIen);
        }
        set;
    }
    public String noteAndEncounterNoteTitleIen {
        get {
            return propertyGetter(noteAndEncounterNoteTitleIen);
        }
        set;
    }
    public String noteAndEncounterServiceCategory {
        get {
            return propertyGetter(noteAndEncounterServiceCategory);
        }
        set;
    }
    public String noteAndEncounterProcedures {
        get {
            return propertyGetter(noteAndEncounterProcedures);
        }
        set;
    }
    public String noteAndEncounterDiagnoses {
        get {
            return propertyGetter(noteAndEncounterDiagnoses);
        }
        set;
    }
    public String noteAndEncounterVisitRelatedTos {
        get {
            return propertyGetter(noteAndEncounterVisitRelatedTos);
        }
        set;
    }

    public VCC_DASSaveNoteAndEncounterRQ() {
        this.supplementalParameters = new List<String>{};
    }

    public override Boolean isValid() {
        if (
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.patientName) &&
            !String.isBlank(this.patientLocalPid) &&
            !String.isBlank(this.patientLocalSiteId) &&
            !String.isBlank(this.noteAndEncounterLocationIen) &&
            !String.isBlank(this.noteAndEncounterNoteTitleIen) &&
            !String.isBlank(this.noteAndEncounterServiceCategory)
        ) {
            return true;
        }
        return false;
    }
}
