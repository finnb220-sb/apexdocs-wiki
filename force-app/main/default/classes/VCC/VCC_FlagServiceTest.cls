/**
 * @author Booz Allen Hamilton
 * @description Test for VCC_FlagService class.
 * @see `VCC_FlagService`
 */
@isTest
private with sharing class VCC_FlagServiceTest {
    private static User adminUser = new VATEST_UserBuilder()
        .withUserProfile('System Administrator')
        .withStandardData()
        .build(true);

    private static User rnBaseUser = new VATEST_UserBuilder()
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .withPermissionSet('VCC_Registered_Nurse')
        .build(true);

    private static VCC_FlagLightningRequestWrp makeFlagRequestWrap(Id recordId) {
        VCC_FlagLightningRequestWrp flagLightningRequestWrp = new VCC_FlagLightningRequestWrp();
        flagLightningRequestWrp.recordId = recordId;
        flagLightningRequestWrp.facility = 'test';
        flagLightningRequestWrp.startDate = 'test';
        flagLightningRequestWrp.endDate = 'test';
        return flagLightningRequestWrp;
    }

    /**
     * @description class that implements HttpCalloutMock for use in this or other test classes
     * @see `VCC_FlagService`
     */
    private class FlagsHttpMock implements HttpCalloutMock {
        /**
         * @description List of HttpResponses in the order their respective callouts are made
         */
        public List<HttpResponse> responseFifo = new List<HttpResponse>();
        /**
         * @description List of HttpRequests in the order in which they are received
         */
        public List<HttpRequest> requestFifo = new List<HttpRequest>();

        /**
         * @description implementation of interface `HttpCalloutMock`
         * @param request `HttpRequest` the received http request
         * @return `HttpResponse` the mock response to provide instead of making an actual callout
         */
        public HttpResponse respond(HttpRequest request) {
            this.requestFifo.add(request);
            return responseFifo.remove(0);
        }

        /**
         * @description Constructor taking two mock responses, one for flags and another for womens health
         * @param flagsResponse the mock flags response
         * @param womensHealthResponse the mock womens health response
         */
        public FlagsHttpMock(HttpResponse flagsResponse, HttpResponse womensHealthResponse) {
            this.responseFifo.add(flagsResponse);
            this.responseFifo.add(womensHealthResponse);
        }

        /**
         * @description Empty constructor when no callouts are expected. If a callout is made, an 'out of bounds' exception will occur
         */
        public FlagsHttpMock() {
            return;
        }
    }

    private static FlagsHttpMock setFlagsMock(HttpResponse flagsResponse, HttpResponse womensHealthResponse) {
        FlagsHttpMock flagsHttpMock = new FlagsHttpMock(flagsResponse, womensHealthResponse);
        Test.setMock(HttpCalloutMock.class, flagsHttpMock);
        return flagsHttpMock;
    }

    private static FlagsHttpMock setFlagsMock() {
        FlagsHttpMock flagsHttpMock = new FlagsHttpMock();
        Test.setMock(HttpCalloutMock.class, flagsHttpMock);
        return flagsHttpMock;
    }

    @IsTest
    static void unitFlagServiceConstructorPositive() {
        Test.startTest();
        System.runAs(rnBaseUser) {
            Assert.isNotNull(new VCC_FlagService(), 'Expected non-null result from VCC_FlagService constructor');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitGetFlagsProgressNoteEnvProdEmptyResponsePositive() {
        // Http Mocks
        HttpResponse flagsResponse = new HttpResponse();
        HttpResponse womensHealthResponse = new HttpResponse();
        FlagsHttpMock httpMock = setFlagsMock(flagsResponse, womensHealthResponse);

        // progress note whose record Id we need
        VCC_Progress_Note__c progressNote;

        // return value
        VCC_FlagResponseWrp returnedValue;

        // insert test records
        System.runAs(adminUser) {
            Account testAccount = new Account(LastName = 'test');
            insert testAccount;
            Case testCase = new Case(AccountId = testAccount.Id);
            insert testCase;
            progressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert progressNote;
            insert new CaseShare(CaseAccessLevel = 'Edit', UserOrGroupId = rnBaseUser.Id, CaseId = testCase.Id);
        }

        // run test
        System.runAs(rnBaseUser) {
            Test.startTest();
            returnedValue = new VCC_FlagService().getFlags(makeFlagRequestWrap(progressNote.Id));
            Test.stopTest();
        }

        // asserts
        Assert.areEqual(
            2,
            httpMock.requestFifo.size(),
            'Expected HttpCalloutMock to have recieved two HttpRequests- one for Flags and one for WomensHealth callouts'
        );
        Assert.isTrue(
            String.isBlank(returnedValue.responseBody),
            'Expected null response body because mocked HttpResponse has no body'
        );
        Assert.isTrue(
            String.isBlank(returnedValue.womenHealthResponseBody),
            'Expected null womens health response body because mocked HttpResponse has no body'
        );
    }

    @IsTest
    static void unitGetFlagsCaseEnvProdEmptyResponsePositive() {
        // Http Mocks
        HttpResponse flagsResponse = new HttpResponse();
        HttpResponse womensHealthResponse = new HttpResponse();
        FlagsHttpMock httpMock = setFlagsMock(flagsResponse, womensHealthResponse);

        // case whose record Id we need as input
        Case testCase;

        // return value
        VCC_FlagResponseWrp returnedValue;

        // insert test records
        System.runAs(adminUser) {
            Account testAccount = new Account(LastName = 'test');
            insert testAccount;
            testCase = new Case(AccountId = testAccount.Id);
            insert testCase;
            insert new CaseShare(CaseAccessLevel = 'Edit', UserOrGroupId = rnBaseUser.Id, CaseId = testCase.Id);
        }

        // run test
        System.runAs(rnBaseUser) {
            Test.startTest();
            returnedValue = new VCC_FlagService().getFlags(makeFlagRequestWrap(testCase.Id));
            Test.stopTest();
        }

        // asserts
        Assert.areEqual(
            2,
            httpMock.requestFifo.size(),
            'Expected HttpCalloutMock to have recieved two HttpRequests- one for Flags and one for WomensHealth callouts'
        );
        Assert.isTrue(
            String.isBlank(returnedValue.responseBody),
            'Expected null response body because mocked HttpResponse has no body'
        );
        Assert.isTrue(
            String.isBlank(returnedValue.womenHealthResponseBody),
            'Expected null womens health response body because mocked HttpResponse has no body'
        );
    }

    @IsTest
    static void unitGetFlagsProgressNoteNegative() {
        // http mock
        FlagsHttpMock httpMock = setFlagsMock();

        // progress note needed for input
        VCC_Progress_Note__c progressNote;

        // insert test data
        System.runAs(adminUser) {
            Account testAccount = new Account(LastName = 'test');
            insert testAccount;
            Case testCase = new Case(AccountId = testAccount.Id);
            insert testCase;
            progressNote = new VCC_Progress_Note__c(VCC_Case__c = testCase.Id);
            insert progressNote;
        }

        // run test
        System.runAs(rnBaseUser) {
            Test.startTest();
            try {
                new VCC_FlagService().getFlags(makeFlagRequestWrap(progressNote.Id));
                Assert.fail('Expected an exception because progressNote was not shared with the running user.');
            } catch (ListException thrownException) {
                Assert.areEqual(
                    'List index out of bounds: 0',
                    thrownException.getMessage(),
                    'Expected list out of bounds because the running user does not have visibility on the given progress note record.'
                );
            }
            Test.stopTest();
        }

        // asserts
        Assert.isTrue(
            httpMock.requestFifo.isEmpty(),
            'Expected request FIFO to be empty because no callouts were made'
        );
    }

    @IsTest
    static void unitGetFlagsCaseEnvNotProdPositive() {
        // Http Mocks
        FlagsHttpMock httpMock = setFlagsMock();

        // case whose record Id we need as input
        Case testCase;

        // return value
        VCC_FlagResponseWrp returnedValue;

        // insert test records
        System.runAs(adminUser) {
            Account testAccount = new Account(LastName = 'test');
            insert testAccount;
            testCase = new Case(AccountId = testAccount.Id);
            insert testCase;
            insert new CaseShare(CaseAccessLevel = 'Edit', UserOrGroupId = rnBaseUser.Id, CaseId = testCase.Id);
        }

        // run test
        System.runAs(rnBaseUser) {
            Test.startTest();
            VCC_FlagService.enviornment = 'TEST';
            returnedValue = new VCC_FlagService().getFlags(makeFlagRequestWrap(testCase.Id));
            Test.stopTest();
        }

        // asserts
        Assert.areEqual(
            0,
            httpMock.requestFifo.size(),
            'Expected zero HttpRequests received because VCC_FlagService.enviornment was not set to "PROD"'
        );
        Assert.isNotNull(
            returnedValue.flagModal,
            'Expected flagModal to be non-null because a mock flags response should have been serialized into it'
        );
    }
}
