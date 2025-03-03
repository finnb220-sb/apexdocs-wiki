@isTest
private with sharing class VCC_AddSignersRequestTest {
    @isTest
    static void jsonToClass() {
        Map<String, Object> javaScriptObject = new Map<String, Object>{ 'id' => '00112233', 'assigningFacility' => '613', 'documents' => new List<String>{ '554246' } };

        VCC_Bridg_AdditionalSignersRequest request = new VCC_Bridg_AdditionalSignersRequest(javaScriptObject);
        System.assertEquals('USVHA', request.assigningAuthority);
    }
}
