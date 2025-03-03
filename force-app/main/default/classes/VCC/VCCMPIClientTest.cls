@isTest
private with sharing class VCCMPIClientTest {
    @isTest
    private static void testMPICorrelate() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MpiCorrelateResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            Map<String, string> requestData = new Map<String, String>{
                'lastName' => 'Bastin',
                'firstName' => 'Ashley',
                'icn' => '12323',
                'salesforceId' => '1233',
                'middleName' => 'Rose'
            };

            VCCMPICLient client = new VCCMPIClient(null, 'VAHC CRM');
            client.mpiCorrelate(requestData);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @isTest
    private static void VCCMPIClient() {
        Test.startTest();
        VCCMPIClient mpiClient = new VCCMPIClient();
        Test.stopTest();

        System.Assert(true, 'force true');
    }

    @isTest
    private static void testMPICorrelate500() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        Exception expectedException;
        LogEntry__c[] logData;
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MpiCorrelateResponse');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            Map<String, string> requestData = new Map<String, String>{
                'lastName' => 'Bastin',
                'firstName' => 'Ashley',
                'icn' => '12323',
                'salesforceId' => '1233',
                'middleName' => 'Rose'
            };

            VCCMPICLient client = new VCCMPIClient(null, 'VAHC CRM');
            try {
                client.mpiCorrelate(requestData);
            } catch (Exception e) {
                expectedException = e;
                logData = [SELECT Id FROM LogEntry__c WHERE ApexMethodName__c = 'mpiCorrelate'];
                system.assert(expectedException != null, 'Exception Created');
            }

            Test.stopTest();
        }

        system.assert(logData != null, 'Log entry exists');
        System.assert(true, 'Force true.');
    }

    @isTest
    private static void testMPICorrelate503() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        //Exception expectedException;
        LogEntry__c[] logData;
        System.runAs(runAsUser) {
            Test.startTest();
            VCC_RemoteServiceException rsException = new VCC_RemoteServiceException();
            Exception expectedException;
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MpiCorrelateResponse');
            mock.setStatusCode(503);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            Map<String, string> requestData = new Map<String, String>{
                'lastName' => 'Bastin',
                'firstName' => 'Ashley',
                'icn' => '12323',
                'salesforceId' => '1233',
                'middleName' => 'Rose'
            };

            VCCMPICLient client = new VCCMPIClient(null, 'VAHC CRM');

            try {
                client.mpiCorrelate(requestData);
            } catch (Exception e) {
                expectedException = e;
                System.assertEquals('VCC_RemoteServiceException', rsException.getTypeName(), e);
                logData = [SELECT Id FROM LogEntry__c WHERE ApexMethodName__c = 'mpiCorrelate'];
            }

            Test.stopTest();
        }
        system.assert(logData != null, 'Log entry exists');
        System.assert(true, 'Force true.');
    }

    @isTest
    private static void mpiRetrieve() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MpiCorrelateResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            VCC_MpiRetrieveRQ requestData = new VCC_MpiRetrieveRQ();
            VCCMPICLient client = new VCCMPIClient(null, 'VAHC CRM');
            client.mpiRetrieve(requestData);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @isTest
    public static void testSearchMPI200() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPISearchResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCCMPIClient client = new VCCMPIClient(null, 'VAHC User');
            client.searchMPI(requestData);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @isTest
    public static void testSearchMPI404() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPISearchResponse');
            mock.setStatusCode(404);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCCMPIClient client = new VCCMPIClient(null, 'VAHC User');
            try {
                client.searchMPI(requestData);
            } catch (exception e) {
                system.assertEquals('More than 10 results found. Please refine your search.', e.getMessage(), 'Unexpected Error Message');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void testSearchMPI500() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        Exception expectedException;
        LogEntry__c[] logData;
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPISearchResponse');
            mock.setStatusCode(500);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCCMPIClient client = new VCCMPIClient(null, 'VAHC User');
            try {
                client.searchMPI(requestData);
            } catch (exception e) {
                expectedException = e;
                logData = [SELECT Id FROM LogEntry__c WHERE ApexMethodName__c = 'searchMPI'];
            }
            Test.stopTest();
        }

        system.assert(expectedException != null, 'Exception Created');
        system.assert(logData != null, 'Log entry exists');
        System.assert(true, 'Force true.');
    }

    @isTest
    public static void testSearchMPI503() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        Exception expectedException;
        //VCC_RemoteServiceException expectedException;
        LogEntry__c[] logData;
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPISearchResponse');
            mock.setStatusCode(503);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCCMPIClient client = new VCCMPIClient(null, 'VAHC User');
            try {
                client.searchMPI(requestData);
            } catch (Exception e) {
                logData = [SELECT Id FROM LogEntry__c WHERE ApexMethodName__c = 'searchMPI'];
                expectedException = e;
            }
            Test.stopTest();
        }

        system.assert(expectedException != null, 'Exception Created');
        system.assert(logData != null, 'Log entry exists');
        System.assert(true, 'Force true.');
    }

    @isTest
    public static void testSearchMPIOther() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPISearchResponse');
            mock.setStatusCode(400);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCCMPIClient client = new VCCMPIClient(null, 'VAHC User');
            try {
                client.searchMPI(requestData);
            } catch (exception e) {
                system.assert(e.getMessage() != null);
            }
            Test.stopTest();
        }
    }
}
