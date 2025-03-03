@isTest
private with sharing class VCC_SearchMPISingleVeteranTest {
    @isTest
    private static void testInstantiation() {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MPISearchSingleVet' LIMIT 1];
        String body = sr.Body.toString();
        VCC_SearchMPISingleVeteran newResp = new VCC_SearchMPISingleVeteran();
        VCC_SearchMPISingleVeteran parseResponse = (VCC_SearchMPISingleVeteran) JSON.deserialize(body, VCC_SearchMPISingleVeteran.class);
        newResp = parseResponse;
    }
}
