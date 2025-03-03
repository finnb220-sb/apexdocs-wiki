@isTest
public with sharing class VCC_VdifIsValidEsigRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifIsValidEsigRS isValidEsigRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            isValidEsigRS = new VCC_VdifIsValidEsigRS();
        }

        System.assert(isValidEsigRS != null, 'Response did not instantiate as expected.');
        System.assert(isValidEsigRS.isValidEsigTextTO != null, 'Response did not instantiate as expected.');
    }

    @isTest
    public static void instantiationTestWithHttpResponse() {
        VCC_VdifIsValidEsigRS isValidEsigRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        VCC_BaseClient.BaseResponse baseResponse = new VCC_BaseClient.BaseResponse();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{}');
        baseResponse.httpResponse = mockResponse;
        System.runAs(testuser) {
            isValidEsigRS = new VCC_VdifIsValidEsigRS(baseResponse);
        }

        System.assert(isValidEsigRS != null, 'Response did not instantiate as expected.');
        System.assert(isValidEsigRS.isValidEsigTextTO == null, 'Expected to be null due to mock response');
    }
}
