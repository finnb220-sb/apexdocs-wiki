/**
 * @author Booz Allen
 * @description Test class for VCC_HighlightBarController
 * @see VCC_HighlightBarController
 */

@IsTest
public class VCC_HighlightBarControllerTest {
    private static final User RN_USER;
    private static final Set<String> PROGRESS_NOTE_FIELDS;
    private static final Set<String> CASE_FIELDS;
    private static final Set<String> CONTACT_FIELDS;
    private static final Set<String> ACCOUNT_FIELDS;
    private static VCC_Progress_Note__c progressNote;
    private static Case caseRecord;
    private static Contact contactRecord;
    private static Account accountRecord;

    static {
        RN_USER = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_RN_User')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
        CONTACT_FIELDS = new Set<String>{ 'AccountId', 'VCC_Emergency_Contact__c', 'VCC_Emergency_Contact_Phone__c' };
        CASE_FIELDS = new Set<String>{ 'VCC_Call_back_phone_number__c', 'ContactId' };
        PROGRESS_NOTE_FIELDS = new Set<String>{
            'VCC_Date_of_Birth__c',
            'VCC_Patient_Age__c',
            'VCC_Gender__c',
            'VCC_Current_Location__c',
            'VCC_Case__c'
        };
        ACCOUNT_FIELDS = new Set<String>{ 'VCC_Gender_Identity__c' };
    }

    /**
     * @description Creates test data including Contact, Case, and Progress Note records.
     */
    static void makeData() {
        // Create test Account
        accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.put('VCC_Gender_Identity__c', 'Female');
        Assert.isNotNull(RN_USER, 'RN_USER was not created');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(accountRecord);
        }

        // Create test Contact
        contactRecord = new Contact();
        contactRecord.FirstName = 'Test';
        contactRecord.LastName = 'Contact';
        contactRecord.AccountId = accountRecord.Id;
        contactRecord.put('VCC_Emergency_Contact__c', 'Emergency Contact Name');
        contactRecord.put('VCC_Emergency_Contact_Phone__c', '098-765-4321');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(contactRecord);
        }

        // Create test Case
        caseRecord = new Case();
        caseRecord.ContactId = contactRecord.Id;
        caseRecord.Subject = 'Test Case';
        caseRecord.put('VCC_Call_back_phone_number__c', '123-456-7890');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(caseRecord);
        }

        // Create test Progress Note
        progressNote = new VCC_Progress_Note__c();
        progressNote.VCC_Case__c = caseRecord.Id;
        progressNote.put('VCC_Date_of_Birth__c', Date.newInstance(1990, 1, 1));
        progressNote.put('VCC_Gender__c', 'M');
        progressNote.put('VCC_Current_Location__c', 'Test Location');
        System.runAs(RN_USER) {
            VATEST_SObjectFactory.createSObject(progressNote);
        }
    }

    /**
     * @description Unit test for VCC_HighlightBarController.getPatientDemographics method.
     *              Verifies that the method correctly returns demographics when all related records are present.
     */
    @IsTest
    static void unitGetPatientDemographicsPositive() {
        makeData();
        VTC_RepoFactory.reposByObjName.put(
            'VCC_Progress_Note__c',
            createProgressNoteRepo(progressNote, progressNote.Id)
        );
        VTC_RepoFactory.reposByObjName.put('Case', createCaseRepo(caseRecord, caseRecord.Id));
        VTC_RepoFactory.reposByObjName.put('Contact', createContactRepo(contactRecord, contactRecord.Id));
        VTC_RepoFactory.reposByObjName.put('Account', createAccountRepo(accountRecord, accountRecord.Id));

        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            demographics = VCC_HighlightBarController.getPatientDemographics(progressNote.Id);
            Test.stopTest();
        }

        // Assert the demographics map contains expected values
        Assert.areEqual(
            '1990-01-01 00:00:00',
            demographics.get('DOB'),
            'Expected DOB to be "1990-01-01 00:00:00" but found different value.'
        );
        Assert.areEqual('M', demographics.get('Gender'), 'Expected Gender to be "M" but found different value.');
        Assert.areEqual(
            'Test Location',
            demographics.get('Current Location'),
            'Expected Current Location to be "Test Location" but found different value.'
        );
        Assert.areEqual(
            '123-456-7890',
            demographics.get('Call Back Number'),
            'Expected Call Back Number to be "123-456-7890" but found different value.'
        );
        Assert.areEqual(
            contactRecord.Id,
            demographics.get('ContactId'),
            'Expected ContactId to match the provided Contact record ID but found different value.'
        );
        Assert.areEqual(
            'Emergency Contact Name',
            demographics.get('Emergency Contact'),
            'Expected Emergency Contact to be "Emergency Contact Name" but found different value.'
        );
        Assert.areEqual(
            '098-765-4321',
            demographics.get('Emergency Contact Phone'),
            'Expected Emergency Contact Phone to be "098-765-4321" but found different value.'
        );
        Assert.areEqual(
            accountRecord.Id,
            demographics.get('AccountId'),
            'Expected AccountId to match the provided Account record ID but found different value.'
        );
        Assert.areEqual(
            'Female',
            demographics.get('Gender Identity'),
            'Expected Gender Preferred to be "Female" but found different value.'
        );
    }

    /**
     * @description Unit test for VCC_HighlightBarController.getPatientDemographics method.
     *              Verifies that the method correctly handles the absence of Account record.
     */
    @IsTest
    static void unitGetPatientDemographicsAccountExceptionNegative() {
        makeData();
        VTC_RepoFactory.reposByObjName.put(
            'VCC_Progress_Note__c',
            createProgressNoteRepo(progressNote, progressNote.Id)
        );
        VTC_RepoFactory.reposByObjName.put('Case', createCaseRepo(caseRecord, caseRecord.Id));
        VTC_RepoFactory.reposByObjName.put('Contact', createContactRepo(contactRecord, contactRecord.Id));
        VTC_RepoFactory.reposByObjName.put('Account', createAccountRepoWithException(contactRecord.Id));

        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            try {
                demographics = VCC_HighlightBarController.getPatientDemographics(progressNote.Id);
                Assert.fail('Expected exception was not thrown.');
            } catch (IllegalArgumentException exc) {
                Assert.isNotNull(
                    exc.getMessage(),
                    'Expected exc.getMessage() to not be null but found a different value.'
                );
                Assert.isTrue(demographics.isEmpty(), 'Expected demographics to be Empty but found different value.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Unit test for VCC_HighlightBarController.getPatientDemographics method.
     *              Verifies that the method correctly handles the absence of Contact record.
     */
    @IsTest
    static void unitGetPatientDemographicsContactExceptionNegative() {
        makeData();
        VTC_RepoFactory.reposByObjName.put(
            'VCC_Progress_Note__c',
            createProgressNoteRepo(progressNote, progressNote.Id)
        );
        VTC_RepoFactory.reposByObjName.put('Case', createCaseRepo(caseRecord, caseRecord.Id));
        VTC_RepoFactory.reposByObjName.put('Contact', createContactRepoWithException(contactRecord.Id));

        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            try {
                demographics = VCC_HighlightBarController.getPatientDemographics(progressNote.Id);
                Assert.fail('Expected exception was not thrown.');
            } catch (IllegalArgumentException exc) {
                Assert.isNotNull(
                    exc.getMessage(),
                    'Expected exc.getMessage() to not be null but found a different value.'
                );
                Assert.isNotNull(caseRecord.Id, 'Expected caseRecord.Id to not be null  but found a different value.');
                Assert.isTrue(demographics.isEmpty(), 'Expected demographics to be Empty but found different value.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Unit test for VCC_HighlightBarController.getPatientDemographics method.
     *              Verifies that the method correctly handles the absence of Case record.
     */
    @IsTest
    static void unitGetPatientDemographicsCaseExceptionNegative() {
        makeData();
        VTC_RepoFactory.reposByObjName.put(
            'VCC_Progress_Note__c',
            createProgressNoteRepo(progressNote, progressNote.Id)
        );
        VTC_RepoFactory.reposByObjName.put('Case', createCaseRepoWithException(caseRecord.Id));

        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            try {
                demographics = VCC_HighlightBarController.getPatientDemographics(progressNote.Id);
                Assert.fail('Expected exception was not thrown.');
            } catch (IllegalArgumentException exc) {
                Assert.isNotNull(
                    exc.getMessage(),
                    'Expected exc.getMessage() to not be null but found a different value.'
                );
                Assert.isTrue(demographics.isEmpty(), 'Expected demographics to be Empty but found different value.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Unit test for VCC_HighlightBarController.getPatientDemographics method.
     *              Verifies that the method correctly handles the absence of Progress Note record.
     */
    @IsTest
    static void unitGetPatientDemographicsProgressNoteExceptionNegative() {
        makeData();
        VTC_RepoFactory.reposByObjName.put(
            'VCC_Progress_Note__c',
            createProgressNoteRepoWithException(progressNote.Id)
        );

        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            try {
                demographics = VCC_HighlightBarController.getPatientDemographics(progressNote.Id);
                Assert.fail('Expected exception was not thrown.');
            } catch (IllegalArgumentException exc) {
                Assert.isNotNull(
                    exc.getMessage(),
                    'Expected exc.getMessage() to not be null but found a different value.'
                );
                Assert.isTrue(demographics.isEmpty(), 'Expected demographics to be Empty but found different value.');
            }
            Test.stopTest();
        }
    }

    /**
     * @description Tests the behavior when no progress note ID is provided.
     *              Validates that no demographic information is returned.
     */
    @IsTest
    static void unitGetPatientDemographicsNoProgressNoteIdNegative() {
        Map<String, String> demographics = new Map<String, String>();
        // Call the method and get the demographics map
        System.runAs(RN_USER) {
            Test.startTest();
            demographics = VCC_HighlightBarController.getPatientDemographics('');
            Test.stopTest();
        }
        Assert.isTrue(demographics.isEmpty(), 'Expected demographics to be Empty but found different value.');
    }

    /**
     * @description Creates a mock VCR_ProgressNoteRepo that returns the specified SObject for fetchById method.
     * @param returnValue The SObject to return.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_ProgressNoteRepo instance.
     */
    private static VCR_ProgressNoteRepo createProgressNoteRepo(SObject returnValue, Id recordId) {
        return (VCR_ProgressNoteRepo) new VATEST_StubBuilder(VCR_ProgressNoteRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, PROGRESS_NOTE_FIELDS)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_ProgressNoteRepo that throws an exception for fetchById method.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_ProgressNoteRepo instance that throws an exception.
     */
    private static VCR_ProgressNoteRepo createProgressNoteRepoWithException(Id recordId) {
        return (VCR_ProgressNoteRepo) new VATEST_StubBuilder(VCR_ProgressNoteRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, PROGRESS_NOTE_FIELDS)
            .throwingException()
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_CaseRepo that returns the specified SObject for fetchById method.
     * @param returnValue The SObject to return.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_CaseRepo instance.
     */
    private static VCR_CaseRepo createCaseRepo(SObject returnValue, Id recordId) {
        return (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, CASE_FIELDS)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_CaseRepo that throws an exception for fetchById method.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_CaseRepo instance that throws an exception.
     */
    private static VCR_CaseRepo createCaseRepoWithException(Id recordId) {
        return (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, CASE_FIELDS)
            .throwingException()
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_ContactRepo that returns the specified SObject for fetchById method.
     * @param returnValue The SObject to return.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_ContactRepo instance.
     */
    private static VCR_ContactRepo createContactRepo(SObject returnValue, Id recordId) {
        return (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, CONTACT_FIELDS)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_ContactRepo that throws an exception for fetchById method.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_ContactRepo instance that throws an exception.
     */
    private static VCR_ContactRepo createContactRepoWithException(Id recordId) {
        return (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, CONTACT_FIELDS)
            .throwingException()
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_AccountRepo that returns the specified SObject for fetchById method.
     * @param returnValue The SObject to return.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_AccountRepo instance.
     */
    private static VCR_AccountRepo createAccountRepo(SObject returnValue, Id recordId) {
        return (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, ACCOUNT_FIELDS)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description Creates a mock VCR_AccountRepo that throws an exception for fetchById method.
     * @param recordId The ID of the record to fetch.
     * @return A mocked VCR_AccountRepo instance that throws an exception.
     */
    private static VCR_AccountRepo createAccountRepoWithException(Id recordId) {
        return (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById')
            .withParameterTypes(Id.class, Set<String>.class)
            .withParameterValues(recordId, ACCOUNT_FIELDS)
            .throwingException()
            .defineStub();
    }
}
