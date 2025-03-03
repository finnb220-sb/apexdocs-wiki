public with sharing class VCC_DASIsValidEsigRQ extends VCC_DASBaseRQ {
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
    public String criteria {
        get {
            return propertyGetter(criteria);
        }
        set;
    }

    public VCC_DASIsValidEsigRQ() {
        return;
    }

    public override Boolean isValid() {
        if (
            !String.isBlank(this.providerLoginSiteCode) &&
            !String.isBlank(this.providerName) &&
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.criteria)
        ) {
            return true;
        }
        return false;
    }
}
