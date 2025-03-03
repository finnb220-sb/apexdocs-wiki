/**
 * @description This test class covers both VCC_BatchMPICorrelate.cls <br>
 * and VCC_BatchMPICorrelateScheduler.cls
 * @group Test Classes
 * @see VCC_BatchMPICorrelate
 * @author Booz Allen Hamilton
 */
@IsTest
private with sharing class VCC_BatchMPICorrelateTest {
    /**
     * @description facilitates multiple callouts for a single test. If possible, this should be stored in either a resource
     * or a custom label.
     */
    static final String MOCK_ICN_VALUE = '1013452276V180828';

    @TestSetup
    static void setupData() {
        VA_Identity__c vaId = new VA_Identity__c(
            MPI_Correlation_Status__c = 'New',
            Cerner_specific_ICN__c = MOCK_ICN_VALUE,
            ICN__c = MOCK_ICN_VALUE
        );

        insert vaId;
    }

    /**
     * @description querying for VA_Identity__c.MPI_Correlation_Status__c where mock ICN__c is set
     * @return `string` correlationStatus
     */
    public static String getCorrelationStatus() {
        String correlationStatus = [
            SELECT Id, MPI_Correlation_Status__c
            FROM VA_Identity__c
            WHERE ICN__c = :MOCK_ICN_VALUE
            LIMIT 1
        ]
        ?.MPI_Correlation_Status__c;

        return correlationStatus;
    }

    /**
     * @description QueueHttpMock allows multiple HttpResponses for a single test
     */
    public class QueueHttpMock implements HttpCalloutMock {
        HttpResponse[] responses = new HttpResponse[0];

        /**
         * @description builds list of responses
         * @param response
         */
        public void addResponse(HttpResponse response) {
            responses.add(response);
        }

        /**
         * @description allows multiple HttpResponses for a single test
         * @param request
         * @return HttpResponse
         */
        public HttpResponse respond(HttpRequest request) {
            return responses.remove(0);
        }
    }

    /**
     * @description builds sys_admin test user using VATEST_UserBuilder
     * @return `User`
     */
    public static User getTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('MPI_E_Integration_User')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
    }

    @IsTest
    static void intgnRunBatchToInsertAccountPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfileB');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT Id, FirstName, LastName
            FROM Account
            WHERE VCC_MVI_External_Id__pc = :MOCK_ICN_VALUE
        ];
        List<VA_Identity__c> vaIdRec = [
            SELECT Id, Salesforce_Contact_Id__c
            FROM VA_Identity__c
            WHERE ICN__c = :MOCK_ICN_VALUE
        ];
        Assert.areEqual(1, insertedAccounts.size(), 'Expected one Account, but observed ' + insertedAccounts.size());

        String accountId = insertedAccounts[0].Id;
        List<Contact> con = [SELECT Id FROM Contact WHERE Account.Id = :accountId];

        Assert.areEqual(
            'STOLZE',
            insertedAccounts[0].LastName,
            'Expected "STOLZE", but observed: "' + insertedAccounts[0].LastName + '"'
        );

        Assert.areEqual(
            'LAVERNA',
            insertedAccounts[0].FirstName,
            'Expected "LAVERNA" but observed: ' + insertedAccounts[0].FirstName + '"'
        );

        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'Completed',
            actualCorrelationStatus,
            'Expected Correlation status to be Completed, observed status = ' + actualCorrelationStatus
        );
        Assert.areEqual(
            con[0].Id,
            vaIdRec[0].Salesforce_Contact_Id__c,
            'Expected contact.Id = ' +
                con[0].Id +
                ' but observed: ' +
                vaIdRec[0].Salesforce_Contact_Id__c +
                '. It\'s likely Contact Id did not get correlated correctly'
        );
    }

    @IsTest
    static void intgnBirthAndDeceasedDatePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfileB');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }
        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
        ];

        Assert.areNotEqual(
            0,
            insertedAccounts.size(),
            'Expected insertedAccounts.size() > 0, but observed insertedAccounts.size() = ' + insertedAccounts.size()
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__DeceasedDate__pc,
            ' Expected Deceased date, Deceased Date is null'
        );
        Assert.isNotNull(insertedAccounts[0].Date_of_Birth__pc, ' Expected Date of Birth, Date of Birth Text is null');
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__BirthDate__pc,
            'Expected HealthCloudGA Birth Date, HealthCloudGA Birthdate is null'
        );
        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'Completed',
            actualCorrelationStatus,
            'Expected Correlation status to be Completed, observed ' +
                actualCorrelationStatus +
                '. Likely incorrectly set Correlation status.'
        );
    }

    /**
     * @description tests with callout data consisting of 4 digit date of death and 8 digit date of birth
     */
    @IsTest
    static void intgn4DigitDeceasedDateAnd8DigitBirthdatePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile2');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
        ];
        Assert.areNotEqual(
            0,
            insertedAccounts.size(),
            'Expected insertedAccounts.size() > 0, but observed insertedAccounts.size() =  0'
        );

        Assert.isNotNull(insertedAccounts[0].Date_of_Birth__pc, ' Expected Date of Birth, Date of Birth Text is null');
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__BirthDate__pc,
            'Expected HealthCloudGA Birth Date, HealthCloudGA Birthdate is null'
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__BirthDate__pc,
            'Expected birth date to not be null. Observed that it is null'
        );
        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'Completed',
            actualCorrelationStatus,
            'Expected Correlation status to be Completed, observed ' +
                actualCorrelationStatus +
                '. Likely incorrectly set Correlation status.'
        );
    }

    @IsTest
    static void intgnIncorrectDatePositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile3');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
        ];

        Assert.areEqual(
            1,
            insertedAccounts.size(),
            'Expected insertedAccounts.size() = 1, Actual insertedAccounts.size() = ' + insertedAccounts.size() + '.'
        );

        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'New',
            actualCorrelationStatus,
            'Expected Correlation status to be New, observed ' + actualCorrelationStatus
        );
    }

    @IsTest
    static void funcTestSchedulerPositive() {
        Test.startTest();
        String jobId;
        System.runAs(getTestUser()) {
            VCC_BatchMPICorrelateScheduler schedSUA = new VCC_BatchMPICorrelateScheduler();
            String sch = '0 0 23 * * ?';
            jobId = System.schedule('Testing Scheduler...', sch, schedSUA);
        }
        Test.stopTest();
        CronTrigger cronTrigger = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(
            '0 0 23 * * ?',
            cronTrigger.CronExpression,
            'Expected a cronExpression value of "0 0 23 * * ?" but observed : ' + cronTrigger.CronExpression
        );
    }

    @IsTest
    static void intgnFirstCalloutNegative() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile3');
        mock.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
        ];

        Assert.areEqual(
            0,
            insertedAccounts.size(),
            'Expected insertedAccounts.size() = 0, Actual insertedAccounts.size() = ' + insertedAccounts.size() + '.'
        );
        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'Error',
            actualCorrelationStatus,
            'Expected Correlation status to be New, observed ' + actualCorrelationStatus
        );
    }

    @IsTest
    static void intgnSecondCalloutNegative() {
        List<StaticResource> staticResource = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = 'VCC_MPI_VAProfile3'
            LIMIT 1
        ];
        String myBody = staticResource[0].Body.toString();

        QueueHttpMock mock = new QueueHttpMock();
        HttpResponse res1 = new HttpResponse();
        res1.setStatusCode(200);
        res1.setBody(myBody);
        HttpResponse res2 = new HttpResponse();
        res2.setStatusCode(500);
        res2.setBody(myBody);
        mock.addResponse(res1);
        mock.addResponse(res2);
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_BatchMPICorrelate batch = new VCC_BatchMPICorrelate();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
        ];

        Assert.areEqual(
            0,
            insertedAccounts.size(),
            'Expected insertedAccounts.size() = 0, Actual insertedAccounts.size() = ' + insertedAccounts.size() + '.'
        );
        String actualCorrelationStatus = getCorrelationStatus();
        Assert.areEqual(
            'Error',
            actualCorrelationStatus,
            'Expected MPI_Correlation_Status__c == "Error", however actual MPI_Correlation_Status__c = ' +
            actualCorrelationStatus
        );
    }
}
