@isTest
public with sharing class VCC_VdifGetProvidersBySiteRSTest {
    @isTest
    public static void instantiationTest() {
        VCC_VdifGetProvidersBySiteRS getProvidersBySiteRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            getProvidersBySiteRS = new VCC_VdifGetProvidersBySiteRS();
        }

        System.assert(getProvidersBySiteRS != null, 'Response did not instantiate as expected.');
        System.assert(getProvidersBySiteRS.taggedProviderArray.fault != null, 'Response did not instantiate as expected.');
        System.assert(getProvidersBySiteRS.taggedProviderArray.providers != null, 'Response did not instantiate as expected.');
        System.assert(getProvidersBySiteRS.taggedProviderArray.providers.providerTO != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifGetProvidersBySiteRS.TaggedProviderArray() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifGetProvidersBySiteRS.ArrayOfProviderTO() != null, 'Response did not instantiate as expected.');
        System.assert(new VCC_VdifGetProvidersBySiteRS.ProviderTO() != null, 'Response did not instantiate as expected.');
    }

    @isTest
    public static void instantiationTestWithMockHttpResponse() {
        VCC_VdifGetProvidersBySiteRS getProvidersBySiteRS;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        VCC_BaseClient.BaseResponse baseResponse = new VCC_BaseClient.BaseResponse();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setBody('{}');
        baseResponse.httpResponse = mockResponse;
        System.runAs(testuser) {
            getProvidersBySiteRS = new VCC_VdifGetProvidersBySiteRS(baseResponse);
        }

        System.assert(getProvidersBySiteRS != null, 'Response did not instantiate as expected.');
        System.assert(getProvidersBySiteRS.taggedProviderArray == null, 'Expected to be null due to mock response');
    }
}
