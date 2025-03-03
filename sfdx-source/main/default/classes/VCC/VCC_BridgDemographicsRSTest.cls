@isTest
public class VCC_BridgDemographicsRSTest {
    @isTest
    static void testParseJSON() {
        // Create a sample JSON string
        String jsonString = '{"sites":[{"results":{"demographics":{"total":"1","patient":[{"address":{"streetLine1":"123 Main St","city":"Sample City","postalCode":"12345","stateProvince":"CA"}}]}},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';

        // Call the parseJSON method and assert the results
        VCC_BridgDemographicsRS.Site[] sites = VCC_BridgDemographicsRS.parseJSON(jsonString).sites;
        System.assertEquals(1, sites.size());
        VCC_BridgDemographicsRS.Results results = sites[0].results;
        VCC_BridgDemographicsRS.Demographics demographics = results.demographics;
        System.assertEquals('1', demographics.total);
        VCC_BridgDemographicsRS.Patient[] patients = demographics.patient;
        System.assertEquals(1, patients.size());
        VCC_BridgDemographicsRS.PatientAddress address = patients[0].address;
        System.assertEquals('123 Main St', address.streetLine1);
        System.assertEquals('Sample City', address.city);
        System.assertEquals('12345', address.postalCode);
        System.assertEquals('CA', address.stateProvince);
    }
}
