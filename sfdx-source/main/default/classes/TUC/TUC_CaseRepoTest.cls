/**
 * @description       : Test Class for TUC_CaseRepo
 * @author            : Booz Allen Hamilton
 *
 * @see TUC_CaseRepo
 **/
@IsTest
private with sharing class TUC_CaseRepoTest {
    private static final Integer COUNT_OF_CASES_PER_STATUS = 1;
    private static final String CONTROLLING_METADATA_DEVELOPER_NAME = 'Available_Cases_By_VISN';
    private static final String NEW_STRING = 'New';
    private static final String READY_FOR_MP_STRING = 'Ready for MP';
    private static final String CLOSED_STRING = 'Closed';
    private static final Decimal VISN_DECIMAL = 8;
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
     **/
    private static final TUC_CaseRepo caseRepo {
        get {
            TUC_CaseRepo caseRepoLocal = new TUC_CaseRepo();
            caseRepoLocal.setConfigVisnIds(new List<Decimal>{ VISN_DECIMAL });
            return caseRepoLocal;
        }
    }

    /**
     * @description - Tries to go through and set up some base Case data, 100 records for each status
     **/
    @TestSetup
    private static void testDataSetup() {
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
     * @description - Sanity check for the test data setup to ensure the base load of cases was set up correctly. Smaller dataset of 1 case per status.
     **/
    @IsTest
    static void funcDataSetupSanityCheckPositive() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            Integer expectedCount = COUNT_OF_CASES_PER_STATUS * (caseRepo.kanbanConfig.includedCaseStatuses.size());
            Integer countOfCases = [SELECT Id FROM Case].size();
            Assert.areEqual(
                expectedCount,
                countOfCases,
                'Expected ' + expectedCount + ' Cases but was ' + countOfCases
            );
        }
    }

    /**
     * @description - Sanity check test to ensure that the config is set up correctly
     * @see TUC_CaseRepo() and Config subclass
     */
    @IsTest
    static void unitConfigSanityCheck() {
        System.runAs(DOCTOR_USER) {
            Assert.isNotNull(caseRepo.kanbanConfig.rawCMDT, 'Expected Config to build correctly from constructor');
        }
    }

    /**
     * @description - Tests the advanced constructor and metadata retrieval class used by the Controller
     * @see TUC_CaseRepo().fetchKanbanConfigMetadata(String kanbanConfigId)
     */
    @IsTest
    static void unitCheckMetadataConstructorAndRetrieval() {
        System.runAs(DOCTOR_USER) {
            TUC_Kanban_Config__mdt defaultMetadata = TUC_Kanban_Config__mdt.getInstance(
                CONTROLLING_METADATA_DEVELOPER_NAME
            );
            TUC_CaseRepo caseRepoWithInput = new TUC_CaseRepo(CONTROLLING_METADATA_DEVELOPER_NAME);
            Assert.isNotNull(
                caseRepoWithInput.kanbanConfig.rawCMDT,
                'Expected Config to build correctly from constructor with provided Id'
            );

            TUC_Kanban_Config__mdt returnedMetadata = caseRepoWithInput.fetchKanbanConfigMetadata();
            Assert.areEqual(defaultMetadata.Id, returnedMetadata.Id, 'Expected Config metadata to match');
        }
    }

    /**
     * @description - Tests the Fetch class for New and Patient Callback
     * @see TUC_CaseRepo().fetchCasesSortedByWaitTime(String statusString)
     */
    @IsTest
    static void unitFetchCasesSortedByWaitTime() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            List<Case> caseList = caseRepo.fetchCasesSortedByWaitTime(NEW_STRING);
            Assert.isFalse(caseList.isEmpty(), 'Expected the returned list to have data.');
        }
    }

    /**
     * @description - Tests the Fetch class for the default order by
     * @see TUC_CaseRepo().fetchCasesByStatus(String statusString)
     */
    @IsTest
    static void unitFetchCasesByStatus() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            List<Case> caseList = caseRepo.fetchCasesByStatus(READY_FOR_MP_STRING);
            Assert.isFalse(caseList.isEmpty(), 'Expected the returned list to have data.');
        }
    }

    /**
     * @description - Tests the Fetch class for Closed cases
     * @see TUC_CaseRepo().fetchClosedCases(String statusString)
     */
    @IsTest
    static void unitFetchClosedCases() {
        User creatingUser = getCreatingUser();
        System.runAs(creatingUser) {
            List<Case> caseList = caseRepo.fetchClosedCases(CLOSED_STRING);
            Assert.isFalse(caseList.isEmpty(), 'Expected the returned list to have data.');
        }
    }

    /**
     * @description - Tests the Update Record for a positive Result
     * @see TUC_CaseRepo().updateRecord(String recordId, String recordField, String recordVal)
     */
    @isTest
    private static void unitUpdateRecordPositive() {
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            String returnString = caseRepo.updateRecord(String.valueOf(newCase.id), 'description', 'test-description');
            Test.stopTest();
            Assert.isTrue(returnString.contains('true'), 'Expected to successfully update the object');
        }
    }

    /**
     * @description - Tests the Update Record for a negative Result
     * @see TUC_CaseRepo().updateRecord(String recordId, String recordField, String recordVal)
     */
    @isTest
    private static void unitUpdateRecordNegative() {
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            Contact newContact = new Contact();
            newContact.LastName = 'demo';
            VATEST_SObjectFactory.createSObject(newContact, true);
            SObject newOpportunity = new Opportunity();
            newOpportunity.put('Name', 'value');
            newOpportunity.put('contactId', newContact.id);
            newOpportunity.put('StageName', 'Qualification');
            newOpportunity.put('CloseDate', Date.today());
            VATEST_SObjectFactory.createSObject(newOpportunity, true);
            String returnString = caseRepo.updateRecord(
                String.valueOf(newOpportunity.id),
                'stagename',
                'Qualification'
            );
            caseRepo.updateRecord(String.valueOf(newOpportunity.id) + 'a', 'stagenam', 'Qualificatio1');
            Test.stopTest();
            Assert.isFalse(
                returnString.contains('true'),
                'Expected to not have update access but update access to the object was unexpectedly allowed'
            );
        }
    }

    /**
     * @description - Tests the Delete Record for a positive Result
     * @see TUC_CaseRepo().deleteRecord(SObject deleteTarget)
     * @justification - Delete permissions is not available for the standard user profile.
     *                  Running as a System Admin for this method.
     */
    @isTest
    private static void unitDeleteRecordPositive() {
        VATEST_UserBuilder builder = new VATEST_UserBuilder();
        User sysAdminUser = builder.withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
        System.runAs(sysAdminUser) {
            Test.startTest();
            Case newCase = (Case) VATEST_SObjectFactory.createSObject(new Case(), true);
            String didDelete = caseRepo.deleteRecord(newCase);
            Test.stopTest();
            Assert.isTrue(didDelete.contains('true'), 'Expected to successfully delete the record');
        }
    }

    /**
     * @description - Tests the Delete Record for a negative Result
     * @see TUC_CaseRepo().deleteRecord(SObject deleteTarget)
     */
    @isTest
    private static void unitDeleteRecordNegative() {
        System.runAs(DOCTOR_USER) {
            Test.startTest();
            Contact newContact = new Contact();
            newContact.LastName = 'demo';
            VATEST_SObjectFactory.createSObject(newContact, true);
            SObject newOpportunity = new Opportunity();
            newOpportunity.put('Name', 'value');
            newOpportunity.put('contactId', newContact.id);
            newOpportunity.put('StageName', 'Qualification');
            newOpportunity.put('CloseDate', Date.today());
            VATEST_SObjectFactory.createSObject(newOpportunity, true);
            String didDelete = caseRepo.deleteRecord(newOpportunity);
            Test.stopTest();
            Assert.isFalse(
                didDelete.contains('true'),
                'Expected to not have delete access but record was unexpectedly deleted'
            );
        }
    }

    /**
     * @description - Gets the user that created Case data in the dataSetup for the sanity check and other various fetch test methods
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
