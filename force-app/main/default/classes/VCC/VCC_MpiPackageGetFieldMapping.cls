public with sharing class VCC_MpiPackageGetFieldMapping implements VCC_MpiPackageTrait.GetIdentityFieldMapping {
    public VCC_MpiPackageGetFieldMapping() {
        return;
    }

    @TestVisible
    private static Boolean needsTestCoverage = false;

    public MPIDynamicPersonSearchController.MpiFieldMappingWrap getCustomMetadataMpiFieldMapping(String businessUnit) {
        try {
            if (needsTestCoverage == true && Test.isRunningTest()) {
                needsTestCoverage = false;
                throw new AuraHandledException('test');
            }
            return MPIDynamicPersonSearchController.getCustomMetadataMpiFielMapping(businessUnit);
        } catch (Exception e) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.GetIdentityFieldMapping.class, e);
        }
    }
}
