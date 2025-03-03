public with sharing class VCC_MPISearchResponse {
    public String identityMatchThreshold;
    public String potentialDuplicateThreshold;
    public String mpiRequestType;
    public List<Vets> vets;

    public String timestamp;
    public String errorType;
    public String message;

    public class Vets {
        public String Id;
        public String icn {
            get {
                return this.icn;
            }
            set {
                this.icn = value;
                this.Id = generateId();
            }
        }
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
        public String FirstName;
        public String LastName;
        public String MiddleName;
        public String PersonBirthdate;
        public String PersonDeathdate;
        public String mothersMaidenName;
        public String cityOfBirth;
        public String stateOfBirth;
        public String dob {
            get {
                return this.dob;
            }
            set {
                this.dob = value;
                this.PersonBirthdate = formatPersonBirthDate(value);
            }
        }
        public String dod {
            get {
                return this.dod;
            }
            set {
                this.dod = value;
                this.PersonDeathdate = formatPersonBirthDate(value);
            }
        }
        public String ssn;
        public String itin;
        public String gender;
        public String queryMatchObservation;
        public Address address;
        public List<PhoneNumber> phoneNumber;
        public List<MedicalCenterFacilities> medicalCenterFacilities;
        public List<CorrelatedIds> correlatedIds;
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
    }

    public class PhoneNumber {
        public String value;
        public String use;
    }

    public class MedicalCenterFacilities {
        public String facilityId;
        public String personId;
    }

    public class CorrelatedIds {
        public String shortId;
        public String longId;
        public String idType;
        public String idStatus;
    }

    public static String generateId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
    }

    public static String formatPersonBirthDate(String dob) {
        if (dob != null && dob != '' && dob.length() == 8) {
            return dob.substring(0, 4) + '-' + dob.substring(4, 6) + '-' + dob.substring(6, 8);
        }
        return null;
    }

    public VCC_MPISearchResponse() {
        System.debug(LoggingLevel.INFO, 'VCC_MPIParser initialized.');
    }
}
