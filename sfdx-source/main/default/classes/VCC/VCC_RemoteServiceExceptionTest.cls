@IsTest
private with sharing class VCC_RemoteServiceExceptionTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        new VCC_RemoteServiceException('Unit Test').coverage();
        Test.stopTest();
    }
}
