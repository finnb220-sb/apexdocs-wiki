@IsTest
public with sharing class VCC_MpiPackageTraitTest {
    @IsTest
    static void it_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackageTrait(), 'Expected a non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
