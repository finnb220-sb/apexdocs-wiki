@isTest
public with sharing class VCC_VaProfileServiceTest {
    @IsTest
    static void upsertAssociatedPersonsTestHappy() {
        VCC_VaProfileService vaProfileService = (VCC_VaProfileService) VCC_ModuleService.getModule(VCC_VaProfileService.class);

        HttpResponse mock = new HttpResponse();
        mock.setStatusCode(200);
        VCC_VaProfileAssociatedPersonsRS associatedPersonRs = new VCC_VaProfileAssociatedPersonsRS();
        associatedPersonRs.status = 'SUCCESS';
        associatedPersonRs.message = 'message';
        associatedPersonRs.txAuditId = 'auditId';
        mock.setBody(JSON.serialize(associatedPersonRs));
        VCC_HttpOverride_Mock.mockNext(mock);

        VCC_VaProfileAssociatedPersonsRS response;
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            response = vaProfileService.upsertAssociatedPersons(new VCC_VaProfileAssociatedPersonsRQ());
        }
        Test.stopTest();

        System.assert(response.status == 'SUCCESS', 'Expected correct value.');
        System.assert(response.message == 'message', 'Expected correct value.');
        System.assert(response.txAuditId == 'auditId', 'Expected correct value.');
    }

    @IsTest
    static void upsertAssociatedPersonsTestSad() {
        VCC_VaProfileService vaProfileService = (VCC_VaProfileService) VCC_ModuleService.getModule(VCC_VaProfileService.class);
        HttpResponse mock = new HttpResponse();
        mock.setStatusCode(500);
        VCC_VaProfileAssociatedPersonsRS associatedPersonRs = new VCC_VaProfileAssociatedPersonsRS();
        associatedPersonRs.status = 'SUCCESS';
        associatedPersonRs.message = 'message';
        associatedPersonRs.txAuditId = 'auditId';
        mock.setBody(JSON.serialize(associatedPersonRs));
        VCC_HttpOverride_Mock.mockNext(mock);

        VCC_RemoteServiceException expectedException;

        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            try {
                vaProfileService.upsertAssociatedPersons(new VCC_VaProfileAssociatedPersonsRQ());
            } catch (VCC_RemoteServiceException e) {
                expectedException = e;
            }
        }
        Test.stopTest();
        System.assert(expectedException != null, 'Expected to catch an exception.');
    }
}
