/**
 * @description test class for PC_PatientMpiCalloutsInvocable
 * @author      Booz Allen
 * @since       2024
 * @see         PC_PatientMpiCalloutsInvocable
 */
@IsTest
private with sharing class PC_PatientMpiCalloutsInvocableTest {
    private final static User SPECIALIST_USER;
    static {
        SPECIALIST_USER = new VATEST_UserBuilder()
            .withPermissionSet('PrC_Specialist_Users')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description positive test of getPatientDataFromFlow with a valid account Id parameter. The method should return the list of registered medical facility codes specified in the static resource mock JSON response
     * Used VCC_MPI_VAProfile_Override instead of VCC_MPI_VAProfile static resource as it has medicalCenterFacilities populated
     */
    @IsTest
    private static void unitGetPatientFacilitiesFromFlowPositive() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .returning(
                new Account(Id = patientAcctId, VCC_MVI_External_Id__pc = '1012666986V102800', Name = 'Harry Potter')
            )
            .defineStub();

        PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;
        List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowOutput> flowOutput;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile_Override');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            flowOutput = PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
            );

            Test.stopTest();
        }

        Assert.isTrue(
            String.isNotBlank(flowOutput[0].patientRegisteredFacilities),
            'Expected a string containing a comma-delimited list of the patient\'s registered facilities to be returned when calling getPatientDataFromFlow, but the returned string was blank.'
        );
    }

    /**
     * @description positive test of getPatientDataFromFlow with a valid account Id parameter. The method should return the Person Id for the Referring Provider's location specified in the static resource mock JSON response
     * Used VCC_MPI_VAProfile_Override instead of VCC_MPI_VAProfile static resource as it has medicalCenterFacilities populated
     */
    @IsTest
    private static void unitGetLocalPidFromFlowPositive() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .returning(
                new Account(Id = patientAcctId, VCC_MVI_External_Id__pc = '1012666986V102800', Name = 'Harry Potter')
            )
            .defineStub();

        PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;
        List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowOutput> flowOutput;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile_Override');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            flowOutput = PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
            );

            Test.stopTest();
        }

        Assert.isTrue(
            String.isNotBlank(flowOutput[0].localPid) || String.isNotEmpty(flowOutput[0].patientRegisteredFacilities),
            'Expected a string containing the Person Id for the Referring Provider location when calling getPatientDataFromFlow, but the returned string was blank.'
        );
    }

    /**
     * @description negative test of getPatientDataFromFlow that should cause a 404 Not Found response on the MPI request
     */
    @IsTest
    private static void unitGetPatientFacilitiesFromFlow404Negative() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .returning(
                new Account(Id = patientAcctId, VCC_MVI_External_Id__pc = '1012666986V102800', Name = 'Harry Potter')
            )
            .defineStub();

        PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile_Override');
            mock.setStatusCode(404);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            try {
                PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                    new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
                );
            } catch (VCC_RemoteServiceException caughtExcept) {
                caughtExceptionMessage = caughtExcept.getMessage();
            }

            Test.stopTest();
        }
        Assert.areEqual(
            'MPI Application Error 404',
            caughtExceptionMessage,
            'Expected getPatientDataFromFlow to throw an exception indicating a 404 response error, but no exception was thrown.'
        );
    }

    /**
     * @description negative test getPatientDataFromFlow with a blank patient Id parameter which should throw an error
     */
    @IsTest
    private static void unitGetPatientFacilitiesFromFlowNullPatientIdNegative() {
        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = null;

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            try {
                PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                    new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
                );
            } catch (PC_CustomException caughtCustomExcept) {
                caughtExceptionMessage = caughtCustomExcept.getMessage();
            }

            Test.stopTest();
        }

        Assert.areEqual(
            'MPI retrieveVetInfo request failure: Patient Id is blank.',
            caughtExceptionMessage,
            'Expected PC_PatientMpiCalloutsInvocable.getPatientsICN to throw a blank Patient Id error, but no exception was thrown.'
        );
    }

    /**
     * @description negative test getPatientDataFromFlow with a blank patient ICN value in the person account's VCC_MVI_External_Id__pc field which should throw an error
     */
    @IsTest
    private static void unitGetPatientFacilitiesFromFlowNullPatientICNNegative() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .returning(new Account(Id = patientAcctId, VCC_MVI_External_Id__pc = null, Name = 'Harry Potter'))
            .defineStub();

        PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile_Override');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            try {
                PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                    new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
                );
            } catch (PC_CustomException caughtExcept) {
                caughtExceptionMessage = caughtExcept.getMessage();
            }

            Test.stopTest();
        }
        Assert.areEqual(
            'MPI retrieveVetInfo request failure: Patient ICN is blank.',
            caughtExceptionMessage,
            'Expected PC_PatientMpiCalloutsInvocable.buildRetrieveVetInfoRequest to throw an exception due to a blank patient ICN parameter value, but no expection was thrown.'
        );
    }

    /**
     * @description negative test of getPatientDataFromFlow that should throw a QueryException on the account query
     */
    @IsTest
    private static void unitGetPatientFacilitiesFromFlowQueryExceptionNegative() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));
        String expectedExceptionMessage = 'Query Exception Message';

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .throwingException(new QueryException(expectedExceptionMessage))
            .defineStub();

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;

        List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowOutput> flowOutput;

        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;
            try {
                flowOutput = PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                    new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
                );
            } catch (QueryException caughtQueryException) {
                caughtExceptionMessage = caughtQueryException.getMessage();
            }

            Test.stopTest();
        }

        Assert.areEqual(
            expectedExceptionMessage,
            caughtExceptionMessage,
            'Expected getPatientDataFromFlow to throw a Query Exception, but no exception was thrown.'
        );
    }

    /**
     * @description negative test of getPatientDataFromFlow with a null Facility Id of the FLP's (Referring Provider) location or a blank Person Id for the Referring Provider location parameter. The method shouldn't return the Person Id for the Referring Provider's location specified in the static resource mock JSON response
     * Used VCC_MPI_VAProfile_Override instead of VCC_MPI_VAProfile static resource as it has medicalCenterFacilities populated
     */
    @IsTest
    private static void unitGetLocalPidFromFlowNegative() {
        Id patientAcctId = VATEST_IdFactory.get(Type.forName('Account'));

        VCR_AccountRepo stubbedAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(patientAcctId, new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' })
            //Tell the stub builder what to return
            .returning(
                new Account(Id = patientAcctId, VCC_MVI_External_Id__pc = '1012666986V102800', Name = 'Harry Potter')
            )
            .defineStub();

        PC_PatientMpiCalloutsInvocable.accountRepo = stubbedAccountRepo;

        PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput flowInput = new PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput();
        flowInput.patientAccountId = patientAcctId;
        List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowOutput> flowOutput;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile_Override');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            flowOutput = PC_PatientMpiCalloutsInvocable.getPatientDataFromFlow(
                new List<PC_PatientMpiCalloutsInvocable.PatientMpiFlowInput>{ flowInput }
            );

            Test.stopTest();
        }

        Assert.isFalse(
            String.isNotBlank(flowOutput[0].localPid = '') ||
            String.isNotEmpty(flowOutput[0].patientRegisteredFacilities = null),
            'Expected a string containing the Person Id for the Referring Provider location when calling getPatientDataFromFlow, but the returned string was blank.'
        );
    }

    /**
     * @description negative test of sendRetrieveVetInfoRequest that should throw an exception due to attempting to send an HttpRequest in a test method without a valid mocked Callout
     */
    @IsTest
    private static void unitSendRetrieveVetInfoRequestNegative() {
        // Test data setup

        // Actual test
        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('UnknownStaticResource');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);

            try {
                PC_PatientMpiCalloutsInvocable.sendRetrieveVetInfoRequest(new HttpRequest());
            } catch (Exception caughtExcept) {
                caughtExceptionMessage = caughtExcept.getMessage();
            }
            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            'Static Resource not found: UnknownStaticResource',
            caughtExceptionMessage,
            'Expected sendRetrieveVetInfoRequest to throw an exception due to not finding the specified static resource for the mocked Callout, but no exception was thrown.'
        );
    }

    /**
     * @description negative test of parseRetrieveVetInfoResponse that should throw an exception due to a blank HttpResponse
     */
    @IsTest
    private static void unitParseRetrieveVetInfoResponseNegative() {
        // Test data setup

        // Actual test
        String caughtExceptionMessage;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();

            try {
                PC_PatientMpiCalloutsInvocable.parseRetrieveVetInfoResponse(new HttpResponse());
            } catch (PC_CustomException caughtExcept) {
                caughtExceptionMessage = caughtExcept.getMessage();
            }

            Test.stopTest();
        }

        // Asserts
        Assert.areEqual(
            'MPI retrieveVetInfo response failure: Response body was empty.',
            caughtExceptionMessage,
            'Expected sendRetrieveVetInfoRequest to throw an exception due to a blank HttpResponse, but no exception was thrown.'
        );
    }
}
