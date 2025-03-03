/**
 * @description Tests the VCR_PharmacyRepo class
 * @author Booz Allen
 *
 * @see VCR_PharmacyRepo for class being tested
 */
@IsTest
private with sharing class VCR_PharmacyRepoTest {
    @IsTest
    private static void unitInitializeRepoPositive() {
        User vaVetUser = createTestUser();
        System.runAs(vaVetUser) {
            Test.startTest();
            VCR_PharmacyRepo pharmacyRepo = new VCR_PharmacyRepo();
            Test.stopTest();

            Assert.isNotNull(pharmacyRepo, 'Expected class to be initialized.');
            Assert.isNotNull(VCR_PharmacyRepo.patientService, 'Expected patientService to be initialized.');
        }
    }

    @IsTest
    private static void unitGetTempAddressPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_PharmacyRepo.patientService = createPatientService(args, new VTC_RecordModel(), 'get_temp_address');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_RecordModel pharmacyRecordModel = (VTC_RecordModel) new VCR_PharmacyRepo().getTemporaryAddress(args);
            Assert.isNotNull(pharmacyRecordModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetTempAddressesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_PharmacyRepo.patientService = createPatientService(args, new VTC_DataModel(), 'get_temp_addresses');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel pharmacyDataModel = (VTC_DataModel) new VCR_PharmacyRepo().getTemporaryAddresses(args);
            Assert.isNotNull(pharmacyDataModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetMailingAddressesPositive() {
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN' };
        VCR_PharmacyRepo.patientService = createPatientService(args, new VTC_DataModel(), 'get_mailing_addresses');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel pharmacyDataModel = (VTC_DataModel) new VCR_PharmacyRepo().getMailingAddresses(args);
            Assert.isNotNull(pharmacyDataModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitUpdateMailingAddressesPositive() {
        VTC_Site vtcSite = new VTC_Site();

        VTC_Address address = new VTC_Address();
        address.siteCode = '541';
        address.street1 = '100 Main st';
        vtcSite.records.add(address);
        Map<String, Object> args = new Map<String, Object>{ 'icn' => 'fakeICN', 'site' => vtcSite };
        VCR_PharmacyRepo.patientService = createPatientService(args, new VTC_DataModel(), 'update_mailing_addresses');
        User vaVetUser = createTestUser();

        Test.startTest();
        System.runAs(vaVetUser) {
            VTC_DataModel pharmacyDataModel = (VTC_DataModel) new VCR_PharmacyRepo().updateMailingAddresses(args);
            Assert.isNotNull(pharmacyDataModel, 'Expected valid non-null model to be returned.');
        }
        Test.stopTest();
    }

    /**
     * @description - Creates a stub for VTC_PatientService so that the callout is mocked
     * @param args - Defines the inputs for the get_temp_address call. keys are facilityId and icn. values are the patients registered facilityId and icn.
     * @param returnValue - Defines the desired return value from the mocked callout
     * @param callName - Defines the called function used (either get_temp_address or get_mailing_addresses).
     * @return `VTC_PatientService` - returns a stubbed version of the VTC_PatientService to catch the method call in the test
     */
    private static VTC_PatientService createPatientService(
        Map<String, Object> args,
        Object returnValue,
        String callName
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(callName, args)
            .returning(returnValue)
            .defineStub();
    }

    /**
     * @description - Creates a test user with VAVET Base Profile
     * @return `User` - returns the created user
     */
    private static User createTestUser() {
        return new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }
}
