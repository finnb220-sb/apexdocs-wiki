@IsTest
private with sharing class VCC_MPIParserTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    private static void vccMPIParser() {
        System.runAs(getTestUser()) {
            VCC_MPIParser mpiParser = new VCC_MPIParser();
            Assert.isTrue(mpiParser != null, 'Expected parser not null');
            Assert.isTrue(mpiParser.vets != null, 'Expected vets not null');
            Assert.isTrue(mpiParser.vetsV3 != null, 'Expected vets v3 not null');
        }
    }

    @IsTest
    private static void vetDetails() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VetDetails vetDetails = new VCC_MPIParser.VetDetails();
            Assert.isTrue(vetDetails.mvi != null, 'Expected mvi null');
            Assert.isTrue(vetDetails.ee != null, 'Expected ee null');
            Assert.isTrue(vetDetails.vaProfile != null, 'Expected profile null');
            Assert.isTrue(vetDetails.vaProfileV2 != null, 'Expected profile v2 null');
            Assert.areEqual(null, vetDetails.bgsResult, 'Expected bgs result to be blank');
            Assert.areEqual(null, vetDetails.eeResult, 'Expected ee result to be blank');
            Assert.areEqual(null, vetDetails.emisResult, 'Expected emis result to be blank');
            Assert.areEqual(null, vetDetails.mviResult, 'Expected mvi result to be blank');
            Assert.areEqual(null, vetDetails.vets360Result, 'Expected vet 360 result to be blank');
        }
    }

    @IsTest
    private static void mvi() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.MVI mvi = new VCC_MPIParser.MVI();
            Assert.isTrue(mvi.address != null, 'Expected address null');
            Assert.isTrue(mvi.correlatedIds != null, 'Expected ids null');
            Assert.isTrue(mvi.medicalCenterFacilities != null, 'Expected facilities null');
            Assert.isTrue(mvi.phoneNumber != null, 'Expected number null');
            Assert.isTrue(mvi.relationships != null, 'Expected relationships null');
            Assert.areEqual(null, mvi.brlsFilenumber, 'Expected number to be blank');
            Assert.areEqual(null, mvi.cityOfBirth, 'Expected city to be blank');
            Assert.areEqual(null, mvi.corpId, 'Expected corp id to be blank');
            Assert.areEqual(null, mvi.dob, 'Expected dob to be blank');
            Assert.areEqual(null, mvi.dod, 'Expected dod to be blank');
            Assert.areEqual(null, mvi.edipi, 'Expected edipi to be blank');
            Assert.areEqual(null, mvi.firstName, 'Expected first name to be blank');
            Assert.areEqual(null, mvi.gender, 'Expected gender to be blank');
            Assert.areEqual(null, mvi.icn, 'Expected icn to be blank');
            Assert.areEqual(null, mvi.lastName, 'Expected last name to be blank');
            Assert.areEqual(null, mvi.middleName, 'Expected middle name to be blank');
            Assert.areEqual(null, mvi.mothersMaidenName, 'Expected mothers maiden name to be blank');
            Assert.areEqual(null, mvi.mviIipt, 'Expected iipt to be blank');
            Assert.areEqual(null, mvi.personType, 'Expected type to be blank');
            Assert.areEqual(null, mvi.prefixName, 'Expected prefix to be blank');
            Assert.areEqual(null, mvi.queryMatchObservation, 'Expected query to be blank');
            Assert.areEqual(null, mvi.salesforceId, 'Expected salesforce id to be blank');
            Assert.areEqual(null, mvi.ssn, 'Expected ssn to be blank');
            Assert.areEqual(null, mvi.stateOfBirth, 'Expected state to be blank');
            Assert.areEqual(null, mvi.suffixName, 'Expected name to be blank');
            Assert.areEqual(null, mvi.vet360Id, 'Expected 360 id to be blank');
        }
    }

    @IsTest
    private static void correlatedID() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.CorrelatedID correlatedID = new VCC_MPIParser.CorrelatedID();
            Assert.areEqual(null, correlatedID.idStatus, 'Expected status to be blank');
            Assert.areEqual(null, correlatedID.idType, 'Expected type to be blank');
            Assert.areEqual(null, correlatedID.longId, 'Expected long id to be blank');
            Assert.areEqual(null, correlatedID.shortId, 'Expected short id to be blank');
        }
    }

    @IsTest
    private static void address() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.Address address = new VCC_MPIParser.Address();
            Assert.areEqual(null, address.addressTypeCode, 'Expected type code to be blank');
            Assert.areEqual(null, address.city, 'Expected city to be blank');
            Assert.areEqual(null, address.country, 'Expected country to be blank');
            Assert.areEqual(null, address.postalCode, 'Expected postal code to be blank');
            Assert.areEqual(null, address.state, 'Expected state to be blank');
            Assert.areEqual(null, address.streetAddress, 'Expected street address to be blank');
            Assert.areEqual(null, address.streetAddress2, 'Expected street address 2 to be blank');
            Assert.areEqual(null, address.streetAddress3, 'Expected street address 3 to be blank');
        }
    }

    @IsTest
    private static void medicalCenterFacility() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.MedicalCenterFacility medicalCenterFacility = new VCC_MPIParser.MedicalCenterFacility();
            Assert.areEqual(null, medicalCenterFacility.facilityId, 'Expected id to be blank');
            Assert.areEqual(null, medicalCenterFacility.personId, 'Expected person id to be blank');
            Assert.areEqual(null, medicalCenterFacility.facilityName, 'Expected name to be blank');
        }
    }

    @IsTest
    private static void phoneNumber() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.PhoneNumber phoneNumber = new VCC_MPIParser.PhoneNumber();
            Assert.areEqual(null, phoneNumber.use, 'Expected use to be blank');
            Assert.areEqual(null, phoneNumber.value, 'Expected value to be blank');
        }
    }

    @IsTest
    private static void relationship() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.Relationship relationship = new VCC_MPIParser.Relationship();
            Assert.areEqual(null, relationship.icn, 'Expected icn to be blank');
            Assert.areEqual(null, relationship.direction, 'Expected direction to be blank');
            Assert.areEqual(null, relationship.name, 'Expected name to be blank');
            Assert.areEqual(null, relationship.displayName, 'Expected display name to be blank');
            Assert.areEqual(null, relationship.relationshipType, 'Expected type to be blank');
            Assert.areEqual(null, relationship.statusCode, 'Expected status code to be blank');
            Assert.areEqual(null, relationship.effectiveTime, 'Expected time to be blank');
        }
    }

    @IsTest
    private static void vaProfile() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfile vaProfile = new VCC_MPIParser.VAProfile();
            Assert.isTrue(vaProfile.addresses != null, 'Expected address null');
            Assert.isTrue(vaProfile.emails != null, 'Expected emails null');
            Assert.isTrue(vaProfile.telephones != null, 'Expected telephones null');
            Assert.areEqual(null, vaProfile.createDate, 'Expected create date to be blank');
            Assert.areEqual(null, vaProfile.sourceDate, 'Expected source date to be blank');
            Assert.areEqual(null, vaProfile.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfile.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfile.updateDate, 'Expected date to be blank');
            Assert.areEqual(0, vaProfile.vet360Id, 'Expected 360 id to be 0');
        }
    }

    @IsTest
    private static void vaProfileV2() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VaProfileV2 vaProfile = new VCC_MPIParser.VaProfileV2();
            Assert.isTrue(vaProfile.vaProfileContactInfo != null, 'Expected contact info null');
            Assert.isTrue(vaProfile.vaProfilePersonAttributes != null, 'Expected attributes null');
            Assert.isTrue(vaProfile.vaProfileIdentity != null, 'Expected identity null');
        }
    }

    @IsTest
    private static void vaProfileSensitivityInformation() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VaProfileSensitivityInformation vaProfileSensitivityInformation = new VCC_MPIParser.VaProfileSensitivityInformation();
            Assert.isTrue(vaProfileSensitivityInformation.sensitivityFlag != null, 'Expected sensitivity flag null');
        }
    }

    @IsTest
    private static void vaProfilePersonAttributes() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfilePersonAttributes vaProfilePersonAttributes = new VCC_MPIParser.VAProfilePersonAttributes();
            Assert.isTrue(vaProfilePersonAttributes.fiduciaryInformation != null, 'Expected fid info null');
            Assert.isTrue(vaProfilePersonAttributes.financialFraudInformation != null, 'Expected fraud info null');
            Assert.isTrue(vaProfilePersonAttributes.activePrescriptionBio != null, 'Expected bio null');
        }
    }

    @IsTest
    private static void vaProfileActivePrescriptionBio() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VaProfileActivePrescriptionBio vaProfileActivePrescriptionBio = new VCC_MPIParser.VaProfileActivePrescriptionBio();
            Assert.isTrue(
                vaProfileActivePrescriptionBio.activePrescriptionIndicator != null,
                'Expected prescription indicator null'
            );
        }
    }

    @IsTest
    private static void vaProfileFinancialFraudInformation() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VaProfileFinancialFraudInformation vaProfileFinancialFraudInformation = new VCC_MPIParser.VaProfileFinancialFraudInformation();
            Assert.isTrue(
                vaProfileFinancialFraudInformation.financialFraudIndicator != null,
                'Expected fraud indicator null'
            );
        }
    }

    @IsTest
    private static void vaProfileContact() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfileContact vaProfileContact = new VCC_MPIParser.VAProfileContact();
            Assert.isTrue(vaProfileContact.addresses != null, 'Expected addresses null');
            Assert.isTrue(vaProfileContact.emails != null, 'Expected emails null');
            Assert.isTrue(vaProfileContact.telephones != null, 'Expected telephones null');
            Assert.isTrue(vaProfileContact.permissions != null, 'Expected permissions null');
            Assert.areEqual(null, vaProfileContact.createDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileContact.originatingSourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileContact.sourceDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileContact.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileContact.sourceSystemUser, 'Expected system user to be blank');
            Assert.areEqual(null, vaProfileContact.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfileContact.updateDate, 'Expected update date to be blank');
            Assert.areEqual(0, vaProfileContact.vet360Id, 'Expected 360 id to be blank');
        }
    }

    @IsTest
    private static void vaProfilePermissions() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfilePermissions vaProfilePermissions = new VCC_MPIParser.VAProfilePermissions();
            Assert.areEqual(null, vaProfilePermissions.createDate, 'Expected create date to be blank');
            Assert.areEqual(null, vaProfilePermissions.effectiveEndDate, 'Expected end date to be blank');
            Assert.areEqual(null, vaProfilePermissions.effectiveStartDate, 'Expected start date to be blank');
            Assert.areEqual(null, vaProfilePermissions.originatingSourceSystem, 'Expected system to be blank');
            Assert.areEqual(0, vaProfilePermissions.permissionId, 'Expected permission id to be 0');
            Assert.areEqual(null, vaProfilePermissions.permissionType, 'Expected type to be blank');
            Assert.areEqual(false, vaProfilePermissions.permissionValue, 'Expected value to not match');
            Assert.areEqual(null, vaProfilePermissions.sourceDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfilePermissions.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfilePermissions.sourceSystemUser, 'Expected user to be blank');
            Assert.areEqual(null, vaProfilePermissions.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfilePermissions.updateDate, 'Expected date to be blank');
            Assert.areEqual(0, vaProfilePermissions.vet360Id, 'Expected 360 id to be blank');
        }
    }

    @IsTest
    private static void vaProfileAddress() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfileAddress vaProfileAddress = new VCC_MPIParser.VAProfileAddress();
            Assert.isTrue(vaProfileAddress.county != null, 'Expected county null');
            Assert.areEqual(0, vaProfileAddress.addressId, 'Expected id to be 0');
            Assert.areEqual(null, vaProfileAddress.addressLine1, 'Expected line 1 to be blank');
            Assert.areEqual(null, vaProfileAddress.addressLine2, 'Expected line 2 to be blank');
            Assert.areEqual(null, vaProfileAddress.addressLine2, 'Expected line 2 to be blank');
            Assert.areEqual(null, vaProfileAddress.addressPurposeOfUse, 'Expected purpose to be blank');
            Assert.areEqual(null, vaProfileAddress.addressType, 'Expected type to be blank');
            Assert.areEqual(false, vaProfileAddress.badAddress, 'Expected address to not match');
            Assert.areEqual(null, vaProfileAddress.cityName, 'Expected city to be blank');
            Assert.areEqual(null, vaProfileAddress.confidenceScore, 'Expected score to be blank');
            Assert.areEqual(null, vaProfileAddress.confirmationDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileAddress.countryCodeFips, 'Expected fips to be blank');
            Assert.areEqual(null, vaProfileAddress.countryCodeIso2, 'Expected iso2 to be blank');
            Assert.areEqual(null, vaProfileAddress.countryCodeIso3, 'Expected iso3 id to be blank');
            Assert.areEqual(null, vaProfileAddress.countryName, 'Expected country to be blank');
            Assert.areEqual(null, vaProfileAddress.createDate, 'Expected create date to be blank');
            Assert.areEqual(null, vaProfileAddress.effectiveEndDate, 'Expected end date to be blank');
            Assert.areEqual(null, vaProfileAddress.effectiveStartDate, 'Expected start date to be blank');
            Assert.areEqual(null, vaProfileAddress.geocodeDate, 'Expected geocode date to be blank');
            Assert.areEqual(null, vaProfileAddress.geocodePrecision, 'Expected precision to be blank');
            Assert.areEqual(null, vaProfileAddress.intPostalCode, 'Expected postal code to be blank');
            Assert.areEqual(null, vaProfileAddress.latitude, 'Expected latitude to be blank');
            Assert.areEqual(null, vaProfileAddress.longitude, 'Expected longitude to be blank');
            Assert.areEqual(null, vaProfileAddress.originatingSourceSystem, 'Expected system to be blank');
            Assert.areEqual(false, vaProfileAddress.overrideIndicator, 'Expected indicator to not match');
            Assert.areEqual(null, vaProfileAddress.provinceName, 'Expected province to be blank');
            Assert.areEqual(null, vaProfileAddress.sourceDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileAddress.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileAddress.sourceSystemUser, 'Expected user to be blank');
            Assert.areEqual(null, vaProfileAddress.stateCode, 'Expected state code to be blank');
            Assert.areEqual(null, vaProfileAddress.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfileAddress.updateDate, 'Expected update date to be blank');
            Assert.areEqual(0, vaProfileAddress.validationKey, 'Expected key to be 0');
            Assert.areEqual(0, vaProfileAddress.vet360Id, 'Expected vet id to be 0');
            Assert.areEqual(null, vaProfileAddress.zipCode4, 'Expected zip code4 to be blank');
            Assert.areEqual(null, vaProfileAddress.zipCode5, 'Expected zip code5 to be blank');
        }
    }

    @IsTest
    private static void county() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.County county = new VCC_MPIParser.County();
            Assert.areEqual(null, county.countyCode, 'Expected code to be blank');
            Assert.areEqual(null, county.countyName, 'Expected name to be blank');
        }
    }

    @IsTest
    private static void vaProfileEmail() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfileEmail vaProfileEmail = new VCC_MPIParser.VAProfileEmail();
            Assert.areEqual(null, vaProfileEmail.createDate, 'Expected create date to be blank');
            Assert.areEqual(null, vaProfileEmail.effectiveEndDate, 'Expected end date to be blank');
            Assert.areEqual(null, vaProfileEmail.effectiveStartDate, 'Expected start date to be blank');
            Assert.areEqual(null, vaProfileEmail.emailAddressText, 'Expected text to be blank');
            Assert.areEqual(0, vaProfileEmail.emailId, 'Expected email id to be 0');
            Assert.areEqual(false, vaProfileEmail.emailPermInd, 'Expected perm ind to not match');
            Assert.areEqual(null, vaProfileEmail.emailStatusCode, 'Expected code to be blank');
            Assert.areEqual(null, vaProfileEmail.originatingSourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileEmail.sourceDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileEmail.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileEmail.sourceSystemUser, 'Expected user to be blank');
            Assert.areEqual(null, vaProfileEmail.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfileEmail.updateDate, 'Expected date to be blank');
            Assert.areEqual(0, vaProfileEmail.vet360Id, 'Expected 360 id to be blank');
        }
    }

    @IsTest
    private static void vaProfileTelephone() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.VAProfileTelephone vaProfileTelephone = new VCC_MPIParser.VAProfileTelephone();
            Assert.areEqual(null, vaProfileTelephone.areaCode, 'Expected are code to be blank');
            Assert.areEqual(null, vaProfileTelephone.confirmationDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileTelephone.connectionStatusCode, 'Expected status code to be blank');
            Assert.areEqual(null, vaProfileTelephone.countryCode, 'Expected code to be blank');
            Assert.areEqual(null, vaProfileTelephone.createDate, 'Expected create date to be blank');
            Assert.areEqual(null, vaProfileTelephone.effectiveStartDate, 'Expected start date to be blank');
            Assert.areEqual(null, vaProfileTelephone.effectiveEndDate, 'Expected end date to be blank');
            Assert.areEqual(false, vaProfileTelephone.internationalIndicator, 'Expected indicator to not match');
            Assert.areEqual(null, vaProfileTelephone.originatingSourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileTelephone.phoneNumber, 'Expected number to be blank');
            Assert.areEqual(null, vaProfileTelephone.phoneNumberExt, 'Expected ext to be blank');
            Assert.areEqual(null, vaProfileTelephone.phoneType, 'Expected type to be blank');
            Assert.areEqual(null, vaProfileTelephone.sourceDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileTelephone.sourceSystem, 'Expected system to be blank');
            Assert.areEqual(null, vaProfileTelephone.sourceSystemUser, 'Expected user to be blank');
            Assert.areEqual(0, vaProfileTelephone.telephoneId, 'Expected id to be 0');
            Assert.areEqual(false, vaProfileTelephone.textMessageCapableInd, 'Expected capable ind to not match');
            Assert.areEqual(false, vaProfileTelephone.textMessagePermInd, 'Expected perm ind to not match');
            Assert.areEqual(false, vaProfileTelephone.ttyInd, 'Expected tty ind to not match');
            Assert.areEqual(null, vaProfileTelephone.txAuditId, 'Expected audit id to be blank');
            Assert.areEqual(null, vaProfileTelephone.updateDate, 'Expected date to be blank');
            Assert.areEqual(null, vaProfileTelephone.vet360Id, 'Expected 360 id to be blank');
            Assert.areEqual(false, vaProfileTelephone.voiceMailAcceptableInd, 'Expected acceptable ind to not match');
        }
    }

    @IsTest
    private static void ee() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EE eligibility = new VCC_MPIParser.EE();
            Assert.isTrue(eligibility.monetaryBenefits != null, 'Expected benefits null');
            Assert.isTrue(eligibility.ratedDisabilities != null, 'Expected disabilities null');
            Assert.isTrue(eligibility.serviceBranches != null, 'Expected branches null');
            Assert.isTrue(eligibility.eeExtendedResponse != null, 'Expected response null');
            Assert.areEqual(null, eligibility.eeVeteranStatus, 'Expected statusto be blank');
            Assert.areEqual(null, eligibility.serviceConnectedPercentage, 'Expected percentage to be blank');
            Assert.areEqual(null, eligibility.eligibleForMedicaid, 'Expected medicaid to be blank');
            Assert.areEqual(null, eligibility.priorityGroup, 'Expected group to be blank');
        }
    }

    @IsTest
    private static void eeMonetaryBenefit() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEMonetaryBenefit eeMonetaryBenefit = new VCC_MPIParser.EEMonetaryBenefit();
            Assert.areEqual(null, eeMonetaryBenefit.monetaryBenefitIndicator, 'Expected indicator to be blank');
            Assert.areEqual(null, eeMonetaryBenefit.monetaryBenefitType, 'Expected type to be blank');
            Assert.areEqual(null, eeMonetaryBenefit.monetaryBenefitReportDate, 'Expected date to be blank');
        }
    }

    @IsTest
    private static void eeRatedDisability() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EERatedDisability eeRatedDisability = new VCC_MPIParser.EERatedDisability();
            Assert.areEqual(null, eeRatedDisability.diagnosticExtremity, 'Expected extremity to be blank');
            Assert.areEqual(null, eeRatedDisability.disability, 'Expected disability to be blank');
            Assert.areEqual(null, eeRatedDisability.disabilityCode, 'Expected code to be blank');
            Assert.areEqual(null, eeRatedDisability.originalEffectiveRatingDate, 'Expected date to be blank');
            Assert.areEqual(null, eeRatedDisability.percentage, 'Expected percentage to be blank');
            Assert.areEqual(null, eeRatedDisability.ratingDate, 'Expected date to be blank');
            Assert.areEqual(null, eeRatedDisability.serviceConnected, 'Expected service to be blank');
            Assert.areEqual(null, eeRatedDisability.recordModifiedDate, 'Expected date to be blank');
        }
    }

    @IsTest
    private static void eeServiceBranch() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEServiceBranch eeServiceBranch = new VCC_MPIParser.EEServiceBranch();
            Assert.areEqual(null, eeServiceBranch.serviceBranch, 'Expected branch to be blank');
            Assert.areEqual(null, eeServiceBranch.serviceNumber, 'Expected number to be blank');
            Assert.areEqual(null, eeServiceBranch.serviceEntryDate, 'Expected entry date to be blank');
            Assert.areEqual(null, eeServiceBranch.serviceExitDate, 'Expected exit date to be blank');
            Assert.areEqual(null, eeServiceBranch.servicePeriod, 'Expected period to be blank');
            Assert.areEqual(null, eeServiceBranch.dischargeType, 'Expected type to be blank');
            Assert.areEqual(null, eeServiceBranch.location, 'Expected location to be blank');
        }
    }

    @IsTest
    private static void eeExtendedResponse() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEExtendedResponse eeExtendedResponse = new VCC_MPIParser.EEExtendedResponse();
            Assert.isTrue(eeExtendedResponse.associations != null, 'Expected associations null');
            Assert.isTrue(eeExtendedResponse.insuranceList != null, 'Expected list null');
            Assert.isTrue(eeExtendedResponse.relations != null, 'Expected relations null');
            Assert.isTrue(eeExtendedResponse.healthBenefitPlans != null, 'Expected plans null');
            Assert.isTrue(eeExtendedResponse.person != null, 'Expected person null');
            Assert.isTrue(eeExtendedResponse.demographics != null, 'Expected demographics null');
        }
    }

    @IsTest
    private static void eeAssociation() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEAssociation eeAssociation = new VCC_MPIParser.EEAssociation();
            Assert.isTrue(eeAssociation.address != null, 'Expected address null');
            Assert.areEqual(null, eeAssociation.alternatePhone, 'Expected phone to be blank');
            Assert.areEqual(null, eeAssociation.contactType, 'Expected type to be blank');
            Assert.areEqual(null, eeAssociation.familyName, 'Expected family name to be blank');
            Assert.areEqual(null, eeAssociation.givenName, 'Expected given name to be blank');
            Assert.areEqual(null, eeAssociation.lastUpdateDate, 'Expected date to be blank');
            Assert.areEqual(null, eeAssociation.middleName, 'Expected middle name to be blank');
            Assert.areEqual(null, eeAssociation.organizationName, 'Expected org name to be blank');
            Assert.areEqual(null, eeAssociation.prefix, 'Expected prefix to be blank');
            Assert.areEqual(null, eeAssociation.primaryPhone, 'Expected primary phone to be blank');
            Assert.areEqual(null, eeAssociation.relationship, 'Expected relationship to be blank');
            Assert.areEqual(null, eeAssociation.suffix, 'Expected suffix to be blank');
        }
    }

    @IsTest
    private static void eeAssociationAddress() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEAssociationAddress eeAssociationAddress = new VCC_MPIParser.EEAssociationAddress();
            Assert.areEqual(null, eeAssociationAddress.city, 'Expected city to be blank');
            Assert.areEqual(null, eeAssociationAddress.country, 'Expected country to be blank');
            Assert.areEqual(null, eeAssociationAddress.county, 'Expected county to be blank');
            Assert.areEqual(null, eeAssociationAddress.line1, 'Expected line1 to be blank');
            Assert.areEqual(null, eeAssociationAddress.line2, 'Expected line2 to be blank');
            Assert.areEqual(null, eeAssociationAddress.line3, 'Expected line3 to be blank');
            Assert.areEqual(null, eeAssociationAddress.postalCode, 'Expected postal code to be blank');
            Assert.areEqual(null, eeAssociationAddress.state, 'Expected state to be blank');
            Assert.areEqual(null, eeAssociationAddress.zipCode, 'Expected zip code to be blank');
            Assert.areEqual(null, eeAssociationAddress.zipPlus4, 'Expected plus 4 to be blank');
        }
    }

    @IsTest
    private static void eeDemographics() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEDemographics eeDemographics = new VCC_MPIParser.EEDemographics();
            Assert.isTrue(eeDemographics.preferredFacilities != null, 'Expected facilities null');
            Assert.areEqual(null, eeDemographics.preferredFacility, 'Expected facility to be blank');
            Assert.areEqual(null, eeDemographics.assignmentDate, 'Expected assignment date to be blank');
            Assert.areEqual(null, eeDemographics.unassignmentDate, 'Expected unassignment date to be blank');
        }
    }

    @IsTest
    private static void eeDemographicsPreferredFacility() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEDemographicsPreferredFacility eeDemographicsPreferredFacility = new VCC_MPIParser.EEDemographicsPreferredFacility();
            Assert.areEqual(null, eeDemographicsPreferredFacility.preferredFacility, 'Expected facility to be blank');
            Assert.areEqual(
                null,
                eeDemographicsPreferredFacility.assignmentDate,
                'Expected assignment date to be blank'
            );
            Assert.areEqual(
                null,
                eeDemographicsPreferredFacility.unassignmentDate,
                'Expected unassignment date to be blank'
            );
        }
    }

    @IsTest
    private static void eeEligibilityVerification() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEEligibilityVerification eeEligibilityVerification = new VCC_MPIParser.EEEligibilityVerification();
            Assert.areEqual(null, eeEligibilityVerification.eligibilityStatus, 'Expected status to be blank');
            Assert.areEqual(null, eeEligibilityVerification.eligibilityStatusDate, 'Expected date to be blank');
            Assert.areEqual(null, eeEligibilityVerification.verificationMethod, 'Expected method to be blank');
        }
    }

    @IsTest
    private static void eeEnrollmentDetermination() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEEnrollmentDetermination eeEnrollmentDetermination = new VCC_MPIParser.EEEnrollmentDetermination();
            Assert.isTrue(eeEnrollmentDetermination.monetaryBenefits != null, 'Expected benefits null');
            Assert.isTrue(eeEnrollmentDetermination.otherEligibilities != null, 'Expected eligibilities null');
            Assert.isTrue(eeEnrollmentDetermination.primaryEligibility != null, 'Expected eligibility null');
            Assert.isTrue(
                eeEnrollmentDetermination.secondaryEligibilities != null,
                'Expected secondary eligibilities null'
            );
            Assert.areEqual(null, eeEnrollmentDetermination.effectiveDate, 'Expected effective date to be blank');
            Assert.areEqual(
                null,
                eeEnrollmentDetermination.eligibleForMedicaid,
                'Expected eligible for medicaide to be blank'
            );
            Assert.areEqual(null, eeEnrollmentDetermination.endDate, 'Expected end date to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.enrollmentDate, 'Expected enrollment date to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.enrollmentStatus, 'Expected status to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.enrollmentCategoryName, 'Expected cat name to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.priorityGroup, 'Expected group to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.prioritySubGroup, 'Expected subgroup to be blank');
            Assert.areEqual(null, eeEnrollmentDetermination.veteran, 'Expected veteran to be blank');
        }
    }

    @IsTest
    private static void eeEligibilities() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEEligibilities eeEligibilities = new VCC_MPIParser.EEEligibilities();
            Assert.areEqual(null, eeEligibilities.indicator, 'Expected indicator to be blank');
            Assert.areEqual(null, eeEligibilities.type, 'Expected type to be blank');
            Assert.areEqual(null, eeEligibilities.eligibilityReportDate, 'Expected date to be blank');
        }
    }

    @IsTest
    private static void eeServiceConnectionAward() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEServiceConnectionAward eeServiceConnectionAward = new VCC_MPIParser.EEServiceConnectionAward();
            Assert.areEqual(null, eeServiceConnectionAward.awardDate, 'Expected award date to be blank');
            Assert.areEqual(
                null,
                eeServiceConnectionAward.combinedServiceConnectedPercentageEffectiveDate,
                'Expected percentage effective date to be blank'
            );
            Assert.areEqual(null, eeServiceConnectionAward.permanentAndTotal, 'Expected total to be blank');
            Assert.areEqual(
                null,
                eeServiceConnectionAward.permanentAndTotalEffectiveDate,
                'Expected total effective date to be blank'
            );
            Assert.areEqual(null, eeServiceConnectionAward.serviceConnectedIndicator, 'Expected indicator to be blank');
            Assert.areEqual(
                null,
                eeServiceConnectionAward.serviceConnectedPercentage,
                'Expected percentage to be blank'
            );
            Assert.areEqual(null, eeServiceConnectionAward.permanentAndTotal, 'Expected total to be blank');
            Assert.areEqual(null, eeServiceConnectionAward.unemployable, 'Expected unemployable to be blank');
            Assert.areEqual(null, eeServiceConnectionAward.scReportDate, 'Expected report date to be blank');
        }
    }

    @IsTest
    private static void eeInsurance() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEInsurance eeInsurance = new VCC_MPIParser.EEInsurance();
            Assert.isTrue(eeInsurance.insuranceAddress != null, 'Expected address null');
            Assert.isTrue(eeInsurance.insurancePhone != null, 'Expected phone null');
            Assert.areEqual(null, eeInsurance.companyName, 'Expected company name to be blank');
            Assert.areEqual(false, eeInsurance.enrolledInPartA, 'Expected part A to not match');
            Assert.areEqual(false, eeInsurance.enrolledInPartB, 'Expected part B to not match');
            Assert.areEqual(null, eeInsurance.groupName, 'Expected group name to be blank');
            Assert.areEqual(null, eeInsurance.groupNumber, 'Expected group number to be blank');
            Assert.areEqual(null, eeInsurance.insuranceSiteUploadStatus, 'Expected status to be blank');
            Assert.areEqual(null, eeInsurance.insuranceMappingTypeName, 'Expected type name to be blank');
            Assert.areEqual(null, eeInsurance.lastEditedDate, 'Expected edited date to be blank');
            Assert.areEqual(null, eeInsurance.partAEffectiveDate, 'Expected part A effective date to be blank');
            Assert.areEqual(null, eeInsurance.partBEffectiveDate, 'Expected part B effective date to be blank');
            Assert.areEqual(null, eeInsurance.planType, 'Expected plan type to be blank');
            Assert.areEqual(null, eeInsurance.policyEffectiveDate, 'Expected effective date to be blank');
            Assert.areEqual(null, eeInsurance.policyExpirationDate, 'Expected expiration date to be blank');
            Assert.areEqual(null, eeInsurance.policyHolderName, 'Expected policy holder name to be blank');
            Assert.areEqual(null, eeInsurance.policyNumber, 'Expected number to be blank');
            Assert.areEqual(null, eeInsurance.preadmitCertification, 'Expected certification to be blank');
            Assert.areEqual(null, eeInsurance.reasonInsuranceNotUploaded, 'Expected reason to be blank');
            Assert.areEqual(null, eeInsurance.subscriber, 'Expected subscriber to be blank');
        }
    }

    @IsTest
    private static void eeInsuranceAddress() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEInsuranceAddress eeInsuranceAddress = new VCC_MPIParser.EEInsuranceAddress();
            Assert.isTrue(eeInsuranceAddress.confidentialAddressCategories != null, 'Expected categories null');
            Assert.areEqual(null, eeInsuranceAddress.city, 'Expected city to be blank');
            Assert.areEqual(null, eeInsuranceAddress.country, 'Expected country to be blank');
            Assert.areEqual(null, eeInsuranceAddress.county, 'Expected county to be blank');
            Assert.areEqual(null, eeInsuranceAddress.line1, 'Expected line1 to be blank');
            Assert.areEqual(null, eeInsuranceAddress.line2, 'Expected line2 to be blank');
            Assert.areEqual(null, eeInsuranceAddress.line3, 'Expected line3 to be blank');
            Assert.areEqual(null, eeInsuranceAddress.postalCode, 'Expected postal code to be blank');
            Assert.areEqual(null, eeInsuranceAddress.provinceCode, 'Expected province code to be blank');
            Assert.areEqual(null, eeInsuranceAddress.state, 'Expected state to be blank');
            Assert.areEqual(null, eeInsuranceAddress.zipCode, 'Expected zip code to be blank');
            Assert.areEqual(null, eeInsuranceAddress.zipPlus4, 'Expected plus 4 to be blank');
            Assert.areEqual(null, eeInsuranceAddress.zipcodeDup, 'Expected zip code dup to be blank');
            Assert.areEqual(null, eeInsuranceAddress.addressChangeDateTime, 'Expected change date time to be blank');
            Assert.areEqual(
                null,
                eeInsuranceAddress.addressChangeEffectiveDate,
                'Expected change effective date to be blank'
            );
            Assert.areEqual(null, eeInsuranceAddress.addressChangeSite, 'Expected site to be blank');
            Assert.areEqual(null, eeInsuranceAddress.addressChangeSource, 'Expected source to be blank');
            Assert.areEqual(null, eeInsuranceAddress.addressTypeCode, 'Expected type code to be blank');
            Assert.areEqual(null, eeInsuranceAddress.badAddressReason, 'Expected reason to be blank');
            Assert.areEqual(null, eeInsuranceAddress.endDate, 'Expected end date to be blank');
            Assert.areEqual(null, eeInsuranceAddress.phoneNumber, 'Expected number to be blank');
            Assert.areEqual(null, eeInsuranceAddress.contactMethodType, 'Expected method type to be blank');
            Assert.areEqual(null, eeInsuranceAddress.contactMethodReportDate, 'Expected report date to be blank');
        }
    }

    @IsTest
    private static void eeInsurancePhone() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.EEInsurancePhone eeInsurancePhone = new VCC_MPIParser.EEInsurancePhone();
            Assert.areEqual(null, eeInsurancePhone.phoneNumber, 'Expected number to be blank');
            Assert.areEqual(null, eeInsurancePhone.type, 'Expected type to be blank');
            Assert.areEqual(null, eeInsurancePhone.phoneNumberReportDate, 'Expected report date to be blank');
        }
    }
}
