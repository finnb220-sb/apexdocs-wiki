@IsTest
public with sharing class VCC_EndpointServiceTest {
    @IsTest
    public static void getStatusCodeMetadataTest() {
        // Setup your test data to execute different conditions in `getStatusCodeMetadata` method here

        // Main test
        List<VCC_EndpointService.StatusCodeMetadata> scmList;
        Test.startTest();
        scmList = VCC_EndpointService.getStatusCodeMetadata(400, 'test', 'test');
        Test.stopTest();

        System.assert(scmList != null, 'Expected a list.');

        // Additional tests for different status codes
        // Adapt these scenarios according to your actual data and application logic
        scmList = VCC_EndpointService.getStatusCodeMetadata(300, 'test2', 'test2');
        System.assert(scmList != null, 'Expected a list.');

        scmList = VCC_EndpointService.getStatusCodeMetadata(500, 'test3', 'test');
        System.assert(scmList != null, 'Expected a list.');

        scmList = VCC_EndpointService.getStatusCodeMetadata(200, 'test4', 'test2');
        System.assert(scmList != null, 'Expected a list.');
    }

    @IsTest
    public static void getEndpointTest() {
        String endpoint;

        Test.startTest();
        endpoint = VCC_EndpointService.getEndpoint('Vdif', 'vccVdifIsValidEsig');
        Test.stopTest();

        System.assert(endpoint != null, 'Expected a string.');
    }

    @IsTest
    public static void validateGenerateCode() {
        // Test 1
        VCC_EndpointService.StatusCodeMetadata metadata1 = new VCC_EndpointService.StatusCodeMetadata();
        metadata1.statusCode = Integer.valueOf('200');
        metadata1.type = 'test';
        metadata1.message = 'Validate Me';
        metadata1.illustrationVariant = 'draw';
        metadata1.isRange = true;
        metadata1.subMessage = 'Subscribed';
        System.assert(metadata1 != null);

        // Test for the other constructor
        // Assuming you have the required data in your org
        // Use your actual data inside the brackets
        VCC_Endpoint_Status_Code__mdt mdt = [
            SELECT VCC_Endpoint_Status_Code_Configuration__r.Id
            FROM VCC_Endpoint_Status_Code__mdt
            LIMIT 1
        ];
        VCC_EndpointService.StatusCodeMetadata metadata2 = new VCC_EndpointService.StatusCodeMetadata(mdt, 200);
        System.assert(metadata2 != null);
    }
}
