/**
 * @description helper class to reduce amount of logic in the batch class VCC_BatchMPICorrelate
 * @author Booz Allen
 * @see VCC_BatchMpiCorrelate
 */
public with sharing class VCC_BatchMpiCorrelateHelper {
    /**
     * @description Constant expected year lengths (to differentiate 4 digit vs 2 digit)
     */
    @TestVisible
    static final Integer EXPECTED_YEAR_SIZE = 4;

    /**
     * @description Constant for dash-seperated dates
     */
    @TestVisible
    private static final String DASH_DATE_SEPARATOR = '-';
    /**
     * @description Constant for forward-slash-seperated dates
     */
    @TestVisible
    private static final String FORWARD_SLASH_SEPARATOR = '/';

    /**
     * @description Veteran details value object
     */
    @TestVisible
    private VCC_MPIParser.VetDetails vetDetails;
    /**
     * @description Veteran profile (version 1?) value object
     */
    @TestVisible
    private VCC_MPIParser.VaProfileV1 vaProfileV1;
    /**
     * @description Veteran profile value object
     */
    @TestVisible
    private VCC_MPIParser.VAProfile vaProfile;
    /**
     * @description Veteran identity custom object used throughout
     */
    public VA_Identity__c identityVar = new VA_Identity__c();

    static final String STATUS_COMPLETED = 'Completed';

    /**
     * @description Accounting for v0 & v1 vaProfile structure
     */
    @TestVisible
    List<VCC_MPIParser.VAProfileAddress> addresses;
    /**
     * @description Phone numbers for the given veteran profile
     */
    @TestVisible
    List<VCC_MPIParser.VAProfileTelephone> telephones;

    /**
     * @description Assists in gathering informatkon and metadata for the MPI callout
     * @param helperWrapper an object containing vars and MPI Callout
     * @return ReturnWrapper Straghtforward value/wrapper class that contains MPI callout information
     */
    public ReturnWrapper handleSuccessResponse(HelperWrapper helperWrapper) {
        // Replacing literals with proper values (null vc 'null', true vs 'true' etc. to maintain type and fix reserved word clashes)
        VCC_MPIParser responseData = (VCC_MPIParser) JSON.deserialize(
            helperWrapper.responseBody.replace('"null"', 'null').replace('"true"', 'true').replace('"false"', 'false'), // Swapping "null" string for null literals
            System.Type.forName('VCC_MPIParser')
        );

        this.identityVar = helperWrapper.identityVar;
        HttpRequest mpiServiceRequest = helperWrapper.serviceRequest;
        HttpResponse mpiServiceResponse = helperWrapper.serviceResponse;
        List<Account> accountListToInsert = helperWrapper.accountListToInsert;

        checkResponseDataVersion(responseData);

        // Part 2 - Call the mpiCorrelateWithTraits service
        // Save updates for the end to avoid uncommitted work pending errors

        String mpiEndpoint = VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIeCorrelateWithTraits');
        String jsonSerializedMpiRecord = JSON.serialize(
            new Map<Object, Object>{
                'userId' => 'VA-Vet VAHC CRM Batch Job',
                'icn' => this.identityVar?.Cerner_specific_ICN__c,
                'salesforceId' => this.identityVar?.id,
                'lastName' => this.vetDetails?.mvi?.lastName,
                'firstName' => this.vetDetails?.mvi?.firstName,
                'middleName' => this.vetDetails?.mvi?.middleName,
                'dob' => this.vetDetails?.mvi?.dob,
                'ssn' => this.vetDetails?.mvi?.ssn,
                'mailingStreet' => this.vetDetails?.mvi?.address?.streetAddress,
                'mailingCity' => this.vetDetails?.mvi?.address?.city,
                'mailingStateCode' => this.vetDetails?.mvi?.address?.state,
                'mailingPostalCode' => this.vetDetails?.mvi?.address?.postalCode,
                'mailingCountryCode' => this.vetDetails?.mvi?.address?.country
            }
        );

        String mpiServiceRawResponse = '';
        try {
            mpiServiceRequest.setEndpoint(mpiEndpoint);
            mpiServiceRequest.setBody(jsonSerializedMpiRecord);
            mpiServiceResponse = (new Http()).send(mpiServiceRequest);
            mpiServiceRawResponse = mpiServiceResponse.getBody();
        } catch (CalloutException mpiCalloutException) {
            Logger.info('Service Endpoint: ' + mpiEndpoint);
            Logger.info('Payload: ' + mpiServiceRawResponse);
            Logger.error('Error accessing MPI data: ', mpiCalloutException);
            Logger.saveLog();
        }

        mpiServiceRawResponse = mpiServiceRawResponse.replace('\\', '\\').replace('"null"', 'null'); // Swapping "null" string for null literals

        if (mpiServiceResponse.getStatusCode() != 200) {
            Map<String, Object> responseFieldToValueMap = (Map<String, Object>) JSON.deserializeUntyped(
                mpiServiceRawResponse
            );
            this.identityVar.MPI_Correlation_Status__c = 'Error';
            if (responseFieldToValueMap.containsKey('errorType') && responseFieldToValueMap.containsKey('message')) {
                this.identityVar.MPI_Correlation_Error_Message__c =
                    (String) responseFieldToValueMap.get('errorType') +
                    ': ' +
                    (String) responseFieldToValueMap.get('message');
            }
            this.identityVar.MPI_Correlation_Error_Message_Datetime__c = System.now();
        } else {
            String accountLastName = this.vetDetails?.mvi?.lastName;
            String accountSSN = this.vetDetails?.mvi?.ssn;
            String ssnSearch =
                (accountLastName != null ? accountLastName.substring(0, 1) : '') +
                (accountSSN != null && accountSSN.length() >= 4 ? accountSSN.substring(accountSSN.length() - 4) : '');

            Account accountForInsert = new Account(
                Salutation = this.vetDetails?.mvi?.prefixName,
                PersonTitle = this.vetDetails?.mvi?.prefixName,
                FirstName = this.vetDetails?.mvi?.firstName,
                MiddleName = this.vetDetails?.mvi?.middleName,
                LastName = accountLastName,
                Suffix = this.vetDetails?.mvi?.suffixName,
                HealthCloudGA__TaxId__c = accountSSN,
                SSN_Search__c = ssnSearch,
                RecordTypeId = (new VCR_AccountRepo()).recordTypeConstant.fromDeveloperName('PersonAccount').Id,
                OwnerId = UserInfo.getUserId(),
                VCC_MVI_External_Id__pc = this.vetDetails?.mvi?.icn
            );

            accountForInsert = getGenderForAccount(accountForInsert);

            accountForInsert = setAccountDateOfBirth(accountForInsert);

            String dobFromDetails = this.vetDetails?.mvi?.dob;
            //date of birth
            //Logic for records that come in with only YYYY vs YYYY/MM/DD
            try {
                if (dobFromDetails.length() == 8) {
                    accountForInsert.PersonBirthdate = getDateFormatYYYYMMDD(dobFromDetails, DASH_DATE_SEPARATOR);
                }
            } catch (Exception generalParsingError) {
                Logger.info('DOB: ' + dobFromDetails);
                Logger.error('Error parsing DOB: ', generalParsingError);
                Logger.saveLog();
            }

            //Deceased Date
            try {
                accountForInsert = setDeceasedDateOnAccount(accountForInsert);
            } catch (Exception dateSetException) {
                Logger.error('Error parsing DOD: ', dateSetException);
                Logger.saveLog();
            }

            accountForInsert = VCC_MPIHelper.updateVAProfileFields(accountForInsert, this.vetDetails.vaProfileV1);
            accountForInsert = VCC_MPIHelper.updateESRFields(accountForInsert, this.vetDetails.ee);

            accountListToInsert.add(accountForInsert);

            this.identityVar.MPI_Correlation_Status__c = STATUS_COMPLETED;

            // Update fields based on response from mpiRetrieve (vetRetrive)
            this.identityVar.ICN__c = this.vetDetails?.mvi?.icn;
            this.identityVar.MPI_Person_Type__c = this.vetDetails?.mvi?.personType;
            this.identityVar.First_Name__c = this.vetDetails?.mvi?.firstName;
            this.identityVar.Last_Name__c = this.vetDetails?.mvi?.lastName;
            this.identityVar.Middle_Name__c = this.vetDetails?.mvi?.middleName;
            this.identityVar.Suffix__c = this.vetDetails?.mvi?.suffixName;
            this.identityVar.Mother_s_Maiden_Name__c = this.vetDetails?.mvi?.mothersMaidenName;
            this.identityVar.Place_of_Birth_City__c = this.vetDetails?.mvi?.cityOfBirth;
            this.identityVar.Place_of_Birth_State__c = this.vetDetails.mvi?.stateOfBirth;
            initializeAddressesAndTelephones();
            populateTelephoneFieldsOnVaIdRec();
            populateAddressFieldsOnVaIdRec();
            populateVaIdDateOfBirth();
            this.identityVar.SSN__c = this.vetDetails?.mvi?.ssn;
            this.identityVar.Gender_at_Birth__c = this.vetDetails?.mvi.gender;
            this.identityVar.MPI_Primary_Address_Street_Line_1__c = this.vetDetails?.mvi?.address?.streetAddress;
            this.identityVar.MPI_Primary_Address_City__c = this.vetDetails?.mvi?.address?.city;
            this.identityVar.MPI_Primary_Address_State__c = this.vetDetails?.mvi?.address?.state;
            this.identityVar.MPI_Primary_Address_Postal_Code__c = this.vetDetails?.mvi?.address?.postalCode;
            this.identityVar.MPI_Primary_Address_Country__c = this.vetDetails?.mvi?.address?.country;
            setRegisteredFacility();
        }
        ReturnWrapper returnWrapper = new ReturnWrapper();
        returnWrapper.accountListToInsert = accountListToInsert;
        returnWrapper.identityVar = this.identityVar;
        return returnWrapper;
    }

    /**
     * @description Set the accounts date of display format to the proper localized order (MM/DD/YYYY)
     * @param accountForInsert Account that will have the 'friendly' date updated
     * @return `Account` The account that was modified (this method performs NO data operations)
     */
    private Account setAccountDateOfBirth(Account accountForInsert) {
        try {
            String vetDOB = this.vetDetails?.mvi?.dob;
            if (vetDOB != null && (vetDOB).length() == 8) {
                accountForInsert.Date_of_Birth__pc = getStringUSADateFormatMMDDYYYY(vetDOB, FORWARD_SLASH_SEPARATOR);
            }
        } catch (Exception stringParsingException) {
            Logger.error('Error parsing DOB Text: ', stringParsingException);
            Logger.saveLog();
        }
        return accountForInsert;
    }

    /**
     * @description Retrieve gender friendly-name from abbreviations
     * @param accountForInsert The account to apply the gender to
     * @return `Account` Modified account
     */
    private Account getGenderForAccount(Account accountForInsert) {
        Map<String, String> shortToLongGenderMap = new Map<String, String>{
            'M' => 'Male',
            'F' => 'Female',
            'TF' => 'Transgender Female',
            'FM' => 'Transgender Male',
            'I' => 'Transgender Female',
            'O' => 'Transgender Male'
        };

        String vetGender = this.vetDetails?.mvi?.gender;
        accountForInsert.HealthCloudGA__Gender__pc = shortToLongGenderMap.containsKey(vetGender.toUpperCase())
            ? shortToLongGenderMap.get(vetGender.toUpperCase())
            : vetGender;

        return accountForInsert;
    }

    /**
     * @description Parse the deceased date so that it can be displayed correctly on the account with the right
     * localized format.
     *
     * @param accountForInsert  The account we will be updating and returning after performing the assignment
     * @return `Account`    Updated account
     */
    private Account setDeceasedDateOnAccount(Account accountForInsert) {
        if (this.vetDetails?.mvi?.dod != null && this.vetDetails.mvi.dod.length() == EXPECTED_YEAR_SIZE) {
            final String yearString = this.vetDetails.mvi.dod.substring(0, EXPECTED_YEAR_SIZE);
            accountForInsert.HealthCloudGA__DeceasedDate__pc = Date.valueOf(yearString + '-01-01');
        } else {
            accountForInsert.HealthCloudGA__DeceasedDate__pc = getDateFormatYYYYMMDD(
                this.vetDetails?.mvi?.dod,
                DASH_DATE_SEPARATOR
            );
        }
        return accountForInsert;
    }

    /**
     * @description Set the address compound fields in the VA profile to the appropriate fields in the contact information
     */
    private void initializeAddressesAndTelephones() {
        if (this.vaProfile == null) {
            this.addresses = this.vaProfileV1?.vaProfileContactInfo?.addresses;
            this.telephones = this.vaProfileV1?.vaProfileContactInfo?.telephones;
            if (this.vaProfileV1?.vaProfileContactInfo?.emails != null) {
                this.identityVar.VAP_Email__c = this.vaProfileV1.vaProfileContactInfo.emails[0]?.emailAddressText;
            }
        } else {
            this.addresses = this.vaProfile.addresses;
        }
    }

    /**
     * @description Run throught the different phone types and assign them accordingly to the VA identity record.
     */
    private void populateTelephoneFieldsOnVaIdRec() {
        if (this.telephones != null) {
            for (VCC_MPIParser.VAProfileTelephone profilePhoneNumber : this.telephones) {
                switch on profilePhoneNumber.phoneType.toUpperCase() {
                    when 'MOBILE' {
                        this.identityVar.VAP_Phone_Mobile__c =
                            profilePhoneNumber.areaCode + profilePhoneNumber.phoneNumber;
                    }
                    when 'HOME' {
                        this.identityVar.VAP_Phone_Home__c =
                            profilePhoneNumber.areaCode + profilePhoneNumber.phoneNumber;
                    }
                    when 'WORK' {
                        this.identityVar.VAP_Phone_Work__c =
                            profilePhoneNumber.areaCode + profilePhoneNumber.phoneNumber;
                    }
                    when 'TEMPORARY' {
                        this.identityVar.VAP_Phone_Temporary__c =
                            profilePhoneNumber.areaCode + profilePhoneNumber.phoneNumber;
                    }
                }
            }
        }
    }

    /**
     * @description Retrieve a strongly typed date object from a date formatted as YYYYMMDD. Separator is used for parsing to the date object.
     * @param dateString `String` date in YYYYMMDD format
     * @param separator `String` separator used to parse the supplied date into a date object
     * @return `Date` Resulting date object
     */
    private static Date getDateFormatYYYYMMDD(String dateString, String separator) {
        String yearString = dateString.substring(0, 4);
        String monthString = dateString.substring(4, 6);
        String dayString = dateString.substring(6, 8);
        Date dateResultString = Date.valueOf(yearString + separator + monthString + separator + dayString);
        return (dateResultString);
    }

    /**
     * @description Retrieve a US-formatted date string (month/date/year) from a date formatted as YYYYMMDD
     * @param dateString `String` date in YYYYMMDD format
     * @param separator `String` separator used for the final string output
     * @return `String` Resulting date string formatted as MM/DD/YYYY whrere / is the supplied separator
     */
    private static String getStringUSADateFormatMMDDYYYY(String dateString, String separator) {
        String monthString = dateString.substring(4, 6);
        String dayString = dateString.substring(6, 8);
        String yearString = dateString.substring(0, 4);
        String dateResultString = monthString + separator + dayString + separator + yearString;
        return (dateResultString);
    }

    /**
     * @description checks and populates correct va profile version
     * @param responseData [VCC_MPIParser] parsed response from MPI callout
     */
    private void checkResponseDataVersion(VCC_MPIParser responseData) {
        if (responseData.vetsV1 != null) {
            this.vetDetails = responseData.vetsV1[0];
            this.vaProfileV1 = this.vetDetails.vaProfileV1;
        } else if (responseData.vets != null) {
            this.vetDetails = responseData.vets[0];
            this.vaProfile = this.vetDetails.vaProfile;
        }
    }

    /**
     * @description Set registered facility for the vet details record
     */
    private void setRegisteredFacility() {
        VCC_MPIParser.EE eligibilityEnrollment = this.vetDetails.ee;
        if (eligibilityEnrollment?.eeExtendedResponse?.demographics?.preferredFacility != null) {
            this.identityVar.VCC_Primary_Registered_Facility__c = eligibilityEnrollment.eeExtendedResponse.demographics.preferredFacility;
            if (eligibilityEnrollment?.eeExtendedResponse?.demographics?.preferredFacilities?.size() > 1) {
                this.identityVar.VCC_Secondary_Registered_Facility__c = eligibilityEnrollment.eeExtendedResponse.demographics.preferredFacilities[1]
                    .preferredFacility;
            }
        }
    }

    /**
     * @description Using pattern matching to populate date of birth
     */
    private void populateVaIdDateOfBirth() {
        if (this.vetDetails.mvi.dob != null) {
            if ((this.vetDetails.mvi.dob).length() == 8) {
                Pattern pattern = Pattern.compile('(\\d{4})(\\d{2})(\\d{2})');
                Matcher matcher = pattern.matcher(this.vetDetails.mvi.dob);
                matcher.find();
                Integer year = Integer.valueOf(matcher.group(1)),
                    month = Integer.valueOf(matcher.group(2)),
                    day = Integer.valueOf(matcher.group(3));
                Date myDate = Date.newInstance(year, month, day);
                this.identityVar.Date_of_Birth__c = myDate;
            }
        }
    }

    /**
     * @description Populates address fields on va identity record
     */
    private void populateAddressFieldsOnVaIdRec() {
        if (this.addresses != null) {
            for (VCC_MPIParser.VAProfileAddress address : this.addresses) {
                if (address.addressPurposeOfUse == 'RESIDENCE/CHOICE') {
                    this.identityVar.VAP_Residence_Address_Line_1__c = address.addressLine1;
                    this.identityVar.VAP_Residence_City__c = address.cityName;
                    this.identityVar.VAP_Residence_State__c = address.stateCode;
                    this.identityVar.VAP_Residence_Postal_Code__c = address.zipCode5;
                } else if (address.addressPurposeOfUse == 'CORRESPONDENCE') {
                    this.identityVar.VAP_Corresp_Address_Line_1__c = address.addressLine1;
                    this.identityVar.VAP_Corresp_City__c = address.cityName;
                    this.identityVar.VAP_Corresp_State__c = address.stateCode;
                    this.identityVar.VAP_Corresp_Postal_Code__c = address.zipCode5;
                }
            }
        }
    }

    /**
     * @description wrapper to pass data between the batch class and the helper class
     */
    public class HelperWrapper {
        /**@description responseBody*/
        public String responseBody { get; set; }
        /**@description identityVar*/
        public VA_Identity__c identityVar { get; set; }
        /**@description request*/
        public HttpRequest serviceRequest { get; set; }
        /**@description resp*/
        public HttpResponse serviceResponse { get; set; }
        /**@description accountListToInsert*/
        public List<Account> accountListToInsert { get; set; }

        /**
         * @description HelperWrapper Constructor
         *
         */
        public HelperWrapper() {
            /**
             * @description this.identityVar
             */
            this.identityVar = new VA_Identity__c();
            /**
             * @description this.request
             */
            this.serviceRequest = new HttpRequest();
            /**
             * @description this.resp
             */
            this.serviceResponse = new HttpResponse();
            /**
             * @description this.accountListToInsert
             */
            this.accountListToInsert = new List<Account>();
        }
    }

    /**
     * @description return wrapper class
     *  @author Booz Allen Hamilton
     *  @see VCC_BatchMpiCorrelateHelper
     */
    public class ReturnWrapper {
        /**
         *  @description Identifier from an external system
         **/
        public VA_Identity__c identityVar { get; set; }
        /**
         * @description List of accounts that will be created as a result of the callout
         **/
        public List<Account> accountListToInsert { get; set; }

        /**
         * @description Constructor to ensure property initialization
         * */
        public ReturnWrapper() {
            this.identityVar = new VA_Identity__c();
            this.accountListToInsert = new List<Account>();
        }
    }
}
