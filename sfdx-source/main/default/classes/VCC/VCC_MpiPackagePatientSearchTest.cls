@IsTest
public with sharing class VCC_MpiPackagePatientSearchTest {
    @IsTest
    static void it_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackagePatientSearch(), 'Expected a non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    // @IsTest
    // static void it_throws_an_exception_when_response_is_null(){
    //     Test.startTest();
    //     try{
    //         VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
    //     } catch (Exception e){
    //         System.Assert.fail('Unexpected exception: '+e.getMessage()+'\n'+e.getStackTraceString());
    //     }
    //     Test.stopTest();

    // }

    @IsTest
    static void it_throws_an_exception_when_response_is_null() {
        Test.startTest();
        try {
            VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = patientSearchImpl.mpiPatientSearch('reqBody', 'businessUnit');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected VCC_MpiPackageException exception type.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.NULL_RESPONSE, ((VCC_MpiPackageException) e).kind, 'Expected correct exception kind.');
            System.Assert.isTrue(e.getMessage().contains(VCC_MpiPackagePatientSearch.NULL_RESPONSE_TEMPLATE), 'Expected to find correct error message.');
        }
        Test.stopTest();
    }

    private class HttpMock implements HttpCalloutMock {
        public Integer statusCode;

        public String body;

        public HttpMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    @IsTest
    static void it_throws_an_exception_when_the_response_has_bad_status_code() {
        Integer responseStatusCode = 400;
        String responseBody = JSON.serialize(new Map<String, Object>{ 'test' => 1 });

        Test.setMock(HttpCalloutMock.class, new HttpMock(responseStatusCode, responseBody));

        Test.startTest();
        try {
            VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = patientSearchImpl.mpiPatientSearch('reqBody', 'VAHC');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected VCC_MpiPackageException exception type.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.BAD_RESPONSE, ((VCC_MpiPackageException) e).kind, 'Expected correct exception kind.');
            System.Assert.isTrue(e.getMessage().contains(String.valueOf(responseStatusCode)), 'Expected to find status code in response.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_does_not_throw_an_exception_when_the_response_is_404_ZeroResultsFound() {
        Integer responseStatusCode = Integer.valueOf(VCC_MpiPackagePatientSearch.FOUR_ZERO_FOUR_STATUS_CODE);
        String responseErrorType = VCC_MpiPackagePatientSearch.ZERO_RESULTS_FOUND_ERROR_TYPE;
        String responseBody = JSON.serialize(new Map<String, Object>{ 'test' => 1, 'errorType' => responseErrorType });

        Test.setMock(HttpCalloutMock.class, new HttpMock(responseStatusCode, responseBody));

        Test.startTest();
        try {
            VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = patientSearchImpl.mpiPatientSearch('reqBody', 'VAHC');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception_when_the_response_has_a_non_null_errorType() {
        Integer responseStatusCode = 200;
        String errorType = 'TEST';

        // MPIpersonCorrelationController has a property 'mpie_field_errorType' that stores the 'errorType' string below
        // Ideally I would pull that into this test class but it's not visible
        String responseBody = JSON.serialize(new Map<String, Object>{ 'errorType' => errorType });

        Test.setMock(HttpCalloutMock.class, new HttpMock(responseStatusCode, responseBody));

        Test.startTest();
        try {
            VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = patientSearchImpl.mpiPatientSearch('reqBody', 'VAHC');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected VCC_MpiPackageException exception type.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.BAD_RESPONSE, ((VCC_MpiPackageException) e).kind, 'Expected correct exception kind.');
            System.Assert.isTrue(e.getMessage().contains(String.valueOf(responseStatusCode)), 'Expected to find status code in response.');
            System.Assert.isTrue(e.getMessage().contains(errorType), 'Expected to find response body contents.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_runs_successfully() {
        Integer responseStatusCode = 200;
        String errorType = null;
        String responseBody = '{}';

        Test.setMock(HttpCalloutMock.class, new HttpMock(responseStatusCode, responseBody));

        Test.startTest();
        try {
            VCC_MpiPackagePatientSearch patientSearchImpl = new VCC_MpiPackagePatientSearch();
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = patientSearchImpl.mpiPatientSearch('reqBody', 'VAHC');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
