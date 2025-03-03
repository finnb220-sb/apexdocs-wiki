@isTest
public with sharing class VCC_VdifCreateAddendumRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifCreateAddendumRS createAddendumRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_Util.addPermSetGroupToUser('VAHC_Super_User', testuser);
        System.runAs(testuser) {
            createAddendumRS = new VCC_VdifCreateAddendumRS();
        }

        System.assert(createAddendumRS != null, 'Response did not properly instantiate.');
        System.assert(createAddendumRS.createAddendumTextTO != null, 'Response did not properly instantiate.');
    }

    @isTest
    public static void instantiationTestWithBaseResponse() {
        VCC_VdifCreateAddendumRS createAddendumRS;
        VCC_BaseClient.BaseResponse baseResponse = new VCC_BaseClient.BaseResponse();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{}');
        baseResponse.httpResponse = mockResponse;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_Util.addPermSetGroupToUser('VAHC_Super_User', testuser);
        System.runAs(testuser) {
            createAddendumRS = new VCC_VdifCreateAddendumRS(baseResponse);
        }

        System.assert(createAddendumRS != null, 'Response did not properly instantiate.');
        System.assert(createAddendumRS.createAddendumTextTO == null, 'Response did not properly instantiate.');
    }
}
