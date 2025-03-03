/**
 * @author Booz Allen
 * @date 04/2024
 * @description This class is responsible for handling the E911 Confirm Location processes that captures relevant data
 *
 */
public with sharing class VCC_E911ConfirmLocationController {
    @TestVisible
    private static VCR_E911MetricsRepo memoizedE911MetricsRepo;

    @TestVisible
    private static VCR_ContactRepo memoizedContactRepo;

    /**
     * @description Inits and enforces a single instance of Repo
     */
    @TestVisible
    private static VCR_E911MetricsRepo e911MetricsRepo {
        get {
            if (memoizedE911MetricsRepo == null) {
                memoizedE911MetricsRepo = new VCR_E911MetricsRepo();
            }
            return memoizedE911MetricsRepo;
        }
    }

    /**
     * @description Inits and enforces a single instance of Repo
     */
    @TestVisible
    private static VCR_ContactRepo contactRepo {
        get {
            if (memoizedContactRepo == null) {
                memoizedContactRepo = new VCR_ContactRepo();
            }
            return memoizedContactRepo;
        }
    }

    /**
     * @description Handles process whenever submit action is taking place
     * @param e911RecordId - E911 Metrics Record id
     * @param accountId - Account Id
     * @param serializedAddressInfo - address information as serialized JSON
     * @param nonAddrInfo - location information description that is not an address
     * @return String - success with id or Error with serialized error object
     */
    @AuraEnabled
    public static String handleSubmit(
        String e911RecordId,
        String accountId,
        String serializedAddressInfo,
        String nonAddrInfo
    ) {
        Database.UpsertResult result = handleE911Metrics(e911RecordId, accountId, serializedAddressInfo, nonAddrInfo);
        if (result.isSuccess()) {
            return 'Success ' + result.getId();
        } else {
            return 'Errors: ' + JSON.serialize(result.getErrors());
        }
    }

    /**
     * @description Manages the E911 Metrics retrieval and update for the associated Account Id that is passed in
     * @param e911RecordId - E911 Metrics Record id
     * @param accountId - Account Id
     * @param serializedAddressInfo - serialized address location information that be transfered to the E911 Metrics record
     * @param nonAddrInfo - location information description that is not an address
     * @return Database.UpsertResult - upsert results detailing success or failure.
     */
    @TestVisible
    private static Database.UpsertResult handleE911Metrics(
        String e911RecordId,
        String accountId,
        String serializedAddressInfo,
        String nonAddrInfo
    ) {
        VCC_e911_Metrics__c currentE911Metrics;
        String associatedContactId;
        if (e911RecordId != null) {
            currentE911Metrics = (VCC_e911_Metrics__c) e911MetricsRepo.fetchById(e911RecordId);
        } else {
            associatedContactId = getContactIdFromAccountId(accountId);
            currentE911Metrics = getActiveE911MetricsRecord(associatedContactId);
        }

        if (currentE911Metrics == null) {
            currentE911Metrics = new VCC_e911_Metrics__c();
            currentE911Metrics.VCC_Patient_Account__c = associatedContactId;
        }
        setE911MetricsData(currentE911Metrics, serializedAddressInfo, nonAddrInfo);
        return e911MetricsRepo.doUpsert(currentE911Metrics);
    }

    /**
     * @description Updates the E911 Metric record with non address text or  address information depending on what is available
     * @param metricsRecord - Record to be updated
     * @param serializedAddressInfo - serialized address location information that be transfered to the E911 Metrics record
     * @param nonAddrInfo - location information description that is not an address
     */
    @TestVisible
    private static void setE911MetricsData(
        VCC_e911_Metrics__c metricsRecord,
        String serializedAddressInfo,
        String nonAddrInfo
    ) {
        if (nonAddrInfo != null) {
            metricsRecord.VCC_Non_Address__c = nonAddrInfo;
            //ensure that address info is not set if non address info is present
            metricsRecord.VCC_Street__c = '';
            metricsRecord.VCC_City__c = '';
            metricsRecord.VCC_State__c = '';
            metricsRecord.VCC_Country__c = '';
            metricsRecord.VCC_Zip_Code__c = '';
        } else if (serializedAddressInfo != null) {
            ConfirmLocationAddress addressInfo = (ConfirmLocationAddress) JSON.deserialize(
                serializedAddressInfo,
                ConfirmLocationAddress.class
            );

            metricsRecord.VCC_Street__c = addressInfo.street;
            metricsRecord.VCC_City__c = addressInfo.city;
            metricsRecord.VCC_State__c = addressInfo.state;
            metricsRecord.VCC_Country__c = addressInfo.country;
            metricsRecord.VCC_Zip_Code__c = addressInfo.zipCode;

            //ensure that the non address text field is not populated
            metricsRecord.VCC_Non_Address__c = '';
        }
    }

    /**
     * @description Retrieves the Contact Id that is associated directly with the Account Id
     * @param accountId - Account Id
     * @return Contact Id as a string
     */
    @TestVisible
    private static String getContactIdFromAccountId(String accountId) {
        List<Contact> contactList = contactRepo.getContactFromAccountId(accountId);
        return contactList[0].Id;
    }

    /**
     * @description Retrieves an active/unexecuted E911 Metrics record that corresponds with a Contact Id
     * @param contactId - Contact Id for the respective Account Id
     * @return VCC_e911_Metrics__c - retrieves the active E911 record if ther is one, otherwise null
     */
    @TestVisible
    private static VCC_e911_Metrics__c getActiveE911MetricsRecord(String contactId) {
        List<VCC_e911_Metrics__c> e911MetricsRecord = e911MetricsRepo.getE911MetricsByContactId(contactId);
        if (e911MetricsRecord.size() == 1) {
            return e911MetricsRecord[0];
        }
        return null;
    }

    /**
     * @description Private class to describe the incoming address object that reflects what was in the respective JS component
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    @TestVisible
    private class ConfirmLocationAddress {
        /**
         * @description street of address
         */
        public String street { get; set; }
        /**
         * @description city of address
         */
        public String city { get; set; }
        /**
         * @description state of address
         */
        public String state { get; set; }
        /**
         * @description country of address
         */
        public String country { get; set; }
        /**
         * @description zip code of address
         */
        public String zipCode { get; set; }
    }
}
