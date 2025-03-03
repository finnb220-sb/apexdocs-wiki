@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields')
public with sharing class VCC_VdifSelectPatientRS extends VCC_BaseClient.BaseResponse {
    public List<VCC_VdifSelectPatientRS> patientTOList = new List<VCC_VdifSelectPatientRS>();

    public PatientTO patientTO;

    public class PatientTO {
        public VCC_VdifRSCommon.FaultTO fault;
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
        public VCC_VdifRSCommon.TaggedTextArray sitePids;
        public String vendorPid;
        public HospitalLocationTO location;
        public String cwad;
        public Boolean restricted;
        public String admitTimestamp;
        public Boolean serviceConnected;
        public String scPercent;
        public Boolean inpatient;
        public String deceasedDate;
        public VCC_VdifRSCommon.TaggedText confidentiality;
        public Boolean needsMeansTest;
        public VCC_VdifRSCommon.TaggedTextArray patientFlags;
        public String cmorSiteId;
        public String activeInsurance;
        public Boolean isTestPatient;
        public String currentMeansStatus;
        public Boolean hasInsurance;
        public VCC_VdifRSCommon.TaggedText preferredFacility;
        public String patientType;
        public Boolean isVeteran;
        public Boolean isLocallyAssignedMpiPid;
        public SiteArray sites;
        public Team team;
        public String eligibilityCode;
        public VisitRelatedTO visitrelatedTos;

        public PatientTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.homeAddress = new AddressTO();
            this.homePhone = new PhoneNumTO();
            this.cellPhone = new PhoneNumTO();
            this.demographics = new DemographicSetTO();
            this.relationships = new PersonArray();
            this.sitePids = new VCC_VdifRSCommon.TaggedTextArray();
            this.location = new HospitalLocationTO();
            this.confidentiality = new VCC_VdifRSCommon.TaggedText();
            this.patientFlags = new VCC_VdifRSCommon.TaggedTextArray();
            this.preferredFacility = new VCC_VdifRSCommon.TaggedText();
            this.sites = new SiteArray();
            this.visitrelatedTos = new VisitRelatedTO();
        }
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
        public VCC_VdifRSCommon.FaultTO fault;
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

        public AddressTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
        }
    }

    public class PhoneNumTO {
        public VCC_VdifRSCommon.FaultTO fault;
        public String type;
        public String areaCode;
        public String exchange;
        public String number_s;
        public String description;

        public PhoneNumTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
        }
    }

    public class DemographicSetTO {
        public String tag;
        public ArrayOfAddressTO addresses;
        public ArrayOfPhoneNumTO phones;
        public ArrayOfEmailAddresses emailAddresses;
        public ArrayOfDemographicNames demographicNames;

        public DemographicSetTO() {
            this.addresses = new ArrayOfAddressTO();
            this.phones = new ArrayOfPhoneNumTO();
            this.emailAddresses = new ArrayOfEmailAddresses();
            this.demographicNames = new ArrayOfDemographicNames();
        }
    }

    public class PersonArray {
        public VCC_VdifRSCommon.FaultTO fault;
        public Long count;
        public ArrayOfPersonTO persons;

        public PersonArray() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.persons = new ArrayOfPersonTO();
        }
    }

    public class HospitalLocationTO {
        public VCC_VdifRSCommon.FaultTO fault;
        public String id;
        public String name;
        public VCC_VdifRSCommon.TaggedText department;
        public VCC_VdifRSCommon.TaggedText service;
        public VCC_VdifRSCommon.TaggedText specialty;
        public VCC_VdifRSCommon.TaggedText stopCode;
        public VCC_VdifRSCommon.TaggedText creditStopCode;
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
        public boolean askForCheckIn;
        public String appointmentLength;
        public String clinicDisplayStartTime;
        public String displayIncrements;
        public TimeSlotArray availability;
        public String maxOverbooksPerDay;
        public String prohibitAccessToClinic;

        public HospitalLocationTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.department = new VCC_VdifRSCommon.TaggedText();
            this.service = new VCC_VdifRSCommon.TaggedText();
            this.specialty = new VCC_VdifRSCommon.TaggedText();
            this.stopCode = new VCC_VdifRSCommon.TaggedText();
            this.creditStopCode = new VCC_VdifRSCommon.TaggedText();
            this.availability = new TimeSlotArray();
        }
    }

    public class Team {
        public String attendingName;
        public String team;
        public String name;
        public String pcpname;
    }

    public class SiteTO {
        public VCC_VdifRSCommon.FaultTO fault;
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

        public SiteTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.dataSources = new DataSourceArray();
            this.childSites = new SiteArray();
        }
    }

    public class TimeSlotArray {
        public VCC_VdifRSCommon.FaultTO fault;
        public Long count;
        public String tag;
        public ArrayOfTimeSlotTO slots;

        public TimeSlotArray() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.slots = new ArrayOfTimeSlotTO();
        }
    }

    public class ArrayOfTimeSlotTO {
        public List<TimeSlotTO> timeSlotTO;

        public ArrayOfTimeSlotTO() {
            this.timeSlotTO = new List<TimeSlotTO>();
        }
    }

    public class TimeSlotTO {
        public VCC_VdifRSCommon.FaultTO fault;
        public String start;
        public String end_s;
        public String text;
        public Boolean available;

        public TimeSlotTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
        }
    }

    public class DataSourceArray {
        public VCC_VdifRSCommon.FaultTO fault;
        public Long count;
        public DataSourceTO dataSourceTO;

        public DataSourceArray() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.dataSourceTO = new DataSourceTO();
        }
    }

    public class DataSourceTO {
        public VCC_VdifRSCommon.FaultTO fault;
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
        public VCC_VdifRSCommon.TaggedText siteId;
        public String welcomeMessage;

        public DataSourceTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.siteId = new VCC_VdifRSCommon.TaggedText();
        }
    }

    public class SiteArray {
        public VCC_VdifRSCommon.FaultTO fault;
        public Long count;
        public ArrayOfSiteTO sites;

        public SiteArray() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.sites = new ArrayOfSiteTO();
        }
    }

    public class ArrayOfSiteTO {
        public List<SiteTO> siteTO;

        public ArrayOfSiteTO() {
            this.siteTO = new List<SiteTO>();
        }
    }

    public class ArrayOfPersonTO {
        public List<PersonTO> personTO;

        public ArrayOfPersonTO() {
            this.personTO = new List<PersonTO>();
        }
    }

    public class PersonTO {
        public VCC_VdifRSCommon.FaultTO fault;
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

        public PersonTO() {
            this.fault = new VCC_VdifRSCommon.FaultTO();
            this.homeAddress = new AddressTO();
            this.homePhone = new PhoneNumTO();
            this.cellPhone = new PhoneNumTO();
            this.demographics = new DemographicSetTO();
        }
    }

    public class ArrayOfAddressTO {
        public List<AddressTO> addressTO;

        public ArrayOfAddressTO() {
            this.addressTO = new List<AddressTO>();
        }
    }

    public class ArrayOfPhoneNumTO {
        public List<PhoneNumTO> phoneNumTO;

        public ArrayOfPhoneNumTO() {
            this.phoneNumTO = new List<PhoneNumTO>();
        }
    }

    public class ArrayOfEmailAddresses {
        public List<String> emailAddressesItem;

        public ArrayOfEmailAddresses() {
            this.emailAddressesItem = new List<String>();
        }
    }

    public class ArrayOfDemographicNames {
        public List<String> demographicNamesItem;

        public ArrayOfDemographicNames() {
            this.demographicNamesItem = new List<String>();
        }
    }

    public VCC_VdifSelectPatientRS() {
        this.patientTO = new PatientTO();
    }

    public VCC_VdifSelectPatientRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        if (baseResponse?.httpResponse != null) {
            this.patientTOList = ((List<VCC_VdifSelectPatientRS>) JSON.deserialize(
                baseResponse.httpResponse.getBody().replace('"number"', '"number_s"').replace('"end"', '"end_s"'),
                List<VCC_VdifSelectPatientRS>.class
            ));
        }
    }
}
