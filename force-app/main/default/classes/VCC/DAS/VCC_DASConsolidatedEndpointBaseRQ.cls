/**
 * @description Base class for VCC_DASWriteNoteAndSignRQ and VCC_DASCreateAddendumAndSignRQ to hold common properties.
 * @author      BAH
 * @since       April 17 2024
 * @see         VCC_DASBaseRQ
 * @see         VCC_DASWriteNoteAndSignRQ
 * @see         VCC_DASCreateAddendumAndSignRQ
 */
@SuppressWarnings('PMD.DescriptionMustHaveText, PMD.ApexDoc')
public abstract with sharing class VCC_DASConsolidatedEndpointBaseRQ extends VCC_DASBaseRQ {
    public List<String> supplementalParameters;

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

    public String providerName {
        get {
            return propertyGetter(providerName);
        }
        set;
    }

    public String esig {
        get {
            return propertyGetter(esig);
        }
        set;
    }

    /**
     * @description Constructor
     */
    public VCC_DASConsolidatedEndpointBaseRQ() {
        this.supplementalParameters = new List<String>();
    }

    /**
     * @description Used to determine if the request is valid (properties are not null or blank) for callout
     * @return `Boolean` Returns true if addendum properties are not blank
     */
    public virtual override Boolean isValid() {
        if (
            !String.isBlank(this.providerUserId) &&
            !String.isBlank(this.providerLoginSiteCode) &&
            !String.isBlank(this.esig)
        ) {
            return true;
        }
        return false;
    }
}
