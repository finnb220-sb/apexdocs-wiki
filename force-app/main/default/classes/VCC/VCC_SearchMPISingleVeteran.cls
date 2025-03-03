public with sharing class VCC_SearchMPISingleVeteran {
    public String FirstName;
    public String Id;
    public String MiddleName;
    public String PersonBirthDate;
    public Address address;
    public String brlsFilenumber;
    public String cityOfBirth;
    public String StateOfBirth;
    public String dob;
    public String dod;
    public String edipi;
    public String gender;
    public String icn;
    public String itin;
    public String personType;
    public String ssn;
    public String suffixName;
    public String vet360Id;
    public String mothersMaidenName;
    public List<PhoneNumber> phoneNumber;

    public class PhoneNumber {
        public String use;
        public String value;
    }

    public class Address {
        public String addressTypeCode;
        public String city;
        public String country;
        public String postalCode;
        public String state;
        public String streetAddress;
        public String streetAddress2;
        public String streetAddress3;
    }

    public VCC_SearchMPISingleVeteran() {
        System.Debug('VCC_SearchMPISingleVeteran initialized');
    }
}
