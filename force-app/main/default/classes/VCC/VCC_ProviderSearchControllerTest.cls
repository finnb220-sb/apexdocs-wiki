/**
 * @description Test class for VCC_ProviderSearchControllerTest
 * @author Booz Allen Hamilton
 * @since  8/07/2024
 */
@IsTest
private class VCC_ProviderSearchControllerTest {
    final static String NAME = 'ProviderName';
    final static String FACILITY_CODE = '984';
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);
    /**
     * @description Test method that confirms that the providerRepo property injects successfully.
     */
    @isTest
    static void unitDidRepoInitializeTest() {
        Test.startTest();
        System.runAs(MSA_USER) {
            VCC_ProviderSearchController.providerRepo = null;
        }
        Test.stopTest();
        Assert.isNotNull(
            VCC_ProviderSearchController.providerRepo,
            'Assertion failed; Expected a non-null value for VCC_ClinicSearchController.clinicRepo'
        );
    }

    /**
     * @description Test method that confirms that a List of VTC_Clinic records are returned
     * when a Facility Code and Name is passed to searchClinicsByNameExternal
     */
    @IsTest
    static void unitSearchProvidersPositive() {
        List<VTC_Record> recordList = new List<VTC_Record>();
        VTC_Provider stubProviderRecord = new VTC_Provider();
        stubProviderRecord.vtcId = '1';
        recordList.add(stubProviderRecord);

        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => FACILITY_CODE,
            'name' => NAME
        };

        VCR_ProviderRepo stubProviderRepo = (VCR_ProviderRepo) new VATEST_StubBuilder(VCR_ProviderRepo.class)
            .mockingMethodCall('searchProviders', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .returning((List<VTC_Record>) recordList)
            .defineStub();

        Test.startTest();
        List<VTC_Record> providerRecordList;
        System.runAs(MSA_USER) {
            VCC_ProviderSearchController.providerRepo = stubProviderRepo;
            providerRecordList = (List<VTC_Record>) VCC_ProviderSearchController.searchProviders(NAME, FACILITY_CODE);
        }
        Test.stopTest();

        Assert.isNotNull(providerRecordList, 'Assertion failed; expected providerRecordList to not be null');
        Assert.isNotNull(providerRecordList[0].vtcId, 'Assertion failed; expected vtcId to not be null');
        Assert.areEqual(
            providerRecordList[0].vtcId,
            recordList[0].vtcId,
            'Assertion failed; expected providerRecordList and recordList vtcIds to match'
        );
    }
    /**
     * @description Test method that confirms that an exception is thrown when empty properties are passed as the request argument
     */
    @IsTest
    static void unitSearchProvidersEmptyPropertiesNegative() {
        Test.startTest();
        List<VTC_Provider> providerRecordList;
        System.runAs(MSA_USER) {
            try {
                providerRecordList = (List<VTC_Provider>) VCC_ProviderSearchController.searchProviders('', '');
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that an exception is thrown when null properties are passed as the request argument
     */
    @IsTest
    static void unitSearchProvidersNullPropertiesNegative() {
        Test.startTest();
        List<VTC_Record> providerRecordList;
        System.runAs(MSA_USER) {
            try {
                providerRecordList = (List<VTC_Provider>) VCC_ProviderSearchController.searchProviders(null, null);
                Assert.fail('Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Invalid Request. Null/Empty request properties detected.',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Invalid Request. Null/Empty request properties detected.'
                );
            }
        }
        Test.stopTest();
    }

    /**
     * @description Test method that confirms that a VTC_LimitException is caught
     */
    @IsTest
    static void unitSearchProvidersLimitExceptionNegative() {
        VTC_LimitException stubLimitException = new VTC_LimitException();
        stubLimitException.setMessage('Timeout Exception');
        Map<String, Object> requestBodyArgs = new Map<String, Object>{
            'application' => 'VAHC',
            'vistaSiteId' => FACILITY_CODE,
            'name' => NAME
        };
        VCR_ProviderRepo stubProviderRepo = (VCR_ProviderRepo) new VATEST_StubBuilder(VCR_ProviderRepo.class)
            .mockingMethodCall('searchProviders', Map<String, Object>.class)
            .withParameterValues(requestBodyArgs)
            .throwingException(stubLimitException)
            .defineStub();

        Test.startTest();
        List<VTC_Record> providerRecordList;
        System.runAs(MSA_USER) {
            VCC_ProviderSearchController.providerRepo = stubProviderRepo;
            try {
                providerRecordList = (List<VTC_Provider>) VCC_ProviderSearchController.searchProviders(
                    NAME,
                    FACILITY_CODE
                );
                Assert.isTrue(false, 'Test failed; expected an exception to be thrown.');
            } catch (AuraHandledException auraError) {
                Assert.areEqual(
                    'Timeout Exception',
                    auraError.getMessage(),
                    'Assertion failed; expected error message to be Timeout Exception'
                );
            }
        }
        Test.stopTest();
    }
}
