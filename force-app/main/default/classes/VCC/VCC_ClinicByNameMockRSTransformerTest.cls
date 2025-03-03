/**
 * @description Unit test that restructures a mock object into the shape of the api response
 * @author Booz Allen Hamilton
 * @since 4/2/2024
 * @see VCC_ClinicByNameMockRSTransformer
 */
@IsTest
private class VCC_ClinicByNameMockRSTransformerTest {
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    /**
     * @description Unit test that restructures a mock object into the shape of the api response
     * @see VCC_ClinicByNameMockRSTransformer
     */
    @IsTest
    private static void unitTransformClinicPositive() {
        List<VCC_Clinic__c> clinics = VATEST_SObjectFactory.createSObjects(
            new VCC_Clinic__c(VCC_IEN__c = '1', Name = 'Test Clinic'),
            10
        );
        VCC_ClinicByNameMockRSTransformer transformedData;
        System.runAs(MSA_USER) {
            Test.startTest();
            transformedData = new VCC_ClinicByNameMockRSTransformer(clinics);
            Test.stopTest();
        }
        Assert.areEqual(10, transformedData.data.size(), 'Assertion failed; expected 10 records in the data property.');
        Assert.areEqual('1', transformedData.data[0].ien, 'Assertion failed; expected value of 1 in the ien property.');
    }

    /**
     * @description Unit test that confirms a null argument for mockClinics will return an empty list.
     * @see VCC_ClinicByNameMockRSTransformer
     */
    @IsTest
    private static void unitTransformClinicNullNegative() {
        List<VCC_Clinic__c> clinics;
        VCC_ClinicByNameMockRSTransformer transformedData;
        System.runAs(MSA_USER) {
            Test.startTest();
            transformedData = new VCC_ClinicByNameMockRSTransformer(clinics);
            Test.stopTest();
        }
        Assert.areEqual(0, transformedData.data.size(), 'Assertion failed; expected 0 records in the data property.');
    }

    /**
     * @description Unit test that confirms an empty list argument for mockClinics will return an empty list.
     * @see VCC_ClinicByNameMockRSTransformer
     */
    @IsTest
    private static void unitTransformClinicEmptyNegative() {
        List<VCC_Clinic__c> clinics = new List<VCC_Clinic__c>();
        VCC_ClinicByNameMockRSTransformer transformedData;
        System.runAs(MSA_USER) {
            Test.startTest();
            transformedData = new VCC_ClinicByNameMockRSTransformer(clinics);
            Test.stopTest();
        }
        Assert.areEqual(0, transformedData.data.size(), 'Assertion failed; expected 0 records in the data property.');
    }
}
