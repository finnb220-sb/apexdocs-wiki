/**
 * @description Contains the request object definitions
 * @author Liberty
 * @since 01/07/2024
 */
public with sharing class VCC_VaProfileAssociatedPersonsRQ {
    // example: John Smith
    // User making this request.
    public String userId;

    // example: 1011210371V162999
    // System identifier of the veteran.
    public String id;

    // example: ICN
    // Identifies the type of id.
    // Enum: [salesforceId, salesforceCorrelationId, ICN, fileNumber, externalSystemId, corpId, rawId]
    public String idType;

    public List<VCC_AssociatedPerson> vaProfileAssociatedPersons;

    /**
     * @description default constructor for this class/object
     */
    public VCC_VaProfileAssociatedPersonsRQ() {
        this.vaProfileAssociatedPersons = new List<VCC_AssociatedPerson>();
    }

    /**
     * @description Associated Person object definition
     */
    public class VCC_AssociatedPerson {
        // pattern: yyyy-mm-ddThh:mm:ss.fffZ
        // example: 2022-03-15T20:00:00.360Z
        // Updates only if this date is more recent than the existing associatedPerson record
        public Datetime updateDate;

        // pattern: yyyy-mm-ddThh:mm:ss.fffZ
        // example: 2022-03-07T11:00:00.360Z
        // Source Date
        public Datetime sourceDate;

        // example: Mr.
        public String prefix;

        // example: Sr.
        // Suffix
        public String suffix;

        // example: John
        // Given Name
        public String givenName;

        // example: Oscar
        // Middle Name
        public String middleName;

        // example: Smith
        // Family Name
        public String familyName;

        // example: address line 1
        // Address Line 1
        public String addressLine1;

        // example: address line 2
        // Address Line 2
        public String addressLine2;

        // example: address line 3
        // Address Line 3
        public String addressLine3;

        // example: city 123
        // City
        public String city;

        // example: state 123
        // State
        public String state;

        // example: county 123
        // County
        public String county;

        // example: 12345
        // Zip Code
        public String zipCode;

        // example: 123456789
        // Zip Plus 4
        public String zipPlus4;

        // example: 12345
        // Postal Code
        public String postalCode;

        // example: province 123
        // Province Code
        public String provinceCode;

        // example: USA
        // Country
        public String country;

        // pattern: 10 digits. No dashes.
        // example: 1112223333
        public String primaryPhone;

        // pattern: 10 digits. No dashes.
        // example: 2223334444
        public String alternatePhone;

        // Enum:
        // [ Primary Next of Kin, Other Next of Kin, Emergency Contact, Other emergency contact, Designee, Power of Attorney, Guardian VA, Guardian Civil ]
        public String contactType;

        // Enum:
        // [ BROTHER, SISTER, SON, STEPCHILD, UNRELATED FRIEND, WARD, WIFE, CHILD-IN-LAW, DAUGHTER, EXTENDED FAMILY MEMBER, FATHER, GRANDCHILD, HUSBAND, MOTHER, NIECE/NEPHEW ]
        public String relationship;
    }
}
