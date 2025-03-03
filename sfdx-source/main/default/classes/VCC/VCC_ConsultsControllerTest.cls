/**
 * @author Kumar Balan
 * @group Test Classes
 * @see VCC_ConsultsController
 */
@isTest
@SuppressWarnings('PMD')
class VCC_ConsultsControllerTest {
    @TestSetup
    static void makeData() {
        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        Account acc = new Account(
            LastName = 'Patient1',
            VCC_MVI_External_Id__pc = 'te123456st',
            RecordTypeId = personAccountRecordType.Id
        );
        insert acc;
    }

    @isTest
    static void UnitVCC_ConsultControllerProdEnvTestNegative() {
        List<Account> acclist = [SELECT id FROM Account];
        Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());

        Test.startTest();
        VCC_ConsultLightningRequestWrp ConsultReqWrp = new VCC_ConsultLightningRequestWrp();
        ConsultReqWrp.recordId = acclist[0].Id;
        ConsultReqWrp.facility = '613';
        ConsultReqWrp.startDate = '1950-01-01';
        ConsultReqWrp.endDate = '2050-01-01';

        VCC_ConsultService.enviornment = 'PROD';
        VCC_ConsultResponseWrp ConsultResWrp = VCC_ConsultsController.getConsults(ConsultReqWrp);
        Assert.AreNotEqual(202, ConsultResWrp.statusCode, 'Failed to retrieve from PROD environment');

        Test.stopTest();
    }

    @isTest
    static void UnitVCC_ConsultControllerTestEnvTestNegative() {
        List<Account> acclist = [SELECT id FROM Account];
        Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());

        Test.startTest();
        VCC_ConsultLightningRequestWrp ConsultReqWrp = new VCC_ConsultLightningRequestWrp();
        ConsultReqWrp.recordId = acclist[0].Id;
        ConsultReqWrp.facility = '613';
        ConsultReqWrp.startDate = '1950-01-01';
        ConsultReqWrp.endDate = '2050-01-01';

        VCC_ConsultService.enviornment = 'TEST';
        VCC_ConsultResponseWrp ConsultResWrp = VCC_ConsultsController.getConsults(ConsultReqWrp);
        Assert.AreNotEqual(202, ConsultResWrp.statusCode, 'Failed to retrieve from TEST environment');

        Test.stopTest();
    }
}
