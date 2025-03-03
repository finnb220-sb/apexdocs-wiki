/**
 * @description       : Test class for VCC_MpiRetrieveBatch.
 *  This class is copied from VCC_BatchMPICorrelateTest, but
 *      (1) change status from 'New' to 'Waiting'
 *      (2) change Cerner_specific_ICN__c to ICN__c
 *      (3) do not check for status 'Completed'
 *      (4) replace VCC_BatchMPICorrelate with VCC_MpiRetrieveBatch
 *      (5) Add testNewCode(), testHandleFailure(), testModifyVaIdentityRecordForUpdate(), testUpdateGender()
 *      (6) change the way that Acccount is created
 * @author            : Mung Fan (Acumen Solutions, Inc)
 * @group             :
 * @modified October 17, 2024
 * @last modified by  : Jakob Orkin & Ian McNicoll
 **/
@IsTest(SeeAllData=false)
private with sharing class VCC_MpiRetrieveBatchTest {
    private static final String SAMPLE_MVI_EXTERNAL_ID = '1013452276V180828';

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('MPI_E_Integration_User')
            .withPermissionSet('VAHC_Test_Data_Import')
            .withUserProfile('System Administrator')
            .withStandardData()
            .build(true);
    }

    @TestSetup
    static void setupData() {
        VA_Identity__c vaId = new VA_Identity__c(MPI_Correlation_Status__c = 'Waiting', ICN__c = '1013452276V180828');
        insert vaId;
    }

    @IsTest
    static void intgnScenarioWithOutError() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfileB');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT Id, FirstName, LastName
            FROM Account
            WHERE VCC_MVI_External_Id__pc = '1013452276V180828'
        ];

        Assert.areEqual(1, insertedAccounts.size(), 'Expected one Account, but observed ' + insertedAccounts.size());
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
    }

    @IsTest
    static void intgnBirthandDeceasedDate() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfileB');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
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
            LIMIT 50
        ];

        Assert.isTrue(
            insertedAccounts.size() > 0,
            'Expected insertedAccounts.size() > 0, but observed insertedAccounts.size() = ' + insertedAccounts.size()
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__DeceasedDate__pc,
            ' Expected Deceased date, Deceased Date is null'
        );
        Assert.isNotNull(
            insertedAccounts[0].Date_of_Birth__pc,
            'Expected Date of Birth 1972/07/06, Date of Birth Text is ' + insertedAccounts[0].Date_of_Birth__pc
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__BirthDate__pc,
            'Expected HealthCloudGA Birth Date, HealthCloudGA Birthdate is null'
        );
    }

    @IsTest
    static void intgn4DigitBirthandDeceasedDate() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile2');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
            Database.executeBatch(batch, 50);
            Test.stopTest();
        }

        List<Account> insertedAccounts = [
            SELECT
                Id,
                FirstName,
                LastName,
                VCC_MVI_External_Id__pc,
                Date_of_Birth__pc,
                HealthCloudGA__BirthDate__pc,
                HealthCloudGA__DeceasedDate__pc
            FROM Account
            LIMIT 50
        ];
        Assert.isTrue(
            insertedAccounts.size() > 0,
            'Expected insertedAccounts.size() > 0, but observed insertedAccounts.size() =  0'
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__DeceasedDate__pc,
            'Expected Deceased Date to be populated, Deceased Date is null'
        );
        Assert.isNotNull(
            insertedAccounts[0].HealthCloudGA__BirthDate__pc,
            'Expected value for insertedAccounts[0].HealthCloudGA__BirthDate__pc, but observed null value'
        );

        String actualExternalID = [
            SELECT Id, VCC_MVI_External_Id__pc
            FROM Account
            WHERE VCC_MVI_External_Id__pc = :SAMPLE_MVI_EXTERNAL_ID
            LIMIT 1
        ]
        ?.VCC_MVI_External_Id__pc;
        Assert.areEqual(
            SAMPLE_MVI_EXTERNAL_ID,
            actualExternalID,
            'Expected VCC_MVI_External_Id__pc status to be ' +
                SAMPLE_MVI_EXTERNAL_ID +
                ', observed ' +
                actualExternalID +
                '. Likely incorrectly set VCC_MVI_External_Id__pc status.'
        );
    }

    @IsTest
    static void intgnThrowIncorrectDateError() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPI_VAProfile3');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
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
            LIMIT 50
        ];

        Assert.isTrue(
            insertedAccounts.size() > 0,
            'Expected insertedAccounts.size() > 0, but observed insertedAccounts.size() = ' + insertedAccounts.size()
        );
        String actualCorrelationStatus = [
            SELECT Id, MPI_Correlation_Status__c
            FROM VA_Identity__c
            WHERE ICN__c = '1013452276V180828'
            LIMIT 1
        ]
        ?.MPI_Correlation_Status__c;
        Assert.areEqual(
            'Waiting',
            actualCorrelationStatus,
            'Expected Correlation status to be Waiting, observed ' +
                actualCorrelationStatus +
                '. Likely incorrectly set Correlation status.'
        );
    }

    @IsTest
    static void funcParseResponse() {
        VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
        Assert.isNotNull(
            batch.personAcctRecordTypeId,
            'Expected batch.personAcctRecordTypeId to not be null.  However observed batch.personAcctRecordTypeId = ' +
            batch.personAcctRecordTypeId
        );

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch.ResponseWrapper respWrapper = new VCC_MpiRetrieveBatch.ResponseWrapper();
            batch.parseResponse(respWrapper);
            HttpResponse resp = new HttpResponse();
            resp.setStatusCode(400);
            respWrapper.resp = resp;
            respWrapper.identityVar = new VA_Identity__c();
            respWrapper.vaIdentityMapByIcn = new Map<String, VA_Identity__c>();
            respWrapper.personAccountToInsert = null;
            batch.parseResponse(respWrapper);
            Assert.isNull(
                batch.sendRequestForIdentity(new HttpRequest(), new VA_Identity__c()),
                'Expected batch.sendRequestForIdentity(new HttpRequest(), new VA_Identity__c()) to not be null.  However observed batch.sendRequestForIdentity(new HttpRequest(), new VA_Identity__c()) = ' +
                batch.personAcctRecordTypeId
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void funcHandleFailure() {
        SObjectType sType = ((SObject) Type.forName('VA_Identity__c').newInstance()).getSObjectType();
        String idVal = sType.getDescribe().getKeyPrefix() + '0'.repeat(12);
        VA_Identity__c idRec = new VA_Identity__c(Id = idVal);

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveBatch batch = new VCC_MpiRetrieveBatch();
            VA_Identity__c failedRec = batch.handleFailure(idRec, null);
            Test.stopTest();

            Assert.isTrue(
                String.isNotBlank(failedRec.MPI_Retrieve_Error_Message__c),
                'Error message should not be empty'
            );

            Assert.isNotNull(
                failedRec.MPI_Retrieve_Error_Message_Datetime__c,
                'Error message datetime should not be null'
            );
            Assert.isTrue(
                batch.failed.equals(failedRec.MPI_Correlation_Status__c),
                'Correlation status should be failed'
            );
        }
    }

    @IsTest
    static void funcModifyVaIdentityRecordForUpdate() {
        VA_Identity__c vaIdRecord = new VA_Identity__c();
        VA_Identity__c identityVar = new VA_Identity__c(
            MPI_Correlation_Requester__c = 'Requester',
            MPI_Correlation_Requester_User__c = 'User'
        );

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MpiRetrieveLogic batch = new VCC_MpiRetrieveLogic();
            batch.modifyVaIdentityRecordForUpdate(vaIdRecord, identityVar);
            Test.stopTest();
        }

        Assert.areEqual(
            'Requester',
            vaIdRecord.MPI_Correlation_Requester__c,
            'Expected MPI_Correlation_Requester__c = \'Requester\',  however observed' +
            vaIdRecord.MPI_Correlation_Requester__c
        );

        Assert.areEqual(
            'User',
            vaIdRecord.MPI_Correlation_Requester_User__c,
            'Expected vaIdRecord.MPI_Correlation_Requester_User__c = \'User\',  however observed' +
            vaIdRecord.MPI_Correlation_Requester_User__c
        );
    }

    @IsTest
    static void funcUpdateGender() {
        Account testAcct = new Account();
        VCC_MPIParser.MVI mviVar = new VCC_MPIParser.MVI();
        VCC_MPIParser.VetDetails vetDetails = new VCC_MPIParser.VetDetails();
        vetDetails.mvi = mviVar;
        VCC_MpiRetrieveLogic batch = new VCC_MpiRetrieveLogic();

        System.runAs(getTestUser()) {
            Test.startTest();
            batch.updateGender(testAcct, vetDetails);
            Test.stopTest();
        }

        Assert.isNull(
            testAcct.HealthCloudGA__Gender__pc,
            'HealthCloudGA__Gender__pc == null, however actual HealthCloudGA__Gender__pc = ' +
            testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'M';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Male',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Male, observed ' + testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'F';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Female',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Female, observed ' + testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'TM';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Transgender Male',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Transgender Male, observed ' +
            testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'TF';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Transgender Female',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Transgender Female, observed ' +
            testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'O';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Other',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Other, observed ' + testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'I';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            'Non-Binary',
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be Non-Binary, observed ' +
            testAcct.HealthCloudGA__Gender__pc
        );

        mviVar.gender = 'X';
        batch.updateGender(testAcct, vetDetails);
        Assert.areEqual(
            mviVar.gender,
            testAcct.HealthCloudGA__Gender__pc,
            'Expected testAcct.HealthCloudGA__Gender__pc to be ' +
                mviVar.gender +
                ', observed ' +
                testAcct.HealthCloudGA__Gender__pc
        );
    }
}
