@IsTest
public with sharing class VCC_Vdif_PatientAndProviderParamsTest {
    @IsTest
    static void consructorTest() {
        Test.startTest();
        try {
            Assert.isNotNull(new VCC_Vdif_PatientAndProviderParams(), 'Expected non-null value');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
