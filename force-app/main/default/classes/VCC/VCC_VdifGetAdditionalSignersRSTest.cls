@isTest
public with sharing class VCC_VdifGetAdditionalSignersRSTest {
    @isTest
    public static void ctor() {
        VCC_VdifGetAdditionalSignersRS getAdditionalSignersRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            getAdditionalSignersRS = new VCC_VdifGetAdditionalSignersRS();
        }

        System.assert(getAdditionalSignersRS != null, 'Did not construct properly.');
        System.assert(getAdditionalSignersRS.taggedTextArray != null, 'Property is unexpectedly null.');
    }

    @isTest
    public static void baseReponseConstructor() {
        VCC_VdifGetAdditionalSignersRS getAdditionalSignersRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        VCC_BaseClient.BaseResponse baseResponse = new VCC_BaseClient.BaseResponse();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{}');
        baseResponse.httpResponse = mockResponse;
        System.runAs(testuser) {
            getAdditionalSignersRS = new VCC_VdifGetAdditionalSignersRS(baseResponse);
        }

        System.assert(getAdditionalSignersRS != null, 'Did not construct properly.');
        System.assert(getAdditionalSignersRS.taggedTextArray == null, 'Was supposed to be null due to mock https response');
    }
}
