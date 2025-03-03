@IsTest
public with sharing class VCC_DASServicesTest {
    @TestVisible
    private static VATEST_Stub stubParser(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub dasServiceParserStub = new VATEST_Stub(VCC_DASServiceParser.class, mockedMethods);
        VCC_DAS.SERVICES.parserService = (VCC_DASServiceParser) dasServiceParserStub.createStub();
        return dasServiceParserStub;
    }

    @TestVisible
    private static VATEST_Stub stubApi(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub dasApiServiceStub = new VATEST_Stub(VCC_DASServiceApi.class, mockedMethods);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) dasApiServiceStub.createStub();
        return dasApiServiceStub;
    }

    @TestVisible
    private static VATEST_Stub stubEndpoint(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub dasEndpointServiceStub = new VATEST_Stub(VCC_DASServiceEndpoint.class, mockedMethods);
        VCC_DAS.SERVICES.endpointService = (VCC_DASServiceEndpoint) dasEndpointServiceStub.createStub();
        return dasEndpointServiceStub;
    }

    @isTest
    public static void apiServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceApi serviceApi = VCC_DAS.SERVICES.API;
            Assert.isNotNull(serviceApi, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void encounterServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceEncounter serviceEncounter = VCC_DAS.SERVICES.ENCOUNTER;
            Assert.isNotNull(serviceEncounter, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void endpointServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceEndpoint serviceEndpoint = VCC_DAS.SERVICES.ENDPOINT;
            Assert.isNotNull(serviceEndpoint, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void httpServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceHttp serviceHttp = VCC_DAS.SERVICES.HTTP;
            Assert.isNotNull(serviceHttp, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void loggerServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceLogger serviceLogger = VCC_DAS.SERVICES.LOGGER;
            Assert.isNotNull(serviceLogger, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void metadataServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceMetadata serviceMetadata = VCC_DAS.SERVICES.METADATA;
            Assert.isNotNull(serviceMetadata, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void parserServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceParser serviceParser = VCC_DAS.SERVICES.PARSER;
            Assert.isNotNull(serviceParser, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @isTest
    public static void utilitiesServiceTest() {
        Test.startTest();
        try {
            VCC_DASServiceUtilities serviceUtilities = VCC_DAS.SERVICES.UTILITIES;
            Assert.isNotNull(serviceUtilities, 'Expected a non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
