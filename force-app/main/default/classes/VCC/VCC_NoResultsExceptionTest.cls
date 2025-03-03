@IsTest
private with sharing class VCC_NoResultsExceptionTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        new VCC_NoResultsException('Unit Test').coverage();
        Test.stopTest();
    }
}
