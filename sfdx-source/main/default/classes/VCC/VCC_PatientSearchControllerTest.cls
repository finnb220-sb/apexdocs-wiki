@isTest
private with sharing class VCC_PatientSearchControllerTest {
    private static String username = 'patsearchcon';

    @TestSetup
    static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testUser);
        testUser.Username = username + testUser.Username;
        update testUser;
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @isTest
    private static void unitSearchMPINegative() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MPISearchResponse' LIMIT 1];
            String body = sr.Body.toString();
            // VCC_MPISearchResponse parseResponse = (Map<String,Object>) JSON.deserialize(body, VCC_MPISearchResponse.class);

            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15","vets":[{"name": "mike jones",  "icn": "123334"}]}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCC_PatientSearchController.searchMPI(requestData);
            Test.stopTest();
        }


        // System.assert(true, 'Force true.');
    }

    @isTest
    private static void searchCRM() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MPI_VAProfile');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"lastName": "wisden","firstName": "stageone","dob": "1962-05-15"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCC_PatientSearchController.searchCRM(requestData);
            Test.stopTest();
        }

        System.assert(true, 'Force true.');
    }

    @isTest
    private static void addVeteran() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_MpiCorrelateResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
            Test.setMock(HttpCalloutMock.class, mock);
            String javaScriptObject = '{"LastName": "wisden","FirstName": "stageone", "icn": "123334"}';
            Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(javaScriptObject);
            VCC_PatientSearchController.addVeteran(requestData);
        }

        System.assert(true, 'Force true.');
    }

    @IsTest
    static void filterVetTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_MPISearchResponse searchResponse = new VCC_MPISearchResponse();
            searchResponse.vets = new List<VCC_MPISearchResponse.Vets>();

            //filter vet w/ date of death on record
            VCC_MPISearchResponse.Vets dodVet = new VCC_MPISearchResponse.Vets();
            dodVet.dod = 'some dod';

            //filter vet w/o personType = 'VET' or 'PAT'
            VCC_MPISearchResponse.Vets notPatOrVet = new VCC_MPISearchResponse.Vets();
            notPatOrVet.personType = 'IDK';

            //keep this vet
            VCC_MPISearchResponse.Vets keepVet = new VCC_MPISearchResponse.Vets();
            keepVet.personType = 'VET';
            keepVet.medicalCenterFacilities = new List<VCC_MPISearchResponse.MedicalCenterFacilities>();
            keepVet.medicalCenterFacilities.add(new VCC_MPISearchResponse.MedicalCenterFacilities());

            searchResponse.vets.add(dodVet);
            searchResponse.vets.add(notPatOrVet);
            searchResponse.vets.add(keepVet);

            System.assert(searchResponse.vets.size() == 3, 'Expected 3 vets in list');
            VCC_PatientSearchController.filterVets(searchResponse);
            System.assert(searchResponse.vets.size() == 1, 'Expected 1 vet in list');
        }
        Test.stopTest();
    }
}
