/**
 *
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

@IsTest
private class VCC_ConsultServiceTest {
    @IsTest
    static void validateGetConsult() {
        VCC_ConsultLightningRequestWrp requestWrp = (VCC_ConsultLightningRequestWrp) VCC_TestDataFactory.getConsultLightningRequest();
        Account a = [SELECT Id, PersonBirthdate, FirstName, LastName FROM Account WHERE Id = :requestWrp.recordId];
        VCC_ConsultService serv = new VCC_ConsultService();
        Test.startTest();
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStatusCode(200);
        mock.setStaticResource('VCC_ConsultJsonExample');
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        Map<String, Object> reqData = new Map<String, Object>();
        reqData.put('lastName', a.LastName);
        reqData.put('firstName', a.FirstName);
        reqData.put('dob', a.PersonBirthdate);

        VCC_ConsultResponseWrp responseWrp = serv.getConsults(requestWrp);
        Assert.areEqual(responseWrp.statusCode, 200, 'Expected 200 status code');
        Test.stopTest();
    }
}
