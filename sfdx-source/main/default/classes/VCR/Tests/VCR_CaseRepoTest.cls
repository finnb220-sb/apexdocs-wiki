/**
 * @author Booz Allen Hamilton
 * @date 2/14/24
 * @description  Tests for VCR_CaseRepo class.
 * @group Depeche Code
 * @see VCR_CaseRepo
 *
 * NOTE: Suppressing warning for PMD.ApexUnitTestClassShouldHaveRunAs as there is no need to use System.RunAs for the
 *  Repository functional tests.
 */
@IsTest
public with sharing class VCR_CaseRepoTest {
    private static final String QUERY_STRING =
        'SELECT CreatedDate, Id, ParentId, RecordTypeId, OwnerId, TYPEOF Owner WHEN User THEN Name, ' +
        'Division WHEN Group THEN DeveloperName END, (SELECT CreatedDate, Id, ParentId, RecordTypeId,' +
        ' OwnerId, TYPEOF Owner WHEN User THEN Name, Division WHEN Group THEN DeveloperName END FROM Cases),' +
        ' (SELECT Id, VCC_Case__c,VCC_VISN__c, VCC_Child_Case__c, RecordTypeId, VCC_Child_Case_Record_Type__c' +
        ' FROM Case_Metrics__r) FROM Case WHERE RecordType.DeveloperName IN :developerNames ORDER BY CreatedDate ASC';
    private static List<String> developerNames = new List<String>{ 'VCC_Administrative', 'VCC_Clinical_Triage' };
    private static Map<String, Object> bindParams = new Map<String, Object>{ 'developerNames' => developerNames };
    private static final User ADMIN_USER;
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }

    /**
     * @description This is a custom defaults class for handling PersonAccount field defaults to
     *  instantiate in the tests
     */
    public class TestPersonAccountDefaults implements VATEST_SObjectFactory.FieldDefaults {
        /**
         * @description Interface required method returning default values for fields
         * @param prototype SObject - any constructed SObject to populate
         * @return Map<Schema.SObjectField, Object> map of fields and default values
         */
        public Map<Schema.SObjectField, Object> getFieldDefaults(SObject prototype) {
            return new Map<Schema.SObjectField, Object>{
                Account.FirstName => 'Harry',
                Account.LastName => 'Potter',
                Account.RecordTypeId => Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount')
                    .getRecordTypeId(),
                Account.PersonEmail => 'harry@harrypotter.com'
            };
        }
    }

    /**
     * @description Inserts accounts using a data factory
     */
    public static void makeAccounts() {
        VATEST_SObjectFactory.createSObject(new Account(), 'VCR_AccountRepoTest.TestPersonAccountDefaults', true);
    }

    /**
     * @description Test fetchById() for success path
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            Test.startTest();
            repo = new VCR_CaseRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_CaseRepo');
        }
    }

    /**
     * @description Test getting the dynamic queryString.
     * Positive test case for getQueryString()
     * @see VCR_CaseRepo.getQueryString()
     */
    @IsTest
    static void unitTestGetQueryStringPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            String queryString;
            Test.startTest();
            repo = new VCR_CaseRepo();
            queryString = repo.getQueryString();
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryString,
                'Expected the getQueryString() method to return the correct query string'
            );
        }
    }
    /**
     * @description Test getting the dynamic queryLocatorString.
     * Positive test case for getQueryLocatorString()
     * @see VCR_CaseRepo.getQueryLocatorString()
     */
    @IsTest
    static void unitTestGetQueryLocatorStringPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            String queryLocatorString;
            Test.startTest();
            repo = new VCR_CaseRepo();
            queryLocatorString = repo.getQueryLocatorString();
            Test.stopTest();
            Assert.areEqual(
                QUERY_STRING,
                queryLocatorString,
                'Expected the getQueryLocatorString() method to return the correct query string'
            );
        }
    }
    /**
     * @description Test getting the dynamic queryLocator.
     * Positive test case for getQueryLocator()
     * Scenario that covers the happy path which is:
     * 1. User is admin
     * 2. Context is batch
     * 3. QueryLocator is not null
     * 4. BindParams is not null
     * @see VCR_CaseRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorPositive() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_CaseRepo();
            queryLocator = repo.getQueryLocator(repo.getQueryLocatorString(), bindParams);
            Test.stopTest();
            Assert.isNotNull(queryLocator, 'Expected the getQueryLocator() method to return a valid query locator');
        }
    }
    /**
     * @description Test getting the dynamic queryLocator.
     * Negative test case for getQueryLocator()
     * Scenario that covers null query
     * @see VCR_CaseRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorNegativeNullQuery() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_CaseRepo();
            queryLocator = repo.getQueryLocator(null, bindParams);
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to return null');
        }
    }
    /**
     * @description Test getting the dynamic queryLocator.
     * Negative test case for getQueryLocator()
     * Scenario that covers null bindParams
     * @see VCR_CaseRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorNegativeNullBindParams() {
        System.runAs(ADMIN_USER) {
            VCR_CaseRepo repo;
            Database.QueryLocator queryLocator;
            Test.startTest();
            repo = new VCR_CaseRepo();
            queryLocator = repo.getQueryLocator(repo.getQueryLocatorString(), null);
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to return null');
        }
    }
    /**
     * @description Test getting the dynamic queryLocator.
     * Negative test case for getQueryLocator()
     * Scenario that covers that the user is not admin
     * @see VCR_CaseRepo.getQueryLocator()
     */
    @IsTest
    static void unitTestGetQueryLocatorNegativeUserIsNotAdmin() {
        System.runAs(VATEST_UserFactory.create(VATEST_UserPersonaEnum.Nurse, true)) {
            VCR_CaseRepo repo;
            Boolean isExceptionThrown = false;
            Database.QueryLocator queryLocator;
            Test.startTest();
            try {
                repo = new VCR_CaseRepo();
                queryLocator = repo.getQueryLocator(repo.getQueryLocatorString(), bindParams);
            } catch (HandledException handledException) {
                isExceptionThrown = true;
            }
            Test.stopTest();
            Assert.isNull(queryLocator, 'Expected the getQueryLocator() method to return null');
            Assert.isTrue(
                isExceptionThrown,
                'Expected the getQueryLocator() method to throw a HandledException when user is not admin'
            );
        }
    }

    /**
     * @description functional test of upserting cases
     * @see VCR_CaseRepo.upsertCasesAllOrNoneFalse()
     */
    @IsTest
    static void funcUpsertCasesAllOrNoneFalse() {
        List<Case> caseList = new List<Case>();
        List<Account> testAccounts = new List<Account>();
        System.runAs(ADMIN_USER) {
            makeAccounts();
            testAccounts = [SELECT Id FROM Account WHERE IsPersonAccount = TRUE LIMIT 1];
            Case testCase = new Case(accountId = testAccounts[0].Id);
            caseList.add(testCase);
            VCR_CaseRepo caseRepo = new VCR_CaseRepo();
            Test.startTest();
            caseRepo.upsertCasesAllOrNoneFalse(caseList);
            Test.stopTest();
        }

        List<Case> insertedCases = [SELECT ID FROM Case WHERE AccountId = :testAccounts[0].Id];
        Assert.areEqual(1, insertedCases.size(), 'Expected case to be inserted. Observed: ' + insertedCases.size());
    }
}
