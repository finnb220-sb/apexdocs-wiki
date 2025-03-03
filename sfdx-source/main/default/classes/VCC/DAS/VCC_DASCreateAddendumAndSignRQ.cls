/**
 * @description Request class for createAddendumAndSign DAS request
 * @author      BAH
 * @since       April 15 2024
 * @see         VCC_DASBaseRQ
 * @see         VCC_DASConsolidatedEndpointBaseRQ
 * @see         VCC_DASCreateAddendumAndSignRQTest
 */
@SuppressWarnings('PMD.DescriptionMustHaveText, PMD.ApexDoc')
public with sharing class VCC_DASCreateAddendumAndSignRQ extends VCC_DASConsolidatedEndpointBaseRQ {
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

    /**
     * @description Constructor
     */
    public VCC_DASCreateAddendumAndSignRQ() {
        return;
    }

    /**
     * @description Used to determine if the request is valid (properties are not null or blank) for callout
     * @return `Boolean` Returns true if addendum properties are not blank
     */
    public override Boolean isValid() {
        if (
            super.isValid() &&
            !String.isBlank(this.itemId) &&
            !String.isBlank(this.type) &&
            !String.isBlank(this.criteria)
        ) {
            return true;
        }
        return false;
    }
}
