/**
 * @description Wrapper class that parses JSON data returned from MPI callout.
 * @author Booz Allen
 * @since 6/30/2021
 * @group API - MPI
 *
 * @justification This is a DTO class used to serialize API json into typed Apex
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.TooManyFields, PMD.ExcessiveClassLength, PMD.FieldNamingConventions')
public with sharing class VCC_MPIParser {
    // main vets property wrapper
    @AuraEnabled
    public List<VetDetails> vets;
    @AuraEnabled
    public List<VetDetails> vetsV1;
    @AuraEnabled
    public List<VetDetails> vetsV3;

    /**
     * @description no arg constructor
     */
    public VCC_MPIParser() {
        this.vets = new List<VetDetails>();
        this.vetsV1 = new List<VetDetails>();
        this.vetsV3 = new List<VetDetails>();
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class MVI {
        @AuraEnabled
        public Address address;
        @AuraEnabled
        public String brlsFilenumber;
        @AuraEnabled
        public String cityOfBirth;
        @AuraEnabled
        public String corpId;
        @AuraEnabled
        public List<CorrelatedID> correlatedIds;
        @AuraEnabled
        public String dob;
        @AuraEnabled
        public String dod;
        @AuraEnabled
        public String edipi;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String icn;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public List<MedicalCenterFacility> medicalCenterFacilities;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String mothersMaidenName;
        @AuraEnabled
        public String mviIipt;
        @AuraEnabled
        public String mviToken;
        @AuraEnabled
        public String personType;
        @AuraEnabled
        public List<PhoneNumber> phoneNumber;
        @AuraEnabled
        public String prefixName;
        @AuraEnabled
        public String queryMatchObservation;
        @AuraEnabled
        public List<Relationship> relationships;
        @AuraEnabled
        public String salesforceId;
        @AuraEnabled
        public String ssn;
        @AuraEnabled
        public String stateOfBirth;
        @AuraEnabled
        public String suffixName;
        @AuraEnabled
        public String vet360Id;

        /**
         * @description no arg constructor
         */
        public MVI() {
            this.address = new Address();
            this.correlatedIds = new List<CorrelatedID>();
            this.medicalCenterFacilities = new List<MedicalCenterFacility>();
            this.phoneNumber = new List<PhoneNumber>();
            this.relationships = new List<Relationship>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class CorrelatedID {
        @AuraEnabled
        public String idStatus;
        @AuraEnabled
        public String idType;
        @AuraEnabled
        public String longId;
        @AuraEnabled
        public String shortId;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class Address {
        @AuraEnabled
        public String addressTypeCode;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String streetAddress;
        @AuraEnabled
        public String streetAddress2;
        @AuraEnabled
        public String streetAddress3;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class MedicalCenterFacility {
        @AuraEnabled
        public String facilityId;
        @AuraEnabled
        public String personId;
        @AuraEnabled
        public String facilityName;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class PhoneNumber {
        @AuraEnabled
        public String use;
        @AuraEnabled
        public String value;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class Relationship {
        @AuraEnabled
        public String icn;
        @AuraEnabled
        public String direction;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String displayName;
        @AuraEnabled
        public String relationshipType;
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String effectiveTime;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfile {
        @AuraEnabled
        public List<VAProfileAddress> addresses;
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public List<VAProfileEmail> emails;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public List<VAProfileTelephone> telephones;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public Integer vet360Id;

        /**
         * @description no arg constructor
         */
        public VAProfile() {
            this.addresses = new List<VAProfileAddress>();
            this.emails = new List<VAProfileEmail>();
            this.telephones = new List<VAProfileTelephone>();
            this.vet360Id = 0;
        }
    }

    /**
     * @description codescan fix
     */
    public class VaProfileV1 {
        @AuraEnabled
        public VAProfileContact vaProfileContactInfo;
        @AuraEnabled
        public VAProfilePersonAttributes vaProfilePersonAttributes;
        @AuraEnabled
        public VAProfileIdentity vaProfileIdentity;
        @AuraEnabled
        public List<VaProfileAssociatedPersonRead> vaProfileAssociatedPersons;

        /**
         * @description codescan fix
         */
        public VaProfileV1() {
            this.vaProfileContactInfo = new VAProfileContact();
            this.vaProfilePersonAttributes = new VAProfilePersonAttributes();
            this.vaProfileIdentity = new VAProfileIdentity();
            this.vaProfileAssociatedPersons = new List<VaProfileAssociatedPersonRead>();
        }
    }

    /**
     * @description codescan fix
     */
    public class VaProfileV2 {
        @AuraEnabled
        public VAProfileContact vaProfileContactInfo;
        @AuraEnabled
        public VAProfilePersonAttributes vaProfilePersonAttributes;
        @AuraEnabled
        public VAProfileIdentity vaProfileIdentity;
        @AuraEnabled
        public List<VaProfileAssociatedPersonRead> vaProfileAssociatedPersons;

        /**
         * @description codescan fix
         */
        public VaProfileV2() {
            this.vaProfileContactInfo = new VAProfileContact();
            this.vaProfilePersonAttributes = new VAProfilePersonAttributes();
            this.vaProfileIdentity = new VAProfileIdentity();
            this.vaProfileAssociatedPersons = new List<VaProfileAssociatedPersonRead>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VaProfileAssociatedPersonRead {
        @AuraEnabled
        public string updateDate;
        @AuraEnabled
        public string sourceDate;
        @AuraEnabled
        public string prefix;
        @AuraEnabled
        public string suffix;
        @AuraEnabled
        public string givenName;
        @AuraEnabled
        public string middleName;
        @AuraEnabled
        public string familyName;
        @AuraEnabled
        public string addressLine1;
        @AuraEnabled
        public string addressLine2;
        @AuraEnabled
        public string addressLine3;
        @AuraEnabled
        public string city;
        @AuraEnabled
        public string state;
        @AuraEnabled
        public string county;
        @AuraEnabled
        public string zipCode;
        @AuraEnabled
        public string zipPlus4;
        @AuraEnabled
        public string postalCode;
        @AuraEnabled
        public string provinceCode;
        @AuraEnabled
        public string country;
        @AuraEnabled
        public string primaryPhone;
        @AuraEnabled
        public string alternatePhone;
        @AuraEnabled
        public string contactType;
        @AuraEnabled
        public string relationship;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfileIdentity {
        @AuraEnabled
        public VaProfileSensitivityInformation sensitivityInformation;

        /**
         * @description no arg constructor
         */
        public VAProfileIdentity() {
            this.sensitivityInformation = new VaProfileSensitivityInformation();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VaProfileSensitivityInformation {
        @AuraEnabled
        public Boolean sensitivityFlag;

        /**
         * @description no arg constructor
         */
        public VaProfileSensitivityInformation() {
            this.sensitivityFlag = false;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfilePersonAttributes {
        @AuraEnabled
        public VaProfileFiduciaryInformation fiduciaryInformation;
        @AuraEnabled
        public VaProfileFinancialFraudInformation financialFraudInformation;
        @AuraEnabled
        public VaProfileActivePrescriptionBio activePrescriptionBio;

        /**
         * @description no arg constructor
         */
        public VAProfilePersonAttributes() {
            this.fiduciaryInformation = new VaProfileFiduciaryInformation();
            this.financialFraudInformation = new VaProfileFinancialFraudInformation();
            this.activePrescriptionBio = new VaProfileActivePrescriptionBio();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VaProfileActivePrescriptionBio {
        @AuraEnabled
        public Boolean activePrescriptionIndicator;

        /**
         * @description no arg constructor
         */
        public VaProfileActivePrescriptionBio() {
            this.activePrescriptionIndicator = false;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VaProfileFiduciaryInformation {
        @AuraEnabled
        public Boolean fiduciaryIndicator;

        /**
         * @description no arg constructor
         */
        public VaProfileFiduciaryInformation() {
            this.fiduciaryIndicator = false;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VaProfileFinancialFraudInformation {
        @AuraEnabled
        public Boolean financialFraudIndicator;

        /**
         * @description no arg constructor
         */
        public VaProfileFinancialFraudInformation() {
            this.financialFraudIndicator = false;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfileContact {
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public String originatingSourceSystem;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public String sourceSystemUser;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public Integer vet360Id;
        @AuraEnabled
        public List<VAProfileAddress> addresses;
        @AuraEnabled
        public List<VAProfileEmail> emails;
        @AuraEnabled
        public List<VAProfileTelephone> telephones;
        @AuraEnabled
        public List<VAProfilePermissions> permissions;

        /**
         * @description no arg constructor
         */
        public VAProfileContact() {
            this.vet360Id = 0;
            this.addresses = new List<VAProfileAddress>();
            this.emails = new List<VAProfileEmail>();
            this.telephones = new List<VAProfileTelephone>();
            this.permissions = new List<VAProfilePermissions>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfilePermissions {
        @AuraEnabled
        public String confirmationDate;
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public String effectiveEndDate;
        @AuraEnabled
        public String effectiveStartDate;
        @AuraEnabled
        public String originatingSourceSystem;
        @AuraEnabled
        public Integer permissionId;
        @AuraEnabled
        public String permissionType; //possible vals VideoPermission, TextPermission, EmailPermission
        @AuraEnabled
        public Boolean permissionValue;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public String sourceSystemUser;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public Integer vet360Id;

        /**
         * @description no arg constructor
         */
        public VAProfilePermissions() {
            this.permissionId = 0;
            this.permissionValue = false;
            this.vet360Id = 0;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfileAddress {
        @AuraEnabled
        public Integer addressId;
        @AuraEnabled
        public String addressLine1;
        @AuraEnabled
        public String addressLine2;
        @AuraEnabled
        public String addressLine3;
        @AuraEnabled
        public String addressPurposeOfUse;
        @AuraEnabled
        public String addressType;
        @AuraEnabled
        public Boolean badAddress;
        @AuraEnabled
        public String cityName;
        @AuraEnabled
        public String confidenceScore;
        @AuraEnabled
        public String confirmationDate;
        @AuraEnabled
        public String countryCodeFips;
        @AuraEnabled
        public String countryCodeIso2;
        @AuraEnabled
        public String countryCodeIso3;
        @AuraEnabled
        public String countryName;
        @AuraEnabled
        public County county;
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public String effectiveEndDate;
        @AuraEnabled
        public String effectiveStartDate;
        @AuraEnabled
        public String geocodeDate;
        @AuraEnabled
        public String geocodePrecision;
        @AuraEnabled
        public String intPostalCode;
        @AuraEnabled
        public String latitude;
        @AuraEnabled
        public String longitude;
        @AuraEnabled
        public String originatingSourceSystem;
        @AuraEnabled
        public Boolean overrideIndicator;
        @AuraEnabled
        public String provinceName;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public String sourceSystemUser;
        @AuraEnabled
        public String stateCode;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public Integer validationKey;
        @AuraEnabled
        public Integer vet360Id;
        @AuraEnabled
        public String zipCode4;
        @AuraEnabled
        public String zipCode5;

        /**
         * @description no arg constructor
         */
        public VAProfileAddress() {
            this.addressId = 0;
            this.badAddress = false;
            this.county = new County();
            this.overrideIndicator = false;
            this.validationKey = 0;
            this.vet360Id = 0;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class County {
        @AuraEnabled
        public String countyCode;
        @AuraEnabled
        public String countyName;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfileEmail {
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public String effectiveEndDate;
        @AuraEnabled
        public String effectiveStartDate;
        @AuraEnabled
        public String emailAddressText;
        @AuraEnabled
        public Integer emailId;
        @AuraEnabled
        public Boolean emailPermInd;
        @AuraEnabled
        public String emailStatusCode;
        @AuraEnabled
        public String originatingSourceSystem;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public String sourceSystemUser;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public Integer vet360Id;

        /**
         * @description no arg constructor
         */
        public VAProfileEmail() {
            this.emailId = 0;
            this.emailPermInd = false;
            this.vet360Id = 0;
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VAProfileTelephone {
        @AuraEnabled
        public String areaCode;
        @AuraEnabled
        public String confirmationDate;
        @AuraEnabled
        public String connectionStatusCode;
        @AuraEnabled
        public String countryCode;
        @AuraEnabled
        public String createDate;
        @AuraEnabled
        public String effectiveEndDate;
        @AuraEnabled
        public String effectiveStartDate;
        @AuraEnabled
        public Boolean internationalIndicator;
        @AuraEnabled
        public String originatingSourceSystem;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public String phoneNumberExt;
        @AuraEnabled
        public String phoneType;
        @AuraEnabled
        public String sourceDate;
        @AuraEnabled
        public String sourceSystem;
        @AuraEnabled
        public String sourceSystemUser;
        @AuraEnabled
        public Integer telephoneId;
        @AuraEnabled
        public Boolean textMessageCapableInd;
        @AuraEnabled
        public Boolean textMessagePermInd;
        @AuraEnabled
        public Boolean ttyInd;
        @AuraEnabled
        public String txAuditId;
        @AuraEnabled
        public String updateDate;
        @AuraEnabled
        public String vet360Id;
        @AuraEnabled
        public Boolean voiceMailAcceptableInd;

        /**
         * @description no arg constructor
         */
        public VAProfileTelephone() {
            this.internationalIndicator = false;
            this.telephoneId = 0;
            this.textMessageCapableInd = false;
            this.textMessagePermInd = false;
            this.ttyInd = false;
            this.voiceMailAcceptableInd = false;
        }
    }

    // end va profile begin EE

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EE {
        @AuraEnabled
        public String eeVeteranStatus;
        @AuraEnabled
        public String serviceConnectedPercentage; //example reponse shows this as integer and not decimal/double
        @AuraEnabled
        public String eligibleForMedicaid;
        @AuraEnabled
        public String priorityGroup;
        @AuraEnabled
        public List<EEMonetaryBenefit> monetaryBenefits;
        @AuraEnabled
        public List<EERatedDisability> ratedDisabilities;
        @AuraEnabled
        public List<EEServiceBranch> serviceBranches;
        @AuraEnabled
        public EEExtendedResponse eeExtendedResponse; //todo

        /**
         * @description no arg constructor
         */
        public EE() {
            this.monetaryBenefits = new List<EEMonetaryBenefit>();
            this.ratedDisabilities = new List<EERatedDisability>();
            this.serviceBranches = new List<EEServiceBranch>();
            this.eeExtendedResponse = new EEExtendedResponse();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEMonetaryBenefit {
        @AuraEnabled
        public String monetaryBenefitIndicator;
        @AuraEnabled
        public String monetaryBenefitType;
        @AuraEnabled
        public String monetaryBenefitReportDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EERatedDisability {
        @AuraEnabled
        public String diagnosticExtremity;
        @AuraEnabled
        public String disability;
        @AuraEnabled
        public String disabilityCode;
        @AuraEnabled
        public String originalEffectiveRatingDate;
        @AuraEnabled
        public String percentage;
        @AuraEnabled
        public String ratingDate;
        @AuraEnabled
        public String serviceConnected;
        @AuraEnabled
        public String recordModifiedDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEServiceBranch {
        @AuraEnabled
        public String serviceBranch;
        @AuraEnabled
        public String serviceNumber;
        @AuraEnabled
        public String serviceEntryDate;
        @AuraEnabled
        public String serviceExitDate;
        @AuraEnabled
        public String servicePeriod;
        @AuraEnabled
        public String dischargeType;
        @AuraEnabled
        public String location;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEExtendedResponse {
        @AuraEnabled
        public List<EEAssociation> associations;
        @AuraEnabled
        public EEDemographics demographics;
        @AuraEnabled
        public EEEligibilityVerification eligibilityVerification;
        @AuraEnabled
        public EEEnrollmentDetermination enrollmentDetermination; //todo
        @AuraEnabled
        public List<EEInsurance> insuranceList; //todo
        @AuraEnabled
        public List<EERelation> relations; //todo
        @AuraEnabled
        public EEPerson person; //todo
        @AuraEnabled
        public List<EEHealthBenefitPlan> healthBenefitPlans; //todo

        /**
         * @description no arg constructor
         */
        public EEExtendedResponse() {
            this.associations = new List<EEAssociation>();
            this.demographics = new EEDemographics();
            this.insuranceList = new List<EEInsurance>();
            this.relations = new List<EERelation>();
            this.person = new EEPerson();
            this.healthBenefitPlans = new List<EEHealthBenefitPlan>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEAssociation {
        @AuraEnabled
        public EEAssociationAddress address;
        @AuraEnabled
        public String alternatePhone;
        @AuraEnabled
        public String contactType;
        @AuraEnabled
        public String familyName;
        @AuraEnabled
        public String givenName;
        @AuraEnabled
        public String lastUpdateDate;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String organizationName;
        @AuraEnabled
        public String prefix;
        @AuraEnabled
        public String primaryPhone;
        @AuraEnabled
        public String relationship;
        @AuraEnabled
        public String suffix;

        /**
         * @description no arg constructor
         */
        public EEAssociation() {
            this.address = new EEAssociationAddress();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEAssociationAddress {
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String county;
        @AuraEnabled
        public String line1;
        @AuraEnabled
        public String line2;
        @AuraEnabled
        public String line3;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String zipCode;
        @AuraEnabled
        public String zipPlus4;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEDemographics {
        @AuraEnabled
        public String preferredFacility;
        @AuraEnabled
        public String assignmentDate;
        @AuraEnabled
        public String unassignmentDate;
        @AuraEnabled
        public List<EEDemographicsPreferredFacility> preferredFacilities;

        /**
         * @description no arg constructor
         */
        public EEDemographics() {
            this.preferredFacilities = new List<EEDemographicsPreferredFacility>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEDemographicsPreferredFacility {
        @AuraEnabled
        public String preferredFacility;
        @AuraEnabled
        public String assignmentDate;
        @AuraEnabled
        public String unassignmentDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEEligibilityVerification {
        @AuraEnabled
        public String eligibilityStatus;
        @AuraEnabled
        public String eligibilityStatusDate;
        @AuraEnabled
        public String verificationMethod;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEEnrollmentDetermination {
        @AuraEnabled
        public String effectiveDate;
        @AuraEnabled
        public String eligibleForMedicaid;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String enrollmentDate;
        @AuraEnabled
        public String enrollmentStatus;
        @AuraEnabled
        public String enrollmentCategoryName;
        @AuraEnabled
        public List<EEMonetaryBenefit> monetaryBenefits;
        @AuraEnabled
        public List<EEEligibilities> otherEligibilities;
        @AuraEnabled
        public EEEligibilities primaryEligibility;
        @AuraEnabled
        public String priorityGroup;
        @AuraEnabled
        public String prioritySubGroup;
        @AuraEnabled
        public List<EEEligibilities> secondaryEligibilities;
        @AuraEnabled
        public EEServiceConnectionAward serviceConnectionAward;
        @AuraEnabled
        public String veteran;

        /**
         * @description no arg constructor
         */
        public EEEnrollmentDetermination() {
            this.monetaryBenefits = new List<EEMonetaryBenefit>();
            this.otherEligibilities = new List<EEEligibilities>();
            this.primaryEligibility = new EEEligibilities();
            this.secondaryEligibilities = new List<EEEligibilities>();
            this.serviceConnectionAward = new EEServiceConnectionAward();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEEligibilities {
        @AuraEnabled
        public String indicator;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String eligibilityReportDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEServiceConnectionAward {
        @AuraEnabled
        public String awardDate;
        @AuraEnabled
        public String combinedServiceConnectedPercentageEffectiveDate;
        @AuraEnabled
        public String permanentAndTotal;
        @AuraEnabled
        public String permanentAndTotalEffectiveDate;
        @AuraEnabled
        public String serviceConnectedIndicator;
        @AuraEnabled
        public String serviceConnectedPercentage;
        @AuraEnabled
        public String unemployable;
        @AuraEnabled
        public String scReportDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEInsurance {
        @AuraEnabled
        public String companyName;
        @AuraEnabled
        public Boolean enrolledInPartA;
        @AuraEnabled
        public Boolean enrolledInPartB;
        @AuraEnabled
        public String groupName;
        @AuraEnabled
        public String groupNumber;
        @AuraEnabled
        public EEInsuranceAddress insuranceAddress;
        @AuraEnabled
        public List<EEInsurancePhone> insurancePhone;
        @AuraEnabled
        public String insuranceSiteUploadStatus;
        @AuraEnabled
        public String insuredRelationship;
        @AuraEnabled
        public String insuranceMappingTypeName;
        @AuraEnabled
        public String lastEditedDate;
        @AuraEnabled
        public String partAEffectiveDate;
        @AuraEnabled
        public String partBEffectiveDate;
        @AuraEnabled
        public String planType;
        @AuraEnabled
        public String policyEffectiveDate;
        @AuraEnabled
        public String policyExpirationDate;
        @AuraEnabled
        public String policyHolderName;
        @AuraEnabled
        public String policyNumber;
        @AuraEnabled
        public String preadmitCertification;
        @AuraEnabled
        public String reasonInsuranceNotUploaded;
        @AuraEnabled
        public String subscriber;

        /**
         * @description no arg constructor
         */
        public EEInsurance() {
            this.enrolledInPartA = false;
            this.enrolledInPartB = false;
            this.insuranceAddress = new EEInsuranceAddress();
            this.insurancePhone = new List<EEInsurancePhone>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEInsuranceAddress {
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String country;
        @AuraEnabled
        public String county;
        @AuraEnabled
        public String line1;
        @AuraEnabled
        public String line2;
        @AuraEnabled
        public String line3;
        @AuraEnabled
        public String postalCode;
        @AuraEnabled
        public String provinceCode;
        @AuraEnabled
        public String state;
        @AuraEnabled
        public String zipCode;
        @AuraEnabled
        public String zipPlus4;
        @AuraEnabled
        public String zipcodeDup;
        @AuraEnabled
        public String addressChangeDateTime;
        @AuraEnabled
        public String addressChangeEffectiveDate;
        @AuraEnabled
        public String addressChangeSite;
        @AuraEnabled
        public String addressChangeSource;
        @AuraEnabled
        public String addressTypeCode;
        @AuraEnabled
        public String badAddressReason;
        @AuraEnabled
        public List<String> confidentialAddressCategories;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public String contactMethodType;
        @AuraEnabled
        public String contactMethodReportDate;

        /**
         * @description no arg constructor
         */
        public EEInsuranceAddress() {
            this.confidentialAddressCategories = new List<String>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEInsurancePhone {
        @AuraEnabled
        public String phoneNumber;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String phoneNumberReportDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EERelation {
        @AuraEnabled
        public String dob;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String familyName;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String givenName;
        @AuraEnabled
        public String middleName;
        @AuraEnabled
        public String relationship;
        @AuraEnabled
        public List<EESSN> ssns;
        @AuraEnabled
        public String startDate;

        /**
         * @description no arg constructor
         */
        public EERelation() {
            this.ssns = new List<EESSN>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EESSN { //ssn as in social security num
        @AuraEnabled
        public String pseudoSsnReason;
        @AuraEnabled
        public String sourceOfChange;
        @AuraEnabled
        public String ssaMessage;
        @AuraEnabled
        public String ssaReceivedDate;
        @AuraEnabled
        public String ssaSentDate;
        @AuraEnabled
        public String ssaVerificationDate;
        @AuraEnabled
        public String ssaVerificationStatus;
        @AuraEnabled
        public String ssnText;
        @AuraEnabled
        public String type;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEPerson {
        @AuraEnabled
        public String ssaVerificationStatus;
        @AuraEnabled
        public String ssaverificationDate;
        @AuraEnabled
        public List<EEVAMCData> vamcData;
        @AuraEnabled
        public List<String> otherNames;

        /**
         * @description no arg constructor
         */
        public EEPerson() {
            this.vamcData = new List<EEVAMCData>();
            this.otherNames = new List<String>();
        }
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEVAMCData {
        @AuraEnabled
        public String dfnNumber;
        @AuraEnabled
        public String facilityNumber;
        @AuraEnabled
        public String lastVisitDate;
        @AuraEnabled
        public String vamcReportDate;
    }

    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class EEHealthBenefitPlan {
        @AuraEnabled
        public String planName;
        @AuraEnabled
        public String effectiveDate;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public String planCode;
        @AuraEnabled
        public String coverageCode;
    }

    // removed commented out code

    // main body of vets object
    /**
     * @description DTO to serialize JSON into typed Apex
     */
    public class VetDetails {
        @AuraEnabled
        public String bgsResult;
        @AuraEnabled
        public String eeResult;
        @AuraEnabled
        public String emisResult;
        @AuraEnabled
        public MVI mvi;
        @AuraEnabled
        public EE ee;
        @AuraEnabled
        public String mviResult;
        @AuraEnabled
        public VAProfile vaProfile;
        @AuraEnabled
        public VaProfileV1 vaProfileV1;
        @AuraEnabled
        public VaProfileV2 vaProfileV2;
        @AuraEnabled
        public String vets360Result;

        /**
         * @description no arg constructor
         */
        public VetDetails() {
            this.mvi = new MVI();
            this.ee = new EE();
            this.vaProfile = new VAProfile();
            this.vaProfileV1 = new VaProfileV1();
            this.vaProfileV2 = new VaProfileV2();
        }
    }
}
