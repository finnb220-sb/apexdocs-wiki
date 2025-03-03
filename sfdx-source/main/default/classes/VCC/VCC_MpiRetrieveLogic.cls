/**
 * @description Helper class for VCC_MpiRetrieveBatch
 * @author Jakob Orkin (Booz Allen Hamilton)
 * @since 10/11/2024
 * @modified October 17, 2024
 */
public with sharing class VCC_MpiRetrieveLogic {
    @TestVisible
    private String requesterDefaultValue = System.Label.vccMpiCorrelationRequesterDefault;
    @TestVisible
    private String requesterUserDefaultValue = 'VA-Vet VAHC CRM Batch Job';

    /**
     * @description populates MPI_Correlation_Requester__c on the VA_Identity__c record
     * @param vaIdRecord  VA_Identity__c record to update
     * @param identityVar VA_Identity__c record to get the values from
     */
    public void modifyVaIdentityRecordForUpdate(VA_Identity__c vaIdRecord, VA_Identity__c identityVar) {
        if (String.isNotBlank(identityVar.MPI_Correlation_Requester__c)) {
            vaIdRecord.MPI_Correlation_Requester__c = identityVar.MPI_Correlation_Requester__c;
        } else {
            vaIdRecord.MPI_Correlation_Requester__c = requesterDefaultValue;
        }
        if (String.isNotBlank(identityVar.MPI_Correlation_Requester_User__c)) {
            vaIdRecord.MPI_Correlation_Requester_User__c = identityVar.MPI_Correlation_Requester_User__c;
        } else {
            vaIdRecord.MPI_Correlation_Requester_User__c = requesterUserDefaultValue;
        }
    }

    /**
     * @description populate the address and telephone data mappings
     * @param identityVar VA_Identity__c record to update
     * @param vaProfileV1 data mapping for va profile v1
     * @param vaProfile  data mapping for va profile
     */
    public void modifyVaIdentityRecordForUpdate(
        VA_Identity__c identityVar,
        VCC_MPIParser.VaProfileV1 vaProfileV1,
        VCC_MPIParser.VAProfile vaProfile
    ) {
        if (vaProfile == null) {
            if (vaProfileV1?.vaProfileContactInfo?.emails != null) {
                identityVar.VAP_Email__c = vaProfileV1?.vaProfileContactInfo?.emails[0]?.emailAddressText;
            }
        }

        //  v0 & v1 vaProfile structure for address and telephone
        List<VCC_MPIParser.VAProfileAddress> addresses;
        List<VCC_MPIParser.VAProfileTelephone> telephones;
        if (vaProfile == null) {
            addresses = vaProfileV1?.vaProfileContactInfo?.addresses;
            telephones = vaProfileV1?.vaProfileContactInfo?.telephones;
        } else {
            addresses = vaProfile?.addresses;
        }
        if (addresses != null) {
            for (VCC_MPIParser.VAProfileAddress address : addresses) {
                identityVar = populateIdentityVarAddress(identityVar, address);
            }
        }

        if (telephones != null) {
            for (VCC_MPIParser.VAProfileTelephone tele : telephones) {
                identityVar = populateIdentityVarTelephone(identityVar, tele);
            }
        }
    }

    /**
     * @description populate fields on VA_Identity__c from MPI callout
     * @param identityVar VA_Identity__c record to update
     * @param vetDetails veteran information from MPI Callout
     */
    public void modifyVaIdentityRecordForUpdate(VA_Identity__c identityVar, VCC_MPIParser.VetDetails vetDetails) {
        if (vetDetails?.mvi != null) {
            identityVar.ICN__c = vetDetails.mvi.icn;
            identityVar.MPI_Person_Type__c = vetDetails.mvi.personType;
            identityVar.First_Name__c = vetDetails.mvi.firstName;
            identityVar.Last_Name__c = vetDetails.mvi.lastName;
            identityVar.Middle_Name__c = vetDetails.mvi.middleName;
            identityVar.Suffix__c = vetDetails.mvi.suffixName;
            identityVar.Mother_s_Maiden_Name__c = vetDetails.mvi.mothersMaidenName;
            identityVar.Place_of_Birth_City__c = vetDetails.mvi.cityOfBirth;
            identityVar.Place_of_Birth_State__c = vetDetails.mvi.stateOfBirth;

            if (vetDetails.mvi.dob != null) {
                if ((vetDetails?.mvi?.dob).length() == 8) {
                    Pattern myPattern = Pattern.compile('(\\d{4})(\\d{2})(\\d{2})');
                    Matcher myMatcher = myPattern.matcher(vetDetails.mvi.dob);
                    myMatcher.find();
                    Integer year = Integer.valueOf(myMatcher.group(1)),
                        month = Integer.valueOf(myMatcher.group(2)),
                        day = Integer.valueOf(myMatcher.group(3));
                    Date myDate = Date.newInstance(year, month, day);
                    identityVar.Date_of_Birth__c = myDate;
                }
            }

            identityVar.SSN__c = vetDetails.mvi.ssn;
            identityVar.Gender_at_Birth__c = vetDetails.mvi.gender;
            identityVar.MPI_Primary_Address_Street_Line_1__c = vetDetails.mvi.address.streetAddress;
            identityVar.MPI_Primary_Address_City__c = vetDetails.mvi.address.city;
            identityVar.MPI_Primary_Address_State__c = vetDetails.mvi.address.state;
            identityVar.MPI_Primary_Address_Postal_Code__c = vetDetails.mvi.address.postalCode;
            identityVar.MPI_Primary_Address_Country__c = vetDetails.mvi.address.country;

            VCC_MPIParser.EE eligibilityEnrollment = vetDetails.ee;
            if (eligibilityEnrollment?.eeExtendedResponse?.demographics?.preferredFacility != null) {
                identityVar.VCC_Primary_Registered_Facility__c = eligibilityEnrollment.eeExtendedResponse.demographics.preferredFacility;
                if (eligibilityEnrollment?.eeExtendedResponse?.demographics?.preferredFacilities?.size() > 1) {
                    identityVar.VCC_Secondary_Registered_Facility__c = eligibilityEnrollment.eeExtendedResponse.demographics.preferredFacilities[1]
                        .preferredFacility;
                }
            }
        }
    }

    /**
     * @description map data coming from MPI Callout
     * @param responseBody the response body from the MPI callout
     * @return VCC_MPIParser.vetDetails the details from the MPI callout
     */
    public VCC_MPIParser.VetDetails extractVetDetails(String responseBody) {
        VCC_MPIParser responseData = (VCC_MPIParser) JSON.deserialize(
            responseBody.replace('"null"', 'null').replace('"true"', 'true').replace('"false"', 'false'),
            System.Type.forName('VCC_MPIParser')
        );
        if (responseData.vetsV1 != null) {
            return responseData.vetsV1[0];
        } else if (responseData.vets != null) {
            return responseData.vets[0];
        }
        return null;
    }

    /**
     * @description populate address fields on identityVar
     * @param identityVar the VA_Identity__c record to update
     * @param address data mapping of the address info
     * @return VA_Identity__c record
     */
    public VA_Identity__c populateIdentityVarAddress(
        VA_Identity__c identityVar,
        VCC_MPIParser.VAProfileAddress address
    ) {
        if (address.addressPurposeOfUse == 'RESIDENCE/CHOICE') {
            identityVar.VAP_Residence_Address_Line_1__c = address.addressLine1;
            identityVar.VAP_Residence_City__c = address.cityName;
            identityVar.VAP_Residence_State__c = address.stateCode;
            identityVar.VAP_Residence_Postal_Code__c = address.zipCode5;
        } else if (address.addressPurposeOfUse == 'CORRESPONDENCE') {
            identityVar.VAP_Corresp_Address_Line_1__c = address.addressLine1;
            identityVar.VAP_Corresp_City__c = address.cityName;
            identityVar.VAP_Corresp_State__c = address.stateCode;
            identityVar.VAP_Corresp_Postal_Code__c = address.zipCode5;
        }
        return identityVar;
    }

    /**
     * @description populate telephone fields on VA_Identity__c from MPI Callout
     * @param identityVar VA_Identity__c to be updated
     * @param tele data mapping of the telephone info
     * @return VA_Identity__c record
     */
    public VA_Identity__c populateIdentityVarTelephone(
        VA_Identity__c identityVar,
        VCC_MPIParser.VAProfileTelephone tele
    ) {
        if (tele != null) {
            switch on tele.phoneType {
                when 'MOBILE' {
                    identityVar.VAP_Phone_Mobile__c = tele.areaCode + tele.phoneNumber;
                }
                when 'HOME' {
                    identityVar.VAP_Phone_Home__c = tele.areaCode + tele.phoneNumber;
                }
                when 'WORK' {
                    identityVar.VAP_Phone_Work__c = tele.areaCode + tele.phoneNumber;
                }
                when 'TEMPORARY' {
                    identityVar.VAP_Phone_Temporary__c = tele.areaCode + tele.phoneNumber;
                }
            }
        }
        return identityVar;
    }

    /**
     * @description update HealthCloudGA__Gender__pc field on Account
     * @param accountForInsert the Account record
     * @param vetDetails data mapping from the MPI Callout of veteran information
     * @return Account record for insert
     */
    public Account updateGender(Account accountForInsert, VCC_MPIParser.VetDetails vetDetails) {
        switch on vetDetails?.mvi?.gender {
            when 'M', 'Male' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Male';
            }
            when 'F', 'Female' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Female';
            }
            when 'TM' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Transgender Male';
            }
            when 'TF' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Transgender Female';
            }
            when 'O', 'Other' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Other';
            }
            when 'I' {
                accountForInsert.HealthCloudGA__Gender__pc = 'Non-Binary';
            }
            when null {
                accountForInsert.HealthCloudGA__Gender__pc = null;
            }
            when else {
                accountForInsert.HealthCloudGA__Gender__pc = vetDetails?.mvi?.gender;
            }
        }
        return accountForInsert;
    }

    /**
     * @description updates text field Date_of_Birth__pc on the Account
     * @param accountForInsert the account record
     * @param vetDetails veteran information from MPI Callout
     * @return Account record
     */
    public Account updateDateOfBirth(Account accountForInsert, VCC_MPIParser.VetDetails vetDetails) {
        try {
            String dateOfBirth = vetDetails?.mvi?.dob;
            String dateOfBirthYear = dateOfBirth.substring(0, 4);
            String dateOfBirthMonth = dateOfBirth.substring(4, 6);
            String dateOfBirthDay = dateOfBirth.substring(6, 8);
            if (dateOfBirth != null && (dateOfBirth).length() == 8) {
                accountForInsert.Date_of_Birth__pc = dateOfBirthMonth + '/' + dateOfBirthDay + '/' + dateOfBirthYear;
            }
        } catch (Exception e) {
            Logger.error('Error parsing DOB Text.', e);
        }
        return accountForInsert;
    }

    /**
     * @description updates date field PersonBirthdate on the Account
     * @param accountForInsert the account record
     * @param vetDetails veteran information from MPI Callout
     * @return Account record
     */
    public Account updateDateOfBirthText(Account accountForInsert, VCC_MPIParser.VetDetails vetDetails) {
        //Logic for records that come in with only YYYY vs YYYYMMDD
        try {
            String dateOfBirth = vetDetails?.mvi?.dob;
            String dateOfBirthYear = dateOfBirth.substring(0, 4);
            String dateOfBirthMonth = dateOfBirth.substring(4, 6);
            String dateOfBirthDay = dateOfBirth.substring(6, 8);
            if (dateOfBirth != null && (dateOfBirth).length() == 8) {
                accountForInsert.PersonBirthdate = Date.valueOf(
                    dateOfBirthYear + '-' + dateOfBirthMonth + '-' + dateOfBirthDay
                );
            }
        } catch (Exception e) {
            Logger.error('Error parsing DOB.', e);
        }
        return accountForInsert;
    }

    /**
     * @description updates date field HealthCloudGA__DeceasedDate__pc on the Account
     * @param accountForInsert the account record
     * @param vetDetails veteran information from MPI Callout
     * @return Account record
     */
    public Account updateDateOfDeath(Account accountForInsert, VCC_MPIParser.VetDetails vetDetails) {
        //Deceased Date
        try {
            String dateOfDeath = vetDetails?.mvi?.dod;
            String dateOfDeathYear = vetDetails?.mvi?.dod.substring(0, 4);
            if (dateOfDeath != null && (dateOfDeath).length() <= 4) {
                accountForInsert.HealthCloudGA__DeceasedDate__pc = Date.valueOf(dateOfDeathYear + '-01-01');
            } else {
                String dateOfDeathMonth = dateOfDeath?.substring(4, 6);
                String dateOfDeathDay = vetDetails?.mvi?.dod.substring(6, 8);
                accountForInsert.HealthCloudGA__DeceasedDate__pc = Date.valueOf(
                    dateOfDeathYear + '-' + dateOfDeathMonth + '-' + dateOfDeathDay
                );
            }
        } catch (Exception e) {
            Logger.error('Error parsing DOD.', e);
        }
        return accountForInsert;
    }
}
