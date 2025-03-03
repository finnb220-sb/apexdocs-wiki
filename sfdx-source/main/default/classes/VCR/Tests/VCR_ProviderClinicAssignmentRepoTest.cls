@isTest
private class VCR_ProviderClinicAssignmentRepoTest {
    final static User MSA_USER;
    final static User ADMIN;
    final static String PROVIDER_IEN = '4590';
    final static String DAYSHR_FACILITY_CODE = '984';
    final static String CHYSHR_FACILITY_CODE = '983';
    final static String DAYSHR_CLINIC_IEN = '5678';
    final static String CHYSHR_CLINIC_IEN = '4676';

    static {
        MSA_USER = new VATEST_UserBuilder()
            .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
            .withPermissionSet('VAHC_Scheduling_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }
    static {
        ADMIN = new VATEST_UserBuilder().withUserProfile('System Administrator').withStandardData().build(true);
    }
    @TestSetup
    static void makeData() {
        System.runAs(ADMIN) {
            VCC_Clinic__c clinic984 = new VCC_Clinic__c(
                Name = 'DAYSHR',
                VCC_Station_Id__c = DAYSHR_FACILITY_CODE,
                VCC_IEN__c = DAYSHR_CLINIC_IEN,
                VCC_Active_Flag__c = true
            );
            VCC_Clinic__c clinic983 = new VCC_Clinic__c(
                Name = 'CHYSHR',
                VCC_Station_Id__c = CHYSHR_FACILITY_CODE,
                VCC_IEN__c = CHYSHR_CLINIC_IEN,
                VCC_Active_Flag__c = false
            );
            insert new List<VCC_Clinic__c>{ clinic983, clinic984 };
            VCC_Provider__c provider984 = new VCC_Provider__c(Name = 'Dr.ORL', VCC_IEN__c = PROVIDER_IEN);
            insert provider984;
            insert new VCC_Provider_Clinic_Assignment__c(
                Name = '984 - Dr.ORL',
                VCC_Clinic__c = clinic984.Id,
                VCC_Provider__c = provider984.Id,
                VCC_IEN__c = provider984.VCC_IEN__c
            );
        }
    }
    /**
     * @description Test method that confrims the VCR_ProviderClinicAssignmentRepo instantiates successfully.
     */
    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        VCR_ProviderClinicAssignmentRepo repo;
        System.runAs(MSA_USER) {
            repo = new VCR_ProviderClinicAssignmentRepo();
        }
        Test.stopTest();
        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_ProviderClinicAssignmentRepo');
    }
    /**
     * @description Test method that confirms that the getProviderClinicsInternal method returns expected Provider Clinic Assignment record.
     */
    @IsTest
    static void funcTestSearchClinicsPositive() {
        Test.startTest();
        List<VCC_Provider_Clinic_Assignment__c> providerClinics;
        System.runAs(MSA_USER) {
            VCR_ProviderClinicAssignmentRepo repo = new VCR_ProviderClinicAssignmentRepo();
            providerClinics = repo.getProviderClinicsInternal(PROVIDER_IEN, DAYSHR_FACILITY_CODE);
        }
        Test.stopTest();
        Assert.areEqual(1, providerClinics.size(), 'Assertion passes; Expected a list size of 1 to be returned');
        Assert.areEqual(
            PROVIDER_IEN,
            providerClinics[0].VCC_IEN__c,
            'Assertion Passes; Expected Provider IEN to match global variable'
        );
        Assert.areEqual(
            DAYSHR_CLINIC_IEN,
            providerClinics[0].VCC_Clinic__r.VCC_IEN__c,
            'Assertion Passes; Expected Clinic IEN to match DAYSHR Clinic IEN'
        );
    }
    /**
     * @description Test method that confirms that the getProviderClinicsInternal method will not return unexpected Provider Clinic Assignment record.
     */
    @IsTest
    static void funcTestSearchClinicsNegative() {
        Test.startTest();
        List<VCC_Provider_Clinic_Assignment__c> providerClinics;
        System.runAs(MSA_USER) {
            VCR_ProviderClinicAssignmentRepo repo = new VCR_ProviderClinicAssignmentRepo();
            providerClinics = repo.getProviderClinicsInternal(PROVIDER_IEN, DAYSHR_FACILITY_CODE);
        }
        Test.stopTest();
        Assert.areEqual(1, providerClinics.size(), 'Assertion Passes; Expected a list size of 1 to be returned');
        Assert.areNotEqual(
            '00000',
            providerClinics[0].VCC_IEN__c,
            'Assertion Passes; Provider IEN is not set to 00000'
        );
        Assert.areNotEqual(
            CHYSHR_CLINIC_IEN,
            providerClinics[0].VCC_Clinic__r.VCC_IEN__c,
            'Assertion Passes; Expected Clinic IEN to match DAYSHR IEN, not CHYSHR variable'
        );
    }
    /**
     * @description Test method that confirms that the getProvidersInternal method returns an expected Provider Clinic Assignment record.
     */
    @IsTest
    static void funcTestSearchProvidersPositive() {
        Test.startTest();
        List<VCC_Provider_Clinic_Assignment__c> providerClinics;
        System.runAs(MSA_USER) {
            VCR_ProviderClinicAssignmentRepo repo = new VCR_ProviderClinicAssignmentRepo();
            providerClinics = repo.getProvidersInternal(DAYSHR_CLINIC_IEN);
        }
        Test.stopTest();
        Assert.areEqual(1, providerClinics.size(), 'Assertion passes; Expected a list size of 1 to be returned');
        Assert.areEqual(
            PROVIDER_IEN,
            providerClinics[0].VCC_IEN__c,
            'Assertion Passes; Expected Provider IEN to match global variable'
        );
        Assert.areEqual(
            DAYSHR_CLINIC_IEN,
            providerClinics[0].VCC_Clinic__r.VCC_IEN__c,
            'Assertion Passes; Expected Clinic IEN to match DAYSHR Clinic IEN'
        );
    }
    /**
     * @description Test method that confirms that the getProvidersInternal method returns an Provider Clinic Assignment record.
     */
    @IsTest
    static void funcTestSearchProvidersNegative() {
        Test.startTest();
        List<VCC_Provider_Clinic_Assignment__c> providerClinics;
        System.runAs(MSA_USER) {
            VCR_ProviderClinicAssignmentRepo repo = new VCR_ProviderClinicAssignmentRepo();
            providerClinics = repo.getProvidersInternal(DAYSHR_CLINIC_IEN);
        }
        Test.stopTest();
        Assert.areEqual(1, providerClinics.size(), 'Assertion fails; Expected a list size of 1 to be returned');
        Assert.areNotEqual(
            '00000',
            providerClinics[0].VCC_IEN__c,
            'Assertion Passes; Provider IEN is not set to 00000'
        );
        Assert.areNotEqual(
            CHYSHR_CLINIC_IEN,
            providerClinics[0].VCC_Clinic__r.VCC_IEN__c,
            'Assertion Passes; Expected Clinic IEN to match DAYSHR IEN, not CHYSHR variable'
        );
    }
}
