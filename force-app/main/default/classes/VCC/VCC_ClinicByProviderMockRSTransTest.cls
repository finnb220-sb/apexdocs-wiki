/**
 * @description Unit test that restructures a mock object into the shape of the api response
 * @author Booz Allen Hamilton
 * @since 4/2/2024
 * @see VCC_ClinicByProviderMockRSTransform
 */
@IsTest
public class VCC_ClinicByProviderMockRSTransTest {
    final static User MSA_USER;
    final static String CLINIC_IEN = '5000';
    final static STRING PROVIDER_IEN = '2000';
    static {
        MSA_USER = new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VAHC_Scheduling_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }
    /**
     * @description positive unit testing for mock object into the shape of the api response
     */
    @IsTest
    private static void unitTransformMockProviderClinicPositive() {
        List<VCC_Clinic__c> clinicList = VATEST_SObjectFactory.createSObjects(
            new VCC_Clinic__c(VCC_IEN__c = CLINIC_IEN, Name = 'Test Clinic'),
            1
        );

        List<VCC_Provider__c> providerList = VATEST_SObjectFactory.createSObjects(
            new VCC_Provider__c(VCC_IEN__c = PROVIDER_IEN, Name = 'ORLANDO, DOCTOR'),
            1
        );

        List<VCC_Provider_Clinic_Assignment__c> providerClinicList = VATEST_SObjectFactory.createSObjects(
            new VCC_Provider_Clinic_Assignment__c(
                Name = 'ORLANDO, DOCTOR',
                VCC_Clinic__c = clinicList[0].id,
                VCC_Provider__c = providerList[0].id,
                VCC_IEN__C = PROVIDER_IEN
            ),
            1
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            List<String> clinicIENList = new List<String>{ CLINIC_IEN };
            VCC_ClinicByProviderMockRSTransform transformedData = new VCC_ClinicByProviderMockRSTransform(
                providerClinicList
            );
            Test.stopTest();
            Assert.areEqual(
                clinicIENList.size(),
                transformedData.associatedClinicIEN.size(),
                'Assertion passes; expected List size of Clinic IENs to match, since only 1 Clinic IEN is used.'
            );
            Assert.areEqual(
                1,
                transformedData.associatedClinicName.size(),
                'Assertion passes; expected List size of Clinic Names to match 1 since only 1 record was passed into transformer.'
            );
            Assert.areEqual(
                providerList[0].VCC_IEN__c,
                transformedData.providerIEN,
                'Assertion passes; expected Provider IENs from providerList to match transformedData.'
            );
        }
    }
    /**
     * @description negative unit testing for mock object into the shape of the api response
     */
    @IsTest
    private static void unitTransformMockProviderClinicNegative() {
        List<VCC_Clinic__c> clinicList = VATEST_SObjectFactory.createSObjects(
            new VCC_Clinic__c(VCC_IEN__c = CLINIC_IEN, Name = 'Test Clinic'),
            1
        );

        List<VCC_Provider__c> providerList = VATEST_SObjectFactory.createSObjects(
            new VCC_Provider__c(VCC_IEN__c = PROVIDER_IEN, Name = 'ORLANDO, DOCTOR'),
            1
        );

        List<VCC_Provider_Clinic_Assignment__c> providerClinicList = VATEST_SObjectFactory.createSObjects(
            new VCC_Provider_Clinic_Assignment__c(
                Name = 'ORLANDO, DOCTOR',
                VCC_Clinic__c = clinicList[0].id,
                VCC_Provider__c = providerList[0].id
            ),
            1
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            VCC_ClinicByProviderMockRSTransform transformedData = new VCC_ClinicByProviderMockRSTransform(
                providerClinicList
            );
            Test.stopTest();
            Assert.areNotEqual(
                2,
                transformedData.associatedClinicIEN.size(),
                'Assertion passes; List size of associatedClinicIEN is 1 since only 1 record is passed into the transformer.'
            );
            Assert.areNotEqual(
                2,
                transformedData.associatedClinicName.size(),
                'Assertion passes; expected List size of Clinic Names to match 1 since only 1 record was passed into transformer.'
            );
            Assert.isNull(
                transformedData.providerIEN,
                'Assertion passes; Provider IEN was not passed into transformer'
            );
        }
    }
}
