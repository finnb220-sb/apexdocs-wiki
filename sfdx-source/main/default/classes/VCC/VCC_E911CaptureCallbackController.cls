/**
 * @description VCC_E911CaptureCallbackController Class
 * This class is responsible for capturing the Callback Number for an e911 call.
 * It also updates fields on the e911 record
 */
@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_E911CaptureCallbackController {
    @TestVisible
    private static final String RECORD_TYPE_HOME = 'Home';
    @TestVisible
    private static final String SUCCESS_MESSAGE = 'Success';
    @TestVisible
    private static final String SURFACED_ON_INVALID_OBJECT_ERROR = 'ERROR: This component is not on a Case, Progress Note, Account, or Home Page';
    @TestVisible
    private static final String UPSERT_FAILED_ERROR = 'ERROR: Saving the records failed';

    @TestVisible
    private static VCR_CaseRepo memoizedCaseRepo;

    @TestVisible
    private static VCR_ProgressNoteRepo memoizedProgressNoteRepo;

    @TestVisible
    private static VCR_AccountRepo memoizedAccountRepo;

    @TestVisible
    private static VCR_ContactRepo memoizedContactRepo;

    @TestVisible
    private static VCR_E911MetricsRepo memoizedE911MetricsRepo;

    @TestVisible
    private static VCR_bsConfigurationsAssignedUserRepo memoizedBSConfigRepo;

    @TestVisible
    /**
     * @description the Case repo
     * @return returns the memoized repo
     */
    private static VCR_CaseRepo caseRepo {
        get {
            if (memoizedCaseRepo == null) {
                memoizedCaseRepo = new VCR_CaseRepo();
            }
            return memoizedCaseRepo;
        }
    }

    @TestVisible
    /**
     * @description the Progress Note repo
     * @return returns the memoized repo
     */
    private static VCR_ProgressNoteRepo pnRepo {
        get {
            if (memoizedProgressNoteRepo == null) {
                memoizedProgressNoteRepo = new VCR_ProgressNoteRepo();
            }
            return memoizedProgressNoteRepo;
        }
    }

    /**
     * @description the account repo
     * @return returns the memoized repo
     */
    public static VCR_AccountRepo accountRepo {
        get {
            if (memoizedAccountRepo == null) {
                memoizedAccountRepo = new VCR_AccountRepo();
            }
            return memoizedAccountRepo;
        }
    }

    /**
     * @description the contact repo
     * @return returns the memoized repo
     */
    public static VCR_ContactRepo contactRepo {
        get {
            if (memoizedContactRepo == null) {
                memoizedContactRepo = new VCR_ContactRepo();
            }
            return memoizedContactRepo;
        }
    }

    /**
     * @description the e911 metrics repo
     * @return returns the memoized repo
     */
    private static VCR_E911MetricsRepo e911MetricsRepo {
        get {
            if (memoizedE911MetricsRepo == null) {
                memoizedE911MetricsRepo = new VCR_E911MetricsRepo();
            }
            return memoizedE911MetricsRepo;
        }
    }

    /**
     * @description the VCR_bsConfigurationsAssignedUserRepo repo
     * @return returns the memoized repo
     */
    public static VCR_bsConfigurationsAssignedUserRepo bsCAURepo {
        get {
            if (memoizedBSConfigRepo == null) {
                memoizedBSConfigRepo = new VCR_bsConfigurationsAssignedUserRepo();
            }
            return memoizedBSConfigRepo;
        }
    }

    /**
     * @description This method gets the value of the Allow_BS_Callout__c field of the e911BS_Setting__c custom setting
     * @return returns a boolean equal to the value of the custom setting
     */
    @AuraEnabled
    public static Boolean getCustomSettingsValue() {
        VAHC_E911_Settings__c e911Setting = VAHC_E911_Settings__c.getOrgDefaults();
        return e911Setting.Allow_BS_Callout__c;
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
    private static VCC_e911_Metrics__c getE911MetricsRecord(String contactId) {
        List<VCC_e911_Metrics__c> e911MetricsRecord = e911MetricsRepo.getE911MetricsByContactId(contactId);
        if (e911MetricsRecord.size() == 1) {
            return e911MetricsRecord[0];
        }
        return null;
    }
    /**
     * @description Retrieves an active/unexecuted E911 Metrics record that corresponds with a Contact Id
     * @param metricId - Contact Id for the respective Account Id
     * @return VCC_e911_Metrics__c - retrieves the active E911 record if ther is one, otherwise null
     */
    @AuraEnabled
    public static VCC_e911_Metrics__c getE911MetricsRecordById(Id metricId) {
        Set<String> myAdditionalMetricFields = new Set<String>{ 'Id', 'VCC_Non_Address__c', 'VCC_Active__c' };
        VCC_e911_Metrics__c e911MetricsRecord = (VCC_e911_Metrics__c) e911MetricsRepo.fetchById(
            metricId,
            myAdditionalMetricFields
        );
        if (e911MetricsRecord.Id != null) {
            return e911MetricsRecord;
        }
        return null;
    }

    /**
     * @description Retrieves a cnx__Connects_Configuration_Assignment__c record to see if the user is using Bucher and Suter
     * @return Is user a Bucher and Suter user
     */
    @AuraEnabled
    public static Boolean getBSConfigAssignedUserRecord() {
        List<cnx__Connects_Configuration_Assignment__c> listBSCAU = bsCAURepo.fetchAssociatedUser(UserInfo.getUserId());
        if (listBSCAU.size() < 1) {
            return false;
        }
        return true;
    }
    /**
     * @description Retrieves a cnx__Connects_Configuration_Assignment__c record to see if the user is using Bucher and Suter
     * @return Is there a VCC_E911_Disable__mdt record in the system
     */
    @AuraEnabled
    public static Boolean isE911Enabled() {
        VAHC_E911_Settings__c e911Setting = VAHC_E911_Settings__c.getOrgDefaults();
        if (e911Setting != null && e911Setting.e911_Enabled__c) {
            return true;
        }
        return false;
    }

    /**
     * @description This method is responsible for querying an e911 record (VCC_e911_Metrics__c) associated with clicking the e911 button.
     * Depending on where the button was clicked from, a helper method is called to query and populate additional fields on the e911 record
     *
     * @param objectAPI the API name of the object type associated with the clicked link (e.g., 'Case','Account', 'VCC_Progress_Note__c', or 'Home')
     * @param recordClickedOn the Id of the clicked-on record
     * @param callBackNumber the callback number the user put into the component
     *
     * @return a string that indicates the operation's success or status
     *
     * @throws AuraHandledException if an exception occurs during execution
     *
     * If the passed API object name is anything other than 'Case', 'Account', 'VCC_Progress_Note__c', or 'Home'
     * the function returns a status message stating so
     *
     * The VCC_e911_Metrics__c record is then updated in the database
     *
     **/
    @AuraEnabled
    public static String queryE911Record(String objectAPI, Id recordClickedOn, String callBackNumber) {
        //need to query for the e911 record, passing in the recordclickedOn, objectAPI, and callbackNumber
        String returnString;
        switch on objectAPI {
            when 'Case' {
                Database.UpsertResult result = handleE911MetricsCase(objectAPI, recordClickedOn, callBackNumber);
                if (result.isSuccess()) {
                    returnString = result.getId();
                    return returnString;
                }
                return UPSERT_FAILED_ERROR;
            }
            when 'Account' {
                Database.UpsertResult result = handleE911MetricsAccount(objectAPI, recordClickedOn, callBackNumber);
                if (result.isSuccess()) {
                    returnString = result.getId();
                    return returnString;
                }
                return UPSERT_FAILED_ERROR;
            }
            when 'VCC_Progress_Note__c' {
                Database.UpsertResult result = handleE911MetricsProgressNote(
                    objectAPI,
                    recordClickedOn,
                    callBackNumber
                );
                if (result.isSuccess()) {
                    returnString = result.getId();
                    return returnString;
                }
                return UPSERT_FAILED_ERROR;
            }
            when null {
                Database.UpsertResult result = handleE911MetricsHome(objectAPI, recordClickedOn, callBackNumber);
                if (result.isSuccess()) {
                    returnString = result.getId();
                    return returnString;
                }
                return UPSERT_FAILED_ERROR;
            }
            when else {
                return SURFACED_ON_INVALID_OBJECT_ERROR;
            }
        }
    } //end of queryE911Record
    /**
     * @description - Manages the E911 Metrics retrieval and update for the Case objectAPI and recordID that is passed in
     * @param objectAPI - object API name
     * @param recordClickedOn - recordID from which the process was invoked
     * @param callBackNumber - callback number put into the LWC
     * @return Database.UpsertResult - upsert results detailing success or failure.
     */
    @TestVisible
    private static Database.UpsertResult handleE911MetricsCase(
        String objectAPI,
        Id recordClickedOn,
        String callBackNumber
    ) {
        Set<String> myAdditionalCaseFields = new Set<String>{ 'Id', 'ContactId', 'VCC_Progress_Note__c' };
        Case repoCase = (Case) caseRepo.fetchById(recordClickedOn, myAdditionalCaseFields);
        VCC_e911_Metrics__c currentE911Metrics = getE911MetricsRecord(repoCase.ContactId);
        currentE911Metrics.VCC_e911_Case__c = recordClickedOn;
        currentE911Metrics.VCC_Patient_Account__c = repoCase.ContactId;
        currentE911Metrics = setBaseFields(currentE911Metrics, objectAPI, callBackNumber);
        return e911MetricsRepo.doUpsert(currentE911Metrics);
    }
    /**
     * @description Manages the E911 Metrics retrieval and update for the Account objectAPI and recordID that is passed in
     * @param objectAPI - object API name
     * @param recordClickedOn - recordID from which the process was invoked
     * @param callBackNumber - callback number put into the LWC
     * @return Database.UpsertResult - upsert results detailing success or failure.
     */
    @TestVisible
    private static Database.UpsertResult handleE911MetricsAccount(
        String objectAPI,
        Id recordClickedOn,
        String callBackNumber
    ) {
        Account repoAccount = (Account) accountRepo.fetchById(recordClickedOn);
        List<Contact> repoContact = (List<Contact>) contactRepo.getContactFromAccountId(repoAccount.Id);
        VCC_e911_Metrics__c currentE911Metrics = getE911MetricsRecord(repoContact[0].Id) ?? new VCC_e911_Metrics__c();
        currentE911Metrics.VCC_Patient_Account__c = repoContact[0].Id;

        currentE911Metrics = setBaseFields(currentE911Metrics, objectAPI, callBackNumber);
        return e911MetricsRepo.doUpsert(currentE911Metrics);
    }
    /**
     * @description Manages the E911 Metrics retrieval and update for the Progress Note objectAPI and recordID that is passed in
     * @param objectAPI - object API name
     * @param recordClickedOn - recordID from which the process was invoked
     * @param callBackNumber - callback number put into the LWC
     * @return Database.UpsertResult - upsert results detailing success or failure.
     */
    @TestVisible
    private static Database.UpsertResult handleE911MetricsProgressNote(
        String objectAPI,
        Id recordClickedOn,
        String callBackNumber
    ) {
        Set<String> myAdditionalPNoteFields = new Set<String>{ 'Id', 'VCC_Case__c' };
        VCC_Progress_Note__c progNote = (VCC_Progress_Note__c) pnRepo.fetchById(
            recordClickedOn,
            myAdditionalPNoteFields
        );
        Set<String> myAdditionalCaseFields = new Set<String>{ 'Id', 'ContactId', 'VCC_Progress_Note__c' };
        Case repoCase = (Case) caseRepo.fetchById(progNote.VCC_Case__c, myAdditionalCaseFields);

        VCC_e911_Metrics__c currentE911Metrics = getE911MetricsRecord(repoCase.ContactId);
        currentE911Metrics.VCC_e911_Progress_Note__c = recordClickedOn;
        currentE911Metrics.VCC_e911_Case__c = repoCase.Id;
        currentE911Metrics.VCC_Patient_Account__c = repoCase.ContactId;
        currentE911Metrics = setBaseFields(currentE911Metrics, 'Progress Note', callBackNumber);
        return e911MetricsRepo.doUpsert(currentE911Metrics);
    }
    /**
     * @description Manages the E911 Metrics retrieval and update for the invoked from Home path
     * @param objectAPI - object API name
     * @param recordClickedOn - recordID from which the process was invoked
     * @param callBackNumber - callback number put into the LWC
     * @return Database.UpsertResult - upsert results detailing success or failure.
     */
    @TestVisible
    private static Database.UpsertResult handleE911MetricsHome(
        String objectAPI,
        Id recordClickedOn,
        String callBackNumber
    ) {
        VCC_e911_Metrics__c currentE911Metrics = new VCC_e911_Metrics__c();

        currentE911Metrics = setBaseFields(currentE911Metrics, RECORD_TYPE_HOME, callBackNumber);
        return e911MetricsRepo.doUpsert(currentE911Metrics);
    }
    /**
     * @description This method is a helper method to set base fields of the e911 metric record
     * @param e911record - record we are updating
     * @param objectAPI - object from which the process was invoked
     * @param callBackNumber - callback number put into the LWC
     * @return a VCC_e911_Metrics__c record
     **/
    @TestVisible
    private static VCC_e911_Metrics__c setBaseFields(
        VCC_e911_Metrics__c e911record,
        String objectAPI,
        String callBackNumber
    ) {
        e911record.VCC_Date_Activated__c = System.now();
        e911record.VCC_User_VISN__c = tucCommonUtils.getUserDivisionVISN();
        e911record.VCC_User_Name_Activated__c = UserInfo.getName();
        //call helper method to get Service value
        e911record.VCC_Service__c = getUserService();
        e911record.VCC_Call_Back_Number__c = callBackNumber;
        e911record.VCC_Active__c = true;
        e911record.VCC_Activated_From__c = objectAPI;
        return e911record;
    }
    @TestVisible
    /**
     * @description This method is a helper method to determine what custom permission a user has in order to populate the VCC_Service__c field on the e911 record
     *
     * @return a String to assign the VCC_Service__C field value to
     **/
    private static String getUserService() {
        if (FeatureManagement.checkPermission('VCC_Medical_Provider')) {
            return 'VCV';
        } else if (
            FeatureManagement.checkPermission('VCC_Pharmacy_Tier_II') ||
            FeatureManagement.checkPermission('VCC_Pharmacy_Tier_III')
        ) {
            return 'Pharmacy';
        } else if (FeatureManagement.checkPermission('VCC_Registered_Nurse')) {
            return 'CT Triage';
        } else if (FeatureManagement.checkPermission('TED_RN')) {
            return 'Tele-EC Triage';
        } else if (FeatureManagement.checkPermission('TED_Medical_Provider')) {
            return 'Tele EC MP Visit';
        } else {
            return '';
        }
    }
}
