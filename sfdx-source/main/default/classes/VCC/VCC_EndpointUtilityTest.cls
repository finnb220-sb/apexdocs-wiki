@IsTest
/**
 * @description
 * @author unknown
 * @since
 * @group Test Classes
 * @see VCC_EndpointUtility
 */
public class VCC_EndpointUtilityTest {
    @IsTest
    private static void VCC_EndpointUtilityTest() {
        Test.startTest();
        String endpointResponseData = VCC_EndpointUtility.getEndpoint('Vdif', 'vccVDIFGetAdditionalSigners');
        System.assert(endpointResponseData == 'callout:vccVdif_dev/v0/vdifGetAdditionalSigners', 'Expected correct named cred.');
        System.debug(LoggingLevel.INFO, endpointResponseData);

        Test.stopTest();
    }

    @IsTest
    private static void getUrlForNamedCredTest() {
        Test.startTest();
        String namedCredEndpoint = [
            SELECT Endpoint
            FROM NamedCredential
            WHERE DeveloperName = 'vccVdif_dev'
        ]
        .Endpoint;
        String namedCredPath = [
            SELECT Id, DeveloperName, Path__c
            FROM vccEndpoint__mdt
            WHERE DeveloperName = 'vccVDIFGetAdditionalSigners'
        ]
        .Path__c;
        String url = VCC_EndpointUtility.getUrlForNamedCredential('callout:vccVdif_dev/v0/vdifGetAdditionalSigners');
        System.assert(url == namedCredEndpoint + '/' + namedCredPath, 'Invalid resulting value.');
        Test.stopTest();
    }
}
