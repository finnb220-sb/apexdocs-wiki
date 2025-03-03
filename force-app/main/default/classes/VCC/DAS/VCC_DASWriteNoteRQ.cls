@SuppressWarnings('PMD.ExcessiveParameterList')
public with sharing class VCC_DASWriteNoteRQ extends VCC_DASBaseRQ {
    public String encounterString {
        get {
            return propertyGetter(encounterString);
        }
        set;
    }
    public String text {
        get {
            return propertyGetter(text);
        }
        set;
    }
    public String providerUserId {
        get {
            return propertyGetter(providerUserId);
        }
        set;
    }
    public String patientLocalPid {
        get {
            return propertyGetter(patientLocalPid);
        }
        set;
    }
    public String patientName {
        get {
            return propertyGetter(patientName);
        }
        set;
    }
    public String patientLocalSiteId {
        get {
            return propertyGetter(patientLocalSiteId);
        }
        set;
    }
    public String titleIEN {
        get {
            return propertyGetter(titleIEN);
        }
        set;
    }
    public String authorDUZ {
        get {
            return propertyGetter(authorDUZ);
        }
        set;
    }

    public VCC_DASWriteNoteRQ() {
        return;
    }

    public override Boolean isValid() {
        if (
            !String.isBlank(this.encounterString) &&
            !String.isBlank(this.text) &&
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.patientLocalPid) &&
            !String.isBlank(this.patientName) &&
            !String.isBlank(this.patientLocalSiteId) &&
            !String.isBlank(this.titleIEN) &&
            !String.isBlank(this.authorDUZ)
        ) {
            return true;
        }

        return false;
    }
}
