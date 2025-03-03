public with sharing class VCC_DASGetAdditionalSignersRQ extends VCC_DASBaseRQ {
    public String providerUserId {
        get {
            return propertyGetter(providerUserId);
        }
        set;
    }
    public String providerLoginSiteCode {
        get {
            return propertyGetter(providerLoginSiteCode);
        }
        set;
    }
    public String itemId {
        get {
            return propertyGetter(itemId);
        }
        set;
    }
    public List<String> supplementalParameters;

    public VCC_DASGetAdditionalSignersRQ() {
        this.supplementalParameters = new List<String>();
    }

    public override Boolean isValid() {
        if (
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.providerLoginSiteCode) &&
            !String.isBlank(this.itemId) &&
            this.supplementalParameters != null
        ) {
            if (this.supplementalParameters.size() > 0) {
                return true;
            }
        }
        return false;
    }
}
