/**
 * @description       : Class used to as a helper for test data creation
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_TestDataFactory {
    /**
     * test email used in user creation
     */
    public static String testEmail = 'test@test.com';

    /**
     * test email encoding used in user creation
     */
    public static String testEncoding = 'UTF-8';

    /**
     * test locale used in user creation
     */
    public static String testLocale = 'en_US';

    /**
     * test time zone used in user creation
     */
    public static String testTZ = 'America/Los_Angeles';

    /**
     * test time zone used in user creation
     */
    public static String consultantPersona = 'NTSP Consultant';

    /**
     * consult time used in case creation
     */
    public static String consultTime = '1122';

    /**
     * Facility Id used in case creation
     */
    public static String facilityId = '1234';

    /**
     * String to be used in any location where value does not matter to NTSP
     */
    public static String testString = 'Test';

    /**
     * String to be used in any location field on NTSP case
     */
    public static String inpatient = 'Inpatient';

    /**
     * @description Method to create users
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void createTestUsers() {
        final User admin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE LIMIT 1];

        //Run as an admin, create users and assign permission sets
        System.runAs(admin) {
            final List<User> usersToInsertList = new List<User>();
            final Profile baseProfile = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];

            final Map<String, String> roleIdToNameMap = new Map<String, String>();
            Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
            final User nurse = new User(
                Email = testEmail,
                EmailEncodingKey = testEncoding,
                LastName = 'NTSP Nurse',
                Alias = 'nurse',
                LanguageLocaleKey = testLocale,
                LocaleSidKey = testLocale,
                ProfileId = baseProfile.Id,
                TimeZoneSidKey = testTZ,
                UserName = 'nurse' + randomInt + '@ntsp.com'
            );

            usersToInsertList.add(nurse);

            final User consultant = new User(
                Email = testEmail,
                EmailEncodingKey = testEncoding,
                LastName = consultantPersona,
                Alias = 'cons',
                LanguageLocaleKey = testLocale,
                LocaleSidKey = testLocale,
                ProfileId = baseProfile.Id,
                TimeZoneSidKey = testTZ,
                UserName = 'consultant' + randomInt + '@ntsp.com',
                Role_Type__c = 'NTSP Consultant'
            );

            usersToInsertList.add(consultant);

            final User nursePR = new User(
                Email = testEmail,
                EmailEncodingKey = testEncoding,
                LastName = 'NTSP Nurse PR',
                Alias = 'nursePR',
                LanguageLocaleKey = testLocale,
                LocaleSidKey = testLocale,
                ProfileId = baseProfile.Id,
                TimeZoneSidKey = testTZ,
                UserName = 'nursePR' + randomInt + '@ntsp.com'
            );

            usersToInsertList.add(nursePR);

            final User consultantPR = new User(
                Email = testEmail,
                EmailEncodingKey = testEncoding,
                LastName = 'NTSP Consultant PR',
                Alias = 'consPR',
                LanguageLocaleKey = testLocale,
                LocaleSidKey = testLocale,
                ProfileId = baseProfile.Id,
                TimeZoneSidKey = testTZ,
                UserName = 'consultantPR' + randomInt + '@ntsp.com',
                Role_Type__c = 'NTSP Consultant'
            );

            usersToInsertList.add(consultantPR);

            insert usersToInsertList;

            Group consultantGroup = new Group();
            Group nurseGroup = new Group();

            List<Group> ntspGroups = [SELECT Id, DeveloperName FROM Group WHERE Name LIKE 'NTSP%'];
            for (Group g : ntspGroups) {
                if (g.DeveloperName == 'NTSP_Consultants') {
                    consultantGroup = g;
                } else if (g.DeveloperName == 'NTSP_Triage_Nurses') {
                    nurseGroup = g;
                }
            }

            List<GroupMember> nurseMembers = new List<GroupMember>();
            nurseMembers.add(new GroupMember(GroupId = nurseGroup.Id, UserOrGroupId = nurse.Id));
            nurseMembers.add(new GroupMember(GroupId = nurseGroup.Id, UserOrGroupId = nursePR.Id));

            insert nurseMembers;

            List<GroupMember> consultantMembers = new List<GroupMember>();
            consultantMembers.add(new GroupMember(GroupId = consultantGroup.Id, UserOrGroupId = consultant.Id));
            consultantMembers.add(new GroupMember(GroupId = consultantGroup.Id, UserOrGroupId = consultantPR.Id));
            insert consultantMembers;

            // final List<PermissionSetAssignment> psaToInsertList = new List<PermissionSetAssignment>();

            final Map<String, String> psIdToNameMap = new Map<String, String>();

            for (PermissionSetGroup pr : [SELECT Id, MasterLabel FROM PermissionSetGroup WHERE MasterLabel LIKE 'NTSP%']) {
                psIdToNameMap.put(pr.MasterLabel, pr.Id);
            }

            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = nurse.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Triage Nurse')) );
            mockPermGroupAssignment(nurse.Id, psIdToNameMap.get('NTSP Triage Nurse'));

            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = consultant.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Consultant')) );
            mockPermGroupAssignment(consultant.Id, psIdToNameMap.get('NTSP Consultant'));

            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = nursePR.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Triage Nurse')) );
            mockPermGroupAssignment(nursePR.Id, psIdToNameMap.get('NTSP Triage Nurse'));
            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = nursePR.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Triage Nurse Peer Reviewer')) );
            mockPermGroupAssignment(nursePR.Id, psIdToNameMap.get('NTSP Triage Nurse Peer Reviewer'));

            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = consultantPR.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Consultant')) );
            mockPermGroupAssignment(consultantPR.Id, psIdToNameMap.get('NTSP Consultant'));
            // psaToInsertList.add( new PermissionSetAssignment(AssigneeId = consultantPR.Id, PermissionSetGroupId = psIdToNameMap.get('NTSP Consultant Peer Reviewer')) );
            mockPermGroupAssignment(consultantPR.Id, psIdToNameMap.get('NTSP Consultant Peer Reviewer'));

            // insert psaToInsertList;
        }
    }

    /**
     * @description Method to create locations
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void createLocations() {
        final List<Schema.Location> locationsList = new List<Schema.Location>();

        for (Integer i = 1; i <= 4; i++) {
            locationsList.add(
                new Schema.Location(Name = 'Test ' + i, LocationType = testString, VAF_Facility_ID__c = facilityId + i, VAF_Location_Time_Zone__c = 'America/Chicago')
            );
        }

        insert locationsList;

        List<NTSP_Facility__c> facilityList = new List<NTSP_Facility__c>();
        for (Schema.Location loc : locationsList) {
            facilityList.add(new NTSP_Facility__c(Name = loc.Name, Station_Code__c = facilityId, NTSP_Registered_Site__c = true, Location__c = loc.Id));
        }
        facilityList[facilityList.size() - 1].NTSP_Registered_Site__c = false;

        insert facilityList;
    }

    /**
     * @description Method to create NTSP cases
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void createCases() {
        final User nurse = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse' LIMIT 1];
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name, CreatedById, NTSP_Registered_Site__c FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];

        mockFacilityCriteriaSharing(new List<NTSP_Facility__c>{ location }, nurse.Id);

        //Create Cases to appear in search, as well as one with blank facility to check if filter is correct
        System.runAs(nurse) {
            final List<NTSP_Case__c> caseList = new List<NTSP_Case__c>();

            for (Integer i = 1; i <= 3; i++) {
                caseList.add(
                    new NTSP_Case__c(
                        Consult_Date__c = Date.today(),
                        Consult_Time_Local_Time_24_hrs__c = consultTime,
                        Last_Name__c = testString,
                        Last_Four__c = facilityId,
                        Telestroke_Consultant__c = consultant.Id,
                        NTSP_Facility__c = location.Id,
                        Location__c = inpatient
                    )
                );
            }

            caseList.add(
                new NTSP_Case__c(
                    Consult_Date__c = Date.today(),
                    Consult_Time_Local_Time_24_hrs__c = consultTime,
                    Last_Name__c = testString,
                    Last_Four__c = facilityId,
                    Telestroke_Consultant__c = consultant.Id,
                    Location__c = inpatient
                )
            ); //Facility left blank

            insert caseList;

            //This case should appear on the second from the top of the case search list as it is the most recent by autonumber
            final NTSP_Case__c completedPRCase = new NTSP_Case__c(
                Consult_Date__c = Date.today(),
                Consult_Time_Local_Time_24_hrs__c = consultTime,
                Last_Name__c = 'Completed',
                Last_Four__c = facilityId,
                Telestroke_Consultant__c = consultant.Id,
                NTSP_Facility__c = location.Id,
                Location__c = inpatient
            );
            insert completedPRCase;
        }

        final User nursePR = [SELECT Id, UserName FROM User WHERE LastName = 'NTSP Nurse PR' LIMIT 1];
        final User consultantPR = [SELECT Id, UserName FROM User WHERE LastName = 'NTSP Consultant PR' LIMIT 1];

        mockFacilityCriteriaSharing(new List<NTSP_Facility__c>{ location }, nursePR.Id);

        //This newest case will be on the top of the search list as it is most recent, used to test 'Own Case' scenario
        System.runAs(nursePR) {
            insert new NTSP_Case__c(
                Consult_Date__c = Date.today(),
                Consult_Time_Local_Time_24_hrs__c = consultTime,
                Last_Name__c = testString,
                Last_Four__c = facilityId,
                Telestroke_Consultant__c = consultantPR.Id,
                NTSP_Facility__c = location.Id,
                Location__c = inpatient
            );
        }
    }

    /**
     * @description Method to create NTSP Peer Reviews
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void createPeerReviews() {
        final List<NTSP_Peer_Review__c> prToInsertList = new List<NTSP_Peer_Review__c>();

        final NTSP_Case__c completedPRCase = [SELECT Id, NTSP_Facility__c FROM NTSP_Case__c WHERE Last_Name__c = 'Completed'];

        final Id consultRtId = Schema.SObjectType.NTSP_Peer_Review__c.getRecordTypeInfosByName().get('Consultant Peer Review').getRecordTypeId();
        final Id nurseRtId = Schema.SObjectType.NTSP_Peer_Review__c.getRecordTypeInfosByName().get('Triage Nurse Peer Review').getRecordTypeId();

        NTSP_Peer_Review__c nurseReview = new NTSP_Peer_Review__c(
            NTSP_Case__c = completedPRCase.Id,
            RecordTypeId = nurseRtId,
            NTSP_Facility__c = completedPRCase.NTSP_Facility__c,
            Length_of_Call_With_Facility__c = '0500',
            Call_length_with_NTSP_Consultant__c = '0500'
        );
        prToInsertList.add(nurseReview);

        NTSP_Peer_Review__c consultantReview = new NTSP_Peer_Review__c(
            NTSP_Case__c = completedPRCase.Id,
            RecordTypeId = consultRtId,
            NTSP_Facility__c = completedPRCase.NTSP_Facility__c,
            Length_of_Call_With_Facility__c = '0500',
            Call_length_with_NTSP_Consultant__c = '0500'
        );
        prToInsertList.add(consultantReview);

        insert prToInsertList;

        final User nursePR = [SELECT Id, UserName FROM User WHERE LastName = 'NTSP Nurse PR' LIMIT 1];
        final User consultantPR = [SELECT Id, UserName FROM User WHERE LastName = 'NTSP Consultant PR' LIMIT 1];

        mockPeerReviewCriteriaSharing(nurseReview.Id, nursePR.Id);

        mockPeerReviewCriteriaSharing(consultantReview.Id, consultantPR.Id);
    }

    /**
     * @description Method to mimic criteria sharing rules for NTSP Case
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void mockCaseCriteriaSharing(List<NTSP_Case__c> caseList, Id userId) {
        final List<NTSP_Case__Share> caseShareList = new List<NTSP_Case__Share>();

        for (NTSP_Case__c ntspCase : caseList) {
            if (ntspCase.CreatedById == userId) {
                continue;
            }

            final NTSP_Case__Share caseShare = new NTSP_Case__Share();

            caseShare.ParentId = ntspCase.Id;

            caseShare.UserOrGroupId = userId;

            caseShare.AccessLevel = 'Edit';

            caseShare.RowCause = Schema.NTSP_Case__Share.RowCause.Manual;

            caseShareList.add(caseShare);
        }

        insert caseShareList;
    }

    /**
     * @description Method to mimic criteria sharing rules for NTSP Facility
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void mockFacilityCriteriaSharing(List<NTSP_Facility__c> facList, Id userId) {
        final List<NTSP_Facility__Share> caseShareList = new List<NTSP_Facility__Share>();

        for (NTSP_Facility__c ntspFacility : facList) {
            if (ntspFacility.CreatedById == userId) {
                continue;
            }

            final NTSP_Facility__Share caseShare = new NTSP_Facility__Share();

            caseShare.ParentId = ntspFacility.Id;

            caseShare.UserOrGroupId = userId;

            caseShare.AccessLevel = 'Read';

            caseShare.RowCause = Schema.NTSP_Facility__Share.RowCause.Manual;

            caseShareList.add(caseShare);
        }

        insert caseShareList;
    }

    /**
     * @description Method to mimic criteria sharing rules for NTSP Peer Review
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    public static void mockPeerReviewCriteriaSharing(Id prId, Id userId) {
        final NTSP_Peer_Review__Share prShare = new NTSP_Peer_Review__Share();

        prShare.ParentId = prId;

        prShare.UserOrGroupId = userId;

        prShare.AccessLevel = 'Edit';

        prShare.RowCause = Schema.NTSP_Peer_Review__Share.RowCause.Manual;

        insert prShare;
    }

    /**
     * @description Method to mimic permission set group assignments
     * @author George Elias | 04-28-2022
     * @return  void
     **/
    public static void mockPermGroupAssignment(Id userId, Id psgId) {
        List<PermissionSetAssignment> lsPSA = new List<PermissionSetAssignment>();

        for (PermissionSetGroupComponent psgc : [SELECT PermissionSetId FROM PermissionSetGroupComponent WHERE PermissionSetGroupId = :psgId]) {
            lsPSA.add(new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = psgc.PermissionSetId));
        }

        insert lsPSA;
    }
}
