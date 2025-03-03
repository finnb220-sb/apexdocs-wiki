@IsTest
private class VCC_InternalExceptionTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        new VCC_InternalException('Unit Test').coverage();
        Test.stopTest();
    }
}
