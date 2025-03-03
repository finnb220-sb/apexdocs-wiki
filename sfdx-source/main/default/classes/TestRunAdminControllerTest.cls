/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Test class for TestRunAdminController
 */
@IsTest
private class TestRunAdminControllerTest {
    @IsTest
    static void testGetOrgWideCodeCoverage() {
        String codeCoverageReponse = '{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ApexOrgWideCoverage","records":[{"attributes":{"type":"ApexOrgWideCoverage","url":"/services/data/v54.0/tooling/sobjects/ApexOrgWideCoverage/7163R00000008ScQAI"},"PercentCovered":77,"LastModifiedDate":"2022-05-27T19:03:56.000+0000"}]}';
        CalloutRequestMock codeCoverageCalloutMock = new CalloutRequestMock(200, 'OK', codeCoverageReponse, null);
        Test.setMock(HttpCalloutMock.class, codeCoverageCalloutMock);

        Test.startTest();
        System.assertEquals(codeCoverageReponse, TestRunAdminController.getOrgWideCodeCoverage());
        Test.stopTest();
    }
}
