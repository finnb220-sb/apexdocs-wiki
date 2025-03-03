/**
 * VCC_ExternalVaLinksController Class
 * @description  This class is responsible for fetching External VA Links.
 * Implement selector pattern before introducing new Audiences
 * @author Booz Allen Hamilton
 *
 * -- Change Log --
 * 9/7/2023 - Added Limit 10 to query
 * 9/7/2023 - Implemented Public method and constructor comments
 * 5/1/2024 - Implemented repo pattern for Database calls and documentation
 * 10/1/2024 - Implemented ProgressNote switch choice for both UserUie911 record creation as well as E911 Tasks
 */
public with sharing class VCC_ExternalVaLinksController {
    @TestVisible
    private static VCR_ExternalVaLinksRepo memoizedExternalVaLinksRepo;

    @TestVisible
    private static VCR_AccountRepo memoizedAccountRepo;

    @TestVisible
    private static VCR_ContactRepo memoizedContactRepo;

    @TestVisible
    private static VCR_CaseRepo memoizedCaseRepo;

    @TestVisible
    private static VCR_ProgressNoteRepo memoizedProgressNoteRepo;

    @TestVisible
    private static VCR_TaskRepo memoizedTaskRepo;

    @TestVisible
    private static VCR_UserUIEventRepo memoizedUserUIEventRepo;

    @TestVisible
    private static VCR_VAHCe911CustomSettingRepo memoized911CustomSetRepo;

    @TestVisible
    private static VCC_ExternalVaLinksControllerHelper helperInstance;

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_VAHCe911CustomSettingRepo e911CustomSetRepo {
        get {
            if (memoized911CustomSetRepo == null) {
                memoized911CustomSetRepo = new VCR_VAHCe911CustomSettingRepo();
            }
            return memoized911CustomSetRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_AccountRepo accountRepo {
        get {
            if (memoizedAccountRepo == null) {
                memoizedAccountRepo = new VCR_AccountRepo();
            }
            return memoizedAccountRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
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
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_CaseRepo caseRepo {
        get {
            if (memoizedCaseRepo == null) {
                memoizedCaseRepo = new VCR_CaseRepo();
            }
            return memoizedCaseRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_ProgressNoteRepo progressNoteRepo {
        get {
            if (memoizedProgressNoteRepo == null) {
                memoizedProgressNoteRepo = new VCR_ProgressNoteRepo();
            }
            return memoizedProgressNoteRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_ExternalVaLinksRepo externalVaLinksRepo {
        get {
            if (memoizedExternalVaLinksRepo == null) {
                memoizedExternalVaLinksRepo = new VCR_ExternalVaLinksRepo();
            }
            return memoizedExternalVaLinksRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_TaskRepo taskRepo {
        get {
            if (memoizedTaskRepo == null) {
                memoizedTaskRepo = new VCR_TaskRepo();
            }
            return memoizedTaskRepo;
        }
    }

    /**
     * @description - Inits and enforces a single instance of Repo
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCR_UserUIEventRepo userUIEventRepo {
        get {
            if (memoizedUserUIEventRepo == null) {
                memoizedUserUIEventRepo = new VCR_UserUIEventRepo();
            }
            return memoizedUserUIEventRepo;
        }
    }

    /**
     * @description - instance of helper class
     * @return returns the memoized repo
     */
    @TestVisible
    private static VCC_ExternalVaLinksControllerHelper helperInstanceRepo {
        get {
            if (helperInstance == null) {
                helperInstance = new VCC_ExternalVaLinksControllerHelper();
            }
            return helperInstance;
        }
        set;
    }

    /**
     * @description Fetches a list of External VA Links from the metadata.
     * @param isCRMUser boolean - True if the user is a CRM user, false if the user is a TUC user
     * @return List<External_VA_Link__mdt> - List of External VA Links
     */
    @AuraEnabled(Cacheable=true)
    public static List<External_VA_Link__mdt> getLinks(Boolean isCRMUser) {
        if (isCRMUser) {
            //? if the user is CRM then query All or VCC with a limit of 10 records
            return externalVaLinksRepo.getVALinksFromAudience(new List<String>{ 'ALL', 'VCC' }, 10);
        } else {
            //? if the user is TUC then query All or TUC with a limit of 10 records
            return externalVaLinksRepo.getVALinksFromAudience(new List<String>{ 'ALL', 'TUC' }, 10);
        }
    }

    /**
     * @description This method is responsible for creating a user interface record (User_UI_Event__c) associated with a clicked link.
     * The created record contains a timestamp, a user's VISN division, and details about the clicked-on object.
     *
     * For a 'Case' object, the method fetches the TUC_Assigned_Facility__c and ContactId from the relevant Case record,
     * and sets these values into the UserUI_Patient_s_Facility__c and UserUI_Patient_s_Name__c fields, respectively, of the new User_UI_Event__c record
     *
     * For an 'Account' object, it fetches the Contact Id linked to the Account and sets it into the UserUI_Patient_s_Name__c of the User_UI_Event__c record
     *
     * For a 'VCC_Progress_Note__c' object, the method fethces the ContactId from the related Case record, and sets those values into the UserUI_Patient_s_Name__c record
     *
     * If the passed API object name is anything other than 'Case' ,'Progress Note', or 'Account', the function returns a status message stating it is not on a Case, Progress Note or Account Page.
     *
     * The newly created User_UI_Event__c record is then inserted into the database.
     *
     * @param objectAPI the API name of the object type associated with the clicked link (e.g., 'Case' or 'Account')
     * @param recordClickedOn the Id of the clicked-on record
     * @return String that indicates the operation's success or status
     * @throws AuraHandledException if an exception occurs during execution
     *
     **/
    @AuraEnabled
    public static String createUserUIe911Record(String objectAPI, Id recordClickedOn) {
        switch on objectAPI {
            when 'Case' {
                if (recordClickedOn == null) {
                    throw new AuraHandledException('Invalid input parameters: objectAPI or recordClickedOn is null.');
                }
                User_UI_Event__c clickedLink = helperInstanceRepo.createUserUIEventRecord();
                Set<String> caseAdditionalFields = new Set<String>{ 'TUC_Assigned_Facility__c', 'ContactId' };
                Case curCase = (Case) caseRepo.fetchById(recordClickedOn, caseAdditionalFields);
                clickedLink.UserUI_Case_Link_was_Clicked_On__c = recordClickedOn;
                clickedLink.UserUI_Patient_s_Facility__c = curCase.TUC_Assigned_Facility__c;
                clickedLink.UserUI_Patient_s_Name__c = curCase.ContactId;
                userUIEventRepo.doCreate(clickedLink);

                return 'Success';
            }
            when 'Account' {
                if (recordClickedOn == null) {
                    throw new AuraHandledException('Invalid input parameters: objectAPI or recordClickedOn is null.');
                }
                User_UI_Event__c clickedLink = helperInstanceRepo.createUserUIEventRecord();
                List<Contact> contactList = contactRepo.getContactFromAccountId(recordClickedOn);
                clickedLink.UserUI_Patient_s_Name__c = contactList[0].Id;
                userUIEventRepo.doCreate(clickedLink);

                return 'Success';
            }
            when 'VCC_Progress_Note__c' {
                if (recordClickedOn == null) {
                    throw new AuraHandledException('Invalid input parameters: objectAPI or recordClickedOn is null.');
                }
                User_UI_Event__c clickedLink = helperInstanceRepo.createUserUIEventRecord();
                Set<String> progressNoteAdditionalFields = new Set<String>{ 'VCC_Case__r.ContactId' };
                VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) progressNoteRepo.fetchById(
                    recordClickedOn,
                    progressNoteAdditionalFields
                );
                clickedLink.UserUI_Patient_s_Name__c = progressNote?.VCC_Case__r?.ContactId;
                userUIEventRepo.doCreate(clickedLink);

                return 'Success';
            }
            when else {
                return 'This component is not on a Case, Progress Note, or Account Page';
            }
        }
    }

    /**
     * @description This method creates a new Task Record when the e911 link
     * is clicked on the externalVALinks LWC (Tele-EC Only atm).
     * When 'Case' is passed as the objectAPI:
     *     - A Task is created with the Subject set as 'e911', Task Order Date as Today's date,
     *       Activity Date as tomorrow's date, and Record Type ID as the ID for 'TED_Task'.
     *     - The WhatId of the Task is set to the Id of the Case that was clicked on and the WhoId is set to the ContactId of that Case.
     *     - If successful, 'Success' is returned.
     *
     * When 'Account' is passed as the objectAPI:
     *     - A Task is created with the Subject set as 'e911', Task Order Date as Today's date,
     *       Activity Date as tomorrow's date, and Record Type ID as the ID for 'TED_Task'.
     *     - The WhoId of the Task is set to the Id of the Contact associated with the Account that was clicked on.
     *     - If successful, 'Success' is returned.
     *
     * When 'VCC_Progress_Note__c' is passed as the objectAPI:
     *     - A Task is created with the Subject set as 'e911', Task Order Date as Today's date,
     *       Activiting Date as tomorrow's date, and REcord Type Id as the ID for 'TED_Task'.
     *     - The WhoId of the Task is set to the ContactId of the related Case from the Progress Note that was clicked on.
     *     - If successful, 'Success' is returned.
     *
     * @param objectAPI The name of the Salesforce Object API.
     * @param recordClickedOn The id of the Salesforce object that was clicked on.
     * @return String message that indicates the status of the operation.
     *     - If the operation was successful, 'Success' is returned.
     *     - If the objectAPI is neither 'Case' nor 'Account', the method returns 'This component is not on a Case or Account Page'.
     * @throws AuraHandledException Exception that are thrown are handled by AuraHandledException.
     *
     */
    @AuraEnabled
    public static String createTaske911(String objectAPI, Id recordClickedOn) {
        try {
            Task clickedLink = new Task();

            clickedLink.Subject = 'e911';
            clickedLink.TED_Task_Order_Date__c = Date.today();
            clickedLink.ActivityDate = Date.today().addDays(1);
            //If CRM also wants a Task created, there will need to be conditional statments to get their own RecordType
            clickedLink.RecordTypeId = taskRepo.recordTypeConstant.fromDeveloperName('TED_Task').Id;

            switch on objectAPI {
                when 'Case' {
                    Set<String> caseAdditionalFields = new Set<String>{ 'ContactId' };
                    Case curCase = (Case) caseRepo.fetchById(recordClickedOn, caseAdditionalFields);
                    clickedLink.WhatId = curCase.Id;
                    clickedLink.WhoId = curCase.ContactId;
                    taskRepo.doCreate(clickedLink);

                    return 'Success';
                }
                when 'Account' {
                    List<Contact> contactList = contactRepo.getContactFromAccountId(recordClickedOn);
                    clickedLink.WhoId = contactList[0].Id;
                    taskRepo.doCreate(clickedLink);

                    return 'Success';
                }
                when 'VCC_Progress_Note__c' {
                    Set<String> progressNoteAdditionalFields = new Set<String>{
                        'VCC_Case__r.Id',
                        'VCC_Case__r.ContactId'
                    };

                    VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) progressNoteRepo.fetchById(
                        recordClickedOn,
                        progressNoteAdditionalFields
                    );

                    clickedLink.WhoId = progressNote?.VCC_Case__r?.ContactId;
                    taskRepo.doCreate(clickedLink);

                    return 'Success';
                }
                when else {
                    return 'This component is not on a Case, Progress Note, or Account Page';
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description retrieves the custom setting responsible for enabling or disabling e911 globally
     * @return VAHC_E911_Settings__c - org wide settings for e911
     */
    @AuraEnabled(cacheable=true)
    public static Boolean getE911ActiveCustomSetting() {
        List<VAHC_E911_Settings__c> e911Setting = e911CustomSetRepo.getAlle911CustomSettingsRecords();
        if (e911Setting.size() > 0) {
            return e911Setting[0].e911_Enabled__c;
        }
        return false;
    }
    /**
     * @description Helper class for mocking because of System.Now() issue
     
    public class VCC_ExternalVaLinksControllerHelper {
        public User_UI_Event__c createUserUIEventRecord() {
            User_UI_Event__c clickedLink = new User_UI_Event__c();
            clickedLink.UserUI_Time_e911_Link_was_Clicked__c = System.now();
            clickedLink.UserUI_Provider_s_VISN__c = tucCommonUtils.getUserDivisionVISN();
            clickedLink.UserUI_Provider_s_Name__c = UserInfo.getUserId();
            return clickedLink;
        }
    }*/
}
