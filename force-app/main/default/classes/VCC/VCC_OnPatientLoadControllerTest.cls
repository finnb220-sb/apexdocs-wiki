/**
 * @description test class for VCC_OnPatientLoadController
 * @author Booz Allen
 * @since 10/22/2024
 * @see `VCC_OnPatientLoadController`
 */
@IsTest
public with sharing class VCC_OnPatientLoadControllerTest {
    private static User standardTestUser;
    private static User adminUser;
    static {
        standardTestUser = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSets(new Set<String>{ 'VAHC_Standard_VCC_User', 'LoggerLogCreator' })
            .withStandardData()
            .build(true);
        adminUser = new VATEST_UserBuilder().withUserProfile('System Administrator').withStandardData().build(true);
    }

    private static Account testSetupInsertAndShareAccount(
        User userToInsertAccount,
        Account accountForInsert,
        User userToShareAccountWith
    ) {
        System.runAs(userToInsertAccount) {
            insert accountForInsert;
            insert new AccountShare(
                AccountId = accountForInsert.Id,
                UserOrGroupId = userToShareAccountWith.Id,
                AccountAccessLevel = 'Edit',
                OpportunityAccessLevel = 'Edit'
            );
        }
        return accountForInsert;
    }

    private class VetRetrieveMock implements HttpCalloutMock {
        private HttpResponse response;
        public HttpRequest request;
        private Exception exceptionToThrow;

        /**
         * @description responds to the http request
         * @param request the http request
         * @return the response
         */
        public HttpResponse respond(HttpRequest request) {
            this.request = request;
            if (this.exceptionToThrow != null) {
                throw this.exceptionToThrow;
            }
            return this.response;
        }

        /**
         * @description constructor for the mock
         * @param response the response to respond with
         */
        public VetRetrieveMock(HttpResponse response) {
            this.response = response;
        }

        /**
         * @description constructor for the mock that throws an exception
         * @param exceptionToThrow the exception to throw
         */
        public VetRetrieveMock(Exception exceptionToThrow) {
            this.exceptionToThrow = exceptionToThrow;
        }
    }

    private static VetRetrieveMock testSetupDoMock(HttpResponse response) {
        VetRetrieveMock mock = new VetRetrieveMock(response);
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static VetRetrieveMock testSetupDoMock(Exception exceptionToThrow) {
        VetRetrieveMock mock = new VetRetrieveMock(exceptionToThrow);
        Test.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    @IsTest
    static void unitBuildAndMakeMpiCalloutPositive() {
        Account testAccount = new Account(VCC_MVI_External_Id__pc = 'test');
        HttpResponse mockResponse = new HttpResponse();
        VetRetrieveMock mock = testSetupDoMock(mockResponse);

        HttpResponse returnedResponse;
        System.runAs(standardTestUser) {
            Test.startTest();
            returnedResponse = VCC_OnPatientLoadController.buildAndMakeMpieCalloutViaDip(testAccount);
            Test.stopTest();
        }
        Assert.isTrue(mockResponse === returnedResponse, 'Expected mocked response to be returned from the method');
        Assert.areEqual('POST', mock.request.getMethod(), 'Expected Http method to be "POST"');
        Assert.areEqual(
            'application/json;charset=UTF-8',
            mock.request.getHeader('Content-Type'),
            'Expected value for header "Content-Type" to be "application/json;charset=UTF-8"'
        );
        Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(mock.request.getBody());
        Assert.areEqual(
            'VAHC CRM',
            requestBody.get('userId'),
            'Expected request body to contain JSON tag "userId" with "VAHC CRM" as its value'
        );
        Assert.areEqual(
            testAccount.VCC_MVI_External_Id__pc,
            requestBody.get('id'),
            'Expected request body to contain JSON tag "id" with the accounts MVI External Id (ICN) as its value'
        );
        Assert.areEqual(
            'ICN',
            requestBody.get('idType'),
            'Expected request body to contain JSON tag "idType" with the value "ICN", indicating that is the id type we are providing in the body'
        );
        Assert.areEqual(
            true,
            requestBody.get('unattended'),
            'Expected request body to contain JSON tag "unattended" with the boolean value "true"'
        );
        Assert.areEqual(
            false,
            requestBody.get('showCorrelated'),
            'Expected request body to contain JSON tag "showCorrelated" with the boolean value "false"'
        );
        Assert.areEqual(
            new List<String>{ 'VA_PROFILE', 'EE' },
            requestBody.get('datasets'),
            'Expected request body to contain JSON tag "datasets", with a List<String> containing values "VA_PROFILE" and "EE"'
        );
    }

    @IsTest
    static void unitBuildAndMakeMpiCalloutAnyExceptionNegative() {
        Account testAccount = new Account(VCC_MVI_External_Id__pc = 'test');
        Exception mockException = new CalloutException();
        testSetupDoMock(mockException);

        Exception caughtException;
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.buildAndMakeMpieCalloutViaDip(testAccount);
                Assert.fail('Expected the mock exception to be thrown');
            } catch (Exception anyThrownException) {
                caughtException = anyThrownException;
            }
            Test.stopTest();
        }
        Assert.isTrue(mockException === caughtException, 'Expected to catch the exception that was mocked');
    }

    @IsTest
    static void unitBuildAndMakeMpiCalloutMissingIcnNegative() {
        Account testAccount = new Account(LastName = 'test');

        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.buildAndMakeMpieCalloutViaDip(testAccount);
                Assert.fail('Expected VCC_RemoteServiceException to be thrown');
            } catch (VCC_RemoteServiceException thrownRemoteServiceException) {
                Assert.areEqual(
                    VCC_OnPatientLoadController.MISSING_MVI_EXTERNAL_ID_MSG,
                    thrownRemoteServiceException.getMessage(),
                    'Expected thrown exception message to match that set in VCC_OnPatientLoadController.MISSING_MVI_EXTERNAL_ID_MSG'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void unitRetrieveVetInfoPositive() {
        String mockIcn = 'something';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(VCC_MVI_External_Id__pc = mockIcn, LastName = 'test'),
            standardTestUser
        );
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        VCC_MPIParser mockBody = new VCC_MPIParser();
        mockResponse.setBody(JSON.serialize(mockBody));
        testSetupDoMock(mockResponse);

        VCC_MPIParser response;
        System.runAs(standardTestUser) {
            Test.startTest();
            response = VCC_OnPatientLoadController.retrieveVetInfo(testAccount.Id);
            Test.stopTest();
        }
        Assert.areEqual(
            JSON.serialize(mockBody),
            JSON.serialize(response),
            'Expected return value from retrieveVetInfo to be the same as the mocked body'
        );
    }

    @IsTest
    static void unitRetrieveVetInfoNon200StatusCodeNegative() {
        String mockIcn = 'something';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(VCC_MVI_External_Id__pc = mockIcn, LastName = 'test'),
            standardTestUser
        );
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(404);
        mockResponse.setBody('test');
        testSetupDoMock(mockResponse);

        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isNull(
                VCC_OnPatientLoadController.retrieveVetInfo(testAccount.Id),
                'Expected return value to be null because status code was not 200'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitRetrieveVetInfoJsonExceptionNegative() {
        String mockIcn = 'something';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(VCC_MVI_External_Id__pc = mockIcn, LastName = 'test'),
            standardTestUser
        );
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('invalidJson');
        testSetupDoMock(mockResponse);

        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isNull(
                VCC_OnPatientLoadController.retrieveVetInfo(testAccount.Id),
                'Expected return value to be null because status code was not 200'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitRetrieveVetInfoCalloutExceptionNegative() {
        String mockIcn = 'something';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(VCC_MVI_External_Id__pc = mockIcn, LastName = 'test'),
            standardTestUser
        );
        Exception exceptionToThrow = new CalloutException();
        testSetupDoMock(exceptionToThrow);

        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isNull(
                VCC_OnPatientLoadController.retrieveVetInfo(testAccount.Id),
                'Expected return value to be null because status code was not 200'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitRetrieveVetInfoOtherExceptionNegative() {
        String mockIcn = 'something';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(VCC_MVI_External_Id__pc = mockIcn, LastName = 'test'),
            standardTestUser
        );
        Exception exceptionToThrow = new AuraHandledException('other exception');
        testSetupDoMock(exceptionToThrow);

        System.runAs(standardTestUser) {
            Test.startTest();
            Assert.isNull(
                VCC_OnPatientLoadController.retrieveVetInfo(testAccount.Id),
                'Expected return value to be null because status code was not 200'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void unitHandleRetrieveVetInfoExceptionIllegalArgumentPositive() {
        System.runAs(standardTestUser) {
            Test.startTest();
            Logger.flushBuffer();
            Assert.areEqual(0, Logger.getBufferSize(), 'Expected Logger buffer to be empty for test pre-condition');
            Logger.suspendSaving();
            VCC_OnPatientLoadController.handleRetrieveVetInfoException(new IllegalArgumentException(), null);
            Assert.areEqual(1, Logger.getBufferSize(), 'Expected Logger buffer to contain one entry');
            Test.stopTest();
        }
    }
    @IsTest
    static void unitDeferredMPIUpdatesPositive() {
        String testLastName = 'SOME LAST NAME';
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(LastName = testLastName),
            standardTestUser
        );
        VCC_MPIParser mpiData = new VCC_MPIParser();
        mpiData.vetsV3.add(new VCC_MPIParser.VetDetails());
        mpiData.vetsV3[0].mvi.lastName = testLastName;

        System.runAs(standardTestUser) {
            Test.startTest();
            VCC_OnPatientLoadController.deferredMPIUpdates(testAccount.Id, JSON.serialize(mpiData));
            Test.stopTest();
        }

        Account accountAfterUpdate = [SELECT LastName FROM Account WHERE Id = :testAccount.Id LIMIT 1];
        //fyi just doing a rudimentary test here because the account updates should have their own tests in VCC_MPIHelper
        Assert.areEqual(testLastName, accountAfterUpdate.LastName, 'Expected last name to have been updated.');
    }

    @IsTest
    static void unitDeferredMPIUpdatesNullMpiDataNegative() {
        Account testAccount = testSetupInsertAndShareAccount(
            adminUser,
            new Account(LastName = 'test'),
            standardTestUser
        );
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.deferredMPIUpdates(testAccount.Id, null);
                Assert.fail('Expected an IllegalArgumentException to be thrown.');
            } catch (IllegalArgumentException thrownIllegalArgumentException) {
                Assert.areEqual(
                    VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_NULL_ARG_MSG,
                    thrownIllegalArgumentException.getMessage(),
                    'Expected exception message to be the String assigned to VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_NULL_ARG_MSG'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDeferredMPIUpdatesNullAccountIdNegative() {
        VCC_MPIParser mpiData = new VCC_MPIParser();
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.deferredMPIUpdates(null, JSON.serialize(mpiData));
                Assert.fail('Expected an IllegalArgumentException to be thrown.');
            } catch (IllegalArgumentException thrownIllegalArgumentException) {
                Assert.areEqual(
                    VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_NULL_ARG_MSG,
                    thrownIllegalArgumentException.getMessage(),
                    'Expected exception message to be the String assigned to VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_NULL_ARG_MSG'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDeferredMPIUpdatesWrongSObjectIdNegative() {
        VCC_MPIParser mpiData = new VCC_MPIParser();
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.deferredMPIUpdates(
                    VATEST_IdFactory.get(Contact.getSObjectType()),
                    JSON.serialize(mpiData)
                );
                Assert.fail('Expected an IllegalArgumentException to be thrown.');
            } catch (IllegalArgumentException thrownIllegalArgumentException) {
                Assert.areEqual(
                    VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_WRONG_ID_TYPE_MSG,
                    thrownIllegalArgumentException.getMessage(),
                    'Expected exception message to be the String assigned to VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_WRONG_ID_TYPE_MSG'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void unitDeferredMPIUpdatesBlankMpiJsonNegative() {
        System.runAs(standardTestUser) {
            Test.startTest();
            try {
                VCC_OnPatientLoadController.deferredMPIUpdates(VATEST_IdFactory.get(Account.getSObjectType()), '');
                Assert.fail('Expected an IllegalArgumentException to be thrown.');
            } catch (IllegalArgumentException thrownIllegalArgumentException) {
                Assert.areEqual(
                    VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_BLANK_MPI_STRING_MSG,
                    thrownIllegalArgumentException.getMessage(),
                    'Expected exception message to be the String assigned to VCC_OnPatientLoadController.DEFERRED_MPI_UPDATE_BLANK_MPI_STRING_MSG'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void unitGetFacilityOverrideMCustomMetadataPositive() {
        Map<String, String> facilityOverrideMap;
        System.runAs(standardTestUser) {
            Test.startTest();
            facilityOverrideMap = VCC_OnPatientLoadController.getFacilityOverrideMCustomMetadata();
            Test.stopTest();
        }
        Assert.isNotNull(facilityOverrideMap, 'Expected non-null value');
    }

    @IsTest
    private static void unitUserVistAsPositive() {
        // Todo: Should this actually be Standard User profile?
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        System.runAs(runAsUser) {
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDuzRecord = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
                User_Id__c = runAsUser.Id,
                VistA_Instance__c = '123',
                DUZ__c = '12345',
                Name = '123.12345'
            );
            insert vistaInstanceToUserDuzRecord;

            Test.startTest();
            List<String> vistAList = VCC_OnPatientLoadController.userVistAs();
            Test.stopTest();
            Assert.areEqual(
                1,
                vistAList.size(),
                'Expected one user vista to be returned from VCC_OnPatientLoadController.userVistAs(), because one was inserted at the beginning of this test'
            );
        }
    }
}
