public class VCC_BridgDemographicsRS {
    // public class TeleCom {
    //     public String value;
    //     public String usageType;
    // }

    public @AuraEnabled
    string facility;

    // not part of official response
    public class Facility {
        @AuraEnabled
        public String facilityId;
        @AuraEnabled
        public String facilityName;
    }

    public class Address {
        @AuraEnabled
        public String streetLine1;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String stateProvince;
    }

    // public class Support {
    //     public List<TeleCom> telecomList;
    //     public Address address;
    //     public String name;
    //     public String relationship;
    //     public String contactType;
    // }

    // public class Eligibility {
    //     public String name;
    //     public String primary;
    // }

    // public class Facility {
    //     public String latestDate;
    //     public String code;
    //     public String domain;
    //     public String name;
    // }

    // public class LRDFN {
    //     public String value;
    // }

    // public class Gender {
    //     public String value;
    // }

    // public class ICN {
    //     public String value;
    // }

    // public class FamilyName {
    //     public String value;
    // }

    // public class GivenNames {
    //     public String value;
    // }

    public class FullName {
        @AuraEnabled
        public String value;
    }

    public class PatientAddress {
        @AuraEnabled
        public String streetLine1;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String stateProvince;
    }

    // public class TelecomList {
    //     public List<TeleCom> telecom;
    // }

    // public class Supports {
    //     public List<Support> support;
    // }

    // public class Eligibilities {
    //     public List<Eligibility> eligibility;
    // }

    // public class Facilities {
    //     public List<Facility> facility;
    // }

    public class Patient {
        // public String total;
        // public LRDFN lrdfn;
        // public Gender gender;
        // public ICN icn;
        // public FamilyName familyName;
        // public GivenNames givenNames;
        // public FullName fullName;
        @AuraEnabled
        public PatientAddress address;
        // public Boolean inpatient;
        // public TelecomList telecomList;
        // public Supports supports;
        // public Eligibilities eligibilities;
        // public Facilities facilities;
        // Add other properties as needed
    }

    public class Demographics {
        @AuraEnabled
        public String total;
        @AuraEnabled
        public List<Patient> patient;
    }

    public class Results {
        @AuraEnabled
        public Demographics demographics;
    }

    public class ErrorSection {
        @AuraEnabled
        public List<String> errors;
        @AuraEnabled
        public List<String> fatalErrors;
        @AuraEnabled
        public List<String> warnings;
    }

    public class Site {
        @AuraEnabled
        public Results results;
        @AuraEnabled
        public ErrorSection errorSection;
    }

    @AuraEnabled
    public List<Site> sites;

    public static VCC_BridgDemographicsRS parseJSON(String jsonString) {
        return (VCC_BridgDemographicsRS) JSON.deserialize(jsonString, VCC_BridgDemographicsRS.class);
    }
}
