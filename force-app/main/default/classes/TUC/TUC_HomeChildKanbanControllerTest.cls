/**
 * @description Test class for TUC_HomeChildKanbanController
 * @author Booz Allen Hamilton
 *
 * @see TUC_HomeChildKanbanController
 */
@IsTest
private with sharing class TUC_HomeChildKanbanControllerTest {
    /// NB: TED_CaseStatusChanged__e is fired by the flow TED CaseStatusChanged, but never consumed (delivered).
    /// Which is on us. It seems to a forgotten PE that used to be used in the past by Tele-EC.
    ///
    /// Until this is resolved, the maximum # of cases we can create is 500 because only 500 Platform Events can be
    /// published in a single transaction. This is less than the real-life-worst-case query situation of 600 cases.
    /// Thus, 83 * 6 distinct statuses = 498 cases is the maximum we can create in a single transaction.
    ///
    /// NB: I've deactivated the flow that fires TED_CaseStatusChanged__e. This is a temporary measure to allow us to
    /// create a large dataset for testing.
    ///
    private static final Integer COUNT_OF_CASES_PER_STATUS = 83;
    private static final Decimal VISN_DECIMAL = 8;
    private static final String GROUP_NAME_STRING = 'Onboarding queue';
    private static final String GROUP_DEV_NAME_STRING = 'TUC_000_testgroup';
    private static final String GROUP_TYPE_STRING = 'Queue';
    private static final User DOCTOR_USER;
    static {
        DOCTOR_USER = new VATEST_UserBuilder()
            .withStandardData()
            .withPermissionSet('TED_Medical_Provider_Group')
            .setFields(User.Division, 'VISN 0')
            .setFields(User.LastName, 'TheTestUser')
            .withUserProfile('VAVET Base Profile')
            .build(true);
    }

    /**
     * @description - Private instantiation of the TUC_CaseRepo
     */
    private static final TUC_CaseRepo caseRepo {
        get {
            return caseRepo ?? new TUC_CaseRepo();
        }
    }

    @TestSetup
    private static void testDataSetup() {
        // in an effort to test apples to oranges, and to test worst case scenarios we'll use a large dataset
        // consisting of 100 case records for every status.
        Id highAcuityRecordType = caseRepo.recordTypeConstant.fromDeveloperName('Tele_Urgent_Care_0_2_Hours').Id;
        Id personAccountRecordType = new VCR_AccountRepo().recordTypeConstant.fromDeveloperName('PersonAccount').Id;

        /// SETUP Objects
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = 'Onboarding queue', DeveloperName = 'TUC_0_testgroup', Type = 'Queue'),
            true
        );

        VATEST_SObjectFactory.createSObject(new QueueSobject(QueueId = testGroup.Id, SObjectType = 'Case'), true);

        Schema.Location facility = (Schema.Location) VATEST_SObjectFactory.createSObject(
            new Schema.Location(
                Name = 'Test Facility',
                VAF_Facility_ID__c = 'VAF_8675309',
                LocationType = 'Site',
                VAF_Facility_Type__c = 'va_health_facility',
                VAF_VISN__c = VISN_DECIMAL
            ),
            true
        );

        VATEST_SObjectFactory.createSObject(
            new GroupMember(GroupId = testGroup.Id, UserOrGroupId = DOCTOR_USER.Id),
            true
        );

        System.runAs(DOCTOR_USER) {
            Account personAccount = (Account) VATEST_SObjectFactory.createSObject(
                new Account(RecordTypeId = personAccountRecordType),
                true
            );
            for (String status : caseRepo.kanbanConfig.includedCaseStatuses) {
                VATEST_SObjectFactory.createSObjects(
                    new Case(
                        RecordTypeId = highAcuityRecordType,
                        Status = status,
                        Subject = 'Test Case',
                        OwnerId = testGroup.Id,
                        AccountId = personAccount.Id,
                        TUC_Assigned_Facility__c = facility.Id
                    ),
                    COUNT_OF_CASES_PER_STATUS,
                    true
                );
            }
        }
    }

    /**
     * @description - Test worst case scenarios using a large dataset consisting of 100 case records for every status.
     **/
    @IsTest
    static void funcDataSetupSanityCheckPositive() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            Integer expectedCount = COUNT_OF_CASES_PER_STATUS * (caseRepo.kanbanConfig.includedCaseStatuses.size() - 1);
            Integer countOfCases = [SELECT Id FROM Case].size();
            Assert.areEqual(
                expectedCount,
                countOfCases,
                'Expected ' + expectedCount + ' Cases but was ' + countOfCases
            );
        }
    }

    /**
     * @description - Full functional test that encompasses the whole process of retrieving a Case dataset for the TUC Case Kanban.
     *                Includes some CPU timing information that can be caught by comment for rigor testing.
     * @see TUC_HomeChildKanbanController.getKanban(List<String> visnFilterValues)
     **/
    @IsTest
    private static void funcTestRefactoredGetKanbanPositive() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            List<Double> queryCpuTimings = new List<Double>();
            List<Double> queryDbTimings = new List<Double>();

            Integer executionCount = 11;
            TUC_HomeChildKanbanDTO kanban;

            Test.startTest();
            for (Integer index = 1; index <= executionCount; index++) {
                Double startingTime = Datetime.now().getTime();
                kanban = TUC_HomeChildKanbanController.getKanban(new List<String>{ '' + VISN_DECIMAL });
                Double endingTime = Datetime.now().getTime();
                Double duration = endingTime - startingTime;
                queryCpuTimings.add(duration);
                queryDbTimings.add(duration - Limits.getCpuTime());
            }
            Test.stopTest();

            Assert.isFalse(kanban.records.isEmpty(), 'Kanban was expected to return records.');
        }
    }

    /**
     * @description - Unit test for getKanban to test for a positive result
     * @see TUC_HomeChildKanbanController.getKanban(List<String> visnFilterValues)
     **/
    @IsTest
    private static void unitTestRefactoredGetKanbanStubbedPositive() {
        User creatingUser = getCreatingUser();

        Map<String, List<Case>> caseMap = new Map<String, List<Case>>();

        List<Decimal> decimalList = new List<Decimal>{ VISN_DECIMAL };
        TUC_GetKanbanStrategyInterface strategy = new TUC_IndividualQueriesProvider();

        TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('fetchListOfCasesForVisns')
            .withParameterTypes(List<Decimal>.class, TUC_GetKanbanStrategyInterface.class)
            .withParameterValues(decimalList, strategy)
            .returning(caseMap)
            .defineStub();
        TUC_HomeChildKanbanController.caseRepo = stubRepo;

        System.runAs(creatingUser) {
            TUC_HomeChildKanbanDTO kanban;

            Test.startTest();
            kanban = TUC_HomeChildKanbanController.getKanban(new List<String>{ '' + VISN_DECIMAL });
            Test.stopTest();

            Assert.areEqual(caseMap, kanban.records, 'Kanban was expected to be an empty map.');
        }
    }

    /**
     * @description - Unit test for Update record, stubbed, positive result
     * @see TUC_HomeChildKanbanController.updateRecord(String recordId, String recordField, String recordValue)
     **/
    @isTest
    private static void unitUpdateRecordStubbedPositive() {
        String recordId = '1234';
        String recordField = 'description';
        String recordValue = 'test-description';
        String expectedReturn = 'true';

        TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('updateRecord')
            .withParameterTypes(String.class, String.class, String.class)
            .withParameterValues(recordId, recordField, recordValue)
            .returning(expectedReturn)
            .defineStub();
        TUC_HomeChildKanbanController.caseRepo = stubRepo;
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            String returnString = TUC_HomeChildKanbanController.updateRecord(recordId, recordField, recordValue);
            Test.stopTest();
            Assert.areEqual(expectedReturn, returnString, 'Expected to successfully update the object');
        }
    }

    /**
     * @description - Unit test for Delete record, stubbed, positive result
     * @see TUC_HomeChildKanbanController.deleteRecord(SObject deleteTarget)
     **/
    @isTest
    private static void unitDeleteRecordStubbedPositive() {
        SObject deleteTarget;
        String expectedReturn = 'true';

        TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('deleteRecord')
            .withParameterTypes(SObject.class)
            .withParameterValues(deleteTarget)
            .returning(expectedReturn)
            .defineStub();
        TUC_HomeChildKanbanController.caseRepo = stubRepo;
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            String returnString = TUC_HomeChildKanbanController.deleteRecord(deleteTarget);
            Test.stopTest();
            Assert.areEqual(expectedReturn, returnString, 'Expected to successfully delete the record');
        }
    }

    @isTest
    private static void unitPushTopicPositive() {
        System.runAs(DOCTOR_USER) {
            String topicName = 'TeleTopic_Test';
            List<PushTopic> pushTopTemp = [SELECT Id, Name FROM PushTopic WHERE Name = :topicName];
            Assert.areEqual(0, pushTopTemp.size(), 'Expecting an empty list');
            TUC_HomeChildKanbanController.setPushTopic(topicName);
            pushTopTemp = [SELECT Id, Name FROM PushTopic WHERE Name = :topicName];
            Assert.areEqual(1, pushTopTemp.size(), 'Expecting a new push topic to be created');
        }
    }

    @isTest
    private static void unitGetKanbanQueryExceptionStubbedNegative() {
        TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('fetchListOfCasesForVisns')
            .withParameterTypes(List<Decimal>.class, TUC_GetKanbanStrategyInterface.class)
            .withParameterValues(null, null)
            .throwingException(new QueryException())
            .defineStub();
        TUC_HomeChildKanbanController.caseRepo = stubRepo;

        String expectedMessage = 'There was an issue getting Tele-EC Kanban Data';
        TUC_HomeChildKanbanDTO result;
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            {
                result = TUC_HomeChildKanbanController.getKanban(null);
            }
            Test.stopTest();
        }

        Assert.isTrue(
            result.errorMessage.contains(expectedMessage),
            'Expected TUC_HomeChildKanbanController.getKanban() method to return a TUC_HomeChildKanbanDTO object with a specific error message.'
        );
    }

    @isTest
    private static void unitGetKanbanConfigPositive() {
        User creatingUser = getCreatingUser();

        TUC_Kanban_Config__mdt kanbanConfigPrototype = new TUC_Kanban_Config__mdt();
        TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
            .mockingMethodCall('fetchKanbanConfigMetadata')
            .withParameterTypes()
            .returning(kanbanConfigPrototype)
            .defineStub();
        TUC_HomeChildKanbanController.caseRepo = stubRepo;
        System.runAs(creatingUser) {
            Test.startTest();
            TUC_Kanban_Config__mdt kanbanConfig = TUC_HomeChildKanbanController.getKanbanConfig();
            Test.stopTest();
            Assert.isNotNull(kanbanConfig, 'Expected to successfully return the config data');
        }
    }

    @isTest
    private static void unitGetVISNFilterPositive() {
        User creatingUser = getCreatingUser();
        String userId = creatingUser.Id;
        Group testGroup = (Group) VATEST_SObjectFactory.createSObject(
            new Group(Name = GROUP_NAME_STRING, DeveloperName = GROUP_DEV_NAME_STRING, Type = GROUP_TYPE_STRING),
            true
        );
        GroupMember member = (GroupMember) VATEST_SObjectFactory.createSObject(
            new GroupMember(GroupId = testGroup.Id, UserOrGroupId = userId),
            true
        );
        List<GroupMember> memberList = new List<GroupMember>{ member };
        List<Id> groupIdList = new List<Id>{ testGroup.Id };
        List<Group> groupList = new List<Group>{ testGroup };

        VCR_GroupMemberRepo stubGroupMemberRepo = (VCR_GroupMemberRepo) new VATEST_StubBuilder(
                VCR_GroupMemberRepo.class
            )
            .mockingMethodCall('fetchByUserOrGroupId')
            .withParameterTypes(Id.class)
            .withParameterValues(userId)
            .returning(memberList)
            .defineStub();
        VCR_GroupRepo stubGroupRepo = (VCR_GroupRepo) new VATEST_StubBuilder(VCR_GroupRepo.class)
            .mockingMethodCall('fetchByGroupIdList')
            .withParameterTypes(List<Id>.class)
            .withParameterValues(groupIdList)
            .returning(groupList)
            .defineStub();
        TUC_HomeChildKanbanController.groupMemberRepo = stubGroupMemberRepo;
        TUC_HomeChildKanbanController.groupRepo = stubGroupRepo;
        System.runAs(creatingUser) {
            Test.startTest();
            String visnString = TUC_HomeChildKanbanController.getVISNFilter();
            Test.stopTest();
            Assert.isNotNull(visnString, 'Expected to successfully return the config data');
        }
    }

    @isTest
    private static void unitLoadRecordPositive() {
        System.runAs(DOCTOR_USER) {
            Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            String recordId = newCase.Id;
            Map<String, String> fieldNames = caseRepo.kanbanConfig.fieldsToDisplayOnPopup;
            TUC_CaseRepo stubRepo = (TUC_CaseRepo) new VATEST_StubBuilder(TUC_CaseRepo.class)
                .mockingMethodCall('fetchById')
                .withParameterTypes(Id.class, Set<String>.class)
                .withParameterValues(recordId, new Set<String>(fieldNames.keySet()))
                .returning(newCase)
                .defineStub();
            stubRepo.kanbanConfig = caseRepo.kanbanConfig;
            TUC_HomeChildKanbanController.caseRepo = stubRepo;

            Test.startTest();
            TUC_HomeChildKanbanController.LinkDetails returnedLinkDetails = TUC_HomeChildKanbanController.loadRecord(
                recordId
            );
            Test.stopTest();
            Assert.isNotNull(returnedLinkDetails, 'Expected to successfully return the LinkDetails');
        }
    }

    @isTest
    private static void unitLoadRecordMinimumNegative() {
        User minimumAccessMolly = VATEST_UserFactory.createMinAccessPersonaUser(false);
        System.runAs(minimumAccessMolly) {
            Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            String recordId = newCase.Id;

            Test.startTest();
            Boolean wasAuraHandledThrown = false;
            try {
                TUC_HomeChildKanbanController.loadRecord(recordId);
                Assert.fail('Should have thrown an exception, as the running user only has minimum access');
            } catch (AuraHandledException auraHandledException) {
                wasAuraHandledThrown = true;
            }
            Assert.isTrue(
                wasAuraHandledThrown,
                'Expected an AuraHandledException to be thrown due to minimum access to load record permissions'
            );
            Test.stopTest();
        }
    }

    @isTest
    private static void unitCheckCustomPermissionPositive() {
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            Boolean doesUserHavePerm = TUC_HomeChildKanbanController.checkCustomPermission('TED_Medical_Provider');
            Test.stopTest();
            Assert.isTrue(doesUserHavePerm, 'Expected to have the perm group set before runAs');
        }
    }

    /**
     * @description - Gets the user that created Case data in the dataSetup for the sanity check and other various fetch test methods
     *                User is reset upon every test method and has a different Id. Queries, even simple get all data queries, will fail
     *                if the current running user isn't the same as the user that created the case data set
     * @return User - The creating user
     */
    private static User getCreatingUser() {
        Case exampleCase = [
            SELECT CreatedById, CreatedBy.Division
            FROM Case
            LIMIT 1
        ];
        return new User(Id = exampleCase.CreatedById, Division = exampleCase.CreatedBy.Division);
    }
}
