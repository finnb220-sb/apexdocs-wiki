// TODO: Bulkify
/**
 * @description Helper for various MPI-related needs.
 * @group API - MPI
 * @author Various VAHC Devs.
 * @since 6/30/2021
 *
 * @author Patrick Skamarak
 * @since 02/08/2024 CCCM-29964
 **/
public with sharing class VCC_MPIHelper {
    /**
     * @description Exception extender method
     */
    private class VAHCException extends Exception {
    }

    /**
     * @description updateESRFields
     * @param account Current account
     * @param esrDetails Detailed returned from callout
     * @return Account
     **/
    public static Account updateESRFields(Account account, VCC_MPIParser.EE esrDetails) {
        setPrimaryFacility(account, esrDetails);
        setEnrolled(account, esrDetails);
        setContacts(account, esrDetails);
        return account;
    }

    /**
     * @description setPrimaryFacility
     * @param account
     * @param esrDetails
     * @return Nothing
     **/
    private static void setPrimaryFacility(Account account, VCC_MPIParser.EE esrDetails) {
        if (String.isNotBlank(esrDetails?.eeExtendedResponse?.demographics?.preferredFacility)) {
            account.VCC_Primary_Facility__c = esrDetails.eeExtendedResponse?.demographics?.preferredFacility;
        }
    }

    /**
     * @description setEnrolled
     * @param account
     * @param esrDetails
     * @return Nothing
     **/
    @TestVisible
    private static void setEnrolled(Account account, VCC_MPIParser.EE esrDetails) {
        if (esrDetails?.eeExtendedResponse?.enrollmentDetermination?.enrollmentStatus == 'Enrolled') {
            account.VCC_Enrolled__pc = true;
        }
    }

    /**
     * @description setContacts
     * @param account
     * @param esrDetails
     * @return Nothing
     */
    private static void setContacts(Account account, VCC_MPIParser.EE esrDetails) {
        if (
            esrDetails?.eeExtendedResponse?.associations != null &&
            esrDetails.eeExtendedResponse.associations.size() > 0
        ) {
            for (VCC_MPIParser.EEAssociation association : esrDetails.eeExtendedResponse.associations) {
                setContact(account, association);
            }
        }
    }

    /**
     * @description setContact
     * @param account
     * @param association
     * @return Nothing
     **/
    private static void setContact(Account account, VCC_MPIParser.EEAssociation association) {
        switch on association.contactType {
            when 'Primary Next of Kin' {
                account.VCC_Next_of_Kin__pc = association.givenName + ' ' + association.familyName;
                account.VCC_Next_of_Kin_Phone__pc = association.primaryPhone;
            }
            when 'Emergency Contact' {
                account.VCC_Emergency_Contact__pc = association.givenName + ' ' + association.familyName;
                account.VCC_Emergency_Contact_Phone__pc = association.primaryPhone;
            }
            when 'Primary Caregiver' {
                account.VCC_Primary_Caregiver__pc = association.givenName + ' ' + association.familyName;
                account.VCC_Primary_Caregiver_Phone__pc = association.primaryPhone;
            }
        }
    }

    @TestVisible
    private static final String NULL_ARG_MESSAGE = 'One of two required args are null';

    /**
     * @deprecated after 1.9.0 do not use this method without checking with Lisa M. or Patrick S. we are meant to start using the MPI package provided by DTC. This method was made as a (probably) one-time exception.
     * @description if the account First/Middle/LastName fields differ from first/middle/lastName from MPI, update it
     * @param accountId `Account` Id, in string form, of the account to update
     * @param mviData `VCC_MPIParser.MPI` data from MPI from which the name data comes
     */
    public static void updateAccountNameFromMpi(String accountId, VCC_MPIParser.MVI mviData) {
        if (String.isBlank(accountId) || mviData == null) {
            throw new UpdatePatientNameException(NULL_ARG_MESSAGE);
        }
        Account accountForUpdate = [
            SELECT FirstName, MiddleName, LastName
            FROM Account
            WHERE Id = :accountId
            WITH USER_MODE
            LIMIT 1
        ];
        Boolean needsUpdate = false;
        if (!String.isBlank(mviData.firstName) && !mviData.firstName.equalsIgnoreCase(accountForUpdate.Firstname)) {
            accountForUpdate.FirstName = mviData.firstName;
            needsUpdate = true;
        }
        if (!String.isBlank(mviData.middleName) && !mviData.middleName.equalsIgnoreCase(accountForUpdate.MiddleName)) {
            accountForUpdate.MiddleName = mviData.middleName;
            needsUpdate = true;
        }
        if (!String.isBlank(mviData.lastName) && !mviData.lastName.equalsIgnoreCase(accountForUpdate.LastName)) {
            accountForUpdate.LastName = mviData.lastName;
            needsUpdate = true;
        }
        if (needsUpdate == true) {
            Database.update(accountForUpdate, AccessLevel.USER_MODE);
        }
    }

    public class UpdatePatientNameException extends Exception {
    }

    /**
     * @description Performs update on ESR.
     * @param recordId
     * @param esrDetails
     * @return Nothing
     */
    public static void updateESR(String recordId, VCC_MPIParser.EE esrDetails) {
        Account acct = new Account(Id = (Id) recordId);

        try {
            if (Account.getSObjectType().getDescribe(SObjectDescribeOptions.FULL).isUpdateable() == true) {
                update (updateESRFields(acct, esrDetails));
            }
        } catch (Exception e) {
            Log.debug(e.getStackTraceString());
        }
    }

    /**
     * @description Loads Facility Names into the Facility Map.
     * @param facilityList
     * @return Nothing
     */
    public static void getFacilityNames(List<VCC_MPIParser.MedicalCenterFacility> facilityList) {
        Map<String, VCC_MPIParser.MedicalCenterFacility> facilityIdToFacilityMap = new Map<String, VCC_MPIParser.MedicalCenterFacility>();
        VCR_LocationRepo locationRepo = new VCR_LocationRepo();
        for (VCC_MPIParser.MedicalCenterFacility facility : facilityList) {
            facilityIdToFacilityMap.put('vha_' + facility.facilityId, facility);
        }
        for (Schema.Location eachLocation : locationRepo.fetchLocationsByExternalId(facilityIdToFacilityMap.keySet())) {
            facilityIdToFacilityMap.get((String) eachLocation.VAF_Facility_ID__c).facilityName = String.isNotBlank(
                    eachLocation.Common_Name__c
                )
                ? eachLocation.Common_Name__c
                : eachLocation.Name;
        }
    }

    /**
     * @description Generates MPI body
     * @param icn the ICN of the patient whose MPI data you want
     * @param datasets the datasets you want in the MPI vetRetrieveResponse
     * additional datasets are BGS and EE, eg.: "datasets": ["BGS", "VA_PROFILE", "EE"]
     * @return String that acts as a body for the MPI callout
     */
    public static String generateMPIBody(String icn, Set<String> datasets) {
        return '{' +
            String.format(
                '"userId": "VA-Vet VAHC CRM Batch Job",' +
                    '"id": "{0}",' +
                    '"idType": "ICN",' +
                    '"unattended": true,' +
                    '"showCorrelated": false,' +
                    '"datasets": [{1}]',
                new List<String>{ icn, datasets.toString() }
            ) +
            '}';
    }

    /**
     * @description update VA Profile Fields
     * @param account
     * @param vaProfileData
     * @return Account
     */
    public static Account updateVAProfileFields(Account account, VCC_MPIParser.VaProfileV2 vaProfileData) {
        setEmail(account, vaProfileData);
        setPhone(account, vaProfileData);
        List<VCC_MPIParser.VAProfileAddress> addresses = vaProfileData?.vaProfileContactInfo?.addresses == null
            ? new List<VCC_MPIParser.VAProfileAddress>()
            : vaProfileData?.vaProfileContactInfo?.addresses;
        setAddress(account, addresses);
        return account;
    }

    /**
     * @description update VA Profile Fields
     * @param account
     * @param vaProfileData
     * @return Account
     */
    public static Account updateVAProfileFields(Account account, VCC_MPIParser.VaProfileV1 vaProfileData) {
        setEmail(account, vaProfileData);
        setPhone(account, vaProfileData);
        List<VCC_MPIParser.VAProfileAddress> addresses = vaProfileData?.vaProfileContactInfo?.addresses == null
            ? new List<VCC_MPIParser.VAProfileAddress>()
            : vaProfileData?.vaProfileContactInfo?.addresses;
        setAddress(account, addresses);
        return account;
    }

    /**
     * @description Updates (no DML, in memory only at this point) the given Account
     * SObject PersonEmail field with the *first* value in the provided VaProfileV2 object
     * property/attribute emailAddressText
     * @param account The Account whose PersonEmail field is to be modified
     * @param vaProfileData the `VCC_MPIParser.VaProfileV2` object which contains an email to update the Account with
     */
    private static void setEmail(Account account, VCC_MPIParser.VaProfileV2 vaProfileData) {
        if (
            vaProfileData?.vaProfileContactInfo?.emails != null &&
            vaProfileData?.vaProfileContactInfo?.emails.size() >= 1
        ) {
            account.PersonEmail = vaProfileData?.vaProfileContactInfo?.emails[0]?.emailAddressText;
        }
    }

    /**
     * @description setEmail
     * @param account
     * @param vaProfileData
     * @return Nothing
     */
    private static void setEmail(Account account, VCC_MPIParser.VaProfileV1 vaProfileData) {
        if (vaProfileData?.vaProfileContactInfo?.emails != null) {
            System.assert(vaProfileData?.vaProfileContactInfo?.emails.size() == 1, 'Expected only one email.');
            account.PersonEmail = vaProfileData?.vaProfileContactInfo?.emails[0]?.emailAddressText;
        }
    }

    /**
     * @description setPhone
     * @param account
     * @param vaProfileData
     * @return Nothing
     */
    private static void setPhone(Account account, VCC_MPIParser.VaProfileV2 vaProfileData) {
        if (vaProfileData?.vaProfileContactInfo?.telephones != null) {
            for (VCC_MPIParser.VAProfileTelephone telephone : vaProfileData.vaProfileContactInfo.telephones) {
                switch on telephone.phoneType {
                    when 'MOBILE' {
                        account.PersonMobilePhone = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'HOME' {
                        account.Phone = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'WORK' {
                        account.VCC_Work_Phone__pc = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'TEMPORARY' {
                        account.VCC_Temp_Phone__pc = telephone.areaCode + telephone.phoneNumber;
                    }
                }
            }
        }
    }

    /**
     * @description setPhone
     * @param account
     * @param vaProfileData
     * @return Nothing
     */
    private static void setPhone(Account account, VCC_MPIParser.VaProfileV1 vaProfileData) {
        if (vaProfileData?.vaProfileContactInfo?.telephones != null) {
            for (VCC_MPIParser.VAProfileTelephone telephone : vaProfileData.vaProfileContactInfo.telephones) {
                switch on telephone.phoneType {
                    when 'MOBILE' {
                        account.PersonMobilePhone = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'HOME' {
                        account.Phone = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'WORK' {
                        account.VCC_Work_Phone__pc = telephone.areaCode + telephone.phoneNumber;
                    }
                    when 'TEMPORARY' {
                        account.VCC_Temp_Phone__pc = telephone.areaCode + telephone.phoneNumber;
                    }
                }
            }
        }
    }

    /**
     * @description setAddress
     * @param account
     * @param addresses
     * @return Nothing
     */
    private static void setAddress(Account account, List<VCC_MPIParser.VAProfileAddress> addresses) {
        for (VCC_MPIParser.VAProfileAddress address : addresses) {
            switch on address.addressPurposeOfUse {
                when 'RESIDENCE' {
                    setBillingAddress(account, address);
                }
                when 'CORRESPONDENCE' {
                    setPersonAddress(account, address);
                }
            }
        }
    }

    /**
     * @description  setBillingAddress
     * @param account
     * @param address
     * @return Nothing
     */
    private static void setBillingAddress(Account account, VCC_MPIParser.VAProfileAddress address) {
        account.BillingStreet =
            (address.addressLine1 != null ? address.addressLine1 : '') +
            (address.addressLine2 != null ? '\n' + address.addressLine2 : '') +
            (address.addressLine3 != null ? '\n' + address.addressLine3 : '');
        account.BillingPostalCode = address.zipCode5;
        account.BillingCity = address.cityName;
        account.BillingState = address.stateCode;
        account.BillingCountry = address.countryName;
    }

    /**
     * @description setPersonAddress
     * @param account
     * @param address
     * @return Nothing
     */
    private static void setPersonAddress(Account account, VCC_MPIParser.VAProfileAddress address) {
        account.PersonMailingStreet =
            (address.addressLine1 != null ? address.addressLine1 : '') +
            (address.addressLine2 != null ? '\n' + address.addressLine2 : '') +
            (address.addressLine3 != null ? '\n' + address.addressLine3 : '');
        account.PersonMailingPostalCode = address.zipCode5;
        account.PersonMailingCity = address.cityName;
        account.PersonMailingState = address.stateCode;
        account.PersonMailingCountry = address.countryName;
    }

    /**
     * @description Updates the VA Profile.
     * @param recordId
     * @param vaProfileData
     * @return Nothing
     */
    public static void updateVAProfile(String recordId, VCC_MPIParser.VaProfileV2 vaProfileData) {
        Account acct = [
            SELECT
                Id,
                PersonMailingStreet,
                PersonMailingState,
                PersonMailingPostalCode,
                PersonMailingCity,
                PersonMailingCountry,
                BillingStreet,
                BillingState,
                BillingPostalCode,
                BillingCity,
                BillingCountry
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (acct.Id == null) {
            return;
        }

        if (Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable() == true) {
            update (updateVAProfileFields(acct, vaProfileData));
        }
    }

    /**
     * @description Updates the VA Profile.
     * @param recordId
     * @param vaProfileData
     * @return Nothing
     */
    public static void updateVAProfile(String recordId, VCC_MPIParser.VaProfileV1 vaProfileData) {
        Account acct = [
            SELECT
                Id,
                PersonMailingStreet,
                PersonMailingState,
                PersonMailingPostalCode,
                PersonMailingCity,
                PersonMailingCountry,
                BillingStreet,
                BillingState,
                BillingPostalCode,
                BillingCity,
                BillingCountry
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (acct.Id == null) {
            return;
        }

        if (Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable() == true) {
            update (updateVAProfileFields(acct, vaProfileData));
        }
    }

    /**
     * @description Fetches Patient Params related to the Account.
     * @param recordId
     *
     * @return Map<Id, Map<String, String>>
     */
    public static Map<Id, Map<String, String>> getPatientParameters(String recordId) {
        List<Account> accounts = [
            SELECT Id, Name, PersonContactId, VCC_MVI_External_Id__pc, (SELECT Id FROM VA_Identity__pr)
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<VA_Identity__c> vaids = [
            SELECT Id, Salesforce_Contact_Id__c
            FROM VA_Identity__c
            WHERE Salesforce_Contact_Id__c = :accounts[0].PersonContactId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        return new Map<Id, Map<String, String>>{
            recordId => new Map<String, String>{
                'icn' => accounts[0].VCC_MVI_External_Id__pc,
                'vaid' => accounts[0]?.VA_Identity__pr.size() > 0 ? vaids[0]?.id : null
            }
        };
    }
}
