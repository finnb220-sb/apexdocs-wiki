/**
 * @description Parser class, primarily for use in Apex JSON.deserialize;
 * @author Patrick Skamarak
 * @since 7/29/2021
 * @group API - VDIF
 * @see VCC_VdifService
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class VCC_VDIFResponseParser {
    @AuraEnabled
    public TextTO textTO;
    @AuraEnabled
    public NoteResultTO noteResultTO;
    @AuraEnabled
    public PatientTO patientTO;
    @AuraEnabled
    public Boolean exceptionOccurred;
    @AuraEnabled
    public String exceptionMessage;
    @AuraEnabled
    public TaggedTextArray taggedTextArray;
    @AuraEnabled
    public TaggedProviderArray taggedProviderArray;

    //vdifSelectPatient
    public class PatientTO {
        public Fault fault;
        public String type;
        public String birthPlace;
        public String religion;
        public String name;
        public String ssn;
        public String gender;
        public String dob;
        public String ethnicity;
        public Long age;
        public String maritalStatus;
        public AddressTO homeAddress;
        public PhoneNumTO homePhone;
        public PhoneNumTO cellPhone;
        public DemographicSetTO demographics;
        public String occupation;
        public String employmentStatus;
        public String employerName;
        public PersonArray relationships;
        public String patientName;
        public String mpiPid;
        public String mpiChecksum;
        public String localPid;
        public TaggedTextArray sitePids;
        public String vendorPid;
        public String cwad;
        public Boolean restricted;
        public String admitTimestamp;
        public String scPercent;
        public Boolean inpatient;
        public String deceasedDate;
        public TaggedText confidentiality;
        public HospitalLocationTo location;
        public Boolean needsMeansTest;
        public TaggedTextArray patientFlags;
        public String cmorSiteId;
        public String activeInsurance;
        public Boolean isTestPatient;
        public String currentMeansStatus;
        public Boolean hasInsurance;
        public TaggedText preferredFacility;
        public String patientType;
        public Boolean isVeteran;
        public Boolean isLocallyAssignedMpiPid;
        public SiteArray sites;
        public Team team;
        public String eligibilityCode;
        public VisitRelatedTO visitrelatedTos;
    }

    public class VisitRelatedTO {
        public Boolean serviceConnected;
        public Boolean combatVeteran;
        public Boolean agentorangeExposure;
        public Boolean ionizingradiationExposure;
        public Boolean southwestasiaConditions;
        public Boolean shipboardhazardandDefence;
        public Boolean mst;
        public Boolean headandneckCancer;
        public Boolean persiangulfExposure;
    }

    public class AddressTO {
        public Fault fault;
        public String type;
        public String streetAddress1;
        public String streetAddress2;
        public String streetAddress3;
        public String city;
        public String county;
        public String state;
        public String zipcode;
        public String country;
        public String description;
    }

    public class PhoneNumTO {
        public Fault fault;
        public String type;
        public String areaCode;
        public String exchange;
        // public String number; the keyword 'number' is a reserved for apex
        public String phoneNum; //replacing the preceeding 'number'
        public String description;
    }

    public class DemographicSetTO {
        public String tag;
        public ArrayOfaddressTOAddressTO addresses;
        public ArrayOfphoneNumTOPhoneNumTO phones;
        public ArrayOfemailAddressesItemString emailAddresses;
        public ArrayOfdemographicNamesItemString demographicNames;
    }

    public class ArrayOfaddressTOAddressTO {
        public List<AddressTO> addressTO;
    }
    public class ArrayOfphoneNumTOPhoneNumTO {
        public List<PhoneNumTO> phoneNumTO;
    }
    public class ArrayOfemailAddressesItemString {
        List<String> emailAddressesItem;
    }
    public class ArrayOfdemographicNamesItemString {
        List<String> demographicNamesItem;
    }

    public class PersonArray {
        public List<PersonTO> personTO;
    }

    public class PersonTO {
        public Fault fault;
        public String type;
        public String birthPlace;
        public String religion;
        public String name;
        public String ssn;
        public String gender;
        public String dob;
        public String ethnicity;
        public Long age;
        public String maritalStatus;
        public AddressTO homeAddress;
        public PhoneNumTO homePhone;
        public PhoneNumTO cellPhone;
        public DemographicSetTO demographics;
    }
    public class HospitalLocationTo {
        public Fault fault;
        public String id;
        public String name;
        public TaggedText department;
        public TaggedText service;
        public TaggedText specialty;
        public TaggedText stopCode;
        public TaggedText creditStopCode;
        public SiteTO facility;
        public String building;
        public String floor;
        public String room;
        public String bed;
        public String status;
        public String phone;
        public String appointmentTimestamp;
        public String type;
        public String physicalLocation;
        public Boolean askForCheckIn;
        public String appointmentLength;
        public String clinicDisplayStartTime;
        public String displayIncrements;
        public TimeSlotArray availability;
        public String maxOverbooksPerDay;
        public String prohibitAccessToClinic;
    }
    public class SiteArray {
        public Fault fault;
        public Long count;
        public ArrayOfsiteTOSiteTO sites;
    }
    public class ArrayOfsiteTOSiteTO {
        public List<SiteTO> siteTO;
    }
    public class SiteTO {
        public Fault fault;
        public String sitecode;
        public String name;
        public String displayName;
        public String moniker;
        public String regionID;
        public String lastEventTimestamp;
        public String lastEventReason;
        public String uid;
        public String pid;
        public DataSourceArray dataSources;
        public String parentSiteId;
        public SiteArray childSites;
        public String address;
        public String city;
        public String state;
        public String systemName;
        public String siteType;
    }
    public class DataSourceArray {
        public Fault fault;
        public Long count;
        public DataSourceTO dataSourceTo;
    }
    public class DataSourceTO {
        public Fault fault;
        public String protocol;
        public String modality;
        public Integer timeout;
        public Integer port;
        public String provider;
        public String status;
        public String description;
        public String context;
        public Boolean testSource;
        public String vendor;
        public String version;
        public TaggedText siteId;
        public String welcomeMessage;
    }
    public class TimeSlotArray {
        public Fault fault;
        public Long count;
        public String tag;
        public ArrayOftimeSlotTOTimeSlotTO slots;
    }
    public class ArrayOftimeSlotTOTimeSlotTO {
        public List<TimeSlotTO> timeSlotTO;
    }
    public class TimeSlotTO {
        public Fault fault;
        public String start;
        //public String end; identifier is reserved
        public String endValue; // replacing 'end'
        public String text;
        public Boolean available;
    }
    public class Team {
        public String attendingName;
        public String team;
        public String name;
        public String pcpname;
    }

    //vdifSaveNoteAndEncouter
    public class TextTO {
        public String text;
        public Fault fault;
    }

    public class TaggedProviderArray {
        public Fault fault;
        public Long count;
        public String tag;
        public ArrayOfproviderTOProviderTO providers;
    }

    public class ArrayOfproviderTOProviderTO {
        public List<ProviderTO> providerTO;
    }

    public class ProviderTO {
        public Fault fault;
        public String duz;
        public String providername;
        public String providertitle;
        public String loginSiteCode;
    }

    public class TaggedTextArray {
        public Fault fault;
        public Long count;
        public String tag;
        public ArrayOftaggedTextTaggedText results;
        public Boolean textOnly;
    }

    public class ArrayOftaggedTextTaggedText {
        List<TaggedText> taggedText;
    }

    public class TaggedText {
        public Fault fault;
        public String tag;
        public String text;
    }

    //vdifWriteNote
    public class NoteResultTO {
        public Fault fault;
        public String id;
        public Integer totalPages;
        public Integer lastPageRecd;
        public String explanation;
    }

    public class Fault {
        public String innerMessage;
        public String innerStackTrace;
        public String innerType;
        public String message;
        public String stackTrace;
        public String suggestion;
        public String type;
    }
}
