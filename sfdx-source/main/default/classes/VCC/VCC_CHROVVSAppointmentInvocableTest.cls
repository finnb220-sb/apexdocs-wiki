@IsTest
public with sharing class VCC_CHROVVSAppointmentInvocableTest {
    public static Map<String, Object> expectedParams = new Map<String, Object>{
        'application' => 'VAHC',
        'dateTime' => '2024-10-25T15:30:00.000Z',
        'patientICN' => '0123456789V123456',
        'patientEmail' => 'testPatientEmail@test.com',
        'providerEmail' => 'testProviderEmail@test.com',
        'facilitySiteCode' => '516',
        'facilityName' => 'Bay Pines,FL',
        'patientFirstName' => 'Test',
        'patientLastName' => 'Patient',
        'patientMobile' => '5551231234',
        'duration' => 30,
        'timeZone' => 'America/New_York',
        'facilityTimezone' => 'America/New_York',
        'providerId' => '1111',
        'providerAssigningAuthority' => 'DFN-516'
    };

    /**
     * @description Utility method that generates a stub object that can be used in tests.
     * @param args the map containing the parameters
     * @param returnValue the object to return
     * @return `VTC_PatientService`
     */
    private static VTC_PatientService createPatientServiceStub(Map<String, Object> args, Object returnValue) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues('create_vvs_appointment', args)
            .returning(returnValue)
            .defineStub();
    }

    @IsTest
    private static void createVVSAppointmentPositive() {
        String mockURL = 'https://test.salesforce.com';
        VTC_CHROCreateAppointmentModel model = new VTC_CHROCreateAppointmentModel();
        model.url = mockURL;
        VCC_CHROVVSAppointmentInvocable.patientService = createPatientServiceStub(expectedParams, model);
        String responseURL;
        Test.startTest();
        System.runAs(VTC_CHROTestHelpers.chroTestUser) {
            String flowInput = JSON.serialize(expectedParams);
            List<String> results = VCC_CHROVVSAppointmentInvocable.createVVSAppointment(new List<String>{ flowInput });
            responseURL = results[0];
        }
        Test.StopTest();
        Assert.areEqual(mockURL, responseURL, 'Expected returned URL to be the mockURL but observed different result.');
    }

    @IsTest
    private static void invalidInputMissingDateTime() {
        String errorMsg;
        String missingDateTimeMsg = 'Error getting VVS link: Missing dateTime in RQ';
        Test.startTest();
        System.runAs(VTC_CHROTestHelpers.chroTestUser) {
            errorMsg = callInvocableMethodWithBadRequest('dateTime');
        }
        Test.StopTest();
        Assert.areEqual(errorMsg, missingDateTimeMsg, 'Received different error message.');
    }

    @IsTest
    private static void invalidInputMissingProviderEmail() {
        String errorMsg;
        String missingProviderEmailMsg = 'Error getting VVS link: Missing Provider Email in RQ';
        Test.startTest();
        System.runAs(VTC_CHROTestHelpers.chroTestUser) {
            errorMsg = callInvocableMethodWithBadRequest('providerEmail');
        }
        Test.StopTest();
        Assert.areEqual(errorMsg, missingProviderEmailMsg, 'Received different error message.');
    }

    @IsTest
    private static void invalidInputMissingPatientEmail() {
        String errorMsg;
        String missingPatientEmailMsg = 'Error getting VVS link: Missing Patient Email in RQ';
        Test.startTest();
        System.runAs(VTC_CHROTestHelpers.chroTestUser) {
            errorMsg = callInvocableMethodWithBadRequest('patientEmail');
        }
        Test.StopTest();
        Assert.areEqual(errorMsg, missingPatientEmailMsg, 'Received different error message.');
    }

    @IsTest
    private static void invalidInputMissingPatientICN() {
        String errorMsg;
        String missingPatientIcnMsg = 'Error getting VVS link: Missing Patient ICN in RQ';
        Test.startTest();
        System.runAs(VTC_CHROTestHelpers.chroTestUser) {
            errorMsg = callInvocableMethodWithBadRequest('patientICN');
        }
        Test.StopTest();
        Assert.areEqual(errorMsg, missingPatientIcnMsg, 'Received different error message.');
    }

    private static String callInvocableMethodWithBadRequest(String missingParameter) {
        String result;
        try {
            expectedParams.remove(missingParameter);
            String flowInput = JSON.serialize(expectedParams);
            List<String> results = VCC_CHROVVSAppointmentInvocable.createVVSAppointment(new List<String>{ flowInput });
            result = results[0];
        } catch (VCC_CHROVVSAppointmentInvocable.VCC_CHROVVSAppointmentInvocableException badRequestException) {
            result = badRequestException.getMessage();
        }
        return result;
    }
}
