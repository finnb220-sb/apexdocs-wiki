@IsTest
public with sharing class VCC_MpiPackageGetFieldMappingTest {
    @IsTest
    static void it_constructs() {
        try {
            System.Assert.isNotNull(new VCC_MpiPackageGetFieldMapping(), 'Expected non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @IsTest
    static void it_runs() {
        Test.startTest();
        try {
            VCC_MpiPackageGetFieldMapping getFieldMappingImpl = new VCC_MpiPackageGetFieldMapping();
            MPIDynamicPersonSearchController.MpiFieldMappingWrap fieldMapWrap = getFieldMappingImpl.getCustomMetadataMpiFieldMapping(null);
            System.debug(fieldMapWrap);
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception() {
        Test.startTest();
        try {
            VCC_MpiPackageGetFieldMapping getFieldMappingImpl = new VCC_MpiPackageGetFieldMapping();
            VCC_MpiPackageGetFieldMapping.needsTestCoverage = true;
            MPIDynamicPersonSearchController.MpiFieldMappingWrap fieldMapWrap = getFieldMappingImpl.getCustomMetadataMpiFieldMapping(null);
            System.Assert.fail('Expected an exception');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected correct exception type.');
        }
        Test.stopTest();
    }
}
