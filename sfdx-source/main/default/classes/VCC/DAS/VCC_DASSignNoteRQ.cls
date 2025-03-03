/**
 * @description The request structure for DAS signNote
 */
public with sharing class VCC_DASSignNoteRQ extends VCC_DASBaseRQ {
    public String esig {
        get {
            return propertyGetter(esig);
        }
        set;
    }
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
    public String noteIEN {
        get {
            return propertyGetter(noteIEN);
        }
        set;
    }

    public VCC_DASSignNoteRQ() {
        return;
    }

    /**
     * @description Determines if the request is valid for callout
     * @return `Boolean`
     */
    public override Boolean isValid() {
        if (
            !String.isBlank(esig) &&
            !String.isBlank(providerLoginSiteCode) &&
            !String.isBlank(providerName) &&
            !String.isBlank(providerUserId) &&
            !String.isBlank(noteIEN)
        ) {
            return true;
        }
        return false;
    }
}
