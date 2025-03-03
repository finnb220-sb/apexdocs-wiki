/**
 * @description Unit test helper methods.
 * @author Booz Allen
 *
 *
 * @deprecated This class is deprecated and will be removed in the future. Please use the VATEST_UserFactory,
 * VATEST_UserBuilder, and VATEST_TestDataFactory classes instead.
 *
 */
@IsTest
public with sharing class VCC_TestDataFactory {
    /**
     * @description Creates and inserts a random user with the provided profile.
     * @param profileName `String` represents the String name of the profile to assign to the user
     *
     * @return User
     */
    public static User insertUser(String profileName) {
        String uniqueUserName = 'standarduser' + Datetime.now().getTime() + '@VAHC.com';
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :profileName];
        User user = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName
        );
        insert user;
        return user;
    }

    /**
     * @description Assigns a given user to the specified permission set.
     * @param user `User` represents a User record to have a permission set assigned
     * @param permissionSetName `String` represents the String name of the permission set to assign
     */
    public static void assignPermissionSetByName(User user, String permissionSetName) {
        if (!hasPermissionSet(user, permissionSetName)) {
            PermissionSet permSet = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetName];
            insert new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permSet.Id);
        }
    }

    /**
     * @description Checks if a user has the given permission set assigned.
     * @param user `User` represents a User record
     * @param permissionSetName `String` represents the String name of the permission set
     *
     * @return Boolean representing if the user has the specified permission set
     */
    public static Boolean hasPermissionSet(User user, String permissionSetName) {
        Integer count = [
            SELECT COUNT()
            FROM PermissionSetAssignment
            WHERE AssigneeId = :user.Id AND PermissionSet.Name = :permissionSetName
        ];

        return (count == 0) ? false : true;
    }

    /**
     * @description Retrieves the permission sets in a group given the API name.
     * @param permSetGroupAPIName `String` API name of the permission set group.
     * @return  `List<PermissionSet>` list of permission sets in group.
     */
    public static List<PermissionSet> getPermissionSetsFromGroup(String permSetGroupAPIName) {
        PermissionSetGroup psg;
        List<PermissionSetGroupComponent> permSetGroupComponents;
        Set<Id> permSetIds;

        try {
            psg = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = :permSetGroupAPIName];
        } catch (Exception e) {
            return null;
        }

        if (psg != null) {
            try {
                permSetGroupComponents = [
                    SELECT Id, PermissionSetId
                    FROM PermissionSetGroupComponent
                    WHERE PermissionSetGroupId = :psg.Id
                ];
            } catch (Exception excep) {
                Logger.error('Failed to query PermissionSetGroupComponent', excep);
                Logger.saveLog();
            }

            if (permSetGroupComponents != null && permSetGroupComponents.size() > 0) {
                permSetIds = new Set<Id>();
                for (PermissionSetGroupComponent psa : permSetGroupComponents) {
                    permSetIds.add(psa.PermissionSetId);
                }
            }
        }

        return [SELECT Id FROM PermissionSet WHERE Id IN :permSetIds];
    }

    /**
     * @description Adds permission sets in a permission set group to the specified user.
     *
     * @param permSetGroupAPIName `String` API name of permission set group.
     * @param user `User` User to assign group to.
     */
    public static void addPermSetGroupToUser(String permSetGroupAPIName, User user) {
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        for (PermissionSet permSet : getPermissionSetsFromGroup(permSetGroupAPIName)) {
            psaList.add(new PermissionSetAssignment(PermissionSetId = permSet.Id, AssigneeId = user.Id));
        }
        insert psaList;
    }

    /**
     * @description creates a Problems request
     *
     * @return `VCC_ProblemLightningRequestWrp` wrapper
     */
    public static VCC_ProblemLightningRequestWrp getProblemLightningRequestWrp() {
        VCC_ProblemLightningRequestWrp wrp = new VCC_ProblemLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description creates a Orders request
     *
     * @return `VCC_OrderLightningRequestWrp` wrapper
     */
    public static VCC_OrderLightningRequestWrp getOrderLightningRequest() {
        VCC_OrderLightningRequestWrp wrp = new VCC_OrderLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description creates a Radiology request
     *
     * @return `VCC_RadiologyLightningRequestWrp` wrapper
     */
    public static VCC_RadiologyLightningRequestWrp getRadiologyLightningRequest() {
        VCC_RadiologyLightningRequestWrp wrp = new VCC_RadiologyLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description returns a wrapper after generating a recordId, populating start and end dates, and a facility number
     *
     * @return `VCC_LabLightningRequestWrp` wrapper class VCC_LabLightningRequestWrp
     */
    public static VCC_LabLightningRequestWrp getLabLightningReqeust() {
        VCC_LabLightningRequestWrp wrp = new VCC_LabLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description Creates person account records
     *
     * @return `VCC_ConsultLightningRequestWrp` wrapper class VCC_ConsultLightningRequestWrp
     */
    public static VCC_ConsultLightningRequestWrp getConsultLightningRequest() {
        VCC_ConsultLightningRequestWrp wrp = new VCC_ConsultLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description Creates an immunization request wrapper
     *
     * @return `VCC_ImmunizationLightningRequestWrp` wrapper class VCC_ImmunizationLightningRequestWrp
     */
    public static VCC_ImmunizationLightningRequestWrp getImmunizationLightningRequest() {
        VCC_ImmunizationLightningRequestWrp wrp = new VCC_ImmunizationLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description Creates an appointment request wrapper
     *
     * @return `VCC_AppointmentLightningRequestWrp` wrapper class VCC_AppointmentLightningRequestWrp
     */
    public static VCC_AppointmentLightningRequestWrp getAppointmentLightningRequestWrp() {
        VCC_AppointmentLightningRequestWrp wrp = new VCC_AppointmentLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description Creates a Discharge Summary request wrapper
     *
     * @return `VCC_DischargeSummaryLightningRequestWrp` wrapper class VCC_DischargeSummaryLightningRequestWrp
     */
    public static VCC_DischargeSummaryLightningRequestWrp getDischargeSummaryLightiningRequest() {
        VCC_DischargeSummaryLightningRequestWrp wrp = new VCC_DischargeSummaryLightningRequestWrp();
        wrp.startDate = String.valueOf(Date.today());
        wrp.endDate = String.valueOf(Date.today().addYears(1));
        wrp.recordId = generateVccPersonAccounts(1)[0].Id;
        wrp.facility = '123456';
        return wrp;
    }

    /**
     * @description Creates person account records
     *
     * @param count `Integer` used to determine number of test Accounts to create
     * @return `List<Account>` of person account records
     */
    public static List<Account> generateVccPersonAccounts(Integer count) {
        Integer myInt = 0;
        List<Account> testAccounts = new List<Account>();
        while (myInt != count) {
            Account acc = new Account();
            acc.RecordTypeId = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id;
            acc.FirstName = 'Test';
            acc.LastName = 'PersonAccount' + String.valueOf(myInt);
            acc.VCC_MVI_External_Id__pc = '123456' + String.valueOf(myInt); //Not removing this line yet, as the field is mentioned in 62 other files
            acc.MVI_External_Id__pc = '123456' + String.valueOf(myInt); //Adding this line to cover the change in the progressNote formula field VCC_Patient_ICN__c
            acc.PersonEmail = 'testPerson' + String.valueOf(myInt) + '@domain.com';
            acc.PersonBirthdate = Date.today().addYears(-25).addMonths(-myInt).addDays(-myInt);
            acc.HealthCloudGA__Gender__pc = 'Male';
            acc.Date_of_Birth__pc = String.valueOf(Date.today().addYears(-25).addMonths(-myInt).addDays(-myInt));

            testAccounts.add(acc);
            myInt++;
        }
        insert testAccounts;
        return testAccounts;
    }

    /**
     * @description pass in a String of a Static Resource and return a mock (Add mock generator for test classes)
     *
     * @param mock `String` representing the name of the static resource you want to use to mock the callout
     * @return `StaticResourceCalloutMock` mock object
     */
    public static StaticResourceCalloutMock generateCalloutMockForTest(String mock) {
        StaticResourceCalloutMock iCalloutMock = new StaticResourceCalloutMock();
        switch on mock {
            when 'VCC_BridgAdditionalSignersMock' {
                iCalloutMock.setStaticResource('VCC_BridgAdditionalSignersMock');
            }
            when 'VCC_AppointmentJsonExample' {
                iCalloutMock.setStaticResource('VCC_AppointmentJsonExample');
            }
            when 'VCC_DischargeSummaryJsonExample' {
                iCalloutMock.setStaticResource('VCC_DischargeSummaryJsonExample');
            }
        }
        iCalloutMock.setStatusCode(200);
        iCalloutMock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        return iCalloutMock;
    }

    /**
     * @description Gets the record type but needs to be updated
     *
     * @param sObjectType `String` specifies the sobject we're getting the recordType for
     * @param developerName `String` developerName of the recordType record
     * @return RecordType record
     *
     * @TODO: Change this approach to instead use the VCR_Repo RecordTypeConstant. This will require checking for the
     *        existence of the Repo class as we do not have Repositories for all SObjectTypes.
     * Note, this entire class is deprecated, so this is a low priority.
     */
    public static RecordType getRecordType(String sObjectType, String developerName) {
        return [
            SELECT Id, DeveloperName, Name
            FROM RecordType
            WHERE SobjectType = :sObjectType AND DeveloperName = :developerName
            LIMIT 1
        ];
    }

    /**
     * @description Creates a Case
     *
     * @param subject `String` containing subject
     * @param recordTypeId `Id` which recordTypeId to use
     * @param accountId `Id` which accountId to use
     * @return `Case` record
     */
    public static Case createCase(String subject, Id recordTypeId, Id accountId) {
        Case cse = new Case();
        cse.Subject = subject;
        cse.RecordTypeId = recordTypeId;
        cse.AccountId = accountId;
        cse.VCC_Caller_Relation__c = 'Self';
        cse.VCC_Caller_Name__c = 'Unit Test';
        insert cse;
        return cse;
    }

    /**
     * @description Wrapper Class that contains params for createCallTask Method.
     *
     * Note: Intelli-j seems to think these properties can be final, but without an exhaustive vetting of the calling
     * code, I'm not sure I want to risk it.
     */
    @TestVisible
    private class CallTaskWrapper {
        /**
         * @description Wrapper account assosciated with task
         */
        @TestVisible
        Account acct { get; set; }
        /**
         * @description Wrapper callerName associated with Task
         */
        @TestVisible
        String callerName { get; set; }
        /**
         *  @description Wrapper the Caller Relationship type
         */
        @TestVisible
        String callerRelationType { get; set; }
        /**
         * @description Wrapper the Owner of the task
         */
        @TestVisible
        Id ownerId { get; set; }

        @TestVisible
        private CallTaskWrapper() {
            this.acct = new Account();
        }
    }

    /**
     * @description inserts a task
     *
     * @param callTaskWrapper `CallTaskWrapper` wrapper the Tasks Parameters
     */
    public static void createCallTask(CallTaskWrapper callTaskWrapper) {
        insert new Task(
            WhoId = callTaskWrapper.acct.PersonContactId,
            VCC_Relative_Type_Picklist__c = callTaskWrapper.callerRelationType,
            VCC_Patient_Verified_DateTime__c = Datetime.now(),
            VCC_Name__c = callTaskWrapper.callerName,
            OwnerId = callTaskWrapper.ownerId,
            Type = 'Call'
        );
    }

    /**
     * @description Creates a lab modal
     *
     * @return `VCC_LabModal` record
     */
    public static VCC_LabModal createLabModal() {
        VCC_LabModal labModal = new VCC_LabModal();
        labModal.sites.add(new VCC_LabModal.Sites());
        labModal.sites[0].results = new VCC_LabModal.Results();
        labModal.sites[0].results.labs = new VCC_LabModal.Labs();
        labModal.sites[0].results.labs.lab.add(new VCC_LabModal.Lab());
        labModal.sites[0].results.labs.lab[0].loinc = new VCC_LabModal.Loinc();
        labModal.sites[0].results.labs.lab[0].loinc.value = '18282-4';
        return labModal;
    }

    /**
     * @description Creates a progress note related to the case id param and returns it.
     *
     * @param caseId `id` the case id to associate the progress note with
     * @return `VCC_Progress_Note__c` the created progress note
     */
    public static VCC_Progress_Note__c createProgressNote(Id caseId) {
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Case__c = caseId,
            VCC_Relative_Type__c = 'Self',
            VCC_Caller_Name_Text__c = 'Test',
            VCC_Case__r = [SELECT Id, VCC_Caller_Relation__c, VCC_Caller_Name__c FROM Case WHERE Id = :caseId LIMIT 1]
        );
        insert progressNote;
        return progressNote;
    }
}
