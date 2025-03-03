public with sharing class VCC_MpiRetrieveRS {
    public VCC_MpiRetrieveRS() {
        this.vets = new List<MpiResponse>();
    }

    public String identityMatchThreshold;
    public String potentialDuplicateThreshold;
    public List<MpiResponse> vets;

    public class MpiResponse {
        public String icn;
        public String salesforceId;
        public String corpId;
        public String edipi;
        public String brlsFilenumber;
        public String mviIipt;
        public String mviToken;
        public String personType;
        public String vet360Id;
        public String prefixName;
        public String suffixName;
        public String firstName;
        public String lastName;
        public String middleName;
        public String mothersMaidenName;
        public String cityOfBirth;
        public String stateOfBirth;
        public String dob;
        public String dod;
        public String ssn;
        public String gender;
        public String queryMatchObservation;
        public Address address;
        public List<PhoneNumber> phoneNumber;
        public List<MedicalCenterFacility> medicalCenterFacilities;
        public List<CorrelatedId> correlatedIds;
        public List<MpiRelationship> relationships;

        public MpiResponse() {
            this.address = new Address();
            this.phoneNumber = new List<PhoneNumber>();
            this.medicalCenterFacilities = new List<MedicalCenterFacility>();
            this.correlatedIds = new List<CorrelatedId>();
            this.relationships = new List<MpiRelationship>();
        }
    }

    public class Address {
        public String streetAddress;
        public String streetAddress2;
        public String streetAddress3;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String addressTypeCode;
        public String addressChangeDateTime;
    }

    public class PhoneNumber {
        public String value;
        public String use;
    }

    public class MedicalCenterFacility {
        public String facilityId;
        public String personId;
    }

    public class CorrelatedId {
        public String shortId;
        public String longId;

        /**
         * idType:
         * [
         *      BOSS_ID, ICN_ID, VA_IAM_PROVISIONING_SECURITY_ID_SEC_ID,
         *      DOD_EDIPI_ID, CORP_ID, BIRLS_ID, MHV_USER_ID, VHIC_CARD_ID,
         *      PIV_ID, VA_AD, NWHIN_ID, CP_AND_E_ID, CERNER_ID,
         *      CMS_NATIONAL_PROVIDER_INDEX_NPI_ID, ID_ME, USACCESS_PIV,
         *      USA_STAFFING, VA_SALESFORCE, VHA_CORRELATED_SYSTEMS_ID, OTHER
         * ]
         */
        public String idType;

        // idStatus: [ ACTIVE, DEPRECATED, PENDING, OTHER ]
        public String idStatus;
    }

    public class MpiRelationship {
        /**
         * This list will be empty when performing a Search.
         * It will be populated when performing a Retrieve, if there are any relationships
         */

        public String icn;
        public String direction;
        /**
         * A value of 'QUAL' means that the icn you searched is the Veteran in the relationship.
         * A value of 'PRS' means that the icn you searched is the Caregiver in the relationship.
         **/

        public String name;
        public String displayName;
        public String relationshipType;
        public String statusCode;
        public String effectiveTime;
    }
}
