/**
 * @description Request class for createAddendum DAS request
 * @author     Booz Allen
 * @see        VCC_DASBaseRQ
 */
@SuppressWarnings('PMD.ExcessiveParameterList, PMD.CyclomaticComplexity')
public with sharing class VCC_DASCreateAddendumRQ extends VCC_DASBaseRQ {
    public String itemId {
        get {
            return propertyGetter(itemId);
        }
        set;
    }
    public String type {
        get {
            return propertyGetter(type);
        }
        set;
    }
    public String criteria {
        get {
            return propertyGetter(criteria);
        }
        set;
    }
    public String providerName {
        get {
            return propertyGetter(providerName);
        }
        set;
    }
    public String providerLoginSiteCode {
        get {
            return propertyGetter(providerLoginSiteCode);
        }
        set;
    }
    public String providerUserId {
        get {
            return propertyGetter(providerUserId);
        }
        set;
    }

    /**
     * @description constructor
     */
    public VCC_DASCreateAddendumRQ() {
        return;
    }

    public override Boolean isValid() {
        if (
            !String.isBlank(this.itemId) &&
            !String.isBlank(this.type) &&
            !String.isBlank(this.criteria) &&
            !String.isBlank(this.providerLoginSiteCode) &&
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.providerName)
        ) {
            return true;
        }

        return false;
    }
}
