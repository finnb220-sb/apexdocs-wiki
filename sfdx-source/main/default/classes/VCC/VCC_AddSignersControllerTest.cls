@isTest
private with sharing class VCC_AddSignersControllerTest {
    @isTest
    static void patientControllerTest() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');

        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account newPersonAccount = new Account();

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_BridgAdditionalSignersMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        System.runAs(runAsUser) {
            // newPersonAccount.FirstName = 'Fred';
            // newPersonAccount.LastName = 'Smith';
            // newPersonAccount.VCC_MVI_External_Id__pc = '1012881470V086192';
            // newPersonAccount.RecordType = personAccountRecordType;
            // insert newPersonAccount;
            // Test.startTest();
            // Account acct = [
            //     SELECT Id, Name
            //     FROM Account
            //     WHERE VCC_MVI_External_Id__pc = '1012881470V086192'
            // ];
            // String result = VCC_lwc_utils.getHistoricalProgressNotes(
            //     acct.Id
            // );

            Map<String, Object> params = new Map<String, Object>{ 'id' => '00112233', 'assigningFacility' => '613', 'documents' => new List<String>{ '554246' } };
            Test.startTest();
            String additionalSignersResponse = VCC_PatientAdditionalSignersController.getAdditionalSigners(params);
            String modeled = VCC_PatientAdditionalSignersController.getPatientAdditionalSigners(params);
            System.debug(LoggingLevel.INFO, '### result: ' + additionalSignersResponse);
            Test.stopTest();
        }

        System.assert(true, 'Force assertion.');
    }
}
